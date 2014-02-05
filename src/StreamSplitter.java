package com.edifecs.etools.xeserver.component.splitter;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.OutputStream;

//import com.edifecs.etools.commons.io.SmartStream;
import org.apache.commons.io.IOUtils;


interface SplitterCallback
{
    public void pushMessageCallBack(OutputStream msgOutput);
    public OutputStream getOutputStream();
}

public class StreamSplitter
{
    private SplitterCallback cb;
    OutputStream msgOutput;

    public StreamSplitter(SplitterCallback cb)
    {
        this.cb = cb;
    }

    public void splitMessageByRecords(InputStream inputStream,
                                      byte[] recSep)
    {
//        SmartStream smartStream = new SmartStream();

        try
        {
            inputStream = new BufferedInputStream(inputStream);
            long msgLength;

            boolean flagRecordStarted = false, flagRecordFinished = false;
            int character, nextcharacter;
            while ((character = inputStream.read()) != -1)
            {
                if (!flagRecordStarted)
                {
//                    msgOutput = new SmartStream();
                    msgOutput = cb.getOutputStream();
                    msgLength = 0;
                    flagRecordStarted = true;
                }
                flagRecordFinished = false;
                int j;
                nextcharacter = character;
                for (j = 0; j < recSep.length; j++)
                {
                    if (j > 0)
                    {
                        nextcharacter = inputStream.read();
                        if (nextcharacter == -1)
                        {
                            break;
                        }
                    }
                    if (nextcharacter != (byte) recSep[j])
                    {
                        break;
                    }
                }
                flagRecordFinished = j == recSep.length;

                if (flagRecordFinished)
                {
                    flagRecordStarted = false;
                    cb.pushMessageCallBack(msgOutput);
                }
                else
                {
                    if (j > 0)
                    {
                        msgOutput.write(recSep, 0, j);
                        if (nextcharacter > -1)
                            msgOutput.write(nextcharacter);
                    }
                    else
                    {
                        msgOutput.write(character);
                    }
                }
            }

            if (!flagRecordStarted)
            {
//                msgOutput = new SmartStream();
                msgOutput = cb.getOutputStream();
                msgLength = 0;
            }
            cb.pushMessageCallBack(msgOutput);
//            smartStream.close();
        }
        catch (Exception e)
        {
            // TODO
            //      throw new ProcessingException();
        }

        finally
        {
            IOUtils.closeQuietly(inputStream);
        }
    }
}
