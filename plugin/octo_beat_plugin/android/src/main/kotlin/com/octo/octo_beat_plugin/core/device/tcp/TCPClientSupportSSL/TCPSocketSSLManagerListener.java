package com.octo.octo_beat_plugin.core.device.tcp.TCPClientSupportSSL;
public interface TCPSocketSSLManagerListener {
    /**
     *
     * @param resultCode
     *      CONNECT_SERVER_SUCCESS
     *      CONNECT_SERVER_FAIL
     *
     * @param errorCode
     *      ERROR_NO_INTERNET_CONNECTION
     *      ERROR_SERVER_UNREACHABLE
     *      ERROR_SERVER_CERTIFICATE_INCORRECT
     */
    void onConnectDone(int resultCode, int errorCode);

    void onLostServerConnection();

    void onDidSocketReceive(String message);
}
