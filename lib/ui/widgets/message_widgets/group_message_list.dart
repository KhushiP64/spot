import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/socket/socket_manager.dart';
import 'package:spot/ui/widgets/message_widgets/message_user_name_and_time.dart';
import 'package:spot/ui/widgets/message_widgets/msg_accept_dcline_btn.dart';
import 'package:spot/ui/widgets/message_widgets/reply_message_user_name_and_time.dart';
import 'package:spot/ui/widgets/message_widgets/system_messages.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import '../../../core/media.dart';
import '../../../providers/data_list_provider.dart';
import '../common_widgets/commonWidgets.dart';
import 'convert_decoded_text_to_html_style.dart';
import 'convert_html_to_text.dart';
import 'image_preview.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class GroupMessageList extends StatefulWidget {
  final ScrollController scrollController;

  const GroupMessageList({super.key, required this.scrollController});

  @override
  State<GroupMessageList> createState() => _GroupMessageListState();
}

class _GroupMessageListState extends State<GroupMessageList> {
  Map<String, dynamic> currentUserData = {};
  // final ScrollController _scrollController = ScrollController();
  List<dynamic> messageData = [];
  int currentPage = 1;
  bool isFetching = false;
  bool hasMore = true;
  bool initialScrollDone = false;
  Set<String> loadedMessageIds = {};
  Map<String, double> messageHeights = {};
  bool isLoading = false;
  List<String> loadedGroupMessageIds = [];
  bool isGroupLoading = false;
  bool hasMoreGroup = true;
  bool hasMoreGroupMessages = true;
  bool isGroupMsgSelectionOn = false;

  late final KeyboardVisibilityController _keyboardVisibilityController;
  late final StreamSubscription<bool> _keyboardSubscription;

