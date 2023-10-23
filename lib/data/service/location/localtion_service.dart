import 'dart:io';

import 'package:location/location.dart';

class LocationService {
  static Future<bool> isEnable() async {
    return await Location().serviceEnabled();
  }

  static Future<bool> requestLocation() async {
    return await Location().requestService();
  }

  ///ios: Don't need to enable location for scanning ble.
  static Future<bool> isEnableForScanningBLe() async {
    if (Platform.isIOS) return true;
    return await isEnable();
  }
}
