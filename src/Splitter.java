package com.edifecs.etools.xeserver.component.splitter;

import java.util.Map;
import java.io.IOException;
import java.io.OutputStream;

import java.lang.IllegalArgumentException;
import org.apache.commons.io.IOUtils;

import com.edifecs.etools.commons.io.SmartStream;
import com.edifecs.etools.route.api.ICompositeMessage;
import com.edifecs.etools.route.api.IMessage;
import com.edifecs.etools.route.api.IProcessingContext;
import com.edifecs.etools.route.api.ProcessingException;
import com.edifecs.etools.route.api.integration.IProcessor;

public class Splitter implements IProcessor
{
    public static final String MD_SPLIT_MESSAGE_ID      = "SPLIT_MESSAGE_ID";
    public static final String MD_SPLIT_MESSAGE_COUNT   = "SPLIT_MESSAGE_COUNT";
    public static final String MD_SPLIT_MESSAGE_LAST    = "SPLIT_MESSAGE_LAST";
    public static final String MD_SPLIT_CORRELATION_ID  = "SPLIT_CORRELATION_ID";

    public static final String SUPPRESS_EMPTY_MESSAGES  = "SuppressEmptyMessages";
    public static final String RECORD_SEPARATOR         = "RecordSeparator";
    public static final String DEFAULT_RECORD_SEPARATOR = "0x0D, 0x0A";
    public static final String MD_SPLIT_MESSAGE_LENGTH  = "SPLITTED_MESSAGE_LENGTH";

    public Splitter(Map<String, String> configuration)
    {
    }

    @Override
    public void process(IProcessingContext context) throws ProcessingException
    {
        IMessage[] messages = context.getInputMessage().getMessages();

        for (int i = 0; i < messages.length; i++)
        {

            String suppressEmptyMessagesString = context.getContextProperties().get(SUPPRESS_EMPTY_MESSAGES);
            boolean suppressEmptyMessages = suppressEmptyMessagesString != null && Boolean.valueOf(suppressEmptyMessagesString);
            String recSepHexString = context.getContextProperties().get(RECORD_SEPARATOR);
            boolean splitByMessage = recSepHexString == null;

            //            TODO - REMOVE
            if (recSepHexString == null)
            {
                splitByMessage = true;
            }
            else
            {
                splitByMessage = false;
            }


            Map<String, Object> msgHeaders = context.getInputMessage().getMessages()[i].getHeaders();

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
                    SplitterCallback cb = new SplitterCallback(context, message);
                    cb.setRrecordSeparator(recSepHexString);
                    byte[] recSepBytes = separatorHexToBytes(recSepHexString);

                    StreamSplitter wrk = new StreamSplitter();
                    try (java.io.BufferedInputStream inputStream = new java.io.BufferedInputStream(message.getBodyAsStream()))
                    {
                        wrk.splitMessageByRecords(inputStream, recSepBytes, cb);
                    }
                    catch (Exception e)
                    {
                        throw new ProcessingException(e);
                    }
                    finally
                    {
                    }
                }
            }
        }
    }

    private byte[] separatorHexToBytes(String separatorHexString) throws ProcessingException
    {
        byte[] recSep;
        if (separatorHexString.length() == 0)
        {
            separatorHexString = DEFAULT_RECORD_SEPARATOR;
        }
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
        return recSep;
    }

    //    @Override
    public void pushMessageCallBack(OutputStream msgOutput) throws IOException
    {
    }

    //    @Override
    public OutputStream getOutputStream()
    {
        return new SmartStream();
    }

    @Override
    public void dispose()
    {
        // Doing nothing
    }

    private static class SplitterCallback implements ISplitterCallback
    {

        IProcessingContext context;
        IMessage           message;
        int                nMessageCounter;
        String             recordSeparator;
        boolean            suppressEmptyMessages;

        public SplitterCallback(IProcessingContext cntxt,
                                IMessage messg)
        {
            super();
            this.context = cntxt;
            this.message = messg;
        }

        @Override
        public void pushMessageCallBack(OutputStream msgOutput) throws IOException
        {
            // TODO Auto-generated method stub
            try
            {
                if (!(msgOutput instanceof SmartStream))
                {
                    throw new IllegalArgumentException("SmartStream type expected for message creation");
                }
                else
                {
                    Map<String, Object> msgHeaders = message.getHeaders();
                    if (!suppressEmptyMessages || ((SmartStream) msgOutput).getByteCount() > 0)
                    {
                        ++nMessageCounter;
                        msgHeaders.put(MD_SPLIT_MESSAGE_ID, nMessageCounter);
                        msgHeaders.put(RECORD_SEPARATOR, recordSeparator);
                        msgHeaders.put(MD_SPLIT_MESSAGE_LENGTH, ((SmartStream) msgOutput).getByteCount());
                        IMessage msgProcessed = context.getMessageFactory().createMessage(msgHeaders, ((SmartStream) msgOutput).getInputStream());
                        ICompositeMessage msgExProcessed = context.getMessageFactory().createCompositeMessage(msgHeaders, msgProcessed);
                        context.putResult(msgExProcessed);
                    }
                }
            }
            catch (Exception e)
            {
                throw new IOException(e.getCause());
            }

        }

        @Override
        public OutputStream getOutputStream()
        {
            return new SmartStream();
        }

        public void setRrecordSeparator(String RS)
        {
            recordSeparator = RS;
        }

    }
}
