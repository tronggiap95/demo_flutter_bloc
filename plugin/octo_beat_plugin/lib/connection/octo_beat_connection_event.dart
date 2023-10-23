enum OctoBeatConnectionEvent {
  foundDevice,
  connectSuccess,
  connectFailed;

  static OctoBeatConnectionEvent? from(String value) {
    switch (value) {
      case 'foundDevice':
        return OctoBeatConnectionEvent.foundDevice;
      case 'connectSuccess':
        return OctoBeatConnectionEvent.connectSuccess;
      case 'connectFailed':
        return OctoBeatConnectionEvent.connectFailed;
      default:
        return null;
    }
  }
}
