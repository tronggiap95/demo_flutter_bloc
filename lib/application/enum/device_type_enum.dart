enum DeviceSupportEnum {
  userManual,
  troubleshooting,
  contactSupport,
}

enum DeviceTypeEnum {
  octoBeat;

  static DeviceTypeEnum? from(String? value) {
    switch (value) {
      case 'Octobeat':
        return DeviceTypeEnum.octoBeat;
    }
    return null;
  }
}
