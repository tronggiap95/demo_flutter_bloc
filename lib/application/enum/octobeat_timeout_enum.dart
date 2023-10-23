enum OctobeatTimeout {
  scanningTimeOut,
  pairingTimeOut,
  connectSuccessfullyDelay,
  waitingForChangeStatus; // in second

  int get getValue {
    switch (this) {
      case OctobeatTimeout.scanningTimeOut:
        return 60;
      case OctobeatTimeout.pairingTimeOut:
        return 30;
      case OctobeatTimeout.connectSuccessfullyDelay:
        return 3;
      case OctobeatTimeout.waitingForChangeStatus:
        return 30; // in second
    }
  }
}
