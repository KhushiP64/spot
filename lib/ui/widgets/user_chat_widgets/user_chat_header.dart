import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/responsive_fonts.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';
import 'package:spot/ui/widgets/user_chat_widgets/group_info_menu.dart';
import 'package:spot/ui/widgets/user_chat_widgets/user_chat_header_menu.dart';
import 'package:spot/ui/widgets/user_chat_widgets/user_group_header_menu.dart';

class UserChatHeader extends StatefulWidget {
  final Map<String, dynamic>? userMessageList;
  final Map<String, dynamic>? groupMessageList;
  final Map<String, dynamic>? currentUser;
  final String subTitle;
  const UserChatHeader(
      {super.key,
      required this.currentUser,
      required this.subTitle,
      this.userMessageList,
      this.groupMessageList});

  @override
  State<UserChatHeader> createState() => _UserChatHeaderState();
}

class _UserChatHeaderState extends State<UserChatHeader> {
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

  @override
  Widget build(BuildContext context) {
    final dataListProvider = context.read<DataListProvider>();
    final userData = dataListProvider.openedChatUserData;
    final isInChat = widget.subTitle == 'chat' && userData.isNotEmpty;

    final Color statusColor =
        userData["iStatus"] == 0 ? AppColorTheme.danger : AppColorTheme.success;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Define sizes based on device type and orientation
    // You can customize these breakpoints as needed
    final bool isTablet = screenWidth > 600;

    // Button width depends on device and orientation
    double requestBtnMaxWidth;
    if (isTablet) {
      // Bigger width on tablet
      requestBtnMaxWidth = isLandscape ? screenWidth * 0.2 : screenWidth * 0.3;
    } else {
      // Smaller width on phone
      requestBtnMaxWidth = isLandscape ? screenWidth * 0.3 : screenWidth * 0.27;
    }

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

    // Font size scaling
    double requestBtnFontSize = isTablet ? 14 : 12;

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
          color: AppColorTheme.white,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 0 : 3,
            vertical: isTablet ? 0 : 0,
          ),
          child:
              // Column(
              //   children: [
              //     dataListProvider.openedChatUserData != null && dataListProvider.openedChatUserData.isNotEmpty || dataListProvider.openedChatGroupData != null && dataListProvider.openedChatGroupData.isNotEmpty ? Consumer<DataListProvider>(
              //         builder: (context, DataListProvider, child) {
              //           // debugPrint("Dataaa List Providerrrrrrrrrrrrrrrrrr ${DataListProvider.openedChatGroupData}");
              //           return Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               InkWell(
              //                 onTap: () => widget.subTitle == 'chat' ? null : openGroupInfo(),
              //                 child: Row(
              //                   children: [
              //                     Padding(
              //                       padding: const EdgeInsets.only(bottom: 5,left: 5,right: 2),
              //                       child: InkWell(
              //                         onTap: handleBackPress,
              //                         child: const Icon(FeatherIcons.chevronLeft, color: AppColorTheme.muted, size: 22),
              //                       ),
              //                     ),
              //                     Padding(
              //                       padding: const EdgeInsets.only(left: 10),
              //                       child: ProfileIconStatusDot(
              //                         profilePic: widget.subTitle == 'chat' && dataListProvider.openedChatUserData.isNotEmpty && dataListProvider.openedChatUserData != null ? dataListProvider.openedChatUserData['vProfilePic'] : dataListProvider.openedChatGroupData['vGroupImage'],
              //                         statusColor: statusColor,
              //                         borderRadius: widget.subTitle == 'chat' ? 50 : 10,
              //                         showStatusColor: widget.subTitle == 'chat',
              //                       ),
              //                     ),
              //                     Padding(
              //                       padding: const EdgeInsets.only(left: 8),
              //                       child: Column(
              //                         crossAxisAlignment: CrossAxisAlignment.start,
              //                         children: [
              //                           Container(
              //                             constraints: BoxConstraints(maxWidth: isTablet ? screenWidth * (showRequestChatButton ? 0.4 : 0.5) : screenWidth * (showRequestChatButton ? 0.2 : 0.40),),
              //                             child: Text(
              //                               widget.subTitle == 'chat'
              //                                   ? (dataListProvider.openedChatUserData['vFullName'] ?? '')
              //                                   : (dataListProvider.openedChatGroupData['vGroupName'] ?? ''),
              //                               maxLines: 1,
              //                               overflow: TextOverflow.ellipsis,
              //                               style: AppFontStyles.dmSansRegular.copyWith(fontSize: 16, color: AppColorTheme.dark87),
              //                             ),
              //                           ),
              //                           Text(widget.subTitle == 'chat'
              //                               ? (dataListProvider.openedChatUserData['iStatus'] == 1 ? 'Online' : 'Offline')
              //                               : "${dataListProvider.openedChatGroupData['grpMemberCount']} ${dataListProvider.openedChatGroupData['grpMemberCount'] == 1 ? 'Member' : 'Members'}",
              //                             style: AppFontStyles.dmSansRegular.copyWith(fontSize: isTablet ? 13 : 13, height: 1.7, color: AppColorTheme.dark40),
              //                           ),
              //                         ],
              //                       ),
              //                     )
              //                   ],
              //                 ),
              //               ),
              //               SizedBox(width: isTablet ? 5 : 4),
              //               Row(
              //                 children: [
              //                   if (isInChat
              //                       && dataListProvider.openedChatUserData['isStartChat'] != null
              //                       && dataListProvider.openedChatUserData['eStatus'] != 'n'
              //                       && dataListProvider.openedChatUserData['isStartChat'] != 1
              //                       && (dataListProvider.openedChatUserData['iRequestMsg'] == 3 || dataListProvider.openedChatUserData['iRequestMsg'] == 4 || dataListProvider.openedChatUserData['iRequestMsg'] == 5))
              //                     Container(
              //                       constraints: BoxConstraints(maxWidth: requestBtnMaxWidth),
              //                       child: Button(
              //                         onPressed: handleOnPressRequestChat,
              //                         title: 'Request Chat',
              //                         textStyle: ResponsiveFontStyles.dmSans12Medium(context).copyWith(fontSize: requestBtnFontSize, color: AppColorTheme.white),
              //                         backgroundColor: AppColorTheme.primary,
              //                         textColor: AppColorTheme.white,
              //                       ),
              //                     ),
              //                   SizedBox(width: isTablet ? 16 : 12),
              //                   (dataListProvider.userMessagesList.isEmpty)
              //                       ? Container()
              //                       : InkWell(
              //                     onTap: handleSearchMessageClick,
              //                     child: const Icon(
              //                       FeatherIcons.search,
              //                       color: AppColorTheme.muted,
              //                       size: 21,
              //                     ),
              //                   ),
              //                   SizedBox(width: isTablet ? 16 : 5),
              //                   InkWell(
              //                     onTap: () async {
              //                       final updatedGroupData = await showModalBottomSheet(
              //                         context: context,
              //                         shape: const RoundedRectangleBorder(
              //                           borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              //                         ),
              //                         builder: (BuildContext context) {
              //                           return widget.subTitle == 'chat'
              //                               ? UserChatHeaderMenu(currentUser: widget.currentUser)
              //                               : UserGroupHeaderMenu(ctx: context);
              //                         },
              //                       );
              //                       if (updatedGroupData != null) {
              //                         setState(() {
              //                           DataListProvider.removeOpenedChatGroupData();
              //                           DataListProvider.setOpenedChatGroupData(updatedGroupData);
              //                         });
              //                       }
              //                     },
              //                     child: const Icon(FeatherIcons.moreVertical, color: AppColorTheme.muted, size: 21.5),
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           );
              //         }
              //     ) : Container(),
              //   ],
              // ),
              Column(
            children: [
              dataListProvider.openedChatUserData.isNotEmpty ||
                      dataListProvider.openedChatGroupData.isNotEmpty
                  ? Consumer<DataListProvider>(
                      builder: (context, dataListProvider, child) {
                        // ✅ condition: check if request button should show
                        bool showRequestChatButton = (isInChat &&
                            dataListProvider
                                    .openedChatUserData['isStartChat'] !=
                                null &&
                            dataListProvider.openedChatUserData['eStatus'] !=
                                'n' &&
                            dataListProvider
                                    .openedChatUserData['isStartChat'] !=
                                1 &&
                            (dataListProvider
                                        .openedChatUserData['iRequestMsg'] ==
                                    3 ||
                                dataListProvider
                                        .openedChatUserData['iRequestMsg'] ==
                                    4 ||
                                dataListProvider
                                        .openedChatUserData['iRequestMsg'] ==
                                    5));

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: handleBackPress,
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 5, left: 5, right: 2),
                                      child: const Icon(
                                          FeatherIcons.chevronLeft,
                                          color: AppColorTheme.muted,
                                          size: 22)),
                                ),
                                InkWell(
                                  onTap: () => widget.subTitle == 'chat'
                                      ? null
                                      : openGroupInfo(),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: ProfileIconStatusDot(
                                          profilePic:
                                              widget.subTitle == 'chat' &&
                                                      dataListProvider
                                                          .openedChatUserData
                                                          .isNotEmpty
                                                  ? dataListProvider
                                                          .openedChatUserData[
                                                      'vProfilePic']
                                                  : dataListProvider
                                                          .openedChatGroupData[
                                                      'vGroupImage'],
                                          statusColor: statusColor,
                                          borderRadius:
                                              widget.subTitle == 'chat'
                                                  ? 50
                                                  : 10,
                                          showStatusColor:
                                              widget.subTitle == 'chat',
                                          statusBorderColor:
                                              AppColorTheme.lightPrimary,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: isTablet
                                                    ? screenWidth *
                                                        (showRequestChatButton
                                                            ? 0.2
                                                            : 0.7)
                                                    : screenWidth *
                                                        (showRequestChatButton
                                                            ? 0.3
                                                            : 0.50),
                                              ),
                                              child: Text(
                                                widget.subTitle == 'chat'
                                                    ? (dataListProvider
                                                                .openedChatUserData[
                                                            'vFullName'] ??
                                                        '')
                                                    : (dataListProvider
                                                                .openedChatGroupData[
                                                            'vGroupName'] ??
                                                        ''),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppFontStyles
                                                    .dmSansRegular
                                                    .copyWith(
                                                        fontSize: 16,
                                                        color: AppColorTheme
                                                            .dark87),
                                              ),
                                            ),
                                            Text(
                                              widget.subTitle == 'chat'
                                                  ? (dataListProvider
                                                                  .openedChatUserData[
                                                              'iStatus'] ==
                                                          1
                                                      ? 'Online'
                                                      : 'Offline')
                                                  : "${dataListProvider.openedChatGroupData['grpMemberCount']} ${dataListProvider.openedChatGroupData['grpMemberCount'] == 1 ? 'Member' : 'Members'}",
                                              style: AppFontStyles.dmSansRegular
                                                  .copyWith(
                                                fontSize: isTablet ? 13 : 13,
                                                height: 1.7,
                                                color: AppColorTheme.dark40,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(width: isTablet ? 5 : 4),
                            Row(
                              children: [
                                if (showRequestChatButton)
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth: requestBtnMaxWidth),
                                    child: Button(
                                      onPressed: handleOnPressRequestChat,
                                      title: 'Request Chat',
                                      textStyle:
                                          ResponsiveFontStyles.dmSans12Medium(
                                                  context)
                                              .copyWith(
                                        fontSize: requestBtnFontSize,
                                        color: AppColorTheme.white,
                                      ),
                                      backgroundColor: AppColorTheme.primary,
                                      textColor: AppColorTheme.white,
                                    ),
                                  ),
                                SizedBox(width: isTablet ? 16 : 12),
                                ((widget.subTitle == 'chat' &&
                                            dataListProvider
                                                .userMessagesList.isEmpty) ||
                                        widget.subTitle != 'chat' &&
                                            dataListProvider
                                                .groupMessagesList.isEmpty)
                                    ? Container()
                                    : InkWell(
                                        onTap: handleSearchMessageClick,
                                        child: const Icon(FeatherIcons.search,
                                            color: AppColorTheme.muted,
                                            size: 21),
                                      ),
                                SizedBox(width: isTablet ? 16 : 5),
                                InkWell(
                                  onTap: () async {
                                    final updatedGroupData =
                                        await showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(15)),
                                      ),
                                      builder: (BuildContext context) {
                                        return widget.subTitle == 'chat'
                                            ? UserChatHeaderMenu(
                                                currentUser: widget.currentUser)
                                            : UserGroupHeaderMenu(ctx: context);
                                      },
                                    );
                                    if (updatedGroupData != null) {
                                      setState(() {
                                        dataListProvider
                                            .removeOpenedChatGroupData();
                                        dataListProvider.setOpenedChatGroupData(
                                            updatedGroupData);
                                      });
                                    }
                                  },
                                  child: const Icon(FeatherIcons.moreVertical,
                                      color: AppColorTheme.muted, size: 21.5),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    )
                  : Container(),
            ],
          )),
    );
  }
}
