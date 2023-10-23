package com.octo.octo_beat_plugin.core.device.parser.bluetooth;

import java.io.ByteArrayOutputStream;
import java.util.concurrent.BlockingQueue;

/**
 * Created by caoxuanphong on 12/21/17.
 */

public class PacketBLParserOutputStream extends ByteArrayOutputStream {
    private static final String TAG = "PacketParserOutputStrea";
    private PacketBLParserImp packetBLParserImp;
    private BlockingQueue<byte[]> buffer;

    public PacketBLParserOutputStream(PacketBLParserImp packetBLParserImp, BlockingQueue<byte[]> buffer ) {
        this.packetBLParserImp = packetBLParserImp;
        this.buffer = buffer;
    }

    @Override
    public synchronized void write(byte[] b, int off, int len) {
        super.write(b, off, len);

        // Retrieve data
        byte[] data = this.toByteArray();
        try {
            buffer.put(data);
            this.reset();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

}
