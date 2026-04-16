import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/services/configuration.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../providers/socket_provider.dart';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  WebSocketChannel? _channel;
  bool _isConnected = false;

  final Map<String, Function(dynamic)> _eventListeners = {};

  SocketManager._internal();

  Future<void> connect(BuildContext context) async {
    if (_isConnected) {
      print("Already connected.");
      return;
    }

    final userData = await CommonFunctions.getUserData();

    final token = userData['tToken'];
    final superUser = userData['superuser'] ?? false;
    final url = '${Configuration.SOCKET_URL}?token=$token&superuser=$superUser';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      print("WebSocket connected to: $url");
      // Send message once the connection is established
      _channel?.sink.add(jsonEncode({
        'event': 'join_msg',
        'data': {
          'token': token,
        },
      }));

      _channel!.stream.listen(
        (message) {
          handleMessage(message, context);
        },
        onError: (error) {
          _isConnected = false;
          // Future.delayed(Duration(seconds: 3), () {
          //   connect(navigatorKey.currentContext!);
          // });
        },
        onDone: () {
          _isConnected = false;
          connect(context);
          // Future.delayed(Duration(seconds: 3), () {
          //   connect(navigatorKey.currentContext!);
          // });
        },
      );
    } catch (e) {
      // print("Failed to connect WebSocket: $e");
    }
  }

  void emit(String event, dynamic data) {
    if (_isConnected && _channel != null) {
      final message = jsonEncode({'event': event, 'data': data});
      _channel!.sink.add(message);
    } else {
      print("Socket not connected. Event '$event' not sent.");
    }
  }

  void on(String event, Function(dynamic) callback) {
    _eventListeners[event] = callback;
  }

  void handleMessage(dynamic message, BuildContext context) {
    debugPrint("Raw message received:---- $message", wrapWidth: 1024);
    try {
      final decoded = jsonDecode(message);
      final event = decoded['event'];
      final data = decoded['data'];
      final socketProvider = context.read<SocketProvider>();
      socketProvider.setReceiveSocketEventData(decoded);
      SocketMessageEvents.logout(context);
      SocketMessageEvents.deleteUserMsgsSocketEvent(decoded, context);
      SocketMessageEvents.addUserNewMsgsSocketEvent(decoded, context);
      SocketMessageEvents.updateUserMsgsSocketEvent(decoded, context);
      SocketMessageEvents.addNewSendMsgsSocketEvent(decoded, context);
      SocketMessageEvents.refreshAllList(decoded, context);
      SocketMessageEvents.readSuccessUserMsg(decoded, context);
      SocketMessageEvents.receiverTypingSetupListener(decoded, context);

      if (_eventListeners.containsKey(event)) {
        _eventListeners[event]!(data);
        _eventListeners[event];
      }
    } catch (e) {
      // print("Failed to decode message: $e");
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    // print("WebSocket disconnected.");
  }

  bool get isConnected => _isConnected;
}
