import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/socket/socket_manager.dart';
import '../main.dart';

class AppLifecycleReactor with WidgetsBindingObserver {
  final SocketManager socketManager = SocketManager();

  // Start observing lifecycle events after socket is connected
  void startObserving(BuildContext context) async {
    await socketManager.connect(context); // Ensure socket is connected
    WidgetsBinding.instance.addObserver(this); // Now start observing
  }

  // Stop observing lifecycle events
  void stopObserving() {
    WidgetsBinding.instance.removeObserver(this);
  }

  void callApiForOpenChat() async {
    final chatProvider = navigatorKey.currentContext!.read<ChatProvider>();
    final dataListProvider =
        navigatorKey.currentContext!.read<DataListProvider>();
    if (chatProvider.isUserChatOpen &&
        dataListProvider.openedChatUserData.isNotEmpty) {
      final response = await CommonFunctions.getUserList();
      final sortedData = CommonFunctions.sortListByTime(response);
      dataListProvider.setChatList(sortedData);

      final msgListResponse = await CommonFunctions.getUserMessages(
          dataListProvider.openedChatUserData['_id'], "");
      fetchUserMessages(msgListResponse, dataListProvider);
    }

    if (chatProvider.isGroupChatOpen &&
        dataListProvider.openedChatGroupData.isNotEmpty) {
      final response = await CommonFunctions.getGroupList();
      final sortedData = CommonFunctions.sortListByTime(response);
      dataListProvider.setGroupList(sortedData);

      final currentLoginUser = await CommonFunctions.getLoginUser();
      final isAdmin = currentLoginUser['iUserId'] ==
              dataListProvider.openedChatGroupData['_id']
          ? 1
          : 0;

      final msgListResponse = await CommonFunctions.getGroupMessages(
          dataListProvider.openedChatGroupData['_id'], isAdmin, "");
      dataListProvider.setGroupMessageAllData(msgListResponse);
      fetchGroupMessages(msgListResponse, dataListProvider);
    }
  }

  void fetchUserMessages(
      dynamic userMsgs, DataListProvider dataListProvider) async {
    try {
      if (userMsgs['data'] != null) {
        if (userMsgs['data'] is String) {
          try {
            // debugPrint("userMsgs $userMsgs", wrapWidth: 1024);
            dataListProvider.setUserMessageList(jsonDecode(userMsgs['data']));
            // handleUserMsgData(jsonDecode(userMsgs['data']));
          } catch (e) {
            // print('Failed to parse user message data: $e');
            dataListProvider.clearUserMessageList();
          }
        } else if (userMsgs['data'] is List) {
          dataListProvider.setUserMessageList(userMsgs['data']);
        }
      }
      // print("dataaaaaaaaaaaaaaaa ${dataListProvider.groupMessagesList}");
    } catch (error) {
      // print("Error while fetching user messages $error");
    }
  }

  void fetchGroupMessages(
      dynamic groupMsgs, DataListProvider dataListProvider) async {
    try {
      if (groupMsgs['data'] != null) {
        if (groupMsgs['data'] is String) {
          try {
            dataListProvider.setGroupMessageList(jsonDecode(groupMsgs['data']));
          } catch (e) {
            // print('Failed to parse message data: $e');
            dataListProvider.clearGroupMessageList();
          }
        } else if (groupMsgs['data'] is List) {
          dataListProvider.setGroupMessageList(groupMsgs['data']);
        }
      }
      // print("dataaaaaaaaaaaaaaaa ${dataListProvider.groupMessagesList}");
    } catch (error) {
      // print("Error while fetching user messages $error");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // print("App is in the foreground (resumed)");
        // Reconnect socket when app comes to the foreground
        socketManager.connect(navigatorKey.currentContext!);
        callApiForOpenChat();
        break;

      case AppLifecycleState.inactive:
        // print("App is inactive (e.g., incoming call, dialog, etc.)");
        socketManager.connect(
            navigatorKey.currentContext!); // Temporarily disconnect socket
        break;

      case AppLifecycleState.paused:
        // print("App is paused (background state)");
        // Disconnect socket when app goes to the background
        // socketManager.disconnect();
        socketManager.connect(navigatorKey.currentContext!);
        break;

      case AppLifecycleState.hidden: // For Android 14+ (hidden state)
        // print("App is hidden (app is in the background and about to be terminated)");
        // socketManager.disconnect();
        socketManager.connect(navigatorKey.currentContext!);
        break;

      case AppLifecycleState.detached:
        // print("App is detached (app is about to be terminated)");
        socketManager.connect(navigatorKey.currentContext!);
        // socketManager.disconnect();
        break;
    }
  }
}
