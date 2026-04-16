import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';
import '../../../core/responsive_fonts.dart';
import '../common_widgets/button.dart';

class ForwardBottomSheet {
  static void show({
    required BuildContext context,
    required TextEditingController searchUsers,
    required ValueChanged<String> onSearchChanged,
    required VoidCallback closeForwardListModal,
    required ScrollController controller,
    required Map<String, dynamic>? currentUser,
    required bool isGroupMsgs,
  }) {
    Map<String, bool> selectedIds = {};

    void handleOnPressForwardMsg(selectedMsgs) async {
      final chatProvider = context.read<ChatProvider>();
      final nowUtc = DateTime.now().toUtc();
      final timestamp = nowUtc.millisecondsSinceEpoch;
      final currentUser = await CommonFunctions.getLoginUser();

      // print('selectedIds $selectedIds');
      if (selectedIds.isNotEmpty) {
        int index = 0;
        selectedIds.forEach((selectedId, isGroup) {
          final imageId =
              "${currentUser['iUserId']}_${selectedId}_${index}_$timestamp";
          // print("Idddddddddddddd $imageId");
          // print("chatProvider.selectedImage ${chatProvider.selectedImage}");
          if (chatProvider.selectedImage.isNotEmpty) {
            // print("object 1 ");
            if (isGroup) {
              SocketMessageEvents.sendGroupMessageEvent(
                  receiverChatID: selectedId,
                  senderChatID: currentUser['iUserId'],
                  content: "",
                  imageDataArr: [],
                  vReplyMsg: "",
                  vReplyMsgId: "",
                  isGreetingMsg: 0,
                  id: imageId,
                  vMembersList: [],
                  iRequestMsg: 0,
                  isForwardMsg: 1,
                  isForwardMsgId: chatProvider.selectedImage['id'],
                  isDeleteprofile: 0,
                  vDeleteMemberId: "",
                  vNewAdminId: "",
                  requestMemberId: "");
            } else {
              SocketMessageEvents.sendMessageEvent(
                  receiverChatID: selectedId,
                  senderChatID: currentUser['iUserId'],
                  content: "",
                  imageDataArr: [],
                  vReplyMsg: "",
                  vReplyMsgId: "",
                  vReplyFileName: "",
                  id: imageId,
                  iRequestMsg: 0,
                  isForwardMsg: 1,
                  isForwardMsgId: chatProvider.selectedImage['id'],
                  isDeleteprofile: 0);
            }
          } else if (selectedMsgs.isNotEmpty) {
            // print("object 2");
            selectedMsgs.forEach((msgItem) {
              final msgId =
                  "${currentUser['iUserId']}_${selectedId}_${index}_$timestamp";
              if (isGroup) {
                SocketMessageEvents.sendGroupMessageEvent(
                    receiverChatID: selectedId,
                    senderChatID: currentUser['iUserId'],
                    content: "",
                    imageDataArr: [],
                    vReplyMsg: "",
                    vReplyMsgId: "",
                    isGreetingMsg: 0,
                    id: msgId,
                    vMembersList: [],
                    iRequestMsg: 0,
                    isForwardMsg: 1,
                    isForwardMsgId: msgItem['id'],
                    isDeleteprofile: 0,
                    vDeleteMemberId: "",
                    vNewAdminId: "",
                    requestMemberId: "");
              } else {
                SocketMessageEvents.sendMessageEvent(
                    receiverChatID: selectedId,
                    senderChatID: currentUser['iUserId'],
                    content: "",
                    imageDataArr: [],
                    vReplyMsg: "",
                    vReplyMsgId: "",
                    vReplyFileName: "",
                    id: msgId,
                    iRequestMsg: 0,
                    isForwardMsg: 1,
                    isForwardMsgId: msgItem['id'],
                    isDeleteprofile: 0);
              }
              index++;
              // print("Indexxx $index");
            });
          }
        });
        chatProvider.setSelectedImage({});
        if (isGroupMsgs) {
          chatProvider.clearGroupMsgSelectionIndexes();
          chatProvider.setIsGroupMsgSelectionMode(false);
        } else {
          chatProvider.clearMsgSelectionIndexes();
          chatProvider.setIsMsgSelectionMode(false);
        }
      }
      Navigator.of(context).pop();
    }

    void handleSelectUsersForForward(
        bool isSelected, String itemId, bool isGroup) async {
      if (isSelected) {
        selectedIds.remove(itemId);
      } else {
        selectedIds[itemId] = isGroup;
      }

      if (selectedIds.isNotEmpty) {
        String ids = selectedIds.keys.join(',');
        final response = await CommonFunctions.getSelectedUserListData(ids);
        // print("Response:-------------- $response");
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      backgroundColor: const Color(0xffEEF2F5),
      builder: (context) {
        final chatProvider = context.read<ChatProvider>();
        return WillPopScope(
          onWillPop: () {
            closeForwardListModal();
            return Future.value(false);
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xffEEF2F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              boxShadow: [
                BoxShadow(
                    color: Colors.white,
                    offset: Offset(0, -1),
                    blurRadius: 0,
                    spreadRadius: 1),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 22, 15, 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text("Forward To...",
                                style:
                                    ResponsiveFontStyles.dmSans18Medium(context)
                                        .copyWith(color: AppColorTheme.dark87)),
                          ),
                        ),
                      ),
                      GestureDetector(
                          onTap: closeForwardListModal,
                          child: Icon(Icons.close,
                              color: const Color(0xffAEB9BD).withOpacity(0.7))),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      const BoxShadow(color: Color.fromRGBO(10, 41, 55, 0.16)),
                      BoxShadow(
                        color: const Color(0xffEEF2F5).withOpacity(0.6),
                        offset: const Offset(0, 2),
                        blurRadius: 1.0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchUsers,
                    onChanged: (value) {
                      onSearchChanged(value);
                    },
                    style: ResponsiveFontStyles.dmSans15Regular(context)
                        .copyWith(color: AppColorTheme.inputTitle),
                    cursorColor: AppColorTheme.black,
                    cursorWidth: 0.9,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset('assets/icons/search.svg',
                            height: 18, width: 18, color: AppColorTheme.dark48),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Consumer<DataListProvider>(
                      builder: (context, dataListProvider, child) {
                    return ListView.builder(
                      controller: controller,
                      itemCount: dataListProvider.forwardUsers.length,
                      itemBuilder: (context, index) {
                        final item = dataListProvider.forwardUsers[index];
                        final itemId = item['id'];
                        final isGroup = item.containsKey('vSpaceSetting');
                        final isSelected = selectedIds.containsKey(itemId);
                        // print("printtttttt Itemmmm $item");
                        return ListTile(
                          leading: ProfileIconStatusDot(
                            profilePic: item['vProfilePic'],
                            statusColor: isGroup
                                ? Colors.transparent
                                : (item['iStatus'] == 1
                                    ? AppColorTheme.success
                                    : AppColorTheme.danger),
                            borderRadius: isGroup ? 6 : 50,
                            showStatusColor: !isGroup,
                            statusBorderColor: AppColorTheme.lightPrimary,
                          ),
                          title: Text(item['name'],
                              style:
                                  ResponsiveFontStyles.dmSans15Regular(context)
                                      .copyWith(fontSize: 14.5)),
                          subtitle: Text(
                              isGroup
                                  ? 'Group'
                                  : (item['iStatus'] == 1
                                      ? 'Online'
                                      : 'Offline'),
                              style:
                                  ResponsiveFontStyles.dmSans12Regular(context)
                                      .copyWith(color: AppColorTheme.grey)),
                          trailing: InkWell(
                            child: Container(
                                margin: const EdgeInsets.only(right: 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 2,
                                      color: isSelected
                                          ? AppColorTheme.primary
                                          : AppColorTheme.border),
                                  color: isSelected
                                      ? AppColorTheme.primary
                                      : AppColorTheme.transparent,
                                ),
                                width: 20,
                                height: 20,
                                child: isSelected
                                    ? const Icon(FeatherIcons.check,
                                        color: AppColorTheme.white, size: 14)
                                    : null),
                          ),
                          onTap: () {
                            handleSelectUsersForForward(
                                isSelected, itemId, isGroup);
                            (context as Element).markNeedsBuild();
                          },
                        );
                      },
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 24),
                  child: Button(
                      title: 'Forward',
                      backgroundColor: AppColorTheme.primary,
                      textColor: AppColorTheme.white,
                      width: MediaQuery.of(context).size.width,
                      onPressed: () {
                        handleOnPressForwardMsg(isGroupMsgs
                            ? chatProvider.selectedGroupMsgs
                            : chatProvider.selectedMsgs);
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
