package com.octo.octo_beat_plugin.core.device.parser.bluetooth;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;
import java.io.ByteArrayOutputStream;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import com.octo.octo_beat_plugin.core.device.handler.NotifyLowTCPSpeedHandler;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.device.parser.ParsePacketErrorListener;

/**
 * Created by caoxuanphong on 12/18/17.
 */

public class PacketBLParser implements Runnable {
    private static final String TAG = "PacketBLParser";
    private PacketBLParserOutputStream outputStream;
    private PacketBLParserInputStream inputStream;
    private PacketBLParserImp packetBLParserImp;
    private BlockingQueue<byte[]> buffer = new ArrayBlockingQueue<>(100);
    private DXHDevice dxhDevice;
//    private LifecycleRegistry lifecycleRegistry;
    private Boolean isSendingLowCapacity = false;
    private Boolean isInterrupted = false;

    public PacketBLParser(DXHDevice dxhDevice, ParsePacketErrorListener listener) {
        this.dxhDevice = dxhDevice;
//        lifecycleRegistry = new LifecycleRegistry(this);
        packetBLParserImp = new PacketBLParserImp(dxhDevice, listener);
        inputStream = new PacketBLParserInputStream(packetBLParserImp);
        outputStream = new PacketBLParserOutputStream(packetBLParserImp, buffer);
//        this.getLifecycle().addObserver(packetBLParserImp);
    }

    @Override
    public void run() {
        android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_FOREGROUND);
//        lifecycleRegistry.setCurrentState(Lifecycle.State.STARTED);
        while (dxhDevice.getExecutor() != null
                && !dxhDevice.getExecutor().isTerminating()
                && !dxhDevice.getExecutor().isShutdown()
                && !dxhDevice.getExecutor().isTerminated()) {
            try {
            //    Log.d(TAG, "PACKET-SIZE BUFFER:" + dxhDevice.getClientId() +": "+ buffer.size());
                handleLowBufferCapacity();
                byte[] data = buffer.take();

                if (data != null) {
                    packetBLParserImp.parse(data);
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
//        lifecycleRegistry.setCurrentState(Lifecycle.State.DESTROYED);
    }

    /**
     * LOW PACKET CAPACITY HANDLER
     * 1: LOW MEMORY
     * 0: HIGH MEMORY
     */
    private void handleLowBufferCapacity() {
        if(dxhDevice != null && dxhDevice.getApiVersion() > 1) {
//            Log.d(TAG, "PACKET-SIZE ------" + buffer.size());
            if(buffer.remainingCapacity() < 50 && !isSendingLowCapacity) {
                NotifyLowTCPSpeedHandler.Companion.handle(dxhDevice, 1);
//            Log.d(TAG, "PACKET-SIZE SENDING LOW CAPACITY: " + buffer.size());
                isSendingLowCapacity = true;
            } else if(buffer.remainingCapacity() > 90 && isSendingLowCapacity) {
                NotifyLowTCPSpeedHandler.Companion.handle(dxhDevice, 0);
//            Log.d(TAG, "PACKET-SIZE SENDING HIGH CAPACITY: " + buffer.size());
                isSendingLowCapacity = false;
            }
        }
    }


    public void handleLowCapacity() {
        packetBLParserImp.handleLowCapacity();
    }

    public ByteArrayOutputStream getOutputStream() {
        return outputStream;
    }

    public PacketBLParserInputStream getInputStream() {
        return inputStream;
    }


//    @NonNull
//    @Override
//    public Lifecycle getLifecycle() {
//        return lifecycleRegistry;
//    }
}
