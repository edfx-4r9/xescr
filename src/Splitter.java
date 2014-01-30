package com.edifecs.etools.xeserver.component.splitter;

import java.util.Map;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import com.edifecs.etools.route.api.ICompositeMessage;

import org.apache.commons.io.IOUtils;

import com.edifecs.etools.route.api.ConversionException;
import com.edifecs.etools.route.api.IMessage;
import com.edifecs.etools.route.api.IProcessingContext;
import com.edifecs.etools.route.api.ProcessingException;
import com.edifecs.etools.route.api.integration.IProcessor;

public class Splitter implements IProcessor
{
    public static final String MD_SPLIT_MESSAGE_ID     = "SPLIT_MESSAGE_ID";
    public static final String MD_SPLIT_MESSAGE_COUNT  = "SPLIT_MESSAGE_COUNT";
    public static final String MD_SPLIT_MESSAGE_LAST   = "SPLIT_MESSAGE_LAST";
    public static final String MD_SPLIT_CORRELATION_ID = "SPLIT_CORRELATION_ID";

    public static final String SUPPRESS_EMPTY_MESSAGES = "SuppressEmptyMessages";
    public static final String RECORD_SEPARATOR = "RecordSeparator";

	boolean splitByMessage = true;
	boolean suppressEmptyMessages = false;
	String recSepHexString;
    byte[] recSep;
    int nMessageCounter;

	public Splitter(Map<String, String> configuration)
    {
    }

    @Override
    public void process(IProcessingContext context) throws ProcessingException
    {
    	IMessage[] messages = context.getInputMessage().getMessages();
        
        for (int i = 0; i < messages.length; i++)
        {
            
    		Map<String, Object> msgHeaders = context.getInputMessage().getMessages()[0].getHeaders();
    		
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
        	
            IMessage message = messages[i];
            int nMessageID = i + 1;
            Map <String, Object> md = message.getMessageDescriptor();
            md.put(MD_SPLIT_MESSAGE_ID, String.valueOf(nMessageID));
            md.put(MD_SPLIT_MESSAGE_COUNT, messages.length);
            md.put(MD_SPLIT_MESSAGE_LAST, String.valueOf(nMessageID == messages.length));
            md.put(MD_SPLIT_CORRELATION_ID, context.getInputMessage().getID());
            if (splitByMessage) {
	            context.putResult(message);
	            continue;
            }

            ArrayList<IMessage> splittedMessages = new ArrayList<IMessage>();
        	java.io.ByteArrayOutputStream msgOutput = null;
        	java.io.InputStream inputStream = null;
        	nMessageCounter = 0;

        	try {
        		inputStream = message.getBodyAsStream();
        		boolean flagRecordStarted = false, flagRecordFinished = false;
        		int character, nextcharacter;
        		while ( ( character = inputStream.read()) != -1 )
        		{
        			if (! flagRecordStarted) { 
        				msgOutput = new java.io.ByteArrayOutputStream();
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
        			if (j==recSep.length) { 
        				flagRecordFinished = true;
        			};


        			if (flagRecordFinished) {
        					pushMessage(context, msgHeaders, splittedMessages, msgOutput);
        					flagRecordStarted = false;
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
    				msgOutput = new java.io.ByteArrayOutputStream();
        		}
				pushMessage(context, msgHeaders, splittedMessages, msgOutput);
        	}
        	catch (Exception e) {
        		// TODO
        		throw new ProcessingException();
        	}

        	finally {
        		IOUtils.closeQuietly(inputStream);
        	}

        }
    }

	/**
	 * @param context
	 * @param msgHeaders
	 * @param splittedMessages
	 * @param msgOutput
	 * @throws IOException
	 * @throws ConversionException
	 */
	private void pushMessage(IProcessingContext context,
			Map<String, Object> msgHeaders,
			ArrayList<IMessage> splittedMessages,
			java.io.ByteArrayOutputStream msgOutput) throws IOException,
			ConversionException {
		msgOutput.close();
		byte[] outputMessageBody = msgOutput.toByteArray();
		int messageLength = outputMessageBody.length;
		if (suppressEmptyMessages && messageLength == 0) {
			return;
		}

		++nMessageCounter;
		msgHeaders.put(MD_SPLIT_MESSAGE_ID, nMessageCounter);

		IMessage msgProcessed = context.getMessageFactory().createMessage(msgHeaders, outputMessageBody);
		ICompositeMessage msgExProcessed = context.getMessageFactory().createCompositeMessage(msgHeaders, msgProcessed);
		context.putResult( msgExProcessed );
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
    public void dispose()
    {
        // Doing nothing        
    }
}