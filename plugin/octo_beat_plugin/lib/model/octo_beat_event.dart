enum OctoBeatEvent {
  none,
  updateInfo,
  mctTrigger;

  static OctoBeatEvent from(String value) {
    switch (value) {
      case 'OctoBeat_updateInfo':
        return OctoBeatEvent.updateInfo;
      case 'OctoBeat_mctTrigger':
        return OctoBeatEvent.mctTrigger;
      default:
        return OctoBeatEvent.none;
    }
  }
}
