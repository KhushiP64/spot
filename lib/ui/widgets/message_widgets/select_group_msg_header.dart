import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/ui/widgets/chat_list_widgets/forward_list_bottom_sheet.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/confirm_center_modal.dart';
import 'package:toastification/toastification.dart';

import '../../../core/utils.dart';

class SelectGroupMsgHeader extends StatefulWidget {
  const SelectGroupMsgHeader({super.key});

  @override
  State<SelectGroupMsgHeader> createState() => _SelectGroupMsgHeaderState();
}

class _SelectGroupMsgHeaderState extends State<SelectGroupMsgHeader> {
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // ************** click on back icon ********************
  void handleOnClickBackSelectedGroupMsg() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setIsGroupMsgSelectionMode(false);
    chatProvider.clearGroupMsgSelectionIndexes();
  }

  // ************** click on reply icon ********************
  void handleOnClickReplyMsg() {
    final chatProvider = context.read<ChatProvider>();
    // print("Selected group Reply Messages: ${chatProvider.selectedGroupMsgs}");

    if (chatProvider.isGroupReplying) {
      chatProvider.stopGroupChatReplying();
    } else {
      chatProvider.stopGroupChatEditing();
      chatProvider.startGroupChatReplying();
    }
    chatProvider.setGroupMsgSelectionMode(false);
    // chatProvider.clearGroupMsgSelectionIndexes();
  }

  // ************** click on edit icon ********************
  void handleOnClickEditMsg() {
    final chatProvider = context.read<ChatProvider>();
    // print("Selected group Messages: ${chatProvider.selectedGroupMsgs}");

    if (chatProvider.isGroupEditing) {
      chatProvider.stopGroupChatEditing();
    } else {
      chatProvider.stopGroupChatReplying();
      chatProvider.startGroupChatEditing();
    }

    chatProvider.setGroupMsgSelectionMode(false);
    chatProvider.clearGroupMsgSelectionIndexes();
  }

  // ************** click on forward icon ********************
  Future<void> handleOnClickForwardMsg(BuildContext ctx) async {
    try {
      final dataListProvider =
          Provider.of<DataListProvider>(ctx, listen: false);
      await dataListProvider.getForwardUsers();
      final currentGroupUser = await CommonFunctions.getLoginUser();
      if (!mounted) return;

      CommonModal.show(
        context: context,
        child: ForwardBottomSheet(
          context: ctx,
          currentUser: currentGroupUser,
          searchUsers: searchController,
          controller: _scrollController,
          closeForwardListModal: closeForwardListModal,
          isGroupMsgs: true)
      );
    } catch (error) {
      // print("Error while getting forward user list:--- $error");
    }
  }

  // ******************* handle close forward list Modal ******************
  void closeForwardListModal() {
    setState(() {
      _currentPage = 1;
      searchController.clear();
    });
    Navigator.of(context).pop();
  }

  // ************** click on download icon ********************
  Future<void> handleOnClickDownloadMsg() async {
    final chatProvider = context.read<ChatProvider>();

    if (!chatProvider.isShowDownloadGroupIcon ||
        chatProvider.selectedGroupMsgs.isEmpty) return;

    int successCount = 0;
    int failCount = 0;

    for (var selectedGroupMsgs in chatProvider.selectedGroupMsgs) {
      final success = await CommonFunctions.downloadFileWithPermission(
          selectedGroupMsgs['vFiles'],
          selectedGroupMsgs['isOriginalName'],
          context);
      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    // Show a single summary toast after all downloads
    if (successCount == chatProvider.selectedGroupMsgs.length) {
      toastification.show(
        context: context,
        title: chatProvider.selectedGroupMsgs.length == 1
            ? const Text('File downloaded successfully!')
            : const Text('All files downloaded successfully!'),
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topCenter,
      );
    } else if (successCount > 0 && failCount > 0) {
      toastification.show(
        context: context,
        title: Text('$successCount file(s) downloaded, $failCount failed.'),
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topCenter,
      );
    } else {
      toastification.show(
        context: context,
        title: const Text('All downloads failed.'),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topCenter,
      );
    }

    chatProvider.clearGroupMsgSelectionIndexes();
    chatProvider.setIsGroupMsgSelectionMode(false);
  }

  // ************** click on delete icon ********************
  void handleOnClickDeleteMsg() {
    // ConfirmCenterModal.show(
    //   context,
    //   headerTitle: 'Delete Confirm',
    //   modalTitle: 'Are you sure you want to delete message?',
    //   confirmBtnTitle: 'Delete',
    //   cancelBtnTitle: 'Cancel',
    //   backgroundColor: AppColorTheme.darkDanger,
    //   textColor: AppColorTheme.white,
    //   onPressConfirm: confirmDeleteSelectedMsgs,
    //   onPressCancel: () => Navigator.of(context).pop()
    // );
  }

  void confirmDeleteSelectedMsgs() async {
    try {
      final chatProvider = context.read<ChatProvider>();
      final dataListProvider = context.read<DataListProvider>();
      final currentUser = await CommonFunctions.getLoginUser();

      var selectedMsgIds = [];
      if (chatProvider.selectedGroupMsgs.isNotEmpty) {
        selectedMsgIds = chatProvider.selectedGroupMsgs.map((item) {
          return item['id'];
        }).toList();
      }
      final isAdmin = await CommonFunctions.checkIsAdmin(
          dataListProvider.openedChatGroupData['tGroupAdmins']);

      final groupUserId = dataListProvider.openedChatGroupData['_id'];
      final currentUserId = currentUser['iUserId'];

      if (groupUserId == null || currentUserId == null) {
        return;
      }

      final response = await CommonFunctions.deleteUserMessage(
          selectedMsgIds, groupUserId, "", isAdmin ? 1 : 0, currentUserId);
      if (response['status'] == 200) {
        if (response != null && response['fullMessageData'].isNotEmpty) {}
        if (!mounted) {
          return;
        }
        final dataListProvider = context.read<DataListProvider>();
        CommonFunctions.replaceMatchingItemsById(
            context: context,
            originalList: dataListProvider.groupMessagesList,
            updatedList: response['fullMessageData']);
        Navigator.of(context).pop();
        if (response['status'] == 200) {
          if (response != null && response['fullMessageData'].isNotEmpty) {}

          final originalList = CommonFunctions.replaceMatchingItemsById(
              context: context,
              originalList: dataListProvider.groupMessagesList,
              updatedList: response['fullMessageData']);
          // debugPrint("originalList $originalList", wrapWidth: 1024);
          dataListProvider.setGroupMessageList(originalList);
        }
        chatProvider.setGroupMsgSelectionMode(false);
        chatProvider.clearGroupMsgSelectionIndexes();
      }
    } catch (error) {
      // print("Error while deleting user chat messages $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    return SizedBox(
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CommonWidgets.selectedMsgHeaderIcon(
                  iconName: AppMedia.leftArrow,
                  onIconTap: handleOnClickBackSelectedGroupMsg),
              Text(
                "${chatProvider.selectedGroupMsgs.length} Selected",
                style: AppFontStyles.dmSansMedium
                    .copyWith(fontSize: 14, color: AppColorTheme.dark87),
              )
            ],
          ),
          Row(
            children: [
              if (chatProvider.isShowReplyGroupIcon)
                CommonWidgets.selectedMsgHeaderIcon(
                    iconName: AppMedia.reply,
                    onIconTap: handleOnClickReplyMsg),
              if (chatProvider.isShowEditGroupIcon)
                CommonWidgets.selectedMsgHeaderIcon(
                    iconName: AppMedia.edit,
                    onIconTap: handleOnClickEditMsg),
              CommonWidgets.selectedMsgHeaderIcon(
                  iconName: AppMedia.forward,
                  onIconTap: () {
                    handleOnClickForwardMsg(context);
                  }),
              if (chatProvider.isShowDownloadGroupIcon)
                CommonWidgets.selectedMsgHeaderIcon(
                    iconName: AppMedia.download,
                    onIconTap: handleOnClickDownloadMsg),
              if (chatProvider.isShowDeleteGroupIcon)
                CommonWidgets.selectedMsgHeaderIcon(
                    iconName: AppMedia.delete,
                    onIconTap: handleOnClickDeleteMsg),
            ],
          )
        ],
      ),
    );
  }
}
