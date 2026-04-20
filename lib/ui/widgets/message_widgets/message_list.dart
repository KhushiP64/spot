import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:spot/ui/widgets/common_widgets/audio_message_bubble.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';
import 'package:spot/ui/widgets/message_widgets/convert_decoded_text_to_html_style.dart';
import 'package:spot/ui/widgets/message_widgets/image_preview.dart';
import 'package:spot/ui/widgets/message_widgets/message_user_name_and_time.dart';
import 'package:spot/ui/widgets/message_widgets/msg_accept_dcline_btn.dart';
import 'package:spot/ui/widgets/message_widgets/reply_message_user_name_and_time.dart';
import 'package:spot/ui/widgets/message_widgets/system_messages.dart';
import 'package:toastification/toastification.dart';
import '../../../socket/socket_manager.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../common_widgets/commonWidgets.dart';

class MessageList extends StatefulWidget {
  final ScrollController scrollController;
  const MessageList({super.key, required this.scrollController});
  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  Map<String, dynamic> currentUserData = {};
  bool hasMore = true;
  Set<String> loadedMessageIds = {};
  final socket = SocketManager();
  bool isMsgSelectionOn = false;
  Future<void> loadInitialGroupMessages(String userId) async {
    final dataProvider = context.read<DataListProvider>();

    final response = await CommonFunctions.getUserMessages(userId, "");

    List<Map<String, dynamic>> parsedMessages = [];

    if (response?['data'] is List) {
      parsedMessages = List<Map<String, dynamic>>.from(response['data']);
    }

    if (parsedMessages.isNotEmpty) {
      dataProvider.setUserMessageList(parsedMessages);

      setState(() {
        loadedMessageIds.addAll(
            parsedMessages.map((e) => (e['id'] ?? e['_id']).toString()));
        hasMore = parsedMessages.length >= 50;
      });
    }
  }

