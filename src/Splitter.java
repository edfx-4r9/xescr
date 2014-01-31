package com.edifecs.etools.xeserver.component.splitter;

import java.util.Map;
import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;

import com.edifecs.etools.commons.io.SmartStream;
import com.edifecs.etools.route.api.ICompositeMessage;

import org.apache.commons.io.IOUtils;

import com.edifecs.etools.route.api.ConversionException;
import com.edifecs.etools.route.api.IMessage;
import com.edifecs.etools.route.api.IProcessingContext;
import com.edifecs.etools.route.api.ProcessingException;
import com.edifecs.etools.route.api.integration.IProcessor;

public class Splitter implements IProcessor, Callback
{
    public static final String MD_SPLIT_MESSAGE_ID     = "SPLIT_MESSAGE_ID";
    public static final String MD_SPLIT_MESSAGE_COUNT  = "SPLIT_MESSAGE_COUNT";
    public static final String MD_SPLIT_MESSAGE_LAST   = "SPLIT_MESSAGE_LAST";
    public static final String MD_SPLIT_CORRELATION_ID = "SPLIT_CORRELATION_ID";

    public static final String SUPPRESS_EMPTY_MESSAGES = "SuppressEmptyMessages";
    public static final String RECORD_SEPARATOR = "RecordSeparator";

    private boolean splitByMessage = true;
	private boolean suppressEmptyMessages = false;
	private String recSepHexString;
	private byte[] recSep;
    private int nMessageCounter;
    
    private IProcessingContext cntxt = null;
    private Map<String, Object> msgHeaders = null;

	public Splitter(Map<String, String> configuration)
    {
    }

    @Override
    public void process(IProcessingContext context) throws ProcessingException
    {
    	IMessage[] messages = context.getInputMessage().getMessages();
        
    	cntxt = context;
    	msgHeaders = context.getInputMessage().getMessages()[0].getHeaders();
		
    	String suppressEmptyMessagesString = context.getContextProperties().get(SUPPRESS_EMPTY_MESSAGES);
    	suppressEmptyMessages = suppressEmptyMessagesString != null && suppressEmptyMessagesString.compareToIgnoreCase("true") == 0;
    	recSepHexString = context.getContextProperties().get(RECORD_SEPARATOR);
    	if (recSepHexString == null) { 
    		splitByMessage = true;
    	} else {
    		splitByMessage = false;
	    	separatorHexToBytes(recSepHexString);
			msgHeaders.put(RECORD_SEPARATOR, recSepHexString);
    	}

        for (int i = 0; i < messages.length; i++)
        {
            IMessage message = messages[i];
            int nMessageID = i + 1;
            Map <String, Object> md = message.getMessageDescriptor();
            md.put(MD_SPLIT_MESSAGE_ID, String.valueOf(nMessageID));
            md.put(MD_SPLIT_MESSAGE_COUNT, messages.length);
            md.put(MD_SPLIT_MESSAGE_LAST, String.valueOf(nMessageID == messages.length));
            md.put(MD_SPLIT_CORRELATION_ID, context.getInputMessage().getID());
            if (!suppressEmptyMessages || message.getBodySize()>0){
//            	continue;
	            if (splitByMessage) {
		            context.putResult(message);
	            } else {
		        	java.io.InputStream inputStream = null;
		        	nMessageCounter = 0;
		        	
		        	Worker wrk = new Worker(this);
		        	try {
			        	inputStream = message.getBodyAsStream();
			        	wrk.splitMessageByRecords(inputStream, recSep);
		        	} catch (Exception e) { /* TODO */ }
	            }
            }
        }
    }

	private void separatorHexToBytes(String separatorHexString)  throws ProcessingException {
		if (separatorHexString.compareTo("")==0) {
    		recSepHexString = "0x0d, 0x0a";
	    	recSep = new byte[2];
	    	recSep[0] = 13;
	  	  	recSep[1] = 10;
		} else {
			String[] recSepBytes = separatorHexString.split("[ ,]+");
			recSep = new byte[recSepBytes.length];
			try {
				for (int i=0; i<recSepBytes.length; i++){
					recSep[i] = Integer.decode(recSepBytes[i]).byteValue();
				}
			} catch (Exception e) {
				throw new ProcessingException("Incorrect record separator " + separatorHexString);
			}
		}
	}

    @Override
    public void pushMessageCallBack(SmartStream msgOutput)
//    		throws IOException, ConversionException
    		{
    	IProcessingContext context = this.cntxt;
//    	Map<String, Object> msgHeaders = this.msgHeaders;
//    	msgHeaders = context.getInputMessage().getMessages()[0].getHeaders();
    	try {
	    	msgOutput.close();
			++nMessageCounter;
			if (!suppressEmptyMessages || msgOutput.getByteCount() > 0) {
				msgHeaders.put(MD_SPLIT_MESSAGE_ID, nMessageCounter);
				IMessage msgProcessed = context.getMessageFactory().createMessage(msgHeaders, msgOutput.getInputStream());
				ICompositeMessage msgExProcessed = context.getMessageFactory().createCompositeMessage(msgHeaders, msgProcessed);
				context.putResult( msgExProcessed );
			}
    	} catch (Exception e) {
    		// TODO
    		e=e;
    	}

    }

    @Override
    public void dispose()
    {
        // Doing nothing        
    }
}

interface Callback {
    public void pushMessageCallBack(SmartStream msgOutput);
}

class Worker 
{
    private Callback cb;
    public SmartStream msgOutput;
    public Worker(Callback cb) {
        this.cb = cb;
    }
    public void splitMessageByRecords(InputStream inputStream, byte[] recSep){
    	SmartStream smartStream = new SmartStream();
    	
    	try {
//		inputStream = message.getBodyAsStream();
		inputStream = new BufferedInputStream(inputStream);
		
		boolean flagRecordStarted = false, flagRecordFinished = false;
		int character, nextcharacter;
		while ( ( character = inputStream.read()) != -1 )
		{
			if (! flagRecordStarted) { 
				msgOutput = new SmartStream();
				flagRecordStarted = true;
			}
			flagRecordFinished = false;
			int j;
			nextcharacter = character ;
			for (j=0; j<recSep.length; j++) {
				if (j>0) {
					nextcharacter = inputStream.read();
					if (nextcharacter == -1) { break; }
				}
				if (nextcharacter != (byte)recSep[j]) {
					break;
				}
			}
			flagRecordFinished = j==recSep.length;
	
	
			if (flagRecordFinished) {
					flagRecordStarted = false;
//					cb.pushMessageCallBack(context, msgHeaders, message, msgOutput);
					cb.pushMessageCallBack(msgOutput);
			} else {
					if (j>0) {
						msgOutput.write(recSep,0,j);
						if (nextcharacter>-1) msgOutput.write(nextcharacter);
					} else {
						msgOutput.write(character);
					}
			}
		}
	
		if (!flagRecordStarted) {
			msgOutput = new SmartStream();
		}
//		cb.pushMessageCallBack(context, msgHeaders, message, msgOutput);
		cb.pushMessageCallBack(msgOutput);
		smartStream.close();
	}
	catch (Exception e) {
		// TODO
//		throw new ProcessingException();
	}
	
	finally {
		IOUtils.closeQuietly(inputStream);
	}
    }
}
