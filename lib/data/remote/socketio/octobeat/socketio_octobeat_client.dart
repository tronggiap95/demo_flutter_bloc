import 'dart:async';

import 'package:octo360/application/enum/socket_event.dart';
import 'package:octo360/application/env/env_config.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/data/local/bridge/package/package_manager_plugin.dart';
import 'package:octo360/data/remote/graphql/graphql_header.dart';
import 'package:octo360/data/remote/socketio/socketio_client.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketIOOctoBeatClient extends SocketIOClient {
  Socket? _socketclient;
  bool isConnected = false;
  StreamSocket? _streamSocket;

  @override
  bool isSocketConnected() {
    return isConnected;
  }

  Future<Map<String, String>> _createHeaders() async {
    final defaultversion = await PackageManagerPlugin.getAppVersion();
    final defaultName = HeaderAppName.byPlatfrom();
    final accessToken = await FactoryManager.provideAuthenRepo().getUserToken();

    return {
      'apollographql-client-name': defaultName,
      'apollographql-client-version': defaultversion,
      'accessToken': accessToken,
    };
  }

  Future<Map<String, String>> _getToken() async {
    final accessToken = await FactoryManager.provideAuthenRepo().getUserToken();

    return {
      'accessToken': accessToken,
    };
  }

  @override
  Future<void> connect() async {
    try {
      if (_socketclient != null) return;

      final headers = await _createHeaders();
      final url = EnvConfigApp.getEnv().socketEndpoint;
      _socketclient = io(
          url,
          OptionBuilder()
              .setTransports(['websocket'])
              .setExtraHeaders(headers)
              .setAuthFn((callback) async {
                final token = await _getToken();
                callback.call(token);
              })
              .enableAutoConnect()
              .build());
      _streamSocket = StreamSocket();
      _socketclient?.connect();
      _subscribeSocketEvents();
    } catch (error) {
      Log.e("connect Socket $error");
    }
  }

  @override
  Stream<SocketData>? listenEvents() {
    return _streamSocket?.getResponse;
  }

  @override
  void addEvent(SocketData data) {
    _streamSocket?.addResponse(data);
  }

  @override
  void on(String event, Function(dynamic) handler) {
    _socketclient?.on(event, handler);
  }

  @override
  void off(String event, [dynamic Function(dynamic)? handler]) {
    _socketclient?.off(event, handler);
  }

  @override
  void emit(String event, dynamic data) {
    _socketclient?.emit(event, data);
  }

  @override
  void emitWithAck(String event, dynamic data,
      {Function? ack, bool binary = false}) {
    _socketclient?.emitWithAck(event, data, ack: ack, binary: binary);
  }

  @override
  void disConnect() {
    _socketclient?.clearListeners();
    _socketclient?.disconnect();
    _socketclient = null;
    _streamSocket?.dispose();
    isConnected = false;
  }

  void _subscribeSocketEvents() {
    _socketclient?.onConnect((_) {
      Log.w("onconnect");
      isConnected = true;
      _streamSocket?.addResponse(
          SocketData(event: SocketEvent.connected.name, data: null));
      _joinRoom();
    });

    _socketclient?.onDisconnect((_) {
      Log.w("onDisconnect");
      isConnected = false;
      _streamSocket?.addResponse(
          SocketData(event: SocketEvent.disconnected.name, data: null));
    });
  }

  void _joinRoom() {
    try {
      final patientId = FactoryManager.provideGlobalRepo().userDomain?.id;
      _socketclient?.emit(SocketEvent.joinRoom.name, 'patient-$patientId');
      _streamSocket?.addResponse(
          SocketData(event: SocketEvent.joinRoom.name, data: null));
    } catch (error) {
      Log.e("_sayHelloAndJoinRoom $error");
    }
  }
}