  @override
  @override
  void initState() {
    super.initState();
    getCurrentUserData();
    groupInfo();
    final chatProvider = context.read<ChatProvider>();

    _keyboardVisibilityController = KeyboardVisibilityController();

    _keyboardSubscription =
        _keyboardVisibilityController.onChange.listen((visible) async {
      if (!visible || chatProvider.isGroupEditing) return;
      if (!mounted) return;

      // Wait for the keyboard animation + relayout
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted || !widget.scrollController.hasClients) return;

      final pos = widget.scrollController.position;
      widget.scrollController.animateTo(
        pos.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  // **************** read message socket *****************
  void listenForReadUpdateGroup() async {
    final dataListProvider = context.read<DataListProvider>();
    SocketManager socketManager = SocketManager();
    socketManager.emit("join_group",
        {"iGroupId": dataListProvider.openedChatGroupData['_id']});

    if (dataListProvider.groupsData.isNotEmpty) {
      var updatedData = <Map<String, dynamic>>[];
      Map<String, dynamic>? updatedItem;

      if (dataListProvider.openedChatGroupData['iTotalUnReadMsg'] > 0) {
        for (var item in dataListProvider.groupsData) {
          if (item['_id'] == dataListProvider.openedChatGroupData['_id']) {
            updatedItem = Map<String, dynamic>.from(item);
            updatedItem['iTotalUnReadMsg'] = 0;
            updatedData.add(updatedItem);
          } else {
            updatedData.add(item);
          }

          final sortedData = CommonFunctions.sortListByTime(updatedData);
          dataListProvider.setGroupList(updatedData);
        }
      }
    }
  }

  Future<void> loadInitialGroupMessages(String groupId, int isAdmin) async {
    final dataProvider = context.read<DataListProvider>();

    final response =
        await CommonFunctions.getGroupMessages(groupId, isAdmin, "");
    List<Map<String, dynamic>> parsedMessages = [];

    if (response['data'] is List) {
      parsedMessages = List<Map<String, dynamic>>.from(response['data']);
    }

    if (parsedMessages.isNotEmpty) {
      dataProvider.setGroupMessageList(parsedMessages);

      setState(() {
        loadedMessageIds.addAll(
            parsedMessages.map((e) => (e['id'] ?? e['_id']).toString()));
        hasMore = parsedMessages.length >= 50;
      });
    }
  }

  void groupInfo() async {
    final dataListProvider = context.read<DataListProvider>();
    final response = await CommonFunctions.getGroupInfoData(
        dataListProvider.openedChatGroupData['_id']);
    if (mounted) {
      if (response.containsKey("data") && response['data'] != null) {
        dataListProvider.setGroupInfoData(response);
      }
    }
    final responseList = await CommonFunctions.getGroupUserList(
        dataListProvider.openedChatGroupData['_id'], "", 1);
    if (responseList['status'] == 200) {
      dataListProvider.setGroupInfoMemberList(responseList);
      // print("dataListProviderrrrrrrrrrrrrrrrr ${dataListProvider.groupInfoMemberList}");
    }
  }

  void fetchGroupMessages() async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final groupMsgs = dataListProvider.groupMessages;

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
      // print("Error while fetching group messages $error");
    }
  }

  Future<void> getCurrentUserData() async {
    final currntUser = await CommonFunctions.getLoginUser();
    setState(() {
      currentUserData = currntUser;
    });
  }

  // ************************ handle request btns ***********************
  void onPressAcceptChatRequest(
      Map<String, dynamic> item, Map<String, dynamic> messageItem) async {
    final dataListProvider = context.read<DataListProvider>();
    final currntUser = await CommonFunctions.getLoginUser();
    if (item['name'] == 'Accept') {
      try {
        final acceptResponse = await CommonFunctions.addGroupJoinAcceptRequest(
            iUserId: currntUser['_id'],
            vActiveGroupId: dataListProvider.openedChatGroupData['_id']);
        // print("acceptResponse $acceptResponse");
        final isAdmin =
            currntUser['iUserId'] == dataListProvider.openedChatGroupData['_id']
                ? 1
                : 0;
        final groupMsgs = await CommonFunctions.getGroupMessages(
            dataListProvider.openedChatGroupData['_id'], isAdmin, "");
        dataListProvider.setGroupMessageAllData(groupMsgs);
      } catch (error) {
        // print("Error while accepting chat request....$error");
      }
    }

    if (item['name'] == 'Decline') {
      try {
        final declineResponse =
            await CommonFunctions.addGroupJoinDeclineRequest(
                iUserId: currntUser['_id'],
                vActiveGroupId: dataListProvider.openedChatGroupData['_id']);
        // print("declineResponse $declineResponse");
      } catch (error) {
        // print("Error while declining chat request....$error");
      }
    }

    final removedList = CommonFunctions.removeMsgInList(
        originalList: dataListProvider.groupMessagesList,
        updatedList: messageItem,
        context: context);
    // debugPrint('removedList $removedList', wrapWidth: 1024);
    dataListProvider.setGroupMessageList(removedList);
  }

  void handleDownloadImage(Map<String, dynamic> messageItem) async {
    final success = await CommonFunctions.downloadFileWithPermission(
        messageItem['vFiles'], messageItem['isOriginalName'], context);
    if (success) {
      toastification.show(
        context: context,
        title: const Text('Image downloaded successfully'),
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topCenter,
      );
    } else {
      toastification.show(
        context: context,
        title: const Text('Image download failed.'),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topCenter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataListProvider = context.watch<DataListProvider>();
    dynamic userList = dataListProvider.groupMemberList;
    // debugPrint("userList $userList", wrapWidth: 1024);

    void openImagePreviewScreen(
        String imgUrl, String imgName, messageItem) async {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.setSelectedImage(messageItem);
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreview(
            imgUrl: imgUrl,
            imgName: imgName,
            messageItem: messageItem,
          ),
        ),
      );
      if (result != null && result is Map<String, dynamic>) {
        chatProvider.startGroupChatImageReply(
          replyText: result['replyText'] ?? '',
          replyFileThumb: result['replyFileThumb'] ?? '',
          replyFileName: result['replyFileName'] ?? '',
          hasFile: result['isImage'] ?? true,
          senderId: result['iFromUserId'],
          senderName: result['vFullName'],
        );
      }
    }

    return WillPopScope(
      onWillPop: () async {
        final chatProvider = context.read<ChatProvider>();
        final dataListProvider = context.read<DataListProvider>();
        if (isGroupMsgSelectionOn) {
          chatProvider.setGroupMsgSelectionMode(false);
          chatProvider.clearGroupMsgSelectionIndexes();
          setState(() {
            isGroupMsgSelectionOn = false;
          });
          return Future.value(false);
        }
        dataListProvider.clearGroupMessageList();
        return Future.value(true);
      },
      child: Consumer2<DataListProvider, ChatProvider>(
        builder: (context, dataListProvider, chatProvider, child) {
          final messages = dataListProvider.groupMessagesList;
          // final reversedMessages = messages.reversed.toList();
          // print("messages $messages");
          if (messages.isEmpty) {
            return Container();
          }

          if (!chatProvider.groupMsgSelectionMode &&
              chatProvider.selectedGroupMsgs.isEmpty &&
              chatProvider.shouldScrollToBottom) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (messages.isNotEmpty) {
                widget.scrollController.animateTo(
                  widget.scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                chatProvider.shouldScrollToBottom = false;
              }
            });
          }

          return ListView.builder(
            itemCount: messages.length,
            controller: widget.scrollController,
            itemBuilder: (context, index) {
              final messageItem = messages[index];
              // final messageItem = reversedMessages[index];
              // debugPrint("messageItem ${messageItem}", wrapWidth: 1024);
              final isSender =
                  messageItem['iFromUserId'] == currentUserData['iUserId'];
              // print("isSender $isSender");
              List receiverData = userList != null
                  ? userList.where((item) {
                      return item['iUserId'] == messageItem['iFromUserId'];
                    }).toList()
                  : [];
              // debugPrint("receiverData $receiverData", wrapWidth: 1024);
              final messageText = messageItem['message'] ?? 'No message';
              bool isMsgImage = CommonFunctions.isImage(messageItem['vFiles']);
              bool isReplyMsgSvg = (messageItem['vReplyMsgData'] is Map &&
                      messageItem['vReplyMsgData'].isNotEmpty &&
                      messageItem['vReplyMsgData']['vReplyFilePath'] != ""
                  ? messageItem['vReplyMsgData']['vReplyFilePath']!
                      .toLowerCase()
                      .endsWith('.svg')
                  : false);
              DateTime dateTime = DateTime.parse(messageItem['created_at']);
              String formattedTime = DateFormat('h:mm a').format(dateTime);
              bool isSenderSvgProfile = (currentUserData['vProfilePic'] != null
                  ? currentUserData['vProfilePic']!
                      .toLowerCase()
                      .endsWith('.svg')
                  : false);
              bool isReceiverSvgProfile = receiverData.isNotEmpty &&
                  (receiverData[0]['vProfilePic'] != null
                      ? receiverData[0]['vProfilePic']!
                          .toLowerCase()
                          .endsWith('.svg')
                      : false);
              bool isSenderSvgMsgImage = (messageItem['vFiles'] != null
                  ? messageItem['vFiles']!.toLowerCase().endsWith('.svg')
                  : false);
              final bool isImageReply =
                  (messageItem['vReplyFileName'] != null &&
                      messageItem['vReplyFileName'].toString().isNotEmpty);
              // bool isReceiverSvgProfile = (receiverData[0]['vProfilePic'] != null ? receiverData[0]['vProfilePic']!.toLowerCase().endsWith('.svg') : false);
              var unescape = HtmlUnescape();
              var decoded = unescape.convert(messageText);
              final chatProvider = context.watch<ChatProvider>();
              final List<dynamic> selectedGroupMsgs =
                  chatProvider.selectedGroupMsgs.isNotEmpty
                      ? chatProvider.selectedGroupMsgs.where((item) {
                          return item['_id'] == messageItem['_id'];
                        }).toList()
                      : [];
              final selectedIndexContains = selectedGroupMsgs.isNotEmpty &&
                  selectedGroupMsgs[0]['_id'] == messageItem['_id'];

              void checkIconsConditions() {
                if (chatProvider.groupMsgSelectionMode) {
                  if (messageItem['vMsgData'].isEmpty) {
                    setState(() {
                      if (selectedIndexContains) {
                        chatProvider
                            .removeSelectedGroupMsgs(messageItem['_id']);
                        if (chatProvider.selectedGroupMsgs.isEmpty) {
                          chatProvider.setIsGroupMsgSelectionMode(false);
                          setState(() {
                            isGroupMsgSelectionOn = false;
                          });
                        }
                      } else {
                        chatProvider.setSelectedGroupMsgs(messageItem);
                      }
                    });

                    // *********** edit msg icon conditions ***********
                    // print("selectedIndex $selectedIndex");
                    final senderMsgSelectedForEdit =
                        chatProvider.selectedGroupMsgs.isNotEmpty
                            ? chatProvider.selectedGroupMsgs.where((item) {
                                return item['iFromUserId'] !=
                                    currentUserData['iUserId'];
                              }).toList()
                            : [];
                    if (senderMsgSelectedForEdit.isEmpty &&
                        chatProvider.selectedGroupMsgs.length == 1 &&
                        chatProvider.selectedGroupMsgs.first['vFiles'] == "") {
                      chatProvider.setShowEditGroupIcon(true);
                    } else {
                      chatProvider.setShowEditGroupIcon(false);
                    }

                    // *********** delete msg icon conditions ***********
                    final senderMsgSelectedForDelete =
                        chatProvider.selectedGroupMsgs.isNotEmpty
                            ? chatProvider.selectedGroupMsgs.where((item) {
                                return item['iFromUserId'] !=
                                    currentUserData['iUserId'];
                              }).toList()
                            : [];
                    if (senderMsgSelectedForDelete.isEmpty) {
                      chatProvider.setShowDeleteGroupIcon(true);
                    } else {
                      final checkAdmin = dataListProvider
                          .openedChatGroupData['tGroupAdmins']
                          .contains(currentUserData['iUserId']);
                      if (checkAdmin) {
                        chatProvider.setShowDeleteGroupIcon(true);
                      } else {
                        chatProvider.setShowDeleteGroupIcon(false);
                      }
                    }

                    // *********** download msg icon conditions ***********
                    final senderMsgSelectedForDownload =
                        chatProvider.selectedGroupMsgs.isNotEmpty
                            ? chatProvider.selectedGroupMsgs.where((item) {
                                return item['vFiles'] == "";
                              }).toList()
                            : [];
                    if (senderMsgSelectedForDownload.isEmpty) {
                      chatProvider.setShowDownloadGroupIcon(true);
                    } else {
                      chatProvider.setShowDownloadGroupIcon(false);
                    }

                    // ************* reply icon condition *************
                    // print("chatProvider.selectedGroupMsgs.length ${chatProvider.selectedGroupMsgs.length}");
                    if (chatProvider.selectedGroupMsgs.length == 1) {
                      chatProvider.setShowReplyGroupIcon(true);
                    } else {
                      chatProvider.setShowReplyGroupIcon(false);
                    }
                  }
                }
              }

              //************************* group chat date formatting ***************************

              final createdAt = DateTime.parse(messageItem['created_at']);
              final currentDate =
                  DateTime(createdAt.year, createdAt.month, createdAt.day);

              bool showDate = false;

              if (index == 0) {
                showDate = true;
              } else {
                final prevCreatedAt =
                    DateTime.parse(messages[index - 1]['created_at']);
                final prevDate = DateTime(
                    prevCreatedAt.year, prevCreatedAt.month, prevCreatedAt.day);
                if (currentDate != prevDate) {
                  showDate = true;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDate)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Expanded(
                              child: Divider(thickness: 1, indent: 10)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              CommonFunctions.getFormattedDate(currentDate),
                              style: AppFontStyles.dmSansMedium.copyWith(
                                color: AppColorTheme.dark40,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Divider(thickness: 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  GestureDetector(
                    onLongPress: () {
                      final chatProvider = context.read<ChatProvider>();
                      if (messageItem['vMsgData'].isEmpty &&
                          !chatProvider.isGroupReplying &&
                          !chatProvider.isGroupEditing) {
                        chatProvider.setIsGroupMsgSelectionMode(true);
                        setState(() {
                          isGroupMsgSelectionOn = true;
                        });
                        checkIconsConditions();
                      }
                    },
                    onTap: () {
                      checkIconsConditions();
                    },
                    child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 8),
                        decoration: BoxDecoration(
                            color: selectedIndexContains &&
                                    chatProvider.groupMsgSelectionMode
                                ? AppColorTheme.lightInfo
                                : AppColorTheme.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (chatProvider.groupMsgSelectionMode)
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 8.0, top: 10),
                                child: messageItem['vMsgData'].isEmpty
                                    ? Icon(
                                        selectedIndexContains
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: selectedIndexContains
                                            ? Colors.blue
                                            : Colors.grey,
                                      )
                                    : SizedBox(width: 25, height: 25),
                              ),
                            messageItem['vMsgData'] is Map &&
                                    messageItem['vMsgData'].isNotEmpty
                                ? messageItem['vMsgData']['flags'] == 0
                                    ? SystemMessages(
                                        messageItem: messageItem,
                                        formattedTime: formattedTime,
                                        systemMessageHighlightedText: "",
                                      )
                                    : MsgAcceptDeclineBtn(
                                        messageItem: messageItem,
                                        onPressAcceptChatRequest: (item) {
                                          onPressAcceptChatRequest(
                                              item, messageItem);
                                        },
                                        formattedTime: formattedTime,
                                        sendUserName: isSender
                                            ? "You"
                                            : receiverData[0]['vFullName'])
                                : Expanded(
                                    child: Align(
                                      alignment: isSender
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          !isSender
                                              ? ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(50)),
                                                  child: (receiverData
                                                              .isNotEmpty &&
                                                          receiverData[0][
                                                                  'vProfilePic'] !=
                                                              null)
                                                      ? CommonWidgets
                                                          .isChatSvgProfilePic(
                                                              isReceiverSvgProfile,
                                                              receiverData[0][
                                                                  'vProfilePic'])
                                                      : Container())
                                              : Container(),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment: isSender
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: [
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: chatProvider
                                                            .groupMsgSelectionMode
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.58
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.66),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft: isSender
                                                          ? const Radius
                                                              .circular(14)
                                                          : const Radius
                                                              .circular(0),
                                                      topRight: isSender
                                                          ? const Radius
                                                              .circular(0)
                                                          : const Radius
                                                              .circular(14),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              14),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              14),
                                                    ),
                                                    color: isSender
                                                        ? AppColorTheme
                                                            .primary16
                                                        : AppColorTheme
                                                            .secondary5,
                                                  ),
                                                  child: messageItem[
                                                              'vFiles'] !=
                                                          ""
                                                      ? Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 1,
                                                                  right: 1,
                                                                  bottom: 0),
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                          child: CommonFunctions
                                                                  .isImage(
                                                                      messageItem[
                                                                          'vFiles'])
                                                              ? Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .stretch,
                                                                  children: [
                                                                    if (messageItem['vFilesThumb'] !=
                                                                            null &&
                                                                        messageItem['vFilesThumb']
                                                                            .toString()
                                                                            .isNotEmpty)
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            openImagePreviewScreen(
                                                                                messageItem['vFiles'],
                                                                                messageItem['isOriginalName'],
                                                                                messageItem);
                                                                          },
                                                                          child:
                                                                              Image.network(
                                                                            messageItem['vFilesThumb'],
                                                                            width:
                                                                                double.infinity,
                                                                            height:
                                                                                120,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            errorBuilder: (context,
                                                                                error,
                                                                                stackTrace) {
                                                                              return Container(
                                                                                height: 120,
                                                                                color: Colors.grey.shade200,
                                                                                child: const Center(
                                                                                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                                                                ),
                                                                              );
                                                                            },
                                                                            loadingBuilder: (context,
                                                                                child,
                                                                                loadingProgress) {
                                                                              if (loadingProgress == null) {
                                                                                return child;
                                                                              }
                                                                              return const SizedBox(
                                                                                height: 180,
                                                                                child: Center(child: CircularProgressIndicator()),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      )
                                                                    else
                                                                      Container(
                                                                        height:
                                                                            120,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(6),
                                                                          color: Colors
                                                                              .grey
                                                                              .shade100,
                                                                        ),
                                                                        child:
                                                                            const Center(
                                                                          child: Icon(
                                                                              Icons.image_not_supported,
                                                                              size: 40,
                                                                              color: Colors.grey),
                                                                        ),
                                                                      ),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              0,
                                                                          right:
                                                                              8),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: ConvertDecodedTextToHtmlStyle(
                                                                                message: messageItem['isOriginalName'] ?? '',
                                                                                highlightText: chatProvider.groupSearchController.text,
                                                                              ),
                                                                              // Text(messageItem['isOriginalName'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                                                              //   style: AppFontStyles.dmSansRegular.copyWith(fontSize: 14, color: AppColorTheme.inputTitle,),)
                                                                            ),
                                                                            const SizedBox(width: 8),
                                                                            if (isMsgImage)
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  openImagePreviewScreen(messageItem['vFiles'], messageItem['isOriginalName'], messageItem);
                                                                                },
                                                                                child: const Icon(FeatherIcons.eye, size: 20, color: AppColorTheme.muted),
                                                                              ),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                handleDownloadImage(messageItem);
                                                                              },
                                                                              child: const Padding(
                                                                                padding: EdgeInsets.only(left: 14),
                                                                                child: Icon(FeatherIcons.download, size: 20, color: AppColorTheme.muted),
                                                                              ),
                                                                            ),
                                                                            if (messageItem['isFileExist'] != 1 &&
                                                                                messageItem['isFileExist'] != 2)
                                                                              const Padding(
                                                                                padding: EdgeInsets.only(left: 12),
                                                                                child: Icon(FeatherIcons.alertCircle, size: 20, color: AppColorTheme.danger),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : Row(
                                                                  children: [
                                                                    SvgPicture.asset(
                                                                        AppMedia
                                                                            .file),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    Expanded(
                                                                      child:
                                                                          ConvertDecodedTextToHtmlStyle(
                                                                        message:
                                                                            messageItem['isOriginalName'] ??
                                                                                '',
                                                                        highlightText: chatProvider
                                                                            .groupSearchController
                                                                            .text,
                                                                      ),
                                                                      // Text(messageItem['isOriginalName'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                                                      //   style: AppFontStyles.dmSansRegular.copyWith(fontSize: 14, color: AppColorTheme.inputTitle,),),
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        CommonFunctions.downloadFileWithPermission(
                                                                            messageItem['vFiles'],
                                                                            messageItem['isOriginalName'],
                                                                            context);
                                                                      },
                                                                      child:
                                                                          const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                12,
                                                                            right:
                                                                                5),
                                                                        child: Icon(
                                                                            FeatherIcons
                                                                                .download,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                AppColorTheme.muted),
                                                                      ),
                                                                    ),
                                                                    if (messageItem['isFileExist'] !=
                                                                            1 &&
                                                                        messageItem['isFileExist'] !=
                                                                            2)
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                12,
                                                                            right:
                                                                                5),
                                                                        child: Icon(
                                                                            FeatherIcons
                                                                                .alertCircle,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                AppColorTheme.danger),
                                                                      ),
                                                                  ],
                                                                ),
                                                        )
                                                      : messageItem['vReplyMsg_id'] !=
                                                                  "" &&
                                                              messageItem[
                                                                      'vReplyMsgData']
                                                                  is Map &&
                                                              messageItem[
                                                                      'vReplyMsgData']
                                                                  .isNotEmpty
                                                          ? Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                IntrinsicHeight(
                                                                  child:
                                                                      Container(
                                                                    margin:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppColorTheme
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topLeft: isSender
                                                                            ? const Radius.circular(14)
                                                                            : const Radius.circular(0),
                                                                        topRight: isSender
                                                                            ? const Radius.circular(0)
                                                                            : const Radius.circular(14),
                                                                        bottomLeft: const Radius
                                                                            .circular(
                                                                            14),
                                                                        bottomRight: const Radius
                                                                            .circular(
                                                                            14),
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              2,
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              top: 11,
                                                                              bottom: 10,
                                                                              left: 8,
                                                                              right: 8),
                                                                          padding: EdgeInsets.only(
                                                                              top: 10,
                                                                              bottom: 10),
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color:
                                                                                AppColorTheme.primary,
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: Color.fromRGBO(0, 163, 239, 0.5),
                                                                                offset: Offset(2, 0),
                                                                                blurRadius: 9,
                                                                                spreadRadius: 0,
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(top: 10, right: 5),
                                                                                child: ReplyMessageUserNameAndTime(
                                                                                  formattedTime: CommonFunctions.dateFormat(messageItem['vReplyMsgData']['vReplyDate']),
                                                                                  sendUserName: messageItem['vReplyMsgData']['vReplyUserName'],
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 6),
                                                                              if (messageItem['vReplyMsgData']['vReplyFilePath'] != "")
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(right: 8),
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(6),
                                                                                        child: isReplyMsgSvg
                                                                                            ? SvgPicture.network(
                                                                                                messageItem['vReplyMsgData']['vReplyFilePath'],
                                                                                                height: 120,
                                                                                                width: double.infinity,
                                                                                                fit: BoxFit.cover,
                                                                                                placeholderBuilder: (context) => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
                                                                                              )
                                                                                            : Image.network(
                                                                                                messageItem['vReplyMsgData']['vReplyFilePath'],
                                                                                                height: 120,
                                                                                                width: double.infinity,
                                                                                                fit: BoxFit.cover,
                                                                                                errorBuilder: (context, error, stack) => const SizedBox(
                                                                                                    height: 120,
                                                                                                    child: Center(
                                                                                                        child: Icon(
                                                                                                      Icons.broken_image,
                                                                                                      size: 40,
                                                                                                      color: Colors.grey,
                                                                                                    ))),
                                                                                                loadingBuilder: (context, child, loadingProgress) {
                                                                                                  if (loadingProgress == null) return child;
                                                                                                  return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));
                                                                                                },
                                                                                              ),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(height: 3),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(bottom: 10),
                                                                                      child: ConvertDecodedTextToHtmlStyle(
                                                                                        message: messageItem['vReplyMsgData']['vReplyFileName'],
                                                                                        highlightText: chatProvider.groupSearchController.text,
                                                                                      )
                                                                                      // Text(messageItem['vReplyMsgData']['vReplyFileName'], maxLines: 1, overflow: TextOverflow.ellipsis,
                                                                                      //   style: AppFontStyles.dmSansRegular.copyWith(fontSize: 14, color: AppColorTheme.inputTitle,),)
                                                                                      ,
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              else
                                                                                ConvertDecodedTextToHtmlStyle(
                                                                                  message: messageItem['vReplyMsgData']['vReplyMsg'],
                                                                                  highlightText: chatProvider.groupSearchController.text,
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                ConvertDecodedTextToHtmlStyle(
                                                                  message: messageItem[
                                                                          'vReplyMsgData']
                                                                      [
                                                                      'message'],
                                                                  highlightText:
                                                                      chatProvider
                                                                          .groupSearchController
                                                                          .text,
                                                                ),
                                                              ],
                                                            )
                                                          //    : ConvertHTMLToText(
                                                          //       decoded: decoded,
                                                          //       searchText: chatProvider.groupSearchController.text,
                                                          //       currentMatchIndex: chatProvider.currentGroupMatchIndex,
                                                          //       totalMatches: chatProvider.matchedGroupIndexes.length,
                                                          // ),
                                                          : ConvertDecodedTextToHtmlStyle(
                                                              message:
                                                                  messageText,
                                                              highlightText:
                                                                  chatProvider
                                                                      .groupSearchController
                                                                      .text,
                                                            ),
                                                ),
                                              ),
                                              SizedBox(height: 3),
                                              MessageUserNameAndTime(
                                                formattedTime: formattedTime,
                                                sendUserName: isSender
                                                    ? "You"
                                                    : receiverData.isNotEmpty
                                                        ? receiverData[0]
                                                            ['vFullName']
                                                        : "",
                                                isForwarded: messageItem[
                                                            'isForwardMsg'] !=
                                                        ""
                                                    ? int.parse(messageItem[
                                                        'isForwardMsg'])
                                                    : 0,
                                                isEdited:
                                                    messageItem['iEdited'],
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          isSender
                                              ? ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(50)),
                                                  child: (currentUserData[
                                                              'vProfilePic'] !=
                                                          null)
                                                      ? CommonWidgets
                                                          .isChatSvgProfilePic(
                                                              isSenderSvgProfile,
                                                              currentUserData[
                                                                  'vProfilePic'])
                                                      : Container())
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        )),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
