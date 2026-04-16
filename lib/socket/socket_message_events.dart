import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/providers/socket_provider.dart';
import 'package:spot/socket/socket_manager.dart';

class SocketMessageEvents {
  static final SocketManager socket = SocketManager();

  static void groupTypingSetupListener(BuildContext context) {
    final socketProvider = context.read<SocketProvider>();
    socket.on("MessageTypingGroupStart", (data) {
      socketProvider.setEventData("MessageTypingStart", data);

      // Optional: clear after delay
      Future.delayed(const Duration(seconds: 1), () {
        socketProvider.clearEventData("MessageTypingStart");
      });
    });

    socket.on("MessageTypingGroupEnd", (data) {
      socketProvider.clearEventData("MessageTypingStart");
    });
  }

  static void logout(BuildContext context) async {
    final socketProvider = context.read<SocketProvider>();
    if (socketProvider.socketReceiveEventData['event'] == 'receive_message') {
      if (socketProvider.socketReceiveEventData['data'] != null &&
          socketProvider.socketReceiveEventData['data']['type'] != null &&
          socketProvider.socketReceiveEventData['data']['type'] == 'logout') {
        // print("SocketProvider logout========== ${socketProvider.socketReceiveEventData}");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // print("================User Logout SuccessFully====================");
        prefs.clear();
        // Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (Route<dynamic> route) => false);
        }
        socketProvider.clearReceiveSocketEventData();
        SocketManager socketManager = SocketManager();
        socketManager.disconnect();
      }
    }
  }

  static void sendMessageEvent(
      {required String receiverChatID,
      required String senderChatID,
      required String content,
      List? imageDataArr,
      required String vReplyMsg,
      required String vReplyMsgId,
      required String vReplyFileName,
      required String id,
      required int iRequestMsg,
      required int isForwardMsg,
      required String isForwardMsgId,
      required int isDeleteprofile,
      int? isFileUpload,
      int? communicationType,
      int? chat,
      int? contentType}) {
    final data = {
      "receiverChatID": receiverChatID,
      "senderChatID": senderChatID,
      "content": content,
      "ImageDataArr": imageDataArr,
      "vReplyMsg": vReplyMsg,
      "vReplyMsg_id": vReplyMsgId,
      "vReplyFileName": vReplyFileName,
      "id": id,
      "iRequestMsg": iRequestMsg,
      "isForwardMsg": isForwardMsg,
      "isForwardMsg_id": isForwardMsgId,
      "isDeleteprofile": isDeleteprofile,
      // "isFileUpload": isFileUpload,
    };

    // if (fileType != null) {
    //   data["fileType"] = fileType;
    // }

    if (communicationType != null) {
      data["communicationType"] = communicationType;
    }

    if (contentType != null) {
      data["contentType"] = contentType;
    }

    if (chat != null) {
      data["chat"] = chat;
    }

    socket.emit("send_message", data);
  }

  static void sendGroupMessageEvent({
    required String receiverChatID,
    required String senderChatID,
    required String content,
    String? vReplyFileName,
    required String vReplyMsg,
    required String vReplyMsgId,
    required String id,
    required int isGreetingMsg,
    String? vGroupMessageType,
    required int isForwardMsg,
    String? isForwardMsgId,
    // required String isForwardMsg_id,
    required int isDeleteprofile,
    required int iRequestMsg,
    required String vDeleteMemberId,
    required String vNewAdminId,
    required String requestMemberId,
    int? chat,
    required List vMembersList,
    List? imageDataArr,
    int? isFileUpload,
  }) {
    final data = {
      "receiverChatID": receiverChatID,
      "senderChatID": senderChatID,
      "content": content,
      "vReplyMsg": vReplyMsg,
      "vReplyMsg_id": vReplyMsgId,
      "id": id,
      "isGreetingMsg": isGreetingMsg,
      "isForwardMsg": isForwardMsg,
      "isDeleteprofile": isDeleteprofile,
      "iRequestMsg": iRequestMsg,
      "vDeleteMemberId": vDeleteMemberId,
      "vNewAdminId": vNewAdminId,
      "RequestMemberId": requestMemberId,
      "vMembersList": vMembersList,
      "ImageDataArr": imageDataArr,
    };
    if (isFileUpload != null) {
      data["isFileUpload"] = isFileUpload;
    }

    if (isForwardMsgId != null) {
      data["isForwardMsg_id"] = isForwardMsgId;
    }

    if (vGroupMessageType != null) {
      data["vGroupMessageType"] = vGroupMessageType;
    }

    if (chat != null) {
      data["chat"] = chat;
    }

    if (vReplyFileName != null) {
      data["vReplyFileName"] = vReplyFileName;
    }

    socket.emit("send_grp_message", data);
  }

  // ******************* All User Get My New Sts *********************
  static void allUsersGetNewSts(String tToken, String vUsers) {
    socket.emit("AllUserGetMyNewSts", {
      "tToken": tToken,
      "vUsers": vUsers,
    });
  }

  //******************** user logout status ******************
  static void logOutStatus(String iLoginId, int iStatus) {
    print("Logout emit ");
    socket.emit("logout", {"iLoggedId": iLoginId, "iStatus": iStatus});
  }

  // **************** read message socket *****************
  static void listenForReadUpdate(BuildContext context) async {
    final dataListProvider = context.read<DataListProvider>();
    final currentUser = await CommonFunctions.getLoginUser();
    SocketManager socketManager = SocketManager();
    final postData = {
      "iFromUserId": currentUser['iUserId'],
      "iToUserId": dataListProvider.openedChatUserData['iUserId']
    };
    if (dataListProvider.openedChatUserData['iTotalUnReadMsg'] > 0) {
      socketManager.emit("messageReadUpdate", postData);
    }
    final response = await CommonFunctions.getUserList();
    final sortedList = CommonFunctions.sortListByTime(response);
    dataListProvider.setChatList(sortedList);
  }

  //   *********************** delete user msgs ************************
  static void deleteUserMsgsSocketEvent(
      Map<String, dynamic> socketEventData, BuildContext context) {
    try {
      final dataListProvider = context.read<DataListProvider>();
      // print("socketEventData $socketEventData" );

      // *************** delete user msgs *******************
      if (socketEventData['event'] == 'receive_message') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'DeleteMessage') {
          final replacedDeletedData = CommonFunctions.replaceMatchingItemsById(
              originalList: dataListProvider.userMessagesList,
              updatedList: socketData['fullMessageData'],
              context: context);
          // debugPrint("replacedDeletedData $replacedDeletedData", wrapWidth: 1024);
          dataListProvider.setUserMessageList(replacedDeletedData);
        }
      }

      // *************** delete group msgs *******************
      if (socketEventData['event'] == 'receive_grp_message') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'DeleteMessage') {
          final replacedDeletedData = CommonFunctions.replaceMatchingItemsById(
              originalList: dataListProvider.groupMessagesList,
              updatedList: socketData['fullMessageData'],
              context: context);
          dataListProvider.setGroupMessageList(replacedDeletedData);
        }
      }
    } catch (error) {
      // print("Error while deleting user msgs socket event $error");
    }
  }

  //   *********************** add new msgs socket event ************************
  static void addUserNewMsgsSocketEvent(
      Map<String, dynamic> socketEventData, BuildContext context) async {
    final dataListProvider = context.read<DataListProvider>();
    final chatProvider = context.read<ChatProvider>();
    try {
      // print("socketEventData $socketEventData" );

      // *************** add user msgs *******************
      if (socketEventData['event'] == 'receive_message') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'newMessage') {
          if (chatProvider.isUserChatOpen &&
              socketData['iSenderId'] ==
                  dataListProvider.openedChatUserData['iUserId']) {
            final addNewMsgData = CommonFunctions.addNewMsgInList(
                originalList: dataListProvider.userMessagesList,
                updatedList: socketData['fullMessageData'],
                context: context);
            dataListProvider.setUserMessageList(addNewMsgData);
            chatProvider.shouldScrollToBottom = true;
          }

          // ***************** refresh all user chats if user does exist in list ********************
          final checkIsUserExist = dataListProvider.chatsData.where((item) {
            return item['iUserId'] == socketData['iSenderId'];
          }).toList();

          if (checkIsUserExist.isEmpty) {
            final response = await CommonFunctions.getUserList();
            final sortedData = CommonFunctions.sortListByTime(response);
            dataListProvider.setChatList(sortedData);
          } else {
            // ******************** if chat is open then remove flag from list ************************
            if (chatProvider.isUserChatOpen &&
                dataListProvider.openedChatUserData.isNotEmpty) {
              listenForReadUpdate(context);
              chatProvider.setShowTabUserDotIndication(false);
            } else {
              // ******************** if chat is not open then add flag from list ************************
              if (chatProvider.activeTab != 0) {
                chatProvider.setShowTabUserDotIndication(true);
              } else {
                chatProvider.setShowTabUserDotIndication(false);
              }

              var updatedData = <Map<String, dynamic>>[];
              Map<String, dynamic>? updatedItem;

              for (var item in dataListProvider.chatsData) {
                if (item['iUserId'] == socketData['iSenderId']) {
                  updatedItem = Map<String, dynamic>.from(item);
                  updatedItem['iTotalUnReadMsg'] = 1;
                } else {
                  updatedData.add(item);
                }
              }
              if (updatedItem != null) {
                updatedData.insert(0, updatedItem);
              }
              dataListProvider.setChatList(updatedData);
            }
          }

          // ****************** check for request ********************
          if (socketData['iRequestMsg'] == 1 ||
              socketData['iRequestMsg'] == 2 ||
              socketData['iRequestMsg'] == 3 ||
              socketData['iRequestMsg'] == 4 ||
              socketData['iRequestMsg'] == 5) {
            // print("socketData['UserData']['iUserId'] ${socketData['UserData']['iUserId']}");
            final data = await CommonFunctions.getSingleUser(
                dataListProvider.openedChatUserData['iUserId']);
            dataListProvider.setOpenedChatUserData(data);
          }
        }
      }

      // *************** delete group msgs *******************
      if (socketEventData['event'] == 'receive_grp_message') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'newMessage') {
          if (socketData['iGroupSenderId'] ==
              dataListProvider.openedChatGroupData['_id']) {
            final addNewMessage = CommonFunctions.addNewMsgInList(
                originalList: dataListProvider.groupMessagesList,
                updatedList: socketData['fullMessageData'],
                context: context);
            dataListProvider.setGroupMessageList(addNewMessage);
            chatProvider.shouldScrollToBottom = true;
          }

          // ***************** refresh all user chats if user does exist in list ********************
          final checkIsGroupExist = dataListProvider.groupsData.where((item) {
            return item['_id'] == socketData['iGroupSenderId'];
          }).toList();

          if (checkIsGroupExist.isEmpty) {
            final response = await CommonFunctions.getGroupList();
            final sortedData = CommonFunctions.sortListByTime(response);
            dataListProvider.setGroupList(sortedData);
          } else {
            if (!chatProvider.isGroupChatOpen) {
              // ******************** if chat is not open then add flag to list ************************
              var updatedData = <Map<String, dynamic>>[];
              Map<String, dynamic>? updatedItem;

              for (var item in dataListProvider.groupsData) {
                if (item['_id'] == socketData['iGroupSenderId']) {
                  updatedItem = Map<String, dynamic>.from(item);
                  updatedItem['iTotalUnReadMsg'] = 1;
                } else {
                  updatedData.add(item);
                }
              }
              if (updatedItem != null) {
                updatedData.insert(0, updatedItem);
              }
              dataListProvider.setGroupList(updatedData);

              if (chatProvider.activeTab != 1) {
                chatProvider.setShowTabGroupDotIndication(true);
              } else {
                chatProvider.setShowTabGroupDotIndication(false);
              }
            } else {
              chatProvider.setShowTabGroupDotIndication(false);
            }
          }
        }
      }
    } catch (error) {
      // print("Error while adding user msgs socket event $error");
    }
  }

  //   *********************** update user msgs ************************
  static void updateUserMsgsSocketEvent(
      Map<String, dynamic> socketEventData, BuildContext context) {
    try {
      final dataListProvider = context.read<DataListProvider>();
      // print("socketEventData $socketEventData" );

      // *************** delete user msgs *******************
      if (socketEventData['event'] == 'receive_message') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'UpdateMessage') {
          final replacedDeletedData = CommonFunctions.replaceMatchingItemsById(
              originalList: dataListProvider.userMessagesList,
              updatedList: socketData['fullMessageData'],
              context: context);
          // debugPrint("replacedDeletedData $replacedDeletedData", wrapWidth: 1024);
          dataListProvider.setUserMessageList(replacedDeletedData);
        }
      }

      // *************** delete group msgs *******************
      if (socketEventData['event'] == 'receive_grp_message') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'UpdateMessage') {
          final replacedDeletedData = CommonFunctions.replaceMatchingItemsById(
              originalList: dataListProvider.groupMessagesList,
              updatedList: socketData['fullMessageData'],
              context: context);
          // debugPrint("replacedDeletedData $replacedDeletedData", wrapWidth: 1024);
          dataListProvider.setGroupMessageList(replacedDeletedData);
        }
      }
    } catch (error) {
      // print("Error while updating user msgs socket event $error");
    }
  }

  //   *********************** add new sender msgs socket event ************************
  static void addNewSendMsgsSocketEvent(
      Map<String, dynamic> socketEventData, BuildContext context) async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final chatProvider = context.read<ChatProvider>();
      // *************** delete user msgs *******************
      if (socketEventData['event'] == 'receive_message_sender') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'newMessage') {
          final addNewMsgData = CommonFunctions.addNewMsgInList(
              originalList: dataListProvider.userMessagesList,
              updatedList: socketData['fullMessageData'],
              context: context);

          // dataListProvider.setUserMessageList(addNewMsgData);
          // debugPrint("chatProvider.isUserChatOpen ${chatProvider.isUserChatOpen} =============dataListProvider.openedChatUserData['iUserId'] ${dataListProvider.openedChatUserData['iUserId']} =================== socketData['iSenderId'] ${socketData['iSenderId']}", wrapWidth: 1024);
          if (chatProvider.isUserChatOpen &&
              socketData['iSenderId'] ==
                  dataListProvider.openedChatUserData['iUserId']) {
            // debugPrint("callll");
            if (addNewMsgData.isNotEmpty) {
              var updatedData = <Map<String, dynamic>>[];
              Map<String, dynamic>? updatedItem;
              for (var item in addNewMsgData) {
                updatedItem = Map<String, dynamic>.from(item);
                updatedItem['iReadTo'] = 1;
                updatedData.add(updatedItem);
              }

              // debugPrint("updatedData $updatedData", wrapWidth: 1024);
              dataListProvider.setUserMessageList(updatedData);
            }
          } else {
            dataListProvider.setUserMessageList(addNewMsgData);
            chatProvider.shouldScrollToBottom = true;
          }

          // debugPrint("socketData['iRequestMsg'] ${socketData['iRequestMsg']}", wrapWidth: 1024);
          if (socketData['iRequestMsg'] == 1 ||
              socketData['iRequestMsg'] == 2 ||
              socketData['iRequestMsg'] == 3 ||
              socketData['iRequestMsg'] == 4 ||
              socketData['iRequestMsg'] == 5) {
            // print("iffffffffffffff");
            final dataListProvider = context.read<DataListProvider>();
            // print("socketData['UserData']['iUserId'] ${socketData['UserData']['iUserId']}");

            final data = await CommonFunctions.getSingleUser(
                dataListProvider.openedChatUserData['iUserId']);
            // print("iRequest ${data['iRequestMsg']}");

            dataListProvider.setOpenedChatUserData(data);
            // debugPrint("dataaaaaaaaaaaaaaaa ${dataListProvider.openedChatUserData}", wrapWidth: 1024);
          }
        }
      }

      // *************** delete group msgs *******************
      if (socketEventData['event'] == 'receive_grp_message_sender') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'newMessage') {
          final replacedDeletedData = CommonFunctions.addNewMsgInList(
              originalList: dataListProvider.groupMessagesList,
              updatedList: socketData['fullMessageData'],
              context: context);
          // debugPrint("addNewMsgData addNewMsgData", wrapWidth: 1024);
          dataListProvider.setGroupMessageList(replacedDeletedData);
          chatProvider.shouldScrollToBottom = true;
        }
      }
    } catch (error) {
      // print("Error while adding new sent msg socket event $error");
    }
  }

  static void refreshAllList(
      Map<String, dynamic> socketEventData, BuildContext context) async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final chatProvider = context.read<ChatProvider>();
      // print("socketEventData $socketEventData" );

      // ****************** Refrash user all data ********************
      if (socketEventData['event'] == 'receive_message') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'RefreshUserList') {
          if (socketData['UserData'] != null &&
              socketData['UserData'].isNotEmpty) {
            if (socketData['UserData']['iUserId'] != null) {
              String userId = socketData['UserData']['iUserId'];

              // **************** refresh chat list users *******************
              if (dataListProvider.chatsData.isNotEmpty) {
                final chatsData = dataListProvider.chatsData;
                // debugPrint("chatsData $chatsData", wrapWidth: 1024);
                // print("userId $userId");
                int index =
                    chatsData.indexWhere((chat) => chat['iUserId'] == userId);
                if (index != -1) {
                  chatsData[index] = socketData['UserData'];
                  // final sortedData = CommonFunctions.sortListByTime(chatsData);
                  dataListProvider.setChatList(chatsData);
                }
              }

              // **************** refresh user data *******************
              if (dataListProvider.openedChatUserData.isNotEmpty) {
                Map<String, dynamic> openChatUserData =
                    dataListProvider.openedChatUserData;
                if (openChatUserData['iUserId'] == userId) {
                  socketData['UserData'].forEach((key, value) {
                    openChatUserData[key] = value;
                  });
                  dataListProvider.setOpenedChatUserData(openChatUserData);
                }
              }
            }
          } else {
            final response = await CommonFunctions.getUserList();
            dataListProvider.setChatList(response);

            if (chatProvider.isUserChatOpen) {
              // **************** refresh user data *******************
              if (dataListProvider.openedChatUserData.isNotEmpty) {
                Map<String, dynamic> openChatUserData =
                    dataListProvider.openedChatUserData;
                final singleUserData = await CommonFunctions.getSingleUser(
                    openChatUserData['iUserId']);
                dataListProvider.setOpenedChatUserData(singleUserData);
              }
            }
          }
        }
      }

      // ****************** Refrash group all data ********************
      if (socketEventData['event'] == 'receive_message') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'refreshGroupList') {
          dataListProvider.getGroupListData();
        }
      }

      if (socketEventData['event'] == 'receive_grp_message') {
        final socketData = socketEventData['data'];
        if (socketData != null && socketData['type'] == 'refreshGroup') {
          dataListProvider.getGroupListData();
          if (socketData['vActiveGroupId'] ==
              dataListProvider.openedChatGroupData['_id']) {
            // print("dataListProvider.openedChatGroupData['_id'] ----------------- ${dataListProvider.openedChatGroupData['_id']}");
            // debugPrint("socketData['vActiveGroupId']======== ${socketData['vActiveGroupId']}");
            final groupInfoData = await CommonFunctions.getGroupInfoData(
                socketData['vActiveGroupId']);
            // debugPrint("groupInfoData-------------------- $groupInfoData", wrapWidth: 1024);
            dataListProvider.setGroupInfoData(groupInfoData['data']);

            // debugPrint("dataListProvider---------------- ${dataListProvider.groupInfoData}", wrapWidth: 1024);
            dataListProvider.setOpenedChatGroupData(groupInfoData['data']);

            final currentLoginUser = await CommonFunctions.getLoginUser();
            final isAdmin = currentLoginUser['iUserId'] ==
                    dataListProvider.openedChatGroupData['_id']
                ? 1
                : 0;
            final groupMsgs = await CommonFunctions.getGroupMessages(
                dataListProvider.openedChatGroupData['_id'], isAdmin, "");
            dataListProvider.setGroupMessageAllData(groupMsgs);

            if (groupMsgs['data'] != null) {
              if (groupMsgs['data'] is String) {
                try {
                  dataListProvider
                      .setGroupMessageList(jsonDecode(groupMsgs['data']));
                } catch (e) {
                  // print('Failed to parse message data: $e');
                  dataListProvider.clearGroupMessageList();
                }
              } else if (groupMsgs['data'] is List) {
                dataListProvider.setGroupMessageList(groupMsgs['data']);
              }
            }
          }
        }
      }
    } catch (error) {
      // print("Error while refrashing all list $error");
    }
  }

  static void groupRefreshUpdate(
      Map<String, dynamic> socketEventData, BuildContext context) async {
    try {
      if (socketEventData['event'] == 'GroupRefreshUpdate') {}
    } catch (error) {
      // print("Error while refrashing all group list $error");
    }
  }

  static void readSuccessUserMsg(
      Map<String, dynamic> socketEventData, BuildContext context) {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final chatProvider = context.read<ChatProvider>();
      if (socketEventData['event'] == 'readSuccessMsg') {
        final socketData = socketEventData['data'];
        if (chatProvider.isUserChatOpen &&
            socketData['iFromUserId'] ==
                dataListProvider.openedChatUserData['iUserId']) {
          if (dataListProvider.userMessagesList.isNotEmpty) {
            var updatedData = <Map<String, dynamic>>[];
            Map<String, dynamic>? updatedItem;
            for (var item in dataListProvider.userMessagesList) {
              updatedItem = Map<String, dynamic>.from(item);
              updatedItem['iReadTo'] = 1;
              updatedData.add(updatedItem);
            }
            dataListProvider.setUserMessageList(updatedData);
          }
        }
      }
    } catch (error) {
      // print("Error while read user messsage $error");
    }
  }

  static void receiverTypingSetupListener(
      Map<String, dynamic> socketEventData, BuildContext context) async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final chatProvider = context.read<ChatProvider>();
      final currentUser = await CommonFunctions.getLoginUser();

      // *************** show typing in user chats ***********************
      if (socketEventData['event'] == 'MessageTypingStart') {
        final socketData = socketEventData['data'];
        if (chatProvider.isUserChatOpen &&
            socketData['iFromUserId'] ==
                dataListProvider.openedChatUserData['iUserId'] &&
            socketData['iToUserId'] == currentUser['iUserId']) {
          chatProvider.setIsShowUserTyping(true);
          // Hide typing after 2 seconds
          Future.delayed(Duration(seconds: 2), () {
            chatProvider.setIsShowUserTyping(false);
          });
        }
      }

      if (socketEventData['event'] == 'MessageTypingEnd') {
        final socketData = socketEventData['data'];
        if (socketData['iFromUserId'] ==
                dataListProvider.openedChatUserData['iUserId'] &&
            socketData['iFromUserId'] == currentUser['iUserId']) {
          chatProvider.setIsShowUserTyping(false);
        }
      }

      // *************** show typing in group chats ***********************
      // if (socketEventData['event'] == 'MessageTypingGroupStart') {
      //   final socketData = socketEventData['data'];
      //   // debugPrint("dataListProvider.openedChatGroupData ${dataListProvider.openedChatGroupData}", wrapWidth: 1024);
      //   // print("object ${chatProvider.isGroupChatOpen} ${socketData['iFromUserId']} ${dataListProvider.openedChatGroupData['_id']} ${socketData['iToUserId']} ${currentUser['iUserId']}");
      //   if(chatProvider.isGroupChatOpen && socketData['iToUserId'] == dataListProvider.openedChatGroupData['_id']){
      //     chatProvider.setIsShowGroupTyping(true);
      //
      //     // Hide typing
      //     // after 2 seconds
      //     Future.delayed(Duration(seconds: 2), () {
      //       chatProvider.setIsShowGroupTyping(false);
      //     });
      //   }
      // }
      //
      // if (socketEventData['event'] == 'MessageTypingGroupEnd') {
      //   final socketData = socketEventData['data'];
      //   if(chatProvider.isGroupChatOpen && socketData['iToUserId'] == dataListProvider.openedChatGroupData['_id']){
      //     chatProvider.setIsShowGroupTyping(false);
      //   }
      // }
      if (socketEventData['event'] == 'MessageTypingGroupStart') {
        final socketData = socketEventData['data'];
        final groupId = socketData['iToUserId'];
        final fromUserName = socketData['name'];

        if (chatProvider.isGroupChatOpen &&
            groupId == dataListProvider.openedChatGroupData['_id']) {
          chatProvider.addTypingUser(groupId, fromUserName);
          chatProvider.setIsShowGroupTyping(true);

          Future.delayed(Duration(seconds: 2), () {
            chatProvider.removeTypingUser(groupId, fromUserName);
            chatProvider.setIsShowGroupTyping(false);
          });
        }
      }

      if (socketEventData['event'] == 'MessageTypingGroupEnd') {
        final socketData = socketEventData['data'];
        final groupId = socketData['iToUserId'];
        final fromUserName = socketData['name'];

        if (chatProvider.isGroupChatOpen &&
            groupId == dataListProvider.openedChatGroupData['_id']) {
          chatProvider.removeTypingUser(groupId, fromUserName);
          chatProvider.setIsShowGroupTyping(false);
        }
      }
    } catch (error) {
      // print("Error while read user messsage $error");
    }
  }

  // ********************* single user message typing *******************
  static void messageTyping(
      String iFromUserId, String iToUserId, String msg, String action) {
    socket.emit("MessageTyping", {
      "iFromUserId": iFromUserId,
      "iToUserId": iToUserId,
      "msg": msg,
      "action": action
    });
  }
}
