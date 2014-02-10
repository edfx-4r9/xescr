package com.edifecs.etools.xeserver.component.splitter;

import java.util.Map;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;

import java.lang.IllegalArgumentException;
import org.apache.commons.io.IOUtils;

import com.edifecs.etools.commons.io.SmartStream;
import com.edifecs.etools.route.api.ICompositeMessage;
import com.edifecs.etools.route.api.IMessage;
import com.edifecs.etools.route.api.IProcessingContext;
import com.edifecs.etools.route.api.ProcessingException;
import com.edifecs.etools.route.api.integration.IProcessor;

public class Splitter implements IProcessor, SplitterCallback {
	public static final String MD_SPLIT_MESSAGE_ID = "SPLIT_MESSAGE_ID";
	public static final String MD_SPLIT_MESSAGE_COUNT = "SPLIT_MESSAGE_COUNT";
	public static final String MD_SPLIT_MESSAGE_LAST = "SPLIT_MESSAGE_LAST";
	public static final String MD_SPLIT_CORRELATION_ID = "SPLIT_CORRELATION_ID";

	public static final String SUPPRESS_EMPTY_MESSAGES = "SuppressEmptyMessages";
	public static final String RECORD_SEPARATOR = "RecordSeparator";
	public static final String DEFAULT_RECORD_SEPARATOR = "0x0D, 0x0A";
	public static final String MD_SPLIT_MESSAGE_LENGTH = "SPLITTED_MESSAGE_LENGTH";

	private boolean splitByMessage = true;
	private boolean suppressEmptyMessages = false;
	// private int nMessageCounter;

	private HashMap<Splitter, Map<String, Object>> mapper_headers = new HashMap<Splitter, Map<String, Object>>();
	private HashMap<Splitter, IProcessingContext> mapper_context = new HashMap<Splitter, IProcessingContext>();

	public Splitter(Map<String, String> configuration) {
	}

	@Override
	public void process(IProcessingContext context) throws ProcessingException {
		IMessage[] messages = context.getInputMessage().getMessages();
		mapper_context.put(this, context);

		String suppressEmptyMessagesString = context.getContextProperties()
				.get(SUPPRESS_EMPTY_MESSAGES);
		suppressEmptyMessages = suppressEmptyMessagesString != null
				&& Boolean.valueOf(suppressEmptyMessagesString);
		String recSepHexString = context.getContextProperties().get(
				RECORD_SEPARATOR);
		if (recSepHexString == null) {
			splitByMessage = true;
		} else {
			splitByMessage = false;
		}

		for (int i = 0; i < messages.length; i++) {
			Map<String, Object> msgHeaders = context.getInputMessage()
					.getMessages()[i].getHeaders();

			IMessage message = messages[i];
			int nMessageID = i + 1;
			Map<String, Object> md = message.getMessageDescriptor();
			md.put(MD_SPLIT_MESSAGE_ID, String.valueOf(nMessageID));
			md.put(MD_SPLIT_MESSAGE_COUNT, messages.length);
			md.put(MD_SPLIT_MESSAGE_LAST,
					String.valueOf(nMessageID == messages.length));
			md.put(MD_SPLIT_CORRELATION_ID, context.getInputMessage().getID());
			if (!suppressEmptyMessages || message.getBodySize() > 0) {
				if (splitByMessage) {
					context.putResult(message);
				} else {
					byte[] recSepBytes = separatorHexToBytes(recSepHexString);
					mapper_headers.put(this, msgHeaders);
					msgHeaders.put(RECORD_SEPARATOR, recSepHexString);
					// nMessageCounter = 0;

					StreamSplitter wrk = new StreamSplitter();
					try (java.io.BufferedInputStream inputStream = new java.io.BufferedInputStream(
							message.getBodyAsStream())) {
						wrk.splitMessageByRecords(inputStream, recSepBytes,
								this);
					} catch (Exception e) {
						throw new ProcessingException(e);
					} finally {
						// remove from map
						mapper_headers.remove(this);
					}
				}
			}
		}
		mapper_context.remove(this);
	}

	private byte[] separatorHexToBytes(String separatorHexString)
			throws ProcessingException {
		byte[] recSep;
		if (separatorHexString.length() == 0) {
			separatorHexString = DEFAULT_RECORD_SEPARATOR;
		}
		mapper_headers.get(this).put(RECORD_SEPARATOR, separatorHexString);
		String[] recSepBytes = separatorHexString.split("[ ,]+");
		recSep = new byte[recSepBytes.length];
		try {
			for (int i = 0; i < recSepBytes.length; i++) {
				recSep[i] = Integer.decode(recSepBytes[i]).byteValue();
			}
		} catch (Exception e) {
			throw new ProcessingException("Incorrect record separator "
					+ separatorHexString);
		}
		return recSep;
	}

	@Override
	public void pushMessageCallBack(OutputStream msgOutput) throws IOException {
		try {
			if (!(msgOutput instanceof SmartStream)) {
				throw new IllegalArgumentException(
						"SmartStream type expected for message creation");
			} else {
				Map<String, Object> msgHeaders = mapper_headers.get(this);
				IProcessingContext cntxt = mapper_context.get(this);
				if (!suppressEmptyMessages
						|| ((SmartStream) msgOutput).getByteCount() > 0) {
					// ++nMessageCounter;
					// msgHeaders.put(MD_SPLIT_MESSAGE_ID, nMessageCounter);
					msgHeaders.put(MD_SPLIT_MESSAGE_LENGTH,
							((SmartStream) msgOutput).getByteCount());
					IMessage msgProcessed = cntxt.getMessageFactory()
							.createMessage(msgHeaders,
									((SmartStream) msgOutput).getInputStream());
					ICompositeMessage msgExProcessed = cntxt
							.getMessageFactory().createCompositeMessage(
									msgHeaders, msgProcessed);
					cntxt.putResult(msgExProcessed);
				}
			}
		} catch (Exception e) {
			throw new IOException(e.getCause());
		}

	}

	@Override
	public OutputStream getOutputStream() {
		return new SmartStream();
	}

	@Override
	public void dispose() {
		// Doing nothing
	}
}
