import 'dart:async';

import 'package:octo360/application/enum/socket_event.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/remote/socketio/socketio_client.dart';

enum OctoBeatDeviceEvent {
  studyEvent,
  deviceEvent;

  String get name {
    switch (this) {
      case OctoBeatDeviceEvent.studyEvent:
        return 'studyEvent';
      case OctoBeatDeviceEvent.deviceEvent:
        return 'deviceEvent';
      default:
        return '';
    }
  }

  static OctoBeatDeviceEvent? from(String event) {
    switch (event) {
      case 'studyEvent':
        return OctoBeatDeviceEvent.studyEvent;
      case 'deviceEvent':
        return OctoBeatDeviceEvent.deviceEvent;
      default:
        return null;
    }
  }
}

abstract class SocketOctoBeatDevice {
  void start();
  void dispose();
  Stream<SocketData>? listenEvents();
}

class SocketOctoBeatDeviceHandler extends SocketOctoBeatDevice {
  final SocketIOClient socketClient;
  StreamSubscription<SocketData>? _streamSubscription;
  StreamSocket? _streamSocket;
  bool _isSubscribed = false;

  SocketOctoBeatDeviceHandler({
    required this.socketClient,
  });

  @override
  void start() {
    _streamSocket = StreamSocket();
    _streamSubscription = socketClient.listenEvents()?.listen((data) {
      final event = SocketEvent.from(data.event);
      if (event == null) return;
      switch (event) {
        case SocketEvent.joinRoom:
          _subscribeAndJoinRoom();
          break;
        case SocketEvent.disconnected:
          _unsubscribeEvents();
          break;
        default:
      }
    });
  }

  @override
  Stream<SocketData>? listenEvents() {
    return _streamSocket?.getResponse;
  }

  @override
  void dispose() {
    _unsubscribeEvents();

    _streamSubscription?.cancel();
    _streamSocket?.dispose();
  }

  void _subscribeAndJoinRoom() async {
    try {
      if (_isSubscribed) {
        return;
      }

      //****************** NOTIFY IF A NEW STUDY STARTED ************************** */
      socketClient.on(OctoBeatDeviceEvent.studyEvent.name, (data) {
        final socketData =
            SocketData(event: OctoBeatDeviceEvent.studyEvent.name, data: data);
        _streamSocket?.addResponse(socketData);
      });

      //****************** NOTIFY IF DEVICE CHANGED STATUS ************************** */
      socketClient.on(OctoBeatDeviceEvent.deviceEvent.name, (data) {
        final socketData =
            SocketData(event: OctoBeatDeviceEvent.deviceEvent.name, data: data);
        _streamSocket?.addResponse(socketData);
      });

      _isSubscribed = true;
    } catch (error) {
      Log.e("_subscribeAndJoinRoom $error");
    }
  }

  void _unsubscribeEvents() {
    _isSubscribed = false;
    socketClient.off(OctoBeatDeviceEvent.studyEvent.name);
    socketClient.off(OctoBeatDeviceEvent.deviceEvent.name);
  }
}
