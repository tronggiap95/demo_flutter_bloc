enum OctoConnectionEvent {
  foundDevice,
  connectSuccess,
  connectFailed;

  static OctoConnectionEvent? from(String value) {
    switch (value) {
      case 'foundDevice':
        return OctoConnectionEvent.foundDevice;
      case 'connectSuccess':
        return OctoConnectionEvent.connectSuccess;
      case 'connectFailed':
        return OctoConnectionEvent.connectFailed;
      default:
        return null;
    }
  }
}
