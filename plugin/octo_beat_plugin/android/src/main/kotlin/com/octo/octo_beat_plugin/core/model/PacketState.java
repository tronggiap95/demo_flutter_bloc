package com.octo.octo_beat_plugin.core.model;

/**
 * Created by caoxuanphong on 12/18/17.
 */

public enum PacketState {
    NONE,
    READING_PAYLOAD_SIZE,
    READING_PAYLOAD_DATA,
    READING_CRC,
    FULLED
}
