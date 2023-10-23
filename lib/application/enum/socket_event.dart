enum SocketEvent {
  connected,
  disconnected,
  hello,
  joinRoom;

  String get name {
    switch (this) {
      case SocketEvent.connected:
        return 'connected';
      case SocketEvent.disconnected:
        return 'disconnected';
      case SocketEvent.hello:
        return 'hello';
      case SocketEvent.joinRoom:
        return 'room';
    }
  }

  static SocketEvent? from(String name) {
    switch (name) {
      case 'connected':
        return SocketEvent.connected;
      case 'disconnected':
        return SocketEvent.disconnected;
      case 'room':
        return SocketEvent.joinRoom;
      case 'hello':
        return SocketEvent.hello;
      default:
        return null;
    }
  }
}
