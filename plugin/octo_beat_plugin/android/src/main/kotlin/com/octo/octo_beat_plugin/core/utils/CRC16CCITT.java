package com.octo.octo_beat_plugin.core.utils;

import java.nio.ByteOrder;

/******************************************************************************
 *  Compilation:  javac CRC16CCITT.java
 *  Execution:    java CRC16CCITT s
 *  Dependencies: 
 *  
 *  Reads in a sequence of bytes and prints out its 16 bit
 *  Cylcic Redundancy Check (CRC-CCIIT 0xFFFF).
 *
 *  1 + x + x^5 + x^12 + x^16 is irreducible polynomial.
 *
 *  % java CRC16-CCITT 123456789
 *  CRC16-CCITT = 29b1
 *
 ******************************************************************************/

public class CRC16CCITT { 

    public static byte[] calc(byte[] bytes) {
        int crc = 0xFFFF;
        int polynomial = 0x1021;

        for (byte b : bytes) {
            for (int i = 0; i < 8; i++) {
                boolean bit = ((b   >> (7-i) & 1) == 1);
                boolean c15 = ((crc >> 15    & 1) == 1);
                crc <<= 1;
                if (c15 ^ bit) crc ^= polynomial;
            }
        }

        crc &= 0xffff;

        byte[] tmp = ByteUtils.integerToByteArray(crc, ByteOrder.LITTLE_ENDIAN);
        return ByteUtils.subByteArray(tmp, 0, 2);
    }

}
