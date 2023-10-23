enum AppLifecycleStateEnum {
  // @JsonValue('active')
  active,
  // @JsonValue('inactive')
  inactive;

  String get getValue {
    switch (this) {
      case AppLifecycleStateEnum.active:
        return 'Active';
      case AppLifecycleStateEnum.inactive:
        return 'Inactive';
    }
  }

  static AppLifecycleStateEnum getEnum(String text) {
    switch (text) {
      case 'Active':
        return AppLifecycleStateEnum.active;
      case 'Inactive':
        return AppLifecycleStateEnum.inactive;
      default:
        return AppLifecycleStateEnum.active;
    }
  }

  String toJson() => name;
  static AppLifecycleStateEnum fromJson(String json) => values.byName(json);
}
