import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/confirm_bottom_modal.dart';
import 'package:spot/ui/widgets/user_chat_widgets/chat_bottom_menu_title.dart';
import 'package:spot/ui/widgets/user_chat_widgets/group_edit_menu.dart';
import 'package:spot/ui/widgets/user_chat_widgets/group_info_menu.dart';

class UserGroupHeaderMenu extends StatefulWidget {
  final BuildContext ctx;

  const UserGroupHeaderMenu({super.key, required this.ctx});

  @override
  State<UserGroupHeaderMenu> createState() => _UserGroupHeaderMenuState();
}

class _UserGroupHeaderMenuState extends State<UserGroupHeaderMenu> {
  @override
  void initState() {
    super.initState();
  }

  // ******************** handle on press cancel btn **************************
  void onPressCancelMenu() {
    Navigator.of(context).pop();
  }

  // ******************** handle on press menu title **************************
  void onPressMenuTitle(String type) async {
    final dataListProvider = context.read<DataListProvider>();
    if (type == 'info') {
      final list = await CommonFunctions.getGroupUserList(
          dataListProvider.openedChatGroupData['_id'], '', 1);
      // debugPrint("list ----------------------- $list", wrapWidth: 1024);
      dataListProvider.setGroupInfoMemberList(list);
      if (!mounted) {
        return;
      }
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
          backgroundColor: const Color(0xffEEF2F5),
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: GroupInfoMenu(
                  groupId: dataListProvider.openedChatGroupData['_id']),
            );
          });
    } else if (type == 'edit') {
      final singleUserData = await CommonFunctions.getSingleUser(
          dataListProvider.openedChatGroupData['iCreatedBy']);

      if (!mounted) {
        return;
      }
      final updatedGroupData = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (BuildContext context) {
            return GroupEditMenu(
                singleUserData: singleUserData, ctx: widget.ctx);
          });

      if (updatedGroupData != null) {
        Navigator.of(context).pop(updatedGroupData);
      }
    } else if (type == 'delete') {
      ConfirmModal.show(context,
          headerTitle: 'Delete Confirm',
          modalTitle:
              'Deleting the chat from your history will be permanent. The group members can still view this chat.',
          confirmBtnTitle: 'Delete',
          cancelBtnTitle: 'Cancel',
          backgroundColor: AppColorTheme.darkDanger,
          textColor: AppColorTheme.white,
          onPressConfirm: () => handleConfirmDeleteAllChat(),
          onPressCancel: () => Navigator.of(context).pop());
    } else if (type == 'deleteGroup') {
      ConfirmModal.show(context,
          headerTitle: 'Delete Confirm',
          modalTitle: 'Are you sure you want to delete group?',
          confirmBtnTitle: 'Delete',
          cancelBtnTitle: 'Cancel',
          backgroundColor: AppColorTheme.darkDanger,
          textColor: AppColorTheme.white,
          onPressConfirm: () => handleConfirmDeleteGroupForMe(),
          onPressCancel: () => Navigator.of(context).pop());
    } else if (type == 'exit') {
      ConfirmModal.show(context,
          headerTitle: 'Exit from group',
          modalTitle: 'Are you sure you want to exit from the group?',
          confirmBtnTitle: 'Exit Group',
          cancelBtnTitle: 'Cancel',
          backgroundColor: AppColorTheme.darkDanger,
          textColor: AppColorTheme.white,
          onPressConfirm: () => handleConfirmExitGroup(),
          onPressCancel: () => Navigator.of(context).pop());
    }
  }

  // ********************** handle Confirm Exit Group ***********************
  void handleConfirmExitGroup() async {
    final dataListProvider = context.read<DataListProvider>();
    final response = await CommonFunctions.exitGroupChat(
        dataListProvider.openedChatGroupData['_id']);
    // debugPrint("exit response $response", wrapWidth: 1024);
    if (!mounted) {
      return;
    }
    if (response['status'] == 200) {
      Navigator.of(context).pop();
      Navigator.of(widget.ctx).pop();
      // Navigator.pushNamed(context, '/chatList', arguments: {'tabIndex': 1});
    }
  }

  // ********************** handle Confirm Delete All Chat ***********************
  void handleConfirmDeleteAllChat() async {
    final dataListProvider = context.read<DataListProvider>();
    final response = await CommonFunctions.deleteGroupAllChat(
        dataListProvider.openedChatGroupData['_id'], 0);
    // debugPrint("response $response", wrapWidth: 1024);
    if (response['status'] == 200) {
      Navigator.of(context).pop();
      Navigator.of(widget.ctx).pop();
      getGroupMessages();
    }
  }

  // ********************** handle Delete group for me ***********************
  void handleConfirmDeleteGroupForMe() async {
    final dataListProvider = context.read<DataListProvider>();
    final response = await CommonFunctions.deleteGroupForMe(
        dataListProvider.openedChatGroupData['_id']);
    if (response['status'] == 200) {
      if (!mounted) {
        return;
      }
      dataListProvider.getGroupListData();
      Navigator.of(context).pop();
      Navigator.of(widget.ctx).pop();
      Navigator.pushNamed(context, '/chatList', arguments: {'tabIndex': 1});
    }
  }

  // ********************* get group messages *********************
  void getGroupMessages() async {
    final dataListProvider = context.read<DataListProvider>();
    final currentLoginUser = await CommonFunctions.getLoginUser();
    final isAdmin = currentLoginUser['iUserId'] ==
            dataListProvider.openedChatGroupData['_id']
        ? 1
        : 0;

    final groupMsgs = await CommonFunctions.getGroupMessages(
        dataListProvider.openedChatGroupData['_id'], isAdmin, "");
    // debugPrint("groupMsgs $groupMsgs", wrapWidth: 1024);
    dataListProvider.setGroupMessageAllData(groupMsgs);

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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 12),
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
      child: Consumer<DataListProvider>(
          builder: (context, dataListProvider, child) {
        final menu = dataListProvider.groupMessages['menu'];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            menu == 0 || menu == 1 || menu == 2 || menu == 4
                ? ChatBottomMenuTitle(
                    menuTitle: "Group Info",
                    onPressMenuTitle: () => onPressMenuTitle("info"))
                : Container(),
            menu == 2 || menu == 4
                ? ChatBottomMenuTitle(
                    menuTitle: "Edit Group",
                    onPressMenuTitle: () => onPressMenuTitle("edit"))
                : Container(),
            menu == 0 || menu == 1 || menu == 2 || menu == 3 || menu == 4
                ? ChatBottomMenuTitle(
                    menuTitle: "Delete All Chat For Me",
                    onPressMenuTitle: () => onPressMenuTitle("delete"),
                    isDisabled: menu == 0 || menu == 2 || menu == 3 || menu == 4
                        ? false
                        : true)
                : Container(),
            menu == 3
                ? ChatBottomMenuTitle(
                    menuTitle: "Delete group For Me",
                    onPressMenuTitle: () => onPressMenuTitle("deleteGroup"))
                : Container(),
            menu == 0 || menu == 2 || menu == 4
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ChatBottomMenuTitle(
                        menuTitle: "Exit Group",
                        onPressMenuTitle: () => onPressMenuTitle("exit"),
                        isDisabled: menu == 4 ? true : false),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(bottom: 22, right: 12),
              child: Button(
                  onPressed: onPressCancelMenu,
                  title: 'Cancel',
                  backgroundColor: AppColorTheme.primary,
                  textColor: AppColorTheme.white,
                  width: MediaQuery.of(context).size.width),
            ),
          ],
        );
      }),
    );
  }
}
