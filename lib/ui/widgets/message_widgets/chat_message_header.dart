import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/responsive_fonts.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:spot/ui/widgets/chat_list_widgets/chat_list_item.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';
import 'package:spot/ui/widgets/message_widgets/pinned_user_chat_messages.dart';
import 'package:spot/ui/widgets/user_chat_widgets/group_info_menu.dart';
import 'package:spot/ui/widgets/user_chat_widgets/user_chat_header_menu.dart';
import 'package:spot/ui/widgets/user_chat_widgets/user_group_header_menu.dart';

class ChatMessageHeader extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  final String subTitle;

  const ChatMessageHeader({
    super.key,
    required this.currentUser,
    required this.subTitle,
  });

  @override
  State<ChatMessageHeader> createState() => _ChatMessageHeaderState();
}

class _ChatMessageHeaderState extends State<ChatMessageHeader> {
  Map<String, dynamic> groupInfoApiData = {};

  @override
  void initState() {
    super.initState();
    groupInfo();
  }

  // ******************** get single user data *******************
  Future<void> getSingleUserData(String userId) async {
    final dataListProvider = context.read<DataListProvider>();
    final data = await CommonFunctions.getSingleUser(userId);
    // debugPrint("Get single user dataaa $data",wrapWidth: 1024);
    dataListProvider.setOpenedChatUserData(data);
  }

  // ******************* group info data *******************
  void groupInfo() async {
    final dataListProvider = context.read<DataListProvider>();
    if (dataListProvider.openedChatGroupData['_id'] != null) {
      final response = await CommonFunctions.getGroupInfoData(
          dataListProvider.openedChatGroupData['_id']);
      if (mounted) {
        if (response.containsKey("data") && response['data'] != null) {
          setState(() {
            groupInfoApiData = response;
          });
        }
        // print('groupInfoApiData $groupInfoApiData');
      }
    }
  }

  // ***************** handle on press request chat btn *******************
  void handleOnPressRequestChat() async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      // print("User Id ${dataListProvider.openedChatUserData['iUserId']}");

      final currentUser = await CommonFunctions.getLoginUser();
      final nowUtc = DateTime.now().toUtc();
      final timestamp = nowUtc.millisecondsSinceEpoch;
      final id =
          "${currentUser['iUserId']}_${dataListProvider.openedChatUserData['iUserId']}_$timestamp";
      SocketMessageEvents.sendMessageEvent(
        receiverChatID: dataListProvider.openedChatUserData['iUserId'],
        senderChatID: currentUser['iUserId'],
        content: "",
        imageDataArr: [],
        vReplyMsg: "",
        vReplyMsgId: "",
        vReplyFileName: "",
        id: id,
        iRequestMsg: 1,
        isForwardMsg: 0,
        isForwardMsgId: "",
        isDeleteprofile: 0,
        chat: 1,
        communicationType: 1,
      );
      // print("dataListProvider.openedChatUserData['iUserId'] ${dataListProvider.openedChatUserData['iUserId']}");

