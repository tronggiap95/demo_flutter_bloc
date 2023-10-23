package com.octo.octo_beat_plugin.core.device.parser.tcp;

import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.device.parser.ParsePacketErrorListener;

public class PacketTCPParser implements Runnable {
    private static final String TAG = "PacketBLParser";
    private PacketTCPParserOutputStream outputStream;
    private PacketTCPParserInputStream inputStream;
    private PacketTCPParserImp packetTCPParserImp;
    private BlockingQueue<byte[]> buffer = new ArrayBlockingQueue<>( 100);
    private DXHDevice dxhDevice;

    public PacketTCPParser(DXHDevice dxhDevice, ParsePacketErrorListener listener) {
        this.dxhDevice = dxhDevice;
        packetTCPParserImp = new PacketTCPParserImp(dxhDevice, listener);
        inputStream = new PacketTCPParserInputStream(packetTCPParserImp);
        outputStream = new PacketTCPParserOutputStream(packetTCPParserImp, buffer);
    }

    @Override
    public void run() {
        Log.d(TAG, "run packet parser:");

        while (!dxhDevice.getExecutor().isShutdown() &&
                !dxhDevice.getExecutor().isTerminated()) {
            try {
                byte[] data = buffer.take();

                if (data != null) {
                    packetTCPParserImp.parse(data);
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
                break;
            }
        }
    }

    public ByteArrayOutputStream getOutputStream() {
        return outputStream;
    }

    public PacketTCPParserInputStream getInputStream() {
        return inputStream;
    }
}
