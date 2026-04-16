import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import '../../../core/themes.dart';

class MessageMenuBottomsheet extends StatefulWidget {
  const MessageMenuBottomsheet({super.key});

  @override
  State<MessageMenuBottomsheet> createState() => _MessageMenuBottomsheetState();
}

class _MessageMenuBottomsheetState extends State<MessageMenuBottomsheet> {
  bool isEmojiOptionList = false;
  PlatformFile? selectedUploadFile;
  String uploadedFileThumb = "";

  // ****************** handle on Press formatting option ****************
  void handleOnPressFormattingOption() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setIsShowFormatter(true);
    Navigator.of(context).pop();
  }

  // ****************** handle on Press emoji ****************

  void handleOnPressEmojiListOption() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setEmojiList(true);
    Navigator.of(context).pop();
  }

  void handleOnPressUploadFile() async {
    final chatProvider = context.read<ChatProvider>();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: false,
      );
      if (result != null && result.files.isNotEmpty) {
        if (result.files.length == 1 && result.files.first.path != null) {
          final pf = result.files.first;
          chatProvider.startUserChatFileUpload(
            filePath: pf.path!,
            fileName: pf.name,
          );
        } else {
          chatProvider.startUserChatFileUploadMultiple(files: result.files);
        }

        /// ✅ Close the bottomsheet after processing the file(s)
        Navigator.of(context).pop();
      }
    } catch (e) {
      // print('Error picking documents: $e');
    }
  }

  // ****************** handle on Press cancel menu ****************
  void onPressCancelMenu() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12.h),
        CommonWidgets.chatSendMoreOptions(handleOnPressFormattingOption,
            AppMedia.textFormat, "Formatting Options"),
        CommonWidgets.chatSendMoreOptions(handleOnPressEmojiListOption,
            AppMedia.chatEmojiOptionIcon, "Emoji"),
        CommonWidgets.chatSendMoreOptions(
            handleOnPressUploadFile, AppMedia.uploadIcon, "Upload File"),
        SizedBox(height: 12.h),
        Button(
          onPressed: onPressCancelMenu,
          title: 'Cancel',
          backgroundColor: AppColorTheme.primary,
          textColor: AppColorTheme.white,
        ),
      ],
    );
  }
}
