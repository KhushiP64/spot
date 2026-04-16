import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/confirm_bottom_modal.dart';
import 'package:spot/ui/widgets/common_widgets/dashed_line_painter.dart';
import 'package:spot/ui/widgets/user_chat_widgets/chat_bottom_menu_title.dart';

class UserChatHeaderMenu extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const UserChatHeaderMenu({super.key, required this.currentUser});

  @override
  State<UserChatHeaderMenu> createState() => _UserChatHeaderMenuState();
}

class _UserChatHeaderMenuState extends State<UserChatHeaderMenu> {
// ******************** handle on press cancel btn **************************
  void onPressCancelMenu() {
    Navigator.of(context).pop();
  }

// ******************** handle on press delete chat **************************
  void onPressMenuTitle(String type) async {
    final dataListProvider = context.read<DataListProvider>();

    final nowUtc = DateTime.now().toUtc();
    final timestamp = nowUtc.millisecondsSinceEpoch;
    final currentUser = await CommonFunctions.getLoginUser();
    final id =
        "${dataListProvider.openedChatUserData['iUserId']}_${currentUser['iUserId']}_$timestamp";

    if (type == 'delete') {
      CommonModal.show(
          context: context,
          child: ConfirmBottomModal(
              headerTitle: 'Delete Confirm',
              modalTitle:
                  "Deleting the chat from your history will be permanent. And will remove your connection with ${dataListProvider.openedChatUserData['vFullName']}. ${dataListProvider.openedChatUserData['vFullName']} can still view this chat.",
              confirmBtnTitle: 'Delete',
              cancelBtnTitle: 'Cancel',
              onPressConfirm: () => confirmDeleteUserChat(context),
              onPressCancel: () => Navigator.of(context).pop(),
              backgroundColor: AppColorTheme.darkDanger,
              textColor: AppColorTheme.white));
    } else if (type == 'cancelRequest') {
      try {
        final response = await CommonFunctions.cancelUserChatRequest(
            dataListProvider.openedChatUserData['iUserId']);
        // print("response cancel chat request ----- $response");
        Navigator.of(context).pop();
        if (response['status'] == 200) {
          SocketMessageEvents.sendMessageEvent(
              receiverChatID: dataListProvider.openedChatUserData['iUserId'],
              senderChatID: currentUser['iUserId'],
              content: "",
              imageDataArr: [],
              vReplyMsg: "",
              vReplyMsgId: "",
              vReplyFileName: "",
              id: id,
              iRequestMsg: 4,
              isForwardMsg: 0,
              isForwardMsgId: "",
              isDeleteprofile: 0,
              chat: 1,
              communicationType: 1);
          dataListProvider.getChatListData();
        }
      } catch (error) {
        // print("error while canceling user chat request $error");
      }
    }
  }

  // ********************* delete user chat ************************
  void confirmDeleteUserChat(BuildContext ctx) async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final nowUtc = DateTime.now().toUtc();
      final timestamp = nowUtc.millisecondsSinceEpoch;
      final currentUser = await CommonFunctions.getLoginUser();
      final id =
          "${dataListProvider.openedChatUserData['iUserId']}_${currentUser['iUserId']}_$timestamp";
      final userData = await CommonFunctions.getUserData();
      SocketMessageEvents.sendMessageEvent(
          receiverChatID: dataListProvider.openedChatUserData['iUserId'],
          senderChatID: currentUser['iUserId'],
          content: "",
          imageDataArr: [],
          vReplyMsg: "",
          vReplyMsgId: "",
          vReplyFileName: "",
          id: id,
          iRequestMsg: 5,
          isForwardMsg: 0,
          isForwardMsgId: "",
          isDeleteprofile: 0,
          chat: 1,
          communicationType: 1);

      final response = await CommonFunctions.deleteAllChatUser(
          dataListProvider.openedChatUserData["iUserId"]);
      // print("response $response");
      dataListProvider.getChatListData();
      if (response['status'] == 200) {
        SocketMessageEvents.allUsersGetNewSts(
            userData['tToken'], dataListProvider.openedChatUserData['iUserId']);
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      Navigator.of(ctx).pop();
      Navigator.pop(context);
      Navigator.pushNamed(context, '/chatList');
    } catch (error) {
      // print("Error while calling delete chat api $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataListProvider>(
        builder: (context, dataListProvider, child) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ChatBottomMenuTitle(
            menuTitle: "Pin Chat",
            onPressMenuTitle: () => onPressMenuTitle('pin'),
            // isDisabled: dataListProvider.openedChatUserData['iRequestMsg'] == 1 ? true : false
          ),
          ChatBottomMenuTitle(
            menuTitle: "Mute",
            onPressMenuTitle: () => onPressMenuTitle('mute'),
            // isDisabled: dataListProvider.openedChatUserData['iRequestMsg'] == 1 ? true : false
          ),
          SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(painter: DashedLinePainter()),
          ),
          ChatBottomMenuTitle(
              menuTitle: "Delete Chat",
              onPressMenuTitle: () => onPressMenuTitle('delete'),
              isDisabled:
                  dataListProvider.openedChatUserData['iRequestMsg'] == 1
                      ? true
                      : false),
          dataListProvider.openedChatUserData['iRequestMsg'] == 1
              ? ChatBottomMenuTitle(
                  menuTitle: "Cancel Chat Request",
                  onPressMenuTitle: () => onPressMenuTitle('cancelRequest'),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Button(
              onPressed: onPressCancelMenu,
              title: 'Cancel',
              backgroundColor: AppColorTheme.primary,
              textColor: AppColorTheme.white,
            ),
          ),
        ],
      );
    });
  }
}