      await getSingleUserData(dataListProvider.openedChatUserData['iUserId']);
      dataListProvider.getChatListData();
    } catch (error) {
      // print("Error while on press Request Chat btn $error");
    }
  }

  // ***************** open group info *******************
  void openGroupInfo() async {
    final dataListProvider = context.read<DataListProvider>();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: GroupInfoMenu(
                  groupId: dataListProvider.openedChatGroupData['_id']));
        });
  }

  // ***************** handle on click search message *******************
  void handleSearchMessageClick() {
    final chatProvider = context.read<ChatProvider>();
    if (widget.subTitle == 'chat') {
      chatProvider.setIsSearching(true);
    } else {
      chatProvider.setIsGroupSearching(true);
    }
  }

  // ************************** handle all pinned messages ***************************
  void handleShowPinnedMessages() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PinnedUserChatMessages(),
        // This part removes the animation
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
        // Optional: sets the duration to zero to ensure no delay
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataListProvider = context.read<DataListProvider>();
    final userData = dataListProvider.openedChatUserData;
    final isInChat = widget.subTitle == 'chat' && userData.isNotEmpty;

    final Color statusColor =
        userData["iStatus"] == 0 ? AppColorTheme.danger : AppColorTheme.success;

    final mediaQuery = MediaQuery.of(context);

    // *********************** handle on press back ************************
    void handleBackPress() {
      if (isInChat) {
        Navigator.pushReplacementNamed(context, '/chatList',
            arguments: {'tabIndex': 0});
      } else {
        Navigator.pushReplacementNamed(context, '/chatList',
            arguments: {'tabIndex': 1});
      }
      final dataListProvider = context.read<DataListProvider>();
      final chatProvider = context.read<ChatProvider>();
      dataListProvider.clearGroupMessageList();
      dataListProvider.clearUserMessageList();
      chatProvider.setUserReplyingStop(false);
      chatProvider.setGroupReplyingStop(false);
      chatProvider.setUserEditingStop(false);
      chatProvider.setGroupEditingStop(false);
      chatProvider.setFileUploadingStop(false);
      chatProvider.clearMsgSelectionIndexes();

      chatProvider.clearGroupMsgSelectionIndexes();
      // dataListProvider.removeOpenedChatUserData();
    }

    // *********************** handle on press more menu **********************
    void handleOnPressOpenMoreMenus() async {
      CommonModal.show(
          context: context,
          child: UserChatHeaderMenu(currentUser: widget.currentUser));
      // final updatedGroupData = await showModalBottomSheet(
      //   context: context,
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      //   ),
      //   builder: (BuildContext context) {
      //     return UserChatHeaderMenu(currentUser: widget.currentUser);
      //   },
      // );
      // if (updatedGroupData != null) {
      //   setState(() {
      //     dataListProvider.removeOpenedChatGroupData();
      //     dataListProvider.setOpenedChatGroupData(updatedGroupData);
      //   });
      // }
    }

    // Font size scaling
    double requestBtnFontSize = 12;

    final bool showRequestChatButton = isInChat &&
        dataListProvider.openedChatUserData.isNotEmpty &&
        dataListProvider.openedChatUserData['iRequestMsg'] != null &&
        dataListProvider.openedChatUserData['iRequestMsg'] != 0 &&
        dataListProvider.openedChatUserData['iRequestMsg'] != 1;
    return WillPopScope(
      onWillPop: () {
        handleBackPress();
        return Future.value(false);
      },
      child: Container(
          margin:
              EdgeInsets.only(left: 12.w, right: 20.w, top: 10.h, bottom: 12.h),
          child: dataListProvider.openedChatUserData.isNotEmpty
              ? Consumer<DataListProvider>(
                  builder: (context, dataListProvider, child) {
                    // ✅ condition: check if request button should show
                    bool showRequestChatButton = (isInChat &&
                        dataListProvider.openedChatUserData['isStartChat'] !=
                            null &&
                        dataListProvider.openedChatUserData['eStatus'] != 'n' &&
                        dataListProvider.openedChatUserData['isStartChat'] !=
                            1 &&
                        (dataListProvider.openedChatUserData['iRequestMsg'] ==
                                3 ||
                            dataListProvider
                                    .openedChatUserData['iRequestMsg'] ==
                                4 ||
                            dataListProvider
                                    .openedChatUserData['iRequestMsg'] ==
                                5));

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /// Back Arrow for go to list screen
                              InkWell(
                                onTap: handleBackPress,
                                child: SvgPicture.asset(AppMedia.leftArrow),
                              ),
                              Expanded(
                                child: ChatListItem(
                                    profileIconMarginTop: 3,
                                    verticalPadding: 0,
                                    statusBorderColor: AppColorTheme.white,
                                    statusColor: statusColor,
                                    vProfilePic: dataListProvider
                                        .openedChatUserData['vProfilePic'],
                                    listTitle: dataListProvider
                                        .openedChatUserData['vFullName'],
                                    listSubTitle:
                                        dataListProvider.openedChatUserData[
                                                    'iStatus'] ==
                                                1
                                            ? 'Online'
                                            : 'Offline',
                                    handleOnPressItem: () {}),
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (showRequestChatButton)
                              Button(
                                onPressed: handleOnPressRequestChat,
                                title: 'Request Chat',
                                textStyle: AppFontStyles.dmSansMedium.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColorTheme.white),
                                backgroundColor: AppColorTheme.primary,
                                textColor: AppColorTheme.white,
                                paddingHorizontal: 12,
                              ),
                            SizedBox(width: 8.w),
                            ((widget.subTitle == 'chat' &&
                                        dataListProvider
                                            .userMessagesList.isEmpty) ||
                                    widget.subTitle != 'chat' &&
                                        dataListProvider
                                            .groupMessagesList.isEmpty)
                                ? Container()
                                : InkWell(
                                    onTap: handleSearchMessageClick,
                                    child: SvgPicture.asset(
                                      AppMedia.searchMsg,
                                      height: 22.h,
                                    ),
                                  ),
                            SizedBox(width: 8.w),
                            InkWell(
                              onTap: handleShowPinnedMessages,
                              child: SvgPicture.asset(AppMedia.pinChat),
                            ),
                            SizedBox(width: 8.w),
                            InkWell(
                              onTap: handleOnPressOpenMoreMenus,
                              child: SvgPicture.asset(AppMedia.moreMenu),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                )
              : Container()),
    );
  }
}
