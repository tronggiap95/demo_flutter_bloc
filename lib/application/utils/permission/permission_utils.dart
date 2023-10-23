import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:octo360/data/local/bridge/scanner/ble_scanner_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<PermissionStatus> checkStoragePermission() async {
    if (Platform.isIOS) {
      return PermissionStatus.granted;
    }
    var storageStatus = await Permission.storage.status;
    var manageStorageStatus = await Permission.manageExternalStorage.status;

    if (storageStatus == PermissionStatus.denied) {
      storageStatus = await Permission.storage.request();
    }

    if (manageStorageStatus == PermissionStatus.denied) {
      manageStorageStatus = await Permission.manageExternalStorage.request();
    }

    if (storageStatus != PermissionStatus.granted) {
      return PermissionStatus.denied;
    }

    if (manageStorageStatus != PermissionStatus.granted) {
      return PermissionStatus.denied;
    }

    return PermissionStatus.granted;
  }

  static Future<PermissionStatus> checkExternalStoragePermission() async {
    if (Platform.isIOS) {
      final photosStatus = await Permission.photos.status;
      if (photosStatus != PermissionStatus.granted) {
        final photosStatusSecond = await Permission.photos.request();
        if (photosStatusSecond != PermissionStatus.granted) {
          return PermissionStatus.denied;
        }
      }
      return PermissionStatus.granted;
    }

    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    final sdkVersion = androidInfo.version.sdkInt;

    if (sdkVersion < 33) {
      final storageStatus = await Permission.storage.status;
      if (storageStatus != PermissionStatus.granted) {
        final storageStatusSecond = await Permission.storage.request();
        if (storageStatusSecond != PermissionStatus.granted) {
          return PermissionStatus.denied;
        }
      }
      return PermissionStatus.granted;
    }
    //only apply for android T+ (33+)
    //check case for videos permission
    final videosStatusAndroidT = await Permission.videos.status;
    if (videosStatusAndroidT != PermissionStatus.granted) {
      final videosStatusAndroidTSecond = await Permission.videos.request();
      if (videosStatusAndroidTSecond != PermissionStatus.granted) {
        return PermissionStatus.denied;
      }
    }

    //check case for photos permission
    final photosStatusAndroidT = await Permission.photos.status;
    if (photosStatusAndroidT != PermissionStatus.granted) {
      final photosStatusAndroidTSecond = await Permission.photos.request();
      if (photosStatusAndroidTSecond != PermissionStatus.granted) {
        return PermissionStatus.denied;
      }
    }

    //check case for audio permission
    final audioStatusAndroidT = await Permission.audio.status;

    if (audioStatusAndroidT != PermissionStatus.granted) {
      final audioStatusAndroidTSecond = await Permission.photos.request();
      if (audioStatusAndroidTSecond != PermissionStatus.granted) {
        return PermissionStatus.denied;
      }
    }

    if (videosStatusAndroidT == PermissionStatus.granted &&
        photosStatusAndroidT == PermissionStatus.granted &&
        audioStatusAndroidT == PermissionStatus.granted) {
      return PermissionStatus.granted;
    }

    return PermissionStatus.granted;
  }

  static Future<PermissionStatus> checkBluetoothPermission() async {
    if (await BleScannerPlugin.hasPermission()) {
      return PermissionStatus.granted;
    } else {
      final requests = await Future.wait([
        Permission.bluetooth.status,
        Permission.bluetoothAdvertise.status,
        Permission.bluetoothConnect.status,
        Permission.bluetoothScan.status,
      ]);
      for (final status in requests) {
        if (status != PermissionStatus.granted) {
          return PermissionStatus.denied;
        }
      }
      return PermissionStatus.granted;
    }
  }

  static Future<void> requestBluetoothPermission() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
  }

  static Future<PermissionStatus> checkLocationPermission() async {
    if (Platform.isIOS) {
      return PermissionStatus.granted;
    }
    var status = await Permission.location.status;
    return status;
  }

  static Future<void> requestLocationPermission() async {
    await Permission.location.request();
  }

  static Future<ScanStateEnum> checkScanPermission() async {
    final isBluetoothPermissionGranted = await checkBluetoothPermission();
    if (isBluetoothPermissionGranted == PermissionStatus.granted) {
      final isLocationPermissionGranted = await checkLocationPermission();
      if (isLocationPermissionGranted == PermissionStatus.granted) {
        return ScanStateEnum.granted;
      } else {
        switch (isLocationPermissionGranted) {
          case PermissionStatus.permanentlyDenied:
            return ScanStateEnum.locationPermanentlyDenied;
          default:
            return ScanStateEnum.locationDenied;
        }
      }
    } else {
      switch (isBluetoothPermissionGranted) {
        case PermissionStatus.permanentlyDenied:
          return ScanStateEnum.bluetoothPermanentlyDenied;
        default:
          return ScanStateEnum.bluetoothDenied;
      }
    }
  }

  static Future<PermissionStatus> checkLocalNotificationPermission() async {
    var status = await Permission.notification.status;
    return status;
  }

  static Future<PermissionStatus> checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    return status;
  }

  static Future<void> requestMicrophonePermission() async {
    await Permission.microphone.request();
  }

  static Future<PermissionStatus> checkCameraPermission() async {
    var status = await Permission.camera.status;
    return status;
  }

  static Future<void> requestCameraPermission() async {
    await Permission.camera.request();
  }

  static Future<VideoCallStateEnum> checkVideoCallPermission() async {
    final checkVideoCallPermissionResult = await Future.wait([
      checkMicrophonePermission(),
      checkCameraPermission(),
    ]);

    for (int i = 0; i < checkVideoCallPermissionResult.length; i++) {
      switch (i) {
        case 0:
          final microResult = _handleMicrophonePermissonResult(
              checkVideoCallPermissionResult[i]);
          if (microResult != VideoCallStateEnum.granted) {
            return microResult;
          }
          continue;

        case 1:
          final cameraResult =
              _handleCameraPermissonResult(checkVideoCallPermissionResult[i]);
          if (cameraResult != VideoCallStateEnum.granted) {
            return cameraResult;
          }
          continue;
      }
    }

    return VideoCallStateEnum.granted;
  }

  static VideoCallStateEnum _handleMicrophonePermissonResult(
      PermissionStatus permissionStatus) {
    switch (permissionStatus) {
      case PermissionStatus.granted:
        return VideoCallStateEnum.granted;
      case PermissionStatus.permanentlyDenied:
        return VideoCallStateEnum.microphonePermanentlyDenied;
      case PermissionStatus.denied:
        return VideoCallStateEnum.microphoneDenied;
      default:
        return VideoCallStateEnum.microphoneDenied;
    }
  }

  static VideoCallStateEnum _handleCameraPermissonResult(
      PermissionStatus permissionStatus) {
    switch (permissionStatus) {
      case PermissionStatus.granted:
        return VideoCallStateEnum.granted;
      case PermissionStatus.permanentlyDenied:
        return VideoCallStateEnum.cameraPermanentlyDenied;
      case PermissionStatus.denied:
        return VideoCallStateEnum.cameraDenied;
      default:
        return VideoCallStateEnum.cameraDenied;
    }
  }

  static Future<void> requestIgnoreBatteryOptimizationsPermission() async {
    if (!Platform.isAndroid) {
      return;
    }

    //check permission
    final hasPermission = await Permission.ignoreBatteryOptimizations.status ==
        PermissionStatus.granted;
    if (hasPermission) {
      return;
    }

    //Request permission
    await [
      Permission.ignoreBatteryOptimizations,
    ].request();
  }
}

enum ScanStateEnum {
  granted,
  bluetoothDenied,
  bluetoothPermanentlyDenied,
  locationDenied,
  locationPermanentlyDenied,
}

enum VideoCallStateEnum {
  granted,
  microphoneDenied,
  microphonePermanentlyDenied,
  cameraDenied,
  cameraPermanentlyDenied,
}
