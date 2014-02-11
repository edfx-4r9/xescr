package com.edifecs.etools.xeserver.component.splitter;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.junit.Test;

import com.edifecs.etools.commons.io.SmartStream;

public class SplitterTest implements ISplitterCallback {
	int msgCount = 0;
	String[] msgs = null;

	@Override
	public OutputStream getOutputStream() {
		return new SmartStream();
	}

	@Override
	public void pushMessageCallBack(OutputStream msgOutput) throws IOException {
	    msgOutput.close();
		byte[] b = new byte[(int) ((SmartStream) msgOutput).getByteCount()];
		((SmartStream) msgOutput).getInputStream().read(b);
		String msg = new String(b, "US-ASCII");
		if (!msg.equals(msgs[msgCount])) {
			System.out.print(msgCount);
			System.out.print(" `" + msgs[msgCount] + "`\t");
			System.out.print('`' + msg + '`');
			System.out.print(" <-- mismatch");
			System.out.println();
		}
		assertEquals(msg, msgs[msgCount]);
		++msgCount;
	}

	// @Test
	public void runTestProcess(String inMessage, String rSep, String[] outMes)
			throws IOException {
		byte[] recSep = rSep.getBytes();
		byte[] payload = inMessage.getBytes();
		ByteArrayInputStream is = new ByteArrayInputStream(payload);
		msgs = outMes;

		msgCount = 0;
		StreamSplitter wrk = new StreamSplitter();
		wrk.splitMessageByRecords(is, recSep, this);
	}

	@Test
	public void test001_long_record_separator_checks_mark_and_reset() throws IOException {
		assertTrue(true);
		String recordSeparator = "XXY";
		String inputMessage = "abcXXYdefXXXYghi";
		String[] outputMessages = new String[] { "abc", "defX", "ghi" };
		runTestProcess(inputMessage, recordSeparator, outputMessages);
	}

	@Test
	public void test002_splitting_and_empty_record_inside_message() throws IOException {
		assertTrue(true);
		String recordSeparator = "XZ";
		String inputMessage = "abcXZdefXZXZghi";
		String[] outputMessages = new String[] { "abc", "def", "", "ghi" };
		runTestProcess(inputMessage, recordSeparator, outputMessages);
	}

	@Test
	public void test003_record_separator_not_found() throws IOException {
		assertTrue(true);
		String recordSeparator = "XYZ";
		String inputMessage = "abcXZdefXZXZghi";
		String[] outputMessages = new String[] { "abcXZdefXZXZghi" };
		runTestProcess(inputMessage, recordSeparator, outputMessages);
	}

	@Test
	public void test004_record_separator_contains_two_halves() throws IOException {
		assertTrue(true);
		String recordSeparator = "XZXZ";
		String inputMessage = "abcXZdefXZXZghi";
		String[] outputMessages = new String[] { "abcXZdef", "ghi" };
		runTestProcess(inputMessage, recordSeparator, outputMessages);
	}

	@Test
	public void test005_record_separator_from_one_character() throws IOException {
		assertTrue(true);
		String recordSeparator = "X";
		String inputMessage = "abcXZdefXZXZghi";
		String[] outputMessages = new String[] { "abc", "Zdef", "Z", "Zghi" };
		runTestProcess(inputMessage, recordSeparator, outputMessages);
	}

	@Test
	public void test006_empty_record_at_message_start() throws IOException {
		assertTrue(true);
		String recordSeparator = "XZ";
		String inputMessage = "XZabcXZdef";
		String[] outputMessages = new String[] { "", "abc", "def" };
		runTestProcess(inputMessage, recordSeparator, outputMessages);
	}

	@Test
	public void test007_empty_record_at_message_end() throws IOException {
		assertTrue(true);
		String recordSeparator = "XZ";
		String inputMessage = "abcXZdefXZ";
		String[] outputMessages = new String[] { "abc", "def", "" };
		runTestProcess(inputMessage, recordSeparator, outputMessages);
	}

	@Test
	public void test008_message_contains_only_empty_records() throws IOException {
		assertTrue(true);
		String recordSeparator = "XZ";
		String inputMessage = "XZ";
		String[] outputMessages = new String[] { "", "" };
		runTestProcess(inputMessage, recordSeparator, outputMessages);
	}

	@Test
	public void test009_message_contains_only_empty_records() throws IOException {
		assertTrue(true);
		String recordSeparator = "XZ";
		String inputMessage = "XZXZ";
		String[] outputMessages = new String[] { "", "", "" };
		runTestProcess(inputMessage, recordSeparator, outputMessages);
	}

    @Test
    public void test010_message_is_empty() throws IOException {
        assertTrue(true);
        String recordSeparator = "XZ";
        String inputMessage = "";
        String[] outputMessages = new String[] { "" };
        runTestProcess(inputMessage, recordSeparator, outputMessages);
    }

	public void test_data_010() throws IOException {
		assertTrue(true);
		String recordSeparator = "";
		String inputMessage = "abcXZdefXZ";
		String[] outputMessages = new String[] { "abcXZdefXZ" };
		runTestProcess(inputMessage, recordSeparator, outputMessages);
	}
}
