package com.octo.octo_beat_plugin.core.bluetooth;
import java.util.UUID;

/**
 * Created by caoxuanphong on 12/15/17.
 */

public class BTUUID {
    public static final UUID UUID_BASE = UUID.fromString("00000000-0000-1000-8000-00805F9B34FB");
    public static final UUID UUID_UDP = UUID.fromString("00000002-0000-1000-8000-00805F9B34FB");
    public static final UUID UUID_RFCOMM = UUID.fromString("00000003-0000-1000-8000-00805F9B34FB");
    public static final UUID UUID_TCP = UUID.fromString("00000004-0000-1000-8000-00805F9B34FB");
    public static final UUID UUID_IP = UUID.fromString("00000009-0000-1000-8000-00805F9B34FB");
    public static final UUID UUID_FTP = UUID.fromString("0000000A-0000-1000-8000-00805F9B34FB");
    public static final UUID UUID_HTTP = UUID.fromString("0000000C-0000-1000-8000-00805F9B34FB");
    public static final UUID UUID_SPP = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
}
