import 'package:octo360/application/utils/logger/logger.dart';
import 'package:phone_number/phone_number.dart';

class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static bool isValidPassword(String pass) {
    return pass.length >= 8;
  }

  static bool isInvalidPhoneNumber(String phone) {
    return phone.length < 12;
  }

  static bool isMatch(String v1, String v2) {
    return v1 == v2;
  }

  static bool isValidOTP(String otp) {
    return otp.length == 6;
  }

  static Future<bool> validatePhoneNumber(
    String phoneNumber,
    String? regionCode,
  ) async {
    try {
      final isValid = await PhoneNumberUtil().validate(
        phoneNumber,
        regionCode: regionCode,
      );
      return isValid;
    } catch (e) {
      return false;
    }
  }

  ///+8497123455 - Follow E.164 standard
  ///@Param:
  ///if providing only phone -> phone need to include the regionCode
  ///+840971234567(or +84971234567) and regionCode = null;
  ///Else must provide both args
  ///0971234567(or 971234567) and regionCode = 'VN'
  static Future<String> getFormattedPhoneNumber(
    String phoneNumber,
    String? regionCode,
  ) async {
    Log.e("getPhoneNumberFormatted11 $phoneNumber $regionCode");
    final formattedPhoneNumber =
        await PhoneNumberUtil().parse(phoneNumber, regionCode: regionCode);
    return formattedPhoneNumber.e164;
  }

  ///@Input: +8497123455 - Follow E.164 standard
  static Future<PhoneNumber> parsePhoneNumber(
    String phoneNumber,
    String? regionCode,
  ) async {
    Log.e("getPhoneNumberFormatted11 $phoneNumber $regionCode");
    return await PhoneNumberUtil().parse(phoneNumber, regionCode: regionCode);
  }
}
