package com.edifecs.etools.xeserver.component.splitter;

import java.io.BufferedInputStream;
import java.io.BufferedInputStream;
import java.io.OutputStream;

import java.util.Arrays;

//import com.edifecs.etools.commons.io.SmartStream;
import org.apache.commons.io.IOUtils;


interface SplitterCallback
{
    public void pushMessageCallBack(OutputStream msgOutput);
    public OutputStream getOutputStream();
}

public class StreamSplitter
{

    public void splitMessageByRecords(BufferedInputStream inputStream,
                                      byte[] recSep,
                                      SplitterCallback cb)
    {
        if (inputStream == null) 
        {
            throw new IllegalArgumentException("Input stream cannot be null.");
        }
        if (cb == null) 
        {
            throw new IllegalArgumentException("Callback function cannot be null.");
        }
        if (recSep == null) 
        {
            throw new IllegalArgumentException("Incorrect record separator");
        }
        OutputStream msgOutput = null;

        try
        {
            inputStream = new BufferedInputStream(inputStream);
            int markLimit = recSep.length;
            byte[] recSepBuffer = new byte[markLimit];
            recSepBuffer[0] = recSep[0];

            msgOutput = cb.getOutputStream();
            int character;
            while ((character = inputStream.read()) != -1)
            {
                inputStream.mark(markLimit-1);
                if (character == (byte)recSep[0])
                {
                    int bytesRead = inputStream.read(recSepBuffer, 1, markLimit-1);
                    if (bytesRead == markLimit-1 && Arrays.equals(recSepBuffer, recSep))
                    {
//                        Record separator found
                        msgOutput.close();
                        cb.pushMessageCallBack(msgOutput);
                        msgOutput = cb.getOutputStream();
                    } else {
//                        Record separator not found
                        inputStream.reset();
                        msgOutput.write(character);
                    }
                } else {
                    msgOutput.write(character);
                }

            }

//            Close final output stream 
            {
                msgOutput.close();
                cb.pushMessageCallBack(msgOutput);
            }
        }
        catch (Exception e)
        {
            // TODO
            //      throw new ProcessingException();
            e = e;
        }

        finally
        {
            IOUtils.closeQuietly(inputStream);
        }
    }
}
