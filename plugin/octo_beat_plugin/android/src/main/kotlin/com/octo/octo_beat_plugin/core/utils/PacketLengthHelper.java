package com.octo.octo_beat_plugin.core.utils;

/**
 * Created by caoxuanphong on 12/18/17.
 */

public class PacketLengthHelper {

    public static int encode_length(int len, byte[] buf) {
        int encodedByte, cnt;

        assert (len <= 0xFFFFFFF);
        cnt = 0;

        do {
            encodedByte = len & 0x7F;
            len >>= 7;
            encodedByte |= (len != 0) ? 0x80 : 0x00;

            buf[cnt++] = (byte) encodedByte;
        } while (len != 0);

        return cnt;
    }

    public static int decodePacketLength(byte[] buf, int size) {
        int multiplier, value;
        int decodedByte;
        int cnt = 0;

        assert (size <= 4);
        assert ((buf[size - 1] & 0x80) == 0); // The MSb of the last byte must be '0'

        value = 0;
        multiplier = 1;

        do {
            decodedByte = buf[cnt++];
            value += (decodedByte & 0x7F) * multiplier;
            multiplier <<= 7;
        } while (--size > 0);

        return value;
    }
}
