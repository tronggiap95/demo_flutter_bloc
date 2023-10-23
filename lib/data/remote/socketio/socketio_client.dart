import 'dart:async';

class SocketData {
  final String event;
  final dynamic data;

  SocketData({
    required this.event,
    required this.data,
  });
}

abstract class SocketIOClient {
  Future<void> connect();
  void disConnect();
  bool isSocketConnected();

  void on(String event, Function(dynamic) handler);
  void off(String event, [dynamic Function(dynamic)? handler]);

  void emit(String event, dynamic data);
  void emitWithAck(String event, dynamic data,
      {Function? ack, bool binary = false});

  void addEvent(SocketData data);
  Stream<SocketData>? listenEvents();
}

class StreamSocket {
  final _socketResponse = StreamController<SocketData>.broadcast();

  void Function(SocketData) get addResponse => _socketResponse.sink.add;

  Stream<SocketData> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
