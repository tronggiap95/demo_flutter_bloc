package com.octo.octo_beat_plugin.core.device.parser.tcp;

import java.io.ByteArrayOutputStream;
import java.util.concurrent.BlockingQueue;

public class PacketTCPParserOutputStream extends ByteArrayOutputStream {
    private static final String TAG = "PacketParserOutputStrea";
    private PacketTCPParserImp packetTCPParserImp;
    private BlockingQueue<byte[]> buffer;

    public PacketTCPParserOutputStream(PacketTCPParserImp packetTCPParserImp, BlockingQueue<byte[]> buffer ) {
        this.packetTCPParserImp = packetTCPParserImp;
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
