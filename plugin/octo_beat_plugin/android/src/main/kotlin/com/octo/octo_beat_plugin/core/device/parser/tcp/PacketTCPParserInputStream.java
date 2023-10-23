package com.octo.octo_beat_plugin.core.device.parser.tcp;

import com.octo.octo_beat_plugin.core.model.Packet;

public class PacketTCPParserInputStream {
    private PacketTCPParserImp packetTCPParserImp;

    public PacketTCPParserInputStream(PacketTCPParserImp packetTCPParserImp) {
        this.packetTCPParserImp = packetTCPParserImp;
    }

    public Packet read() throws InterruptedException {
        return packetTCPParserImp.retrievePacket();
    }
}
