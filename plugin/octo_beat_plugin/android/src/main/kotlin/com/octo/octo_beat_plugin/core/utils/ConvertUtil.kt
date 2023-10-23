package com.octo.octo_beat_plugin.core.utils

import java.math.RoundingMode
import java.text.DecimalFormat
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

object ConvertUtil {
    fun convertCmToFt(cm: Double?): Int? {
        if (cm != null) {
            val inches = cm / 2.54
            val ft = inches / 12
            return ft.toInt()
        }
        return 0
    }

    fun convertCmToInches(cm: Double?): Double? {
        if (cm != null) {
            val inches = cm / 2.54
            val ft = (inches / 12).toInt()

            return Math.round(inches - ft * 12).toDouble()
        }
        return 0.0
    }

    fun convertFeetInchesToCm(feet: Double?, inches: Double?): Double? {
        if (feet == null && inches == null) {
            return null
        }

        var tempFeet = feet
        var tempInches = inches

        if (feet == null) {
            tempFeet = 0.0
        }

        if (inches == null) {
            tempInches = 0.0
        }

        return (tempFeet!! * 12 + tempInches!!) * 2.54
    }

    fun convertKilogramsToPounds(kilograms: Double?): Double? {
        if (kilograms != null) {
            return roundToOneDecimal(kilograms * 2.2046)
        }
        return 0.0
    }

    fun convertPoundsToKilograms(pounds: Double?): Double? {
        if (pounds != null) {
            return pounds / 2.2046226218
        }
        return 0.0
    }

    fun roundToOneDecimal(number: Double): Double {
        if (number == null || number.isNaN()) {
            return 0.0
        }
        val df = DecimalFormat("#.#")
        df.roundingMode = RoundingMode.HALF_UP
        return df.format(number).toDouble()
    }

    /**
     * Handle all Android version
     */
    fun convertStringToDateTime(rawStringDate: String?): String? {
        if (rawStringDate == null) {
            return null
        }
        var stringDate = rawStringDate.replace("/", "-")
        stringDate += "T00:00:000Z"
        val parser = SimpleDateFormat("MM-dd-yyyy'T'HH:mm:ss'Z'")
        val dateInMilliseconds = parser.parse(stringDate).time
        val tz = TimeZone.getDefault()
        val format = "yyyy-MM-dd HH:mm:ss.SSSZ"
        val sdf = SimpleDateFormat(format, Locale.US)
        sdf.timeZone = tz
        val dateString = sdf.format(Date(dateInMilliseconds)).split(" ")
        return "${dateString[0]}T${dateString[1].subSequence(0, 8)}.000Z"
    }

    /**
     * @param rawStringDate: Value need parse
     * @param pattern: Pattern String want
     * @return Date?
     */
    fun parseSimpleDateWithPattern(rawStringDate: String, pattern: String): Date? {
        if (rawStringDate.isNullOrEmpty()) {
            return null
        }

        return try {
            val simpleDateFormat = SimpleDateFormat(pattern, Locale.US)
            simpleDateFormat.parse(rawStringDate)
        } catch (e: ParseException) {
            e.printStackTrace()
            null
        }
    }


    /**
     * @param date: Value need format
     * @param pattern: Pattern String want
     * @return String by Pattern
     */
    fun formatSimpleDateWithPattern(date: Date?, pattern: String): String {
        if (date == null) {
            return ""
        }
        val simpleDateFormat = SimpleDateFormat(pattern, Locale.US)
        return simpleDateFormat.format(date)
    }
}