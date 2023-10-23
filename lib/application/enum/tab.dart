enum TabIndex {
  home,
  profile;

  int get getValue {
    switch (this) {
      case TabIndex.home:
        return 0;
      case TabIndex.profile:
        return 1;
    }
  }

  static TabIndex fromIndex(int index) {
    switch (index) {
      case 0:
        return TabIndex.home;
      case 4:
        return TabIndex.profile;
      default:
        return TabIndex.home;
    }
  }
}