  late final KeyboardVisibilityController _keyboardVisibilityController;
  late final StreamSubscription<bool> _keyboardSubscription;

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
    final provider = context.read<DataListProvider>();
    final chatProvider = context.read<ChatProvider>();
    final userId = provider.openedChatUserData['_id'];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadInitialGroupMessages(userId);
      chatProvider.setIsUserChatOpen(true);
      listenForReadUpdate();
    });
    _keyboardVisibilityController = KeyboardVisibilityController();

    _keyboardSubscription =
        _keyboardVisibilityController.onChange.listen((visible) async {
      if (!visible || chatProvider.isUserEditing) return;
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
  void listenForReadUpdate() async {
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

  Future<void> getCurrentUserData() async {
    final currntUser = await CommonFunctions.getLoginUser();
    setState(() {
      currentUserData = currntUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataListProvider = context.read<DataListProvider>();

    // ************************ handle request btns ***********************
    void onPressAcceptChatRequest(item, messageItem) async {
      final nowUtc = DateTime.now().toUtc();
      final dataListProvider = context.read<DataListProvider>();
      final timestamp = nowUtc.millisecondsSinceEpoch;
      final id =
          "${dataListProvider.openedChatUserData['iUserId']}_${currentUserData['iUserId']}_$timestamp";
      // *************** accept action *****************
      if (item['name'] == "Accept") {
        final acceptResponse = await CommonFunctions.acceptUserChatRequest(
            dataListProvider.openedChatUserData['iUserId'], messageItem['id']);
        // print("acceptResponse $acceptResponse");

        if (acceptResponse['status'] == 200) {
          SocketMessageEvents.sendMessageEvent(
            receiverChatID: dataListProvider.openedChatUserData['iUserId'],
            senderChatID: currentUserData['iUserId'],
            content: "",
            imageDataArr: [],
            vReplyMsg: "",
            vReplyMsgId: "",
            vReplyFileName: "",
            id: id,
            iRequestMsg: 2,
            isForwardMsg: 0,
            isForwardMsgId: "",
            isDeleteprofile: 0,
            chat: 1,
            communicationType: 1,
          );
        }
      }

      // *************** decline action *****************
      if (item['name'] == "Decline") {
        final declineResponse = await CommonFunctions.declineUserChatRequest(
            dataListProvider.openedChatUserData['iUserId']);
        // print("declineResponse $declineResponse");

        if (declineResponse['status'] == 200) {
          SocketMessageEvents.sendMessageEvent(
            receiverChatID: dataListProvider.openedChatUserData['iUserId'],
            senderChatID: currentUserData['iUserId'],
            content: "",
            imageDataArr: [],
            vReplyMsg: "",
            vReplyMsgId: "",
            vReplyFileName: "",
            id: id,
            iRequestMsg: 3,
            isForwardMsg: 0,
            isForwardMsgId: "",
            isDeleteprofile: 0,
            chat: 1,
            communicationType: 1,
          );
        }
      }
      final removedList = CommonFunctions.removeMsgInList(
        originalList: dataListProvider.userMessagesList,
        updatedList: messageItem,
        context: context);
      // debugPrint('removedList $removedList', wrapWidth: 1024);
      dataListProvider.setUserMessageList(removedList);
    }

    // ************** open image preview screen *******************
    void openImagePreviewScreen(String imgUrl, String imgName, messageItem, {bool isVideo = false}) async {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.setSelectedImage(messageItem);
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreview(
            imgUrl: imgUrl,
            imgName: imgName,
            messageItem: messageItem,
            isVideo: isVideo,
          ),
        ),
      );

      // debugPrint("result $result", wrapWidth: 1024);

      if (result != null && result is Map<String, dynamic>) {
        // print("result['vFullName'] ${result['vFullName']}");
        chatProvider.startUserChatImageReply(
          replyText: result['replyText'] ?? '',
          replyFileThumb: result['replyFileThumb'] ?? '',
          replyFileName: result['replyFileName'] ?? '',
          hasFile: result['isImage'] ?? true,
          senderId: result['iFromUserId'],
          senderName: result['vFullName'],
        );
        // print("chat provider set value in message list---------------- ${chatProvider.userReplySenderName}");
      }
    }

    // *********************** handle download image ***********************
    void handleDownloadImage(messageItem) async {
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

    // *********************** handle on Press back *************************
    Future<bool> handleOnClickBack() async {
      final chatProvider = context.read<ChatProvider>();
      final dataListProvider = context.read<DataListProvider>();
      if (isMsgSelectionOn) {
        chatProvider.setMsgSelectionMode(false);
        setState(() {
          isMsgSelectionOn = false;
        });
        return Future.value(false);
      }
      dataListProvider.clearUserMessageList();
      return Future.value(true);
    }

    return dataListProvider.openedChatUserData.isNotEmpty
        ? WillPopScope(
            onWillPop: handleOnClickBack,
            child: Consumer2<DataListProvider, ChatProvider>(
                builder: (context, dataListProvider, chatProvider, child) {
              final messages = dataListProvider.userMessagesList;

              if (messages.isEmpty) {
                return Container();
              }

              // if(!chatProvider.msgSelectionMode && chatProvider.shouldScrollToBottom ){
              //   WidgetsBinding.instance.addPostFrameCallback((_) {
              //     if (messages.isNotEmpty) {
              //       widget.scrollController.animateTo(
              //         widget.scrollController.position.maxScrollExtent,
              //         duration: const Duration(milliseconds: 300),
              //         curve: Curves.easeOut,
              //       );
              //     }
              //   });
              // }
              if (!chatProvider.msgSelectionMode &&
                  chatProvider.shouldScrollToBottom) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (messages.isNotEmpty &&
                      widget.scrollController.hasClients) {
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
                    // log("messageItem $messageItem");
                    final isSender = messageItem['iFromUserId'] ==
                        currentUserData['iUserId'];
                    final messageText = messageItem['message'] ?? 'No message';
                    DateTime dateTime =
                        DateTime.parse(messageItem['created_at']);
                    String formattedTime =
                        DateFormat('h:mm a').format(dateTime);
                    bool isReplyMsgSvg = (messageItem['vReplyMsgData'] is Map &&
                            messageItem['vReplyMsgData'].isNotEmpty &&
                            messageItem['vReplyMsgData']['vReplyFilePath'] != ""
                        ? messageItem['vReplyMsgData']['vReplyFilePath']!
                            .toLowerCase()
                            .endsWith('.svg')
                        : false);
                    final bool isImageReply = (messageItem['vReplyFileName'] != null && messageItem['vReplyFileName'].toString().isNotEmpty);
                    bool isMsgImage = CommonFunctions.isImage(messageItem['vFiles']);
                    var unescape = HtmlUnescape();
                    // var decoded = unescape.convert(messageText);
                    final chatProvider = context.watch<ChatProvider>();
                    final List<dynamic> selectedmsgs =
                        chatProvider.selectedMsgs.isNotEmpty
                            ? chatProvider.selectedMsgs.where((item) {
                                return item['_id'] == messageItem['_id'];
                              }).toList()
                            : [];
                    final selectedIndexContains = selectedmsgs.isNotEmpty &&
                        selectedmsgs[0]['_id'] == messageItem['_id'];

                    // ******************** handle on Long press message ********************
                    void checkIconsConditions() {
                      if (chatProvider.msgSelectionMode) {
                        if (messageItem['vMsgData'].isEmpty) {
                          setState(() {
                            if (selectedIndexContains) {
                              chatProvider.removeSelectedMsgs(messageItem['_id']);
                              if (chatProvider.selectedMsgs.isEmpty) {
                                chatProvider.setIsMsgSelectionMode(false);
                                setState(() {
                                  isMsgSelectionOn = false;
                                });
                              }
                            } else {
                              chatProvider.setSelectedMsgs(messageItem);
                            }
                          });

                          // *********** edit msg icon conditions ***********
                          final senderMsgSelectedForEdit =
                              chatProvider.selectedMsgs.isNotEmpty
                                  ? chatProvider.selectedMsgs.where((item) {
                                      return item['iFromUserId'] != currentUserData['iUserId'];
                                    }).toList()
                                  : [];
                          if (senderMsgSelectedForEdit.isEmpty &&
                              chatProvider.selectedMsgs.length == 1 &&
                              chatProvider.selectedMsgs.first['vFiles'] == "") {
                            chatProvider.setShowEditIcon(true);
                          } else {
                            chatProvider.setShowEditIcon(false);
                          }

                          // *********** delete msg icon conditions ***********
                          final senderMsgSelectedForDelete =
                              chatProvider.selectedMsgs.isNotEmpty
                                  ? chatProvider.selectedMsgs.where((item) {
                                      return item['iFromUserId'] !=
                                          currentUserData['iUserId'];
                                    }).toList()
                                  : [];
                          if (senderMsgSelectedForDelete.isEmpty) {
                            chatProvider.setShowDeleteIcon(true);
                          } else {
                            chatProvider.setShowDeleteIcon(false);
                          }

                          // *********** download msg icon conditions ***********
                          final senderMsgSelectedForDownload =
                              chatProvider.selectedMsgs.isNotEmpty
                                  ? chatProvider.selectedMsgs.where((item) {
                                      return item['vFiles'] == "";
                                    }).toList()
                                  : [];
                          if (senderMsgSelectedForDownload.isEmpty) {
                            chatProvider.setShowDownloadIcon(true);
                          } else {
                            chatProvider.setShowDownloadIcon(false);
                          }

                          // ************* reply icon condition *************
                          if (chatProvider.selectedMsgs.length == 1) {
                            chatProvider.setShowReplyIcon(true);
                          } else {
                            chatProvider.setShowReplyIcon(false);
                          }
                        }
                      }
                    }

                    void handleOnLongPressMessage() {
                      final chatProvider = context.read<ChatProvider>();
                      if (messageItem['vMsgData'].isEmpty &&
                          !chatProvider.isUserReplying &&
                          !chatProvider.isUserEditing) {
                        chatProvider.setIsMsgSelectionMode(true);
                        checkIconsConditions();
                        setState(() {
                          isMsgSelectionOn = true;
                        });
                      }
                    }

                    //*************************** date formatting *************************
                    final createdAt = DateTime.parse(messageItem['created_at']);
                    final currentDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
                    bool showDate = false;
                    if (index == 0) {
                      showDate = true;
                    } else {
                      final prevCreatedAt = DateTime.parse(messages[index - 1]['created_at']);
                      final prevDate = DateTime(prevCreatedAt.year, prevCreatedAt.month, prevCreatedAt.day);
                      if (currentDate != prevDate) {
                        showDate = true;
                      }
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Date separator
                        if (showDate) CommonWidgets.dateSeparatorUI(currentDate),

                        /// Message & System Message and Message accept and decline button
                        messageItem['vMsgData'] is Map && messageItem['vMsgData'].isNotEmpty
                        ? messageItem['vMsgData']['flags'] == 0
                          ? SystemMessages(messageItem: messageItem, formattedTime: formattedTime, systemMessageHighlightedText: "")
                          : MsgAcceptDeclineBtn(
                            messageItem: messageItem,
                            onPressAcceptChatRequest: (item) {
                              onPressAcceptChatRequest(item, messageItem);
                            },
                            formattedTime: formattedTime,
                            sendUserName: isSender ? "You" : dataListProvider.openedChatUserData['vFullName']
                          )
                        : Container(
                          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              /// Receiver's Profile Icon
                              !isSender
                              ? ProfileIconStatusDot(
                                profilePic: dataListProvider.openedChatUserData['vProfilePic'],
                                statusColor: AppColorTheme.transparent,
                                statusBorderColor: AppColorTheme.transparent,
                                showStatusColor: false,
                                profileSize: 42,
                              )
                              : Container(),
                              SizedBox(width: 10.w),

                              /// Message
                              Column(
                                crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  messageItem['vFiles'] != ""
                                    ? CommonFunctions.isImage(messageItem['vFiles'])
                                      ? messageItem['isFileCon'] == 'image' &&
                                        messageItem['vFilesThumb'] != null &&
                                        messageItem['vFilesThumb'].toString().isNotEmpty
                                        ? InkWell(
                                          child: Padding(
                                            padding: EdgeInsets.only(right: isSender ? 4.w : 0, left: !isSender ? 4.w : 0),
                                            child: CommonWidgets.chatMessageImageUI(messageItem['vFilesThumb'], () {
                                              openImagePreviewScreen(messageItem['vFiles'], messageItem['isOriginalName'], messageItem);
                                            }),
                                          ),
                                        )
                                        : Container(
                                          height: 120.h,
                                          padding: EdgeInsets.only(right: isSender ? 6.w : 0, left: !isSender ? 6.w : 0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            color: Colors.grey.shade100,
                                          ),
                                          child: Center(
                                            child: Icon(Icons.image_not_supported, size: 40.w, color: Colors.grey),
                                          )
                                        )
                                      : messageItem['isFileCon'] == 'File' && !messageItem['vFiles'].toString().endsWith("gif") && !messageItem['vFiles'].toString().endsWith("mp3")
                                        ? CommonWidgets.chatMessageFileUI(
                                          messageItem: messageItem,
                                          isSender: isSender,
                                          bgColor: isSender ? AppColorTheme.senderMsgBg : AppColorTheme.receiverMsgBg,
                                          width: MediaQuery.of(context).size.width * CommonWidgets.chatBubbleWidth,
                                          fileImage: messageItem['vFilesThumb'],
                                          fileName: messageItem['isOriginalName'],
                                          isShowAlertIcon: messageItem['isFileExist'] != 1 && messageItem['isFileExist'] != 2,
                                          highlightedText: "",
                                          handleOnTapDownload: () {
                                            CommonFunctions.downloadFileWithPermission(
                                              messageItem['vFiles'],
                                              messageItem['isOriginalName'],
                                              context
                                            );
                                          })
                                        : messageItem['isFileCon'] == 'video'
                                          ? CommonWidgets.chatMessageVideoUI(messageItem['vFiles'], (){
                                            // openImagePreviewScreen("https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4", messageItem['isOriginalName'], messageItem, isVideo: true);
                                            openImagePreviewScreen("https://www.w3schools.com/html/mov_bbb.mp4", messageItem['isOriginalName'], messageItem, isVideo: true);
                                            // openImagePreviewScreen("https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4", messageItem['isOriginalName'], messageItem, isVideo: true);
                                          })
                                          : messageItem['vFiles'].toString().endsWith("gif")
                                            ? CommonWidgets.chatMessageImageUI(messageItem['vFiles'], () {
                                              openImagePreviewScreen(messageItem['vFiles'], messageItem['isOriginalName'], messageItem);
                                            })
                                            : messageItem['vFiles'].toString().endsWith("mp3")
                                              ? AudioMessageBubble(
                                                url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
                                                isSender: isSender,
                                                audioName: messageItem['isOriginalName'],
                                              )
                                              // CommonWidgets.chatMessageAudioUI(url: messageItem['vFiles'], isSender: isSender, width: MediaQuery.of(context).size.width * 0.66)
                                              : Container()

                                      /// Chat Message Text
                                    : CommonWidgets.chatMessageTextUI(messageText: messageText, isSender: isSender, width: MediaQuery.of(context).size.width * CommonWidgets.chatBubbleWidth),

                                  /// Sender/Receiver name and time & Forwarded/Edited Text
                                  MessageUserNameAndTime(
                                    formattedTime: formattedTime,
                                    sendUserName: isSender
                                      ? "You"
                                      : dataListProvider.openedChatUserData.isNotEmpty ? dataListProvider.openedChatUserData['vFullName'] : "",
                                    isForwarded: int.tryParse(messageItem['isForwardMsg'] ?.toString() ?? '') ?? 0,
                                    isEdited: messageItem['iEdited'],
                                    isSender: isSender,
                                    statusIndicator: isSender
                                    ? CircleAvatar(
                                      radius: 3.r,
                                      backgroundColor: messageItem['iReadTo'] == 1 ? AppColorTheme.success : AppColorTheme.muted,
                                    )
                                    : null,
                                  ),
                                ],
                              ),

                              /// Sender's Profile Icon
                              SizedBox(width: 10.w),
                              isSender
                              ? ProfileIconStatusDot(
                                profilePic: currentUserData['vProfilePic'],
                                statusColor: AppColorTheme.transparent,
                                statusBorderColor: AppColorTheme.transparent,
                                showStatusColor: false,
                                profileSize: 42,
                              )
                              : Container(),
                            ],
                          ),
                        )
                      ],
                    );
                    // return Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       /// Date separator
                    //       if (showDate) CommonWidgets.dateSeparatorUI(currentDate),
                    //
                    //       /// Message
                    //       GestureDetector(
                    //         onLongPress: handleOnLongPressMessage,
                    //         onTap: checkIconsConditions,
                    //         child: Container(
                    //           padding: EdgeInsets.all(12.w),
                    //           decoration: BoxDecoration(
                    //             color: selectedIndexContains && !chatProvider.isUserReplying && !chatProvider.isUserEditing ? AppColorTheme.receiverMsgBg : AppColorTheme.white,
                    //             borderRadius: BorderRadius.all(Radius.circular(10)),
                    //           ),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.start,
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               if (chatProvider.msgSelectionMode)
                    //                 Padding(
                    //                     padding: const EdgeInsets.only(right: 8.0, top: 10),
                    //                     // child: (chatProvider.isUserEditing || chatProvider.isUserReplying) || messageItem['vMsgData'].isEmpty
                    //                     child: messageItem['vMsgData'].isEmpty
                    //                       ? Icon(selectedIndexContains ? Icons.check_circle : Icons.radio_button_unchecked, color: selectedIndexContains ? Colors.blue : Colors.grey)
                    //                       : SizedBox(width: 25, height: 25)
                    //                 ),
                    //                 messageItem['vMsgData'] is Map && messageItem['vMsgData'].isNotEmpty ? messageItem['vMsgData']['flags'] == 0
                    //                 ? SystemMessages(messageItem: messageItem, formattedTime: formattedTime,)
                    //                 : MsgAcceptDeclineBtn(
                    //                   messageItem: messageItem,
                    //                   onPressAcceptChatRequest: (item) {
                    //                     onPressAcceptChatRequest(item, messageItem);
                    //                   },
                    //                   formattedTime: formattedTime,
                    //                   sendUserName: isSender ? "You" : dataListProvider.openedChatUserData['vFullName']
                    //                 )
                    //               :
                    //               Expanded(
                    //                 child: Align(
                    //                   alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                    //                   child: Row(
                    //                     crossAxisAlignment: CrossAxisAlignment.start,
                    //                     mainAxisSize: MainAxisSize.min,
                    //                     children: [
                    //                       /// Receiver's profile
                    //                       !isSender ?
                    //                       ProfileIconStatusDot(
                    //                         profilePic: dataListProvider.openedChatUserData['vProfilePic'],
                    //                         statusColor: AppColorTheme.transparent,
                    //                         statusBorderColor: AppColorTheme.transparent,
                    //                         showStatusColor: false,
                    //                         profileSize: 42,
                    //                       ) :Container(),
                    //                       SizedBox(width: 6.w,),
                    //
                    //                       Column(
                    //                         crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    //                         children: [
                    //                           ConstrainedBox(
                    //                             constraints: BoxConstraints(maxWidth: chatProvider.msgSelectionMode ? MediaQuery.of(context).size.width * 0.58 : MediaQuery.of(context).size.width * 0.66),
                    //                             child: Container(
                    //                               padding: EdgeInsets.all(2.w),
                    //                               decoration: BoxDecoration(
                    //                                 border: Border.all(
                    //                                   color: chatProvider.isShowEditIcon && chatProvider.isUserEditing && chatProvider.selectedMsgs.isNotEmpty && chatProvider.selectedMsgs.first['id'] == messageItem['id']
                    //                                     ? AppColorTheme.primary : Colors.transparent,
                    //                                   width: 2
                    //                                 ),
                    //                                 borderRadius: BorderRadius.only(
                    //                                   topLeft: isSender ? Radius.circular(12.w) : Radius.circular(0),
                    //                                   topRight: isSender ? Radius.circular(0) : Radius.circular(12.w),
                    //                                   bottomLeft: Radius.circular(12.w),
                    //                                   bottomRight: Radius.circular(12.w),
                    //                                 ),
                    //                               ),
                    //                               child: Container(
                    //                                   padding: EdgeInsets.all(10.w),
                    //                                   decoration: BoxDecoration(
                    //                                     color: isSender ? AppColorTheme.senderMsgBg : AppColorTheme.receiverMsgBg,
                    //                                     borderRadius: BorderRadius.only(
                    //                                       topLeft: isSender ? Radius.circular(12.w) : Radius.circular(0),
                    //                                       topRight: isSender ? Radius.circular(0) : Radius.circular(12.w),
                    //                                       bottomLeft: Radius.circular(12.w),
                    //                                       bottomRight: Radius.circular(12.w),
                    //                                     ),
                    //                                   ),
                    //                                   child: messageItem['vFiles'] != ""
                    //
                    //                                   /// Image in chat
                    //                                   ? CommonFunctions.isImage(messageItem['vFiles'])
                    //                                   ? Column(
                    //                                     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //                                     children: [
                    //                                       if (messageItem['vFilesThumb'] != null && messageItem['vFilesThumb'].toString().isNotEmpty)
                    //                                         ClipRRect(
                    //                                           borderRadius: BorderRadius.circular(6.r),
                    //                                           child: InkWell(
                    //                                             onTap: (){openImagePreviewScreen(messageItem['vFiles'], messageItem['isOriginalName'], messageItem);},
                    //                                             child: Image.network(messageItem['vFilesThumb'],
                    //                                               width: double.infinity,
                    //                                               height: 120,
                    //                                               fit: BoxFit.cover,
                    //                                             ),
                    //                                           ),
                    //                                         )
                    //                                       else
                    //                                         Container(
                    //                                           height: 120,
                    //                                           decoration: BoxDecoration(
                    //                                             borderRadius: BorderRadius.circular(6),
                    //                                             color: Colors.grey.shade100,
                    //                                           ),
                    //                                           child: const Center(
                    //                                             child: Icon(
                    //                                                 Icons.image_not_supported,
                    //                                                 size: 40,
                    //                                                 color: Colors.grey
                    //                                             ),
                    //                                           ),
                    //                                         ),
                    //                                       const SizedBox(height: 8),
                    //
                    //                                       Padding(padding: const EdgeInsets.only(left: 0, right: 4),
                    //                                         child:
                    //                                         Row(
                    //                                           children: [
                    //                                             Expanded(
                    //                                               child: ConvertDecodedTextToHtmlStyle(message: messageItem['isOriginalName'] ?? '',highlightText: chatProvider.searchController.text,),
                    //                                             ),
                    //                                             const SizedBox(width: 5),
                    //                                             InkWell(
                    //                                               onTap: () {handleDownloadImage(messageItem);},
                    //                                               child: const Padding(padding: EdgeInsets.only(left: 12),
                    //                                                 child: Icon(FeatherIcons.download, size: 20, color: AppColorTheme.muted),),
                    //                                             ),
                    //                                             if (messageItem['isFileExist'] != 1 && messageItem['isFileExist'] != 2)
                    //                                               const Padding(padding: EdgeInsets.only(left: 12),
                    //                                                 child: Icon(FeatherIcons.alertCircle, size: 20, color: AppColorTheme.danger),),
                    //                                           ],
                    //                                         )
                    //                                         ,)
                    //                                       ,],)
                    //                                       : Row(
                    //                                     children: [
                    //
                    //                                       /// File in chat
                    //                                       SvgPicture.asset(AppMedia.file),
                    //                                       const SizedBox(width: 6),
                    //                                       Expanded(
                    //                                           child:
                    //                                           // Text(messageItem['isOriginalName'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppFontStyles.dmSansRegular.copyWith(fontSize: 14, color: AppColorTheme.inputTitle,),),
                    //                                           ConvertDecodedTextToHtmlStyle(message: messageItem['isOriginalName'] ?? '',highlightText: chatProvider.searchController.text,)
                    //                                       ),
                    //                                       InkWell(onTap: () {CommonFunctions.downloadFileWithPermission(messageItem['vFiles'], messageItem['isOriginalName'], context);},
                    //                                         child: const Padding(padding: EdgeInsets.only(left: 10,right: 5),
                    //                                           child: Icon(FeatherIcons.download, size: 20, color: AppColorTheme.muted),),),
                    //                                       if (messageItem['isFileExist'] != 1 && messageItem['isFileExist'] != 2)
                    //                                         const Padding(padding: EdgeInsets.only(left: 10,right: 5),
                    //                                           child: Icon(FeatherIcons.alertCircle, size: 20, color: AppColorTheme.danger),),
                    //                                     ],)
                    //                                       : messageItem['vReplyMsg_id'] != "" && messageItem['vReplyMsgData']is Map && messageItem['vReplyMsgData'].isNotEmpty
                    //                                       ? Column(
                    //                                     crossAxisAlignment: CrossAxisAlignment.start,
                    //                                     children: [
                    //                                       IntrinsicHeight(
                    //                                         child: Container(margin: const EdgeInsets.all(6),
                    //                                           decoration: BoxDecoration(color: AppColorTheme.white, borderRadius: BorderRadius.only(
                    //                                             topLeft: isSender ? const Radius.circular(14) : const Radius.circular(0),
                    //                                             topRight: isSender ? const Radius.circular(0) : const Radius.circular(14),
                    //                                             bottomLeft: const Radius.circular(14),
                    //                                             bottomRight: const Radius.circular(14),),),
                    //                                           child:
                    //                                           Row(
                    //                                             children: [
                    //                                               Container(
                    //                                                 width: 2,
                    //                                                 margin: const EdgeInsets.only(top: 11,bottom: 10,left: 8,right: 8),
                    //                                                 padding: EdgeInsets.only(top: 10,bottom: 10),
                    //                                                 decoration: const BoxDecoration(
                    //                                                   color: AppColorTheme.primary,
                    //                                                   boxShadow: [BoxShadow(color: Color.fromRGBO(0, 163, 239, 0.5), offset: Offset(2, 0), blurRadius: 9, spreadRadius: 0,),],
                    //                                                 ),
                    //                                               ),
                    //                                               Expanded(
                    //                                                 child: Column(
                    //                                                   crossAxisAlignment: CrossAxisAlignment.start,
                    //                                                   children: [
                    //                                                     Padding(
                    //                                                       padding: const EdgeInsets.only(top: 10, right: 5),
                    //                                                       child: ReplyMessageUserNameAndTime(
                    //                                                         formattedTime: CommonFunctions.dateFormat(messageItem['vReplyMsgData']['vReplyDate']),
                    //                                                         sendUserName: messageItem['vReplyMsgData']['vReplyUserName'],
                    //                                                       ),
                    //                                                     ),
                    //                                                     const SizedBox(height: 6),
                    //
                    //                                                     if (messageItem['vReplyMsgData']['vReplyFilePath'] != "")
                    //                                                       Padding(
                    //                                                         padding: const EdgeInsets.only(right: 8),
                    //                                                         child: Column(
                    //                                                           crossAxisAlignment: CrossAxisAlignment.start,
                    //                                                           children: [
                    //                                                             ClipRRect(
                    //                                                               borderRadius: BorderRadius.circular(6),
                    //                                                               child: isReplyMsgSvg
                    //                                                                   ? SvgPicture.network(messageItem['vReplyMsgData']['vReplyFilePath'], height: 120, width: double.infinity, fit: BoxFit.cover, placeholderBuilder: (context) => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),)
                    //                                                                   : Image.network(messageItem['vReplyMsgData']['vReplyFilePath'], height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stack) => const SizedBox(height: 140, child: Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey,))),
                    //                                                                 loadingBuilder: (context, child, loadingProgress) {
                    //                                                                   if (loadingProgress == null) return child;
                    //                                                                   return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));},),),
                    //                                                             // const SizedBox(height: 6),
                    //                                                             ConvertDecodedTextToHtmlStyle(message: messageItem['vReplyMsgData']['vReplyFileName'],highlightText: chatProvider.searchController.text,),
                    //                                                           ],
                    //                                                         ),
                    //                                                       )
                    //                                                     else
                    //                                                       ConvertDecodedTextToHtmlStyle(message: messageItem['vReplyMsgData']['vReplyMsg'],highlightText: chatProvider.searchController.text,),
                    //                                                   ],
                    //                                                 ),
                    //                                               ),
                    //                                             ],
                    //                                           ),
                    //                                         ),
                    //                                       ),
                    //                                       // const SizedBox(height: 6),
                    //                                       ConvertDecodedTextToHtmlStyle(message: messageItem['vReplyMsgData']['message'],highlightText: chatProvider.searchController.text, ),
                    //                                     ],
                    //                                   )
                    //                                       :
                    //                                   // ConvertHTMLToText(decoded: decoded,)
                    //                                   // ConvertHTMLToText(
                    //                                   //   decoded: decoded,
                    //                                   //   searchText: chatProvider.SearchController.text,
                    //                                   //   currentMatchIndex: chatProvider.CurrentMatchIndex,
                    //                                   //   totalMatches: chatProvider.MatchedIndexes.length,
                    //                                   //
                    //                                   // ),
                    //                                   ConvertDecodedTextToHtmlStyle(message: messageText,highlightText: chatProvider.searchController.text,)
                    //                               ),
                    //                             ),
                    //                           ),
                    //
                    //                           /// User name and time
                    //                           MessageUserNameAndTime(
                    //                             formattedTime: formattedTime,
                    //                             sendUserName: isSender ? "You" : dataListProvider.openedChatUserData.isNotEmpty ? dataListProvider.openedChatUserData['vFullName'] : "",
                    //                             isForwarded: int.tryParse(messageItem['isForwardMsg']?.toString() ?? '') ?? 0,
                    //                             isEdited: messageItem['iEdited'],
                    //                             isSender: isSender,
                    //                             statusIndicator: isSender
                    //                             ? CircleAvatar(
                    //                               radius: 3.r,
                    //                               backgroundColor: messageItem['iReadTo'] == 1 ? AppColorTheme.success : AppColorTheme.muted,
                    //                             )
                    //                             : null,
                    //                           ),
                    //                         ],
                    //                       ),
                    //
                    //                       /// Sender's profile
                    //                       SizedBox(width: 6.w),
                    //                       isSender ?
                    //                         ProfileIconStatusDot(
                    //                           profilePic: currentUserData['vProfilePic'],
                    //                           statusColor: AppColorTheme.transparent,
                    //                           statusBorderColor: AppColorTheme.transparent,
                    //                           showStatusColor: false,
                    //                           profileSize: 42,
                    //                         )
                    //                       : Container(),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ]);
                  });
            }))
        : Container();
  }
}
