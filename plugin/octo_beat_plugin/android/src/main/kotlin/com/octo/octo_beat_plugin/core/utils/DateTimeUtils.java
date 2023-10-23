package com.octo.octo_beat_plugin.core.utils;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

/**
 * Created by caoxuanphong on    4/29/16.
 */
public class DateTimeUtils {
    private static final String TAG = "DateTimeUtils";

    public interface onReceiveTrueTime {
        void trueTime(Long time);
    }

    public static long currentTimeToEpoch() {

        int offsetFromUtc = getOffsetFromUtc();

        return (System.currentTimeMillis() / 1000 + offsetFromUtc);
    }

    public static int getOffsetFromUtc() {
        TimeZone tz = TimeZone.getDefault();
        Date now = new Date();
        return tz.getOffset(now.getTime()) / 1000;
    }

    /**
     * Get current timezone of device
     *
     * @return
     */
    public static int getTimezone() {
        TimeZone tz = TimeZone.getDefault();
        Date now = new Date();
        int offsetFromUtc = tz.getOffset(now.getTime());

        return offsetFromUtc / 3600000;
    }

    /**
     * Get current timezone of device in minute
     *
     * @return
     */
    public static int getTimezoneInMinute() {
        TimeZone tz = TimeZone.getDefault();
        Date now = new Date();
        int offsetFromUtc = tz.getOffset(now.getTime());

        return offsetFromUtc / 60000;
    }

    public static String epochToString(long epoch, String format) {
        //Date date = new Date((epoch - offsetFromUtc) * 1000);
        Date date = new Date((epoch) * 1000);
        SimpleDateFormat s = new SimpleDateFormat(format);
        return s.format(date);
    }

    public static Date epochToDate(long epoch) {
        TimeZone tz = TimeZone.getDefault();
        Date now = new Date();
        int offsetFromUtc = tz.getOffset(now.getTime()) / 1000;

        Date date = new Date((epoch - offsetFromUtc) * 1000);
        return date;
    }

    public static String getRemaingTime(int minute) {
        int h = minute/60;
        int m = minute%60;
        if(minute ==0){
            return "Fully Charged";
        }

        String hourTextDisplay = "%d hours";
        if(h == 1) {
            hourTextDisplay = "%d hour";
        }

        String minTextDisplay = "%d mins";
        if(m == 1) {
            minTextDisplay = "%d min";
        }

        if (h == 0) {
            return String.format(minTextDisplay, m);
        } else if (m == 0) {
            return String.format(hourTextDisplay, h);
        } else {
            return String.format(hourTextDisplay + " " + minTextDisplay, h, m);
        }
    }

    public static boolean isSameDate(long epoch1, long epoch2) {
        Date date1 = epochToDate(epoch1);
        Date date2 = epochToDate(epoch2);

        if (date1.getDate() == date2.getDate() &&
                date1.getMonth() == date2.getMonth() &&
                date1.getYear() == date2.getYear()) {
            return true;
        }

        return false;
    }

    /**
     * Get current time
     *
     * @param format Wanted format
     * @return
     */
    public static String getCurrentTime(String format) {
        SimpleDateFormat sdf = new SimpleDateFormat(format);
        return sdf.format(new Date());
    }

    public static void getTrueTimeUTCInSecond(onReceiveTrueTime receiveTrueTime) {
        receiveTrueTime.trueTime(System.currentTimeMillis()/1000);
        //true time get error for several networks
//        new Thread(new Runnable() {
//            @Override
//            public void run() {
//                try {
//                    TrueTime trueTime = TrueTime.build();
//                    trueTime.withNtpHost("time.google.com");
//                    trueTime.initialize();
//                    long utcZero = TrueTime.now().getTime() / 1000;
//                    receiveTrueTime.trueTime(utcZero);
//                } catch (IOException e) {
//                    e.printStackTrace();
//                    receiveTrueTime.trueTime(System.currentTimeMillis()/1000);
//                }
//            }
//        }).start();
    }
}
