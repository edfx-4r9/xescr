package com.edifecs.etools.xeserver.component.splitter;

import java.util.Map;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.commons.io.IOUtils;

//import java.lang.Exception;
import java.lang.IllegalArgumentException;

import com.edifecs.etools.commons.io.SmartStream;
import com.edifecs.etools.route.api.ICompositeMessage;
import com.edifecs.etools.route.api.ConversionException;
import com.edifecs.etools.route.api.IMessage;
import com.edifecs.etools.route.api.IProcessingContext;
import com.edifecs.etools.route.api.ProcessingException;
import com.edifecs.etools.route.api.integration.IProcessor;

public class Splitter implements IProcessor, SplitterCallback
{
    public static final String  MD_SPLIT_MESSAGE_ID     = "SPLIT_MESSAGE_ID";
    public static final String  MD_SPLIT_MESSAGE_COUNT  = "SPLIT_MESSAGE_COUNT";
    public static final String  MD_SPLIT_MESSAGE_LAST   = "SPLIT_MESSAGE_LAST";
    public static final String  MD_SPLIT_CORRELATION_ID = "SPLIT_CORRELATION_ID";

    public static final String  SUPPRESS_EMPTY_MESSAGES = "SuppressEmptyMessages";
    public static final String  RECORD_SEPARATOR        = "RecordSeparator";
    public static final String  MD_SPLIT_MESSAGE_LENGTH = "SPLITTED_MESSAGE_LENGTH";

    private boolean             splitByMessage          = true;
    private boolean             suppressEmptyMessages   = false;
    private String              recSepHexString;
    private byte[]              recSep;
    private int                 nMessageCounter;

    private IProcessingContext  cntxt                   = null;
    private Map<String, Object> msgHeaders              = null;

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
        if (recSepHexString == null)
        {
            splitByMessage = true;
        }
        else
        {
            splitByMessage = false;
            separatorHexToBytes(recSepHexString);
            msgHeaders.put(RECORD_SEPARATOR, recSepHexString);
        }

        for (int i = 0; i < messages.length; i++)
        {
            IMessage message = messages[i];
            int nMessageID = i + 1;
            Map<String, Object> md = message.getMessageDescriptor();
            md.put(MD_SPLIT_MESSAGE_ID, String.valueOf(nMessageID));
            md.put(MD_SPLIT_MESSAGE_COUNT, messages.length);
            md.put(MD_SPLIT_MESSAGE_LAST, String.valueOf(nMessageID == messages.length));
            md.put(MD_SPLIT_CORRELATION_ID, context.getInputMessage().getID());
            if (!suppressEmptyMessages || message.getBodySize() > 0)
            {
                if (splitByMessage)
                {
                    context.putResult(message);
                }
                else
                {
                    java.io.BufferedInputStream inputStream = null;
                    nMessageCounter = 0;

                    StreamSplitter wrk = new StreamSplitter();
                    try
                    {
                        inputStream = new java.io.BufferedInputStream(message.getBodyAsStream());
                        wrk.splitMessageByRecords(inputStream, recSep, this);
                    }
                    catch (Exception e)
                    {
                        // TODO
                        throw new ProcessingException(e);
                    }
                }
            }
        }
    }

    private void separatorHexToBytes(String separatorHexString) throws ProcessingException
    {
        if (separatorHexString.compareTo("") == 0)
        {
            recSepHexString = "0x0d, 0x0a";
            recSep = new byte[2];
            recSep[0] = 13;
            recSep[1] = 10;
        }
        else
        {
            String[] recSepBytes = separatorHexString.split("[ ,]+");
            recSep = new byte[recSepBytes.length];
            try
            {
                for (int i = 0; i < recSepBytes.length; i++)
                {
                    recSep[i] = Integer.decode(recSepBytes[i]).byteValue();
                }
            }
            catch (Exception e)
            {
                throw new ProcessingException("Incorrect record separator " + separatorHexString);
            }
        }
    }

    @Override
    public void pushMessageCallBack(OutputStream msgOutput) throws IOException
    {
        try
        {
            if (!(msgOutput instanceof SmartStream))
            {
                throw new IllegalArgumentException("SmartStream type expected for message creation");
            }
            else
            {
                if (!suppressEmptyMessages || ((SmartStream) msgOutput).getByteCount() > 0)
                {
                    ++nMessageCounter;
                    msgHeaders.put(MD_SPLIT_MESSAGE_ID, nMessageCounter);
                    msgHeaders.put(MD_SPLIT_MESSAGE_LENGTH, ((SmartStream) msgOutput).getByteCount());
                    IMessage msgProcessed = cntxt.getMessageFactory().createMessage(msgHeaders, ((SmartStream) msgOutput).getInputStream());
                    ICompositeMessage msgExProcessed = cntxt.getMessageFactory().createCompositeMessage(msgHeaders, msgProcessed);
                    cntxt.putResult(msgExProcessed);
                }
            }
        }
        catch (Exception e)
        {
            // TODO
            throw new IOException(e.getCause());
        }

    }

    @Override
    public OutputStream getOutputStream()
    {
        return new SmartStream();
    }

    @Override
    public void dispose()
    {
        // Doing nothing        
    }
}
