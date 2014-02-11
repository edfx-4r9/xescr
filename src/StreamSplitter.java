package com.edifecs.etools.xeserver.component.splitter;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;

interface ISplitterCallback
{
    public void pushMessageCallBack(OutputStream msgOutput) throws IOException;

    public OutputStream getOutputStream();
}

public class StreamSplitter
{

    public void splitMessageByRecords(InputStream inputStream,
                                      byte[] recSep,
                                      ISplitterCallback cb) throws IOException
    {
        if (cb == null)
        {
            throw new IllegalArgumentException("Callback function cannot be null.");
        }
        if (inputStream == null)
        {
            throw new IllegalArgumentException("Input stream cannot be null.");
        }
        if (recSep == null)
        {
            throw new IllegalArgumentException("Incorrect record separator");
        }
        OutputStream msgOutput = null;

        if (!(inputStream instanceof BufferedInputStream))
        {
            inputStream = new BufferedInputStream(inputStream);
        }
        int markLimit = recSep.length;
        byte[] recSepBuffer = new byte[markLimit];
        recSepBuffer[0] = recSep[0];

        msgOutput = cb.getOutputStream();
        int character;
        while ((character = inputStream.read()) != -1)
        {
            inputStream.mark(markLimit - 1);
            if (character == (byte) recSep[0])
            {
                int bytesRead = inputStream.read(recSepBuffer, 1, markLimit - 1);
                if (bytesRead == markLimit - 1 && Arrays.equals(recSepBuffer, recSep))
                {
                    // Record separator found
                    cb.pushMessageCallBack(msgOutput);
                    msgOutput = cb.getOutputStream();
                }
                else
                {
                    // Record separator not found
                    inputStream.reset();
                    msgOutput.write(character);
                }
            }
            else
            {
                msgOutput.write(character);
            }

        }

        // Close final output record 
        {
            cb.pushMessageCallBack(msgOutput);
        }
    }
}
