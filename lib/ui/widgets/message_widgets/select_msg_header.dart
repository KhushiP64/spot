import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/confirm_center_modal.dart';
import 'package:toastification/toastification.dart';
import '../chat_list_widgets/forward_list_bottom_sheet.dart';

class SelectMsgHeader extends StatefulWidget {
  const SelectMsgHeader({super.key});

  @override
  State<SelectMsgHeader> createState() => _SelectMsgHeaderState();
}

class _SelectMsgHeaderState extends State<SelectMsgHeader> {
  final TextEditingController searchValue = TextEditingController();
  final TextEditingController vGroupName = TextEditingController();
  final TextEditingController tDescription = TextEditingController();
  TextEditingController searchAddUser = TextEditingController();
  quill.QuillController _controller = quill.QuillController.basic();

  bool isGroupNameNotValid = true;
  bool isSubmit = false;
  File? chooseProfile;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // ******************* handle close forward list Modal ******************
  void closeForwardListModal(BuildContext ctx) {
    setState(() {
      _currentPage = 1;
      searchController.clear();
    });
    Navigator.of(ctx).pop();
  }

  void closeCreateGroupModal() async {
    Navigator.of(context).pop();
    setState(() {
      isSubmit = true;
      isGroupNameNotValid = false;
    });
  }

  void onChangedSearchAddUser({
    required String value,
    required List listData,
    required String name
  }) async {
    final provider = context.read<DataListProvider>();
    final searchText = value.trim().toLowerCase();

   setState(() {
      if (searchText.isEmpty) {
        // provider.setUserChatList(provider.userChatListOriginalData);
        provider.getUserChatListData(page: 1, searchText: '');
      } else {
        // provider.setUserChatList(filterData);
        //to responsive mobile tablet etc
        provider.getUserChatListData(page: 1, searchText: searchText);
      }
    });
  }

