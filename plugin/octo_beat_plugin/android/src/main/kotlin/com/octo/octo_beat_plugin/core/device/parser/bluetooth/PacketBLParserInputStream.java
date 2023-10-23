package com.octo.octo_beat_plugin.core.device.parser.bluetooth;

import com.octo.octo_beat_plugin.core.model.Packet;

/**
 * Created by caoxuanphong on 12/21/17.
 */

public class PacketBLParserInputStream {
    private PacketBLParserImp packetBLParserImp;

    public PacketBLParserInputStream(PacketBLParserImp packetBLParserImp) {
        this.packetBLParserImp = packetBLParserImp;
    }

    public byte[] read() throws InterruptedException {
        return packetBLParserImp.retrievePacket();
    }

}
