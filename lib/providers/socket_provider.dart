import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'chat_provider.dart';

class SocketProvider with ChangeNotifier {
  final Map<String, dynamic> _eventData = {};
  Map<String, dynamic> _socketReceiveEventData = {};

  Map<String, dynamic> get socketReceiveEventData => _socketReceiveEventData;

  /// Get data for a specific socket event
  dynamic getEventData(String event) => _eventData[event];

  /// Set data for a specific socket event
  void setEventData(String event, dynamic data) {
    _eventData[event] = data;
    notifyListeners();
  }

  void addIncomingMessage(Map<String, dynamic> message, BuildContext context) {
    // final chatProvider = context.watch<ChatProvider>();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final messages = chatProvider.messages;
    messages.add(message);
    notifyListeners();
  }

  /// Optional: clear event data
  void clearEventData(String event) {
    _eventData.remove(event);
    notifyListeners();
  }

  /// Optional: reset all
  void clearAllEvents() {
    _eventData.clear();
    notifyListeners();
  }

  // ***************** receive socket event data ******************
  void setReceiveSocketEventData(Map<String, dynamic> newData) {
    _socketReceiveEventData = Map<String, dynamic>.from(newData);
    notifyListeners();
  }

  void clearReceiveSocketEventData() {
    _socketReceiveEventData = {};
    notifyListeners();
  }
}
