package com.octo.octo_beat_plugin.core.device.security;

import android.util.Log;

import java.security.MessageDigest;
import java.util.Arrays;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import com.octo.octo_beat_plugin.core.utils.ByteUtils;
import com.octo.octo_beat_plugin.core.utils.MyLog;

public class AESManager {
    private final String TAG = "AESManager";

    //AESCrypt-ObjC uses CBC and PKCS7Padding
    //private final String AES_MODE = "AES/CBC/PKCS7Padding";
    //private final String AES_MODE = "AES/ECB/PKCS5PADDING";
    private final String AES_MODE = "AES/CTR/NoPadding";
    private final String CHARSET = "UTF-8";

    //AESCrypt-ObjC uses SHA-256 (and so a 256-bit key)
    private final String HASH_ALGORITHM = "SHA-256";
//    private final String HASH_ALGORITHM = "SHA-128";

    //togglable log option (please turn off in live!)
    public boolean DEBUG_LOG_ENABLED = false;


    private byte[] key;
    private byte[] iv;
    private SecretKeySpec secretKey;


    public AESManager(String deviceName) {
        initKey(deviceName);
    }

    /**
     * hash device name
     * return iv[0..15]
     * and key[16..31]
     */
    private void initKey(String deviceName) {
        final MessageDigest digest;
        try {
            Log.d(TAG, "Octo-Beat-" + deviceName);
            deviceName = "Octo-Beat-" + deviceName;
            digest = MessageDigest.getInstance(HASH_ALGORITHM);
            byte[] bytes = deviceName.getBytes(CHARSET);
            digest.update(bytes, 0, bytes.length);
            byte[] byteArr = digest.digest();
            key = new byte[16];
            iv = new byte[16];
            iv = Arrays.copyOfRange(byteArr, 0, 16);
            key = Arrays.copyOfRange(byteArr, 16, 32);
            secretKey = new SecretKeySpec(key, "AES");
            MyLog.log("HASH_DEVICE_NAME", "IV: " + ByteUtils.toHexString(iv));
            MyLog.log("HASH_DEVICE_NAME", "KEY: " + ByteUtils.toHexString(key));
            MyLog.log("HASH_DEVICE_NAME", "SECRETKEY: " + secretKey);
            System.out.println(ByteUtils.toHexString(iv));
            System.out.println(ByteUtils.toHexString(key));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public byte[] encrypt(final byte[] bytes) {
        try {
            final Cipher cipher = Cipher.getInstance(AES_MODE);
            IvParameterSpec ivSpec = new IvParameterSpec(iv);
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, ivSpec);
            return cipher.doFinal(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return null;

        }
    }

    public byte[] decrypt(final byte[] bytes) {
        final Cipher cipher;
        try {
            cipher = Cipher.getInstance(AES_MODE);
            IvParameterSpec ivSpec = new IvParameterSpec(iv);
            cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec);
            return cipher.doFinal(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }


    private void log(String what, byte[] bytes) {
        if (DEBUG_LOG_ENABLED)
            Log.d(TAG, what + "[" + bytes.length + "] [" + bytesToHex(bytes) + "]");
    }

    private void log(String what, String value) {
        if (DEBUG_LOG_ENABLED)
            Log.d(TAG, what + "[" + value.length() + "] [" + value + "]");
    }

    public String printBytes(byte[] a) {
        StringBuffer buffer = new StringBuffer();
        for (byte i : a) {
            buffer.append((i & 0xff) + ", ");
        }
        return buffer.toString();
    }

    public String bytesToHex(byte[] bytes) {
        final char[] hexArray = {'0', '1', '2', '3', '4', '5', '6', '7', '8',
                '9', 'A', 'B', 'C', 'D', 'E', 'F'};
        char[] hexChars = new char[bytes.length * 2];
        int v;
        for (int j = 0; j < bytes.length; j++) {
            v = bytes[j] & 0xFF;
            hexChars[j * 2] = hexArray[v >>> 4];
            hexChars[j * 2 + 1] = hexArray[v & 0x0F];
        }
        return new String(hexChars);
    }

}

