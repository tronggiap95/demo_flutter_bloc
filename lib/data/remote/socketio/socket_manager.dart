import 'package:flutter/material.dart';
import 'package:octo360/data/di/factory_manager.dart';

class SocketManager {
  static void connectSocket(BuildContext context) async {
    final socket = FactoryManager.provideSocketIO();
    final octoBeatSocket = FactoryManager.provideSocketOctoBeatDevice();

    await socket.connect();
    octoBeatSocket.start();
  }

  static void disposeSocket() {
    final socket = FactoryManager.provideSocketIOOctoBeatClient();
    final octoBeatSocket = FactoryManager.provideSocketOctoBeatDevice();
    socket.disConnect();
    octoBeatSocket.dispose();
  }
}