  // ************** click on back icon ********************
  void handleOnClickBackSelectedMsg() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setIsMsgSelectionMode(false);
    chatProvider.uploadFiles.clear();
    chatProvider.clearMsgSelectionIndexes();
    chatProvider.setUserEditingStop(false);
    // chatProvider.setUserReplyingStop(false);
    // chatProvider.setFileUploadingStop(false);
  }

  // ************** click on reply icon ********************
  void handleOnClickReplyMsg() {
    final chatProvider = context.read<ChatProvider>();
    // print("Selected Reply Messages: ${chatProvider.selectedMsgs}");

    if (chatProvider.isUserReplying) {
      chatProvider.stopUserChatReplying();
    } else {
      chatProvider.stopUserChatEditing();
      chatProvider.startUserChatReplying();
    }
    chatProvider.setMsgSelectionMode(false);
    // chatProvider.clearMsgSelectionIndexes();
  }

  // ************** click on edit icon ********************
  void handleOnClickEditMsg() {
    final chatProvider = context.read<ChatProvider>();

    chatProvider.setMsgSelectionMode(false);
    if (chatProvider.isUserEditing) {
      chatProvider.stopUserChatEditing();
    } else {
      chatProvider.stopUserChatReplying();
      chatProvider.startUserChatEditing();
      // if (chatProvider.isUserEditing) {
      //   print("user start to the editing----------");
      //   _controller = quill.QuillController(
      //     document: quill.Document()..toPlainText(),
      //     selection: const TextSelection.collapsed(offset: 0),
      //   );
      // }
      //

      if (chatProvider.isUserEditing && _controller.document.toPlainText().trim() != chatProvider.userEditingText.trim()) {
        _controller = quill.QuillController(
          document: quill.Document()..insert(0, chatProvider.userEditingText),
          selection: TextSelection.collapsed(offset: chatProvider.userEditingText.length),
        );
      }
    }
  }

  // ************** click on forward icon ********************
  void handleOnClickForwardMsg(BuildContext ctx) async {
    try {
      final dataListProvider = Provider.of<DataListProvider>(ctx, listen: false);
      await dataListProvider.getForwardUsers();
      final currentUser = await CommonFunctions.getLoginUser();
      if (!mounted) return; // safety before showing UI

      CommonModal.show(
        context: context,
        child: ForwardBottomSheet(
          context: ctx,
          currentUser: currentUser,
          searchUsers: searchController,
          controller: _scrollController,
          closeForwardListModal: () {
            closeForwardListModal(ctx);
          },
          isGroupMsgs: false
        )
      );
    } catch (error) {
      // print("Error while getting forward user list:--- $error");
    }
  }

  // ************** click on download icon ********************
  void handleOnClickDownloadMsg() async {
    final chatProvider = context.read<ChatProvider>();
    if (!chatProvider.isShowDownloadIcon || chatProvider.selectedMsgs.isEmpty)
      return;

    int successCount = 0;
    int failCount = 0;

    for (var selectedImage in chatProvider.selectedMsgs) {
      final success = await CommonFunctions.downloadFileWithPermission(selectedImage['vFiles'], selectedImage['isOriginalName'], context);

      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    // Show a single summary toast after all downloads
    if (successCount == chatProvider.selectedMsgs.length) {
      toastification.show(
        context: context,
        title: chatProvider.selectedMsgs.length == 1
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

    chatProvider.clearSelectedImage();
    chatProvider.clearMsgSelectionIndexes();
    chatProvider.setMsgSelectionMode(false);
  }

  // ************** click on delete icon ********************
  void handleOnClickDeleteMsg() {
    // ConfirmCenterModal.show(context,
    //     headerTitle: 'Delete Confirm',
    //     modalTitle: 'Are you sure you want to delete message?',
    //     confirmBtnTitle: 'Delete',
    //     cancelBtnTitle: 'Cancel',
    //     backgroundColor: AppColorTheme.darkDanger,
    //     textColor: AppColorTheme.white,
    //     onPressConfirm: confirmDeleteSelectedMsgs,
    //     onPressCancel: () => Navigator.of(context).pop());
  }

  void confirmDeleteSelectedMsgs() async {
    // print('deleteeeeeee');
    try {
      final chatProvider = context.read<ChatProvider>();
      final dataListProvider = context.read<DataListProvider>();
      var selectedMsgIds = [];
      // print('chatProvider.selectedMsgs ${chatProvider.selectedMsgs}');
      if (chatProvider.selectedMsgs.isNotEmpty) {
        selectedMsgIds = chatProvider.selectedMsgs.map((item) {
          return item['id'];
        }).toList();
      }

      final currentUser = await CommonFunctions.getLoginUser();
      final response = await CommonFunctions.deleteUserMessage(selectedMsgIds, "", dataListProvider.openedChatUserData['iUserId'], 0, currentUser['iUserId']);
      // print('Response delete messages ${response['fullMessageData']}');
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      if (response['status'] == 200) {
        if (response != null && response['fullMessageData'].isNotEmpty) {}
        final dataListProvider = context.read<DataListProvider>();
        final originalList = CommonFunctions.replaceMatchingItemsById(
          context: context,
          originalList: dataListProvider.userMessagesList,
          updatedList: response['fullMessageData']
        );
        // debugPrint("originalList $originalList", wrapWidth: 1024);
        dataListProvider.setUserMessageList(originalList);
      }
      chatProvider.setMsgSelectionMode(false);
      chatProvider.clearMsgSelectionIndexes();
    } catch (error) {
      // print("Error while deleting user chat messages $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return SizedBox(
      height: 64.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: 4.w,),
              CommonWidgets.selectedMsgHeaderIcon(iconName: AppMedia.selectedHeaderBack, onIconTap: handleOnClickBackSelectedMsg),
              Text("${chatProvider.selectedMsgs.length} Selected", style: AppFontStyles.dmSansMedium.copyWith(fontSize: 14.sp, color: AppColorTheme.black87))
            ],
          ),
          Row(
            children: [
              if (chatProvider.isShowPinMsgIcon)
                CommonWidgets.selectedMsgHeaderIcon(iconName: AppMedia.pin, onIconTap: handleOnClickReplyMsg),
              if (chatProvider.isShowReplyIcon)
                CommonWidgets.selectedMsgHeaderIcon(iconName: AppMedia.reply, onIconTap: handleOnClickReplyMsg),
              if (chatProvider.isShowEditIcon)
                CommonWidgets.selectedMsgHeaderIcon(iconName: AppMedia.msgEdit, onIconTap: handleOnClickEditMsg),
              CommonWidgets.selectedMsgHeaderIcon(iconName: AppMedia.forward, onIconTap: () => handleOnClickForwardMsg(context)),
              if (chatProvider.isShowDownloadIcon)
                CommonWidgets.selectedMsgHeaderIcon(iconName: AppMedia.download, onIconTap: handleOnClickDownloadMsg),
              if (chatProvider.isShowDeleteIcon)
                CommonWidgets.selectedMsgHeaderIcon(iconName: AppMedia.delete, onIconTap: handleOnClickDeleteMsg),
              SizedBox(width: 4.w,)
            ],
          )
        ],
      ),
    );
  }
}
