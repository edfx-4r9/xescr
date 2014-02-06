package com.edifecs.etools.xeserver.component.splitter;

import org.junit.Test;

import static org.junit.Assert.*;

//import java.io.IOException;
//import java.io.InputStream;
//import java.io.OutputStream;
//import java.io.BufferedInputStream;
//import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.InputStream;

import com.edifecs.etools.commons.io.SmartStream;

public class SplitterTest implements SplitterCallback
{
    int      msgCount = 0;
    String[] msgs     = null;

    @Override
    public OutputStream getOutputStream()
    {
        return new SmartStream();
    }

    @Override
    public void pushMessageCallBack(OutputStream msgOutput)
    {
        try
        {
            byte[] b = new byte[(int) ((SmartStream) msgOutput).getByteCount()];
            ((SmartStream) msgOutput).getInputStream().read(b);
            String msg = new String(b);
            if (!msg.equals(msgs[msgCount]))
            {
                System.out.print(msgCount);
                System.out.print(" `" + msgs[msgCount] + "`\t");
                System.out.print('`' + msg + '`');
                System.out.print(" <-- mismatch");
                System.out.println();
            }
            assertEquals(msg, msgs[msgCount]);
            ++msgCount;
        }
        catch (Exception e)
        {
            e = e;
        }
    }

    //    @Test
    public void testPushMessageCallBack()
    {
        //        fail("Not yet implemented"); // TODO
        assertTrue(false);
    }

    //    @Test
    public void runTestProcess(String inMessage,
                               String rSep,
                               String[] outMes) throws IOException
    {
        //        fail("Not yet implemented"); // TODO
        assertTrue(true);
        byte[] recSep = rSep.getBytes();
        byte[] payload = inMessage.getBytes();
        BufferedInputStream is = new BufferedInputStream(new ByteArrayInputStream(payload));
        msgs = new String[] { "abc", "def", "", "ghi" };
        msgs = outMes;

        msgCount = 0;
        StreamSplitter wrk = new StreamSplitter();
        wrk.splitMessageByRecords(is, recSep, this);
    }

    @Test
    public void test_data_001() throws IOException
    {
        assertTrue(true);
        String recordSeparator = "XXY";
        String inputMessage = "abcXXYdefXXXYghi";
        String[] outputMessages = new String[] { "abc", "defX", "ghi" };
        runTestProcess(inputMessage, recordSeparator, outputMessages);
    }

    @Test
    public void test_data_002() throws IOException
    {
        assertTrue(true);
        String recordSeparator = "XZ";
        String inputMessage = "abcXZdefXZXZghi";
        String[] outputMessages = new String[] { "abc", "def", "", "ghi" };
        runTestProcess(inputMessage, recordSeparator, outputMessages);
    }

    @Test
    public void test_data_003() throws IOException
    {
        assertTrue(true);
        String recordSeparator = "XYZ";
        String inputMessage = "abcXZdefXZXZghi";
        String[] outputMessages = new String[] { "abcXZdefXZXZghi" };
        runTestProcess(inputMessage, recordSeparator, outputMessages);
    }

    @Test
    public void test_data_004() throws IOException
    {
        assertTrue(true);
        String recordSeparator = "XZXZ";
        String inputMessage = "abcXZdefXZXZghi";
        String[] outputMessages = new String[] { "abcXZdef", "ghi" };
        runTestProcess(inputMessage, recordSeparator, outputMessages);
    }

    @Test
    public void test_data_005() throws IOException
    {
        assertTrue(true);
        String recordSeparator = "X";
        String inputMessage = "abcXZdefXZXZghi";
        String[] outputMessages = new String[] { "abc", "Zdef", "Z", "Zghi" };
        runTestProcess(inputMessage, recordSeparator, outputMessages);
    }

    @Test
    public void test_data_006() throws IOException
    {
        assertTrue(true);
        String recordSeparator = "XZ";
        String inputMessage = "XZabcXZdef";
        String[] outputMessages = new String[] { "", "abc", "def" };
        runTestProcess(inputMessage, recordSeparator, outputMessages);
    }

    @Test
    public void test_data_007() throws IOException
    {
        assertTrue(true);
        String recordSeparator = "XZ";
        String inputMessage = "abcXZdefXZ";
        String[] outputMessages = new String[] { "abc", "def", "" };
        runTestProcess(inputMessage, recordSeparator, outputMessages);
    }

    @Test
    public void test_data_008() throws IOException
    {
        assertTrue(true);
        String recordSeparator = "XZ";
        String inputMessage = "XZ";
        String[] outputMessages = new String[] { "", "" };
        runTestProcess(inputMessage, recordSeparator, outputMessages);
    }

    @Test
    public void test_data_009() throws IOException
    {
        assertTrue(true);
        String recordSeparator = "XZ";
        String inputMessage = "XZXZ";
        String[] outputMessages = new String[] { "", "", "" };
        runTestProcess(inputMessage, recordSeparator, outputMessages);
    }
}
