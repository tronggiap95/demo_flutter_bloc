package com.octo.octo_beat_plugin.core.device.model;

import com.octo.octo_beat_plugin.core.device._enum.SSLAuthMode;

public class TCPConnection {
    public int id;
    public SSLAuthMode authMode;
    public int serverCaId;
    public int clientCaId;
    public int clientPrivateKeyId;
    public boolean isSSLEnabled;

    public TCPConnection(int id, SSLAuthMode authMode, int serverCaId, int clientCaId, int clientPrivateKeyId) {
        this.id = id;
        this.authMode = authMode;
        this.serverCaId = serverCaId;
        this.clientCaId = clientCaId;
        this.clientPrivateKeyId = clientPrivateKeyId;
    }

    public void paste(TCPConnection connection) {
        this.id = connection.id;
        this.authMode = connection.authMode;
        this.serverCaId = connection.serverCaId;
        this.clientCaId = connection.clientCaId;
        this.clientPrivateKeyId = connection.clientPrivateKeyId;
    }

}
