package com.octo.octo_beat_plugin.core.device.tcp;

/**
 * Created by caoxuanphong on 12/16/17.
 */

public interface TCPClientCallback {
    void didConnected();

    void didLostConnection();

    void didReceiveData(byte[] data);

    void connectFailed();

    void timeout();
}
