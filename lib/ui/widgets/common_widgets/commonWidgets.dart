import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/input.dart';
import 'package:spot/ui/widgets/common_widgets/large_profile_pic.dart';
import 'package:spot/ui/widgets/message_widgets/convert_decoded_text_to_html_style.dart';
import 'package:spot/ui/widgets/message_widgets/reply_message_user_name_and_time.dart';

class CommonWidgets {
  // ********************** Modal widgets *************************
  static Widget groupInfoValue(String groupInfoValueTxt) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        child: Text(groupInfoValueTxt, style: AppStyles.groupInfoValue));
  }

  static Widget modalSubTitle(String modalSubTitleTxt,
      {int paddingBottom = 16}) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom.h),
      child: Text(
        modalSubTitleTxt,
        style: AppStyles.modalSubTitleStyle,
      ),
    );
  }

  static Widget modalMainTitle(String modalMainTitleTxt) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(modalMainTitleTxt, style: AppStyles.modalMainTitleStyle),
    );
  }

  static Widget modalName(String modalNameTxt) {
    return Text(modalNameTxt,
        style: AppStyles.modalNameStyle, textAlign: TextAlign.center);
  }

  static BoxDecoration modalCardBoxDecoration() {
    return BoxDecoration(
      color: AppColorTheme.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: const Color.fromRGBO(10, 41, 55, 0.16),
          offset: Offset(0, 1.w),
          blurRadius: 1.r,
        ),
      ],
    );
  }

  // *********************** profile seperator line ***********************
  static Widget seperatorLine() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.8.w, color: AppColorTheme.border),
        ),
      ),
    );
  }

  // ************************** right check mark for add user in group and group chat permission ****************************
  static Widget rightCheckMark(bool isSelected, {double marginRight = 18}) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 0, right: marginRight.w),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              width: 2.w,
              strokeAlign: BorderSide.strokeAlignInside,
              color: isSelected ? AppColorTheme.primary : AppColorTheme.border),
          color: isSelected ? AppColorTheme.primary : AppColorTheme.transparent,
        ),
        width: 20.w,
        height: 20.h,
        child: isSelected
            ? SvgPicture.asset(AppMedia.checkIcon,
                color: AppColorTheme.white,
                fit: BoxFit.contain,
                width: 6.w,
                height: 7.h)
            : null,
      ),
    );
  }

  // *********************** Common Error Texts **********************
  static Widget errorText(String errorMsg) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(errorMsg, style: AppStyles.errorTextStyle),
    );
  }

  // ************************** divider *******************************
  static Widget divider(
      {double paddingHorizontal = 8, double paddingTop = 13}) {
    return Container(
      margin: EdgeInsets.only(
          left: paddingHorizontal.w,
          right: paddingHorizontal.w,
          top: paddingTop.h,
          bottom: 12.h),
      height: 1.h,
      decoration: BoxDecoration(
        color: AppColorTheme.border,
        borderRadius: BorderRadius.all(Radius.circular(6.r)),
      ),
    );
  }

  // ********************** Chat options Text Formatter, Emojis, Upload file ******************************
  static Widget chatSendMoreOptions(VoidCallback handleOnPressFormattingOption,
      String svgIcon, String menuText) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: InkWell(
        onTap: handleOnPressFormattingOption,
        child: Padding(
          padding: EdgeInsets.only(top: 9.h, bottom: 9.h, left: 8.w),
          child: Row(
            children: [
              SvgPicture.asset(svgIcon, color: AppColorTheme.muted),
              SizedBox(width: 12.w),
              Text(
                menuText,
                style: AppFontStyles.dmSansRegular.copyWith(
                  color: AppColorTheme.dark87,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ************************* Chat Text Formatter Icons ************************
  static Widget chatTextFormatterIcons(
      VoidCallback handleOnPressIcon, String svgPicture, bool isSelected) {
    return Padding(
        padding: EdgeInsets.only(right: 14.w),
        child: InkWell(
            onTap: handleOnPressIcon,
            child: SvgPicture.asset(
                width: 22.w,
                height: 22.h,
                svgPicture,
                color: isSelected
                    ? const Color(0xff4CC9FE)
                    : AppColorTheme.muted)));
  }

  // ************************* chat formatter text color option *********************
  static Widget chatFormatterTextColorOpotion(
      VoidCallback handleOnPressChangeTextColor, Color selectedColor) {
    return InkWell(
        onTap: handleOnPressChangeTextColor,
        child: Container(
            width: 22.w,
            height: 22.h,
            margin: EdgeInsets.only(right: 14.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50.r)),
                color: selectedColor)));
  }

  // ************************ color bar for message text formatter *************************
  static Widget colorBar(
      ValueChanged<int> onTapSelectColor, int selectedColorIndex) {
    return Container(
      padding: EdgeInsets.all(8.w),
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: AppStyles.formatterModalContainerDecoration,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              List.generate(AppColorTheme.textFormatColors.length, (index) {
            final bool isSelected = selectedColorIndex == index;
            return GestureDetector(
              onTap: () {
                onTapSelectColor(index);
              },
              child: Container(
                padding: EdgeInsets.all(1.w), // space for border
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: AppColorTheme.black40,
                          width: 1.5,
                        )
                      : null,
                ),
                child: Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppColorTheme.textFormatColors[index],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            );
          })),
    );
  }

  // ********************** message formatter *************************
  static Widget messageFormatter(
    bool isBoldSelected,
    bool isItalicSelected,
    bool isUnderlineSelected,
    bool isStrikeThroughSelected,
    bool isBulletSelected,
    bool isLinkSelected,
    Color selectedColor,
    VoidCallback onPressLinkIcon,
    VoidCallback handleOnPressChangeTextColor,
    VoidCallback handleCloseFormatter,
    ValueChanged<quill.Attribute> toggleAttribute,
  ) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      return chatProvider.isShowFormatter
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      /// Formatter options
                      CommonWidgets.chatTextFormatterIcons(
                          () => toggleAttribute(quill.Attribute.bold),
                          AppMedia.bold,
                          isBoldSelected),
                      CommonWidgets.chatTextFormatterIcons(
                          () => toggleAttribute(quill.Attribute.italic),
                          AppMedia.italic,
                          isItalicSelected),
                      CommonWidgets.chatTextFormatterIcons(
                          () => toggleAttribute(quill.Attribute.underline),
                          AppMedia.underline,
                          isUnderlineSelected),
                      CommonWidgets.chatFormatterTextColorOpotion(
                          handleOnPressChangeTextColor, selectedColor),
                      CommonWidgets.chatTextFormatterIcons(
                          () => toggleAttribute(quill.Attribute.strikeThrough),
                          AppMedia.minus,
                          isStrikeThroughSelected),
                      CommonWidgets.chatTextFormatterIcons(
                          () => toggleAttribute(quill.Attribute.ul),
                          AppMedia.listBullet,
                          isBulletSelected),
                      CommonWidgets.chatTextFormatterIcons(
                          () => onPressLinkIcon(),
                          AppMedia.link,
                          isLinkSelected),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppMedia.verticalDivider,
                          height: 23.h, width: 23.w),
                      SizedBox(
                        width: 10.w,
                      ),
                      InkWell(
                          onTap: handleCloseFormatter,
                          child: SvgPicture.asset(AppMedia.closeFormatter,
                              height: 21.h, width: 21.w))
                    ],
                  ),
                ],
              ),
            )
          : Container();
    });
  }

  // **************************** modal for send link into message ****************************
  static Widget openLinkOptionSheet(
    TextEditingController textController,
    TextEditingController linkController,
    Function(String) onChangedText,
    Function(String) onChangedLink,
    VoidCallback handleOnPressApplyLink,
    VoidCallback handleOnTapOutsideLinkModal,
  ) {
    return GestureDetector(
      onTap: handleOnTapOutsideLinkModal,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.symmetric(vertical: 10.h),
              decoration: AppStyles.formatterModalContainerDecoration,
              child: Column(
                children: [
                  Input(
                    title: 'Text',
                    // isRequired: true,
                    // isError: isSubmit && isPassNotValid,
                    inputValue: textController,
                    onChanged: (value) {
                      onChangedText(value);
                    },
                  ),
                  Input(
                    title: 'Link',
                    // isRequired: true,
                    // isError: isSubmit && isPassNotValid,
                    inputValue: linkController,
                    onChanged: (value) {
                      onChangedLink(value);
                    },
                  ),
                  SizedBox(
                    height: 14.h,
                  ),
                  Button(
                    title: "Apply",
                    onPressed: handleOnPressApplyLink,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // *************************** Custom Emoji modal for message ******************************
  static Widget openEmojiOptionList(
      VoidCallback handleOnCloseEmojiModal, ValueChanged handleOnTapEmoji) {
    return GestureDetector(
      // onTap: handleOnCloseEmojiModal,
      child: Container(
        decoration: AppStyles.formatterModalContainerDecoration,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Add emoji",
                    style: AppFontStyles.dmSansMedium
                        .copyWith(fontSize: 15.sp, color: AppColorTheme.muted)),
                InkWell(
                  onTap: handleOnCloseEmojiModal,
                  child: SvgPicture.asset(
                    AppMedia.closeFormatter,
                    color: AppColorTheme.muted,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AppMedia.emojiIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
              ),
              itemBuilder: (context, i) {
                final item = AppMedia.emojiIcons[i];
                final path = item['vEmojiPath'] as String;

                return InkWell(
                  borderRadius: BorderRadius.circular(6.r),
                  onTap: () {
                    handleOnTapEmoji(path);
                  },
                  child: Image.asset(
                    path,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.error),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  // ******************* emoji builder for add emoji into message(Quill Editor) *********************
  static Widget emojiEmbedBuilder(
    BuildContext context,
    quill.Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    if (node.value.type == 'image') {
      final String emojiPath = node.value.data;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.0.w),
        child: Image.asset(
          emojiPath,
          width: 16.w,
          height: 16.h,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // **************************** Upload preview widget ****************************
  static Widget uploadPreviewWidget(
      ChatProvider chatProvider, List<String> allowedFileTypes) {
    if (!chatProvider.isUploadingFile || !chatProvider.uploadHasFile) {
      return const SizedBox.shrink();
    }
    // Multiple files
    if (chatProvider.uploadFiles.isNotEmpty) {
      return Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200.h),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: chatProvider.uploadFiles.length,
                itemBuilder: (context, index) {
                  final fileData = chatProvider.uploadFiles[index];
                  return CommonWidgets.singleFilePreview(
                      thumbPath: fileData.path ?? "",
                      fileName: fileData.name,
                      onRemove: () => chatProvider.removeUploadFile(index),
                      allowedFileTypes: allowedFileTypes);
                }),
          )
        ],
      );
    }
    return const SizedBox.shrink();
  }

  // **************************** single file preview in sending message *******************************
  static Widget singleFilePreview(
      {required String thumbPath,
      required String fileName,
      required VoidCallback onRemove,
      required List<String> allowedFileTypes}) {
    final file = File(thumbPath);
    final exists = thumbPath.isNotEmpty && file.existsSync();
    if (!exists) return const SizedBox.shrink();

    final isImage = CommonFunctions.isImage(fileName);
    final extension = fileName.split('.').last.toLowerCase();
    final isBlocked = !allowedFileTypes.contains(extension);
    final fileSizeMB = file.lengthSync() / (1024 * 1024);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      color: Colors.white,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: isBlocked
                ? LargeProfilePic(
                    profilePic: AppMedia.imageThumb,
                    profileSize: 42,
                    borderRadius: 6,
                  )
                : isImage
                    ? LargeProfilePic(
                        profilePic: file.path,
                        borderRadius: 6,
                        isFilePath: true,
                        profileSize: 42,
                      )
                    : SvgPicture.asset(AppMedia.file,
                        width: 43.w, height: 43.h),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBlocked
                      ? 'Document ${fileName.split('.').last} not allowed'
                      : fileName,
                  maxLines: isBlocked ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyles.dmSansRegular.copyWith(
                    fontSize: 16.sp,
                    color: AppColorTheme.inputTitle,
                  ),
                ),
                if (!isBlocked) SizedBox(height: 4.h),
                if (!isBlocked)
                  Text(
                    '${fileSizeMB.toStringAsFixed(2)} MB',
                    style: AppFontStyles.dmSansRegular.copyWith(
                      fontSize: 14.sp,
                      color: AppColorTheme.muted,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              AppMedia.close,
              height: 20.h,
              width: 20.w,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  // ************************** No Message Found ****************************
  static Widget noMessageFoundText() {
    return Text(
      "No Message Found",
      textAlign: TextAlign.left,
      style: AppFontStyles.dmSansRegular.copyWith(
        fontSize: 16.sp,
        color: AppColorTheme.inputTitle,
      ),
    );
  }

  // ************************** Date separator UI for message pagination *************************
  static Widget dateSeparatorUI(DateTime currentDate) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(child: divider(paddingHorizontal: 8.w)),
          Text(
            CommonFunctions.getFormattedDate(currentDate),
            style: AppFontStyles.dmSansMedium.copyWith(
              color: AppColorTheme.dark40,
              fontSize: 13.sp,
            ),
          ),
          Expanded(child: divider(paddingHorizontal: 8.w)),
        ],
      ),
    );
  }

  // ************************** chat bubble ui **************************

  static double chatBubbleWidth = 0.62;

  static Widget chatBubbleUI(
    {
      required bool isSender,
      required double width,
      required Widget childWidget,
      double paddingAll = 10,
      double marginVertical = 4,
      String highlightedText = ""
    }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Container(
        padding: EdgeInsets.all(paddingAll.w),
        margin: EdgeInsets.symmetric(vertical: marginVertical.w),
        decoration: BoxDecoration(
          color: isSender ? AppColorTheme.senderMsgBg : AppColorTheme.receiverMsgBg,
          borderRadius: BorderRadius.only(
            topLeft: isSender ? Radius.circular(12.w) : Radius.circular(0),
            topRight: isSender ? Radius.circular(0) : Radius.circular(12.w),
            bottomLeft: Radius.circular(12.w),
            bottomRight: Radius.circular(12.w),
          )
        ),
        child: childWidget,
      ),
    );
  }

  // ************************** chat message text ui *****************************
  static Widget chatMessageTextUI(
    {required String messageText,
    required bool isSender,
    required double width,
    String highlightedText = ""}) {
    return chatBubbleUI(
      isSender: isSender,
      width: width,
      childWidget: ConvertDecodedTextToHtmlStyle(
        message: messageText,
        highlightText: highlightedText,
      )
    );
  }

  // ************************* Image in chat **************************
  static Widget chatMessageImageUI(String imageUrl, VoidCallback handleOnTapImage) {
    Widget imageWidget;
    imageWidget = InkWell(
      onTap: handleOnTapImage,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 0.60.sw,
          maxHeight: 400.h,
        ),
        decoration: BoxDecoration(
          color: AppColorTheme.searchBg.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            // 3. This handles the 'loading' state so the UI doesn't look broken
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: 0.75.sw,
                height: 200.h, // Initial placeholder height
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },

            // 4. Handle broken URLs/Network issues
            errorBuilder: (context, error, stackTrace) => Container(
              width: 0.75.sw,
              height: 150.h,
              color: AppColorTheme.searchBg,
              child: Icon(Icons.broken_image, color: AppColorTheme.black40),
            ),
          ),
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Stack(
            children: [
              imageWidget,
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                        width: 1.5.w,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget chatReplyMessageUI({
    required BuildContext context,
    required bool isSender,
    required Map<String, dynamic> messageItem,
    required bool isReplyMsgSvg
  }){

  final chatProvider = context.read<ChatProvider>();

    return CommonWidgets.chatBubbleUI(
        isSender: isSender,
        width: MediaQuery.of(context).size.width * 0.62,
        paddingAll: 0,
        marginVertical: 4,
        childWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColorTheme.white,
                border: Border.all(
                  color: isSender ? AppColorTheme.senderMsgBg : AppColorTheme.receiverMsgBg,
                  width: 3.5,
                  strokeAlign: BorderSide.strokeAlignInside
                ),
                borderRadius: BorderRadius.only(
                  topLeft: isSender ? Radius.circular(12.w) : Radius.circular(0),
                  topRight: isSender ? Radius.circular(0) : Radius.circular(12.w),
                  bottomLeft: Radius.circular(12.w),
                  bottomRight: Radius.circular(12.w),
                )
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 2,
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.only(top: 12.h, bottom: 10.h),
                      decoration: BoxDecoration(
                        color: AppColorTheme.primary,
                        borderRadius: BorderRadius.all(Radius.circular(2.r)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 163, 239, 0.5),
                            offset: Offset(2, 0),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ReplyMessageUserNameAndTime(
                            formattedTime: CommonFunctions.dateFormat(messageItem['vReplyMsgData']['vReplyDate']),
                            sendUserName: messageItem['vReplyMsgData']['vReplyUserName'],
                          ),
                          SizedBox(height: 6),
                
                          if (messageItem['vReplyMsgData']['vReplyFilePath'] != "")
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: isReplyMsgSvg
                                      ? SvgPicture.network(messageItem['vReplyMsgData']['vReplyFilePath'], height: 120, width: double.infinity, fit: BoxFit.cover, placeholderBuilder: (context) => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),)
                                      : Image.network(messageItem['vReplyMsgData']['vReplyFilePath'], height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stack) => const SizedBox(height: 140, child: Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey,))),
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));
                                      }
                                    ),
                                  ),
                                  // const SizedBox(height: 6),
                                  ConvertDecodedTextToHtmlStyle(message: messageItem['vReplyMsgData']['vReplyFileName'],highlightText: chatProvider.searchController.text,),
                                ],
                              ),
                            )
                          else
                            ConvertDecodedTextToHtmlStyle(message: messageItem['vReplyMsgData']['vReplyMsg'],highlightText: chatProvider.searchController.text,),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(10.w),
              child: ConvertDecodedTextToHtmlStyle(message: messageItem['vReplyMsgData']['message'], highlightText: chatProvider.searchController.text),
            ),
          ],
        )
    );
    //   Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     IntrinsicHeight(
    //       child: Container(margin: const EdgeInsets.all(6),
    //         decoration: BoxDecoration(color: AppColorTheme.white, borderRadius: BorderRadius.only(
    //           topLeft: isSender ? const Radius.circular(14) : const Radius.circular(0),
    //           topRight: isSender ? const Radius.circular(0) : const Radius.circular(14),
    //           bottomLeft: const Radius.circular(14),
    //           bottomRight: const Radius.circular(14),),),
    //         child:
    //         Row(
    //           children: [
    //             Container(
    //               width: 2,
    //               margin: const EdgeInsets.only(top: 11,bottom: 10,left: 8,right: 8),
    //               padding: EdgeInsets.only(top: 10,bottom: 10),
    //               decoration: const BoxDecoration(
    //                 color: AppColorTheme.primary,
    //                 boxShadow: [BoxShadow(color: Color.fromRGBO(0, 163, 239, 0.5), offset: Offset(2, 0), blurRadius: 9, spreadRadius: 0,),],
    //               ),
    //             ),
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Padding(
    //                     padding: const EdgeInsets.only(top: 10, right: 5),
    //                     child: ReplyMessageUserNameAndTime(
    //                       formattedTime: CommonFunctions.dateFormat(messageItem['vReplyMsgData']['vReplyDate']),
    //                       sendUserName: messageItem['vReplyMsgData']['vReplyUserName'],
    //                     ),
    //                   ),
    //                   const SizedBox(height: 6),
    //
    //                   if (messageItem['vReplyMsgData']['vReplyFilePath'] != "")
    //                     Padding(
    //                       padding: const EdgeInsets.only(right: 8),
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           ClipRRect(
    //                             borderRadius: BorderRadius.circular(6),
    //                             child: isReplyMsgSvg
    //                               ? SvgPicture.network(messageItem['vReplyMsgData']['vReplyFilePath'], height: 120, width: double.infinity, fit: BoxFit.cover, placeholderBuilder: (context) => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),)
    //                               : Image.network(messageItem['vReplyMsgData']['vReplyFilePath'], height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stack) => const SizedBox(height: 140, child: Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey,))),
    //                                 loadingBuilder: (context, child, loadingProgress) {
    //                                   if (loadingProgress == null) return child;
    //                                     return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));
    //                                   }
    //                             ),
    //                           ),
    //                           // const SizedBox(height: 6),
    //                           ConvertDecodedTextToHtmlStyle(message: messageItem['vReplyMsgData']['vReplyFileName'],highlightText: chatProvider.searchController.text,),
    //                         ],
    //                       ),
    //                     )
    //                   else
    //                     ConvertDecodedTextToHtmlStyle(message: messageItem['vReplyMsgData']['vReplyMsg'],highlightText: chatProvider.searchController.text,),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //     // const SizedBox(height: 6),
    //     ConvertDecodedTextToHtmlStyle(message: messageItem['vReplyMsgData']['message'],highlightText: chatProvider.searchController.text, ),
    //   ],
    // );
  }

  // ************************* Files in chat *******************************
  static Widget chatMessageFileUI(
      {required Map<String, dynamic> messageItem,
      required bool isSender,
      required Color bgColor,
      required double width,
      required String fileImage,
      required String fileName,
      required bool isShowAlertIcon,
      required VoidCallback handleOnTapDownload,
      String highlightedText = ""}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Container(
        padding: EdgeInsets.all(10.w),
        margin: EdgeInsets.symmetric(vertical: 4.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: isSender ? Radius.circular(12.w) : Radius.circular(0),
            topRight: isSender ? Radius.circular(0) : Radius.circular(12.w),
            bottomLeft: Radius.circular(12.w),
            bottomRight: Radius.circular(12.w),
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.network(fileImage),
            SizedBox(width: 12.w),
            Flexible(
              child: ConvertDecodedTextToHtmlStyle(
                message: fileName ?? '',
                highlightText: highlightedText,
              )
            ),
            SizedBox(width: 12.w,),
            InkWell(
              borderRadius: BorderRadius.all(Radius.circular(6.r)),
              onTap: handleOnTapDownload,
              child: SvgPicture.asset(AppMedia.download, width: 20.w, height: 20.h),
            ),
            if (isShowAlertIcon)
              Icon(FeatherIcons.alertCircle, size: 20.w, color: AppColorTheme.danger),
          ],
        ),
      ),
    );
  }

  // *********************** videos in chat *****************************
  static Widget chatMessageVideoUI(
      String thumbnailUrl, VoidCallback openFullScreenPlayer) {
    return GestureDetector(
      onTap: () {
        openFullScreenPlayer();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          chatMessageImageUI("https://picsum.photos/seed/42/800/450", (){}),
          Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                color: AppColorTheme.white.withOpacity(0.9),
              ),
              child: InkWell(
                  onTap: () => openFullScreenPlayer?.call(),
                  child: Icon(Icons.play_arrow,
                      size: 35.w, color: AppColorTheme.black40))),
        ],
      ),
    );
  }

  // *********************** gifs in chat *****************************
  static Widget chatMessageGifUI(String gifUrl) {
    return chatMessageImageUI(gifUrl, () {});
  }

  // *********************** audio in chat *****************************
  static Widget chatMessageAudioUI({
    required String url,
    required double width,
    required bool isSender,
  }) {
    // We use a StatefulBuilder to manage play/pause state locally
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        // We use a static or persistent player instance
        // (Note: In a real list, you'd define the player outside the build method)
        final AudioPlayer player = AudioPlayer();
        bool isPlaying = false;
        Duration duration = Duration.zero;
        Duration position = Duration.zero;

        // Listeners to update the UI
        player.onPositionChanged.listen((p) => setState(() => position = p));
        player.onDurationChanged.listen((d) => setState(() => duration = d));
        player.onPlayerStateChanged.listen(
            (s) => setState(() => isPlaying = s == PlayerState.playing));

        return chatBubbleUI(
          isSender: isSender,
          width: width,
          childWidget: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  isPlaying ? player.pause() : player.play(UrlSource(url));
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180.w,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        // 1. Removes the empty space at the start and end of the slider track
                        trackShape: const RoundedRectSliderTrackShape(),
                        // 2. Removes the large "glow" circle when you touch it
                        overlayShape: SliderComponentShape.noOverlay,
                        // 3. Shrinks the vertical height used by the slider
                        valueIndicatorShape:
                            const PaddleSliderValueIndicatorShape(),
                      ),
                      child: Slider(
                        // NOTE: materialTapTargetSize is not a valid parameter here for some versions,
                        // so we handle the sizing in the SliderTheme above.
                        activeColor: AppColorTheme.primaryHover,
                        min: 0,
                        max: duration.inSeconds.toDouble() > 0
                            ? duration.inSeconds.toDouble()
                            : 1.0,
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) =>
                            player.seek(Duration(seconds: value.toInt())),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Text(
                    "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
        // return Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //   decoration: BoxDecoration(
        //     color: Colors.blue.shade100,
        //     borderRadius: BorderRadius.circular(20),
        //   ),
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       IconButton(
        //         icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        //         onPressed: () {
        //           isPlaying ? player.pause() : player.play(UrlSource(url));
        //         },
        //       ),
        //       Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           SizedBox(
        //             width: 150,
        //             child: Slider(
        //               min: 0,
        //               max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
        //               value: position.inSeconds.toDouble(),
        //               onChanged: (value) => player.seek(Duration(seconds: value.toInt())),
        //             ),
        //           ),
        //           Padding(
        //             padding: const EdgeInsets.only(left: 10),
        //             child: Text(
        //               "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}",
        //               style: const TextStyle(fontSize: 10),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // );
      },
    );
  }

  // ******************** selected message header icon ui *************************
  static Widget selectedMsgHeaderIcon({required String iconName, GestureTapCallback? onIconTap}) {
    return InkWell(
      onTap: onIconTap,
      borderRadius: BorderRadius.all(Radius.circular(6.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: SvgPicture.asset(iconName),
      ),
    );
  }


  static Positioned editPictureIconPosition(VoidCallback onPressEditIcon) {
    return Positioned(
        right: 5.w,
        top: 5.h,
        child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColorTheme.white,
              borderRadius: BorderRadius.all(Radius.circular(5.r)),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(10, 41, 55, 0.16),
                    offset: Offset(0, 3.w),
                    blurRadius: 6.r)
              ],
            ),
            child: InkWell(
                onTap: onPressEditIcon,
                child: SvgPicture.asset(
                  AppMedia.edit,
                  color: AppColorTheme.muted,
                ))));
  }

  static Widget isSvgDetailProfile(bool isSvg, String vImage) {
    return isSvg
        ? SvgPicture.network(vImage,
            fit: BoxFit.contain, height: 100, width: 100)
        : Image.network(vImage, fit: BoxFit.contain, height: 100, width: 100);
  }

  static Widget isSvgProfilePic(bool isSvg, String vImage) {
    return isSvg
        ? SvgPicture.network(vImage, fit: BoxFit.contain, height: 43, width: 43)
        : Image.network(vImage, fit: BoxFit.contain, height: 43, width: 43);
  }

  static Widget isChatSvgProfilePic(bool isSvg, String vImage) {
    return isSvg
        ? SvgPicture.network(vImage, fit: BoxFit.contain, height: 42, width: 42)
        : Image.network(vImage, fit: BoxFit.contain, height: 42, width: 42);
  }
}

class RoundedShadowedUnderlineTabIndicator extends Decoration {
  final double indicatorHeight;
  final Color indicatorColor;
  final Color shadowColor;
  final double blurRadius;
  final double shadowOffsetY;
  final double horizontalPadding;
  final double borderRadius;
  final double bottomSpacing;

  const RoundedShadowedUnderlineTabIndicator({
    this.indicatorHeight = 4,
    required this.indicatorColor,
    required this.shadowColor,
    this.blurRadius = 5,
    this.shadowOffsetY = 2,
    this.horizontalPadding = 0,
    this.borderRadius = 8,
    this.bottomSpacing = 8,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundedShadowedUnderlinePainter(
      this,
      indicatorHeight,
      indicatorColor,
      shadowColor,
      blurRadius,
      shadowOffsetY,
      horizontalPadding,
      borderRadius,
      bottomSpacing,
      onChanged,
    );
  }
}

class _RoundedShadowedUnderlinePainter extends BoxPainter {
  final RoundedShadowedUnderlineTabIndicator decoration;
  final double indicatorHeight;
  final Color indicatorColor;
  final Color shadowColor;
  final double blurRadius;
  final double shadowOffsetY;
  final double horizontalPadding;
  final double borderRadius;
  final double bottomSpacing;

  _RoundedShadowedUnderlinePainter(
    this.decoration,
    this.indicatorHeight,
    this.indicatorColor,
    this.shadowColor,
    this.blurRadius,
    this.shadowOffsetY,
    this.horizontalPadding,
    this.borderRadius,
    this.bottomSpacing,
    VoidCallback? onChanged,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final double left = offset.dx + horizontalPadding;
    final double right =
        offset.dx + configuration.size!.width - horizontalPadding;

    final double top = offset.dy +
        configuration.size!.height -
        indicatorHeight -
        bottomSpacing;

    final Rect lineRect = Rect.fromLTWH(
      left,
      top,
      right - left,
      indicatorHeight,
    );

    final RRect roundedRect =
        RRect.fromRectAndRadius(lineRect, Radius.circular(borderRadius));

    final RRect shadowRect = roundedRect.shift(Offset(0, shadowOffsetY));

    final Paint shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    canvas.drawRRect(shadowRect, shadowPaint);

    final Paint linePaint = Paint()..color = indicatorColor;

    canvas.drawRRect(roundedRect, linePaint);
  }
}

class GroupMessageSetting extends StatefulWidget {
  const GroupMessageSetting({super.key});

  @override
  _GroupMessageSettingState createState() => _GroupMessageSettingState();
}

class _GroupMessageSettingState extends State<GroupMessageSetting> {
  String selectedOption = 'Group Manager';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Color(0xFFF6F9FB), // light grey background similar to your image
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Message Setting',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              buildRadioButton('Group Manager'),
              SizedBox(width: 20),
              buildRadioButton('All'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRadioButton(String value) {
    bool isSelected = selectedOption == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = value;
        });
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Color(0xFF00A9E0) : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00A9E0),
                      ),
                    ),
                  )
                : SizedBox(),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class ReplyPreviewWidget extends StatelessWidget {
  final bool isSender;
  final String replyText;
  final bool replyHasFile;
  final String replyFileThumb;
  final VoidCallback onClose;

  const ReplyPreviewWidget({
    super.key,
    required this.isSender,
    required this.replyText,
    required this.replyHasFile,
    required this.replyFileThumb,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColorTheme.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColorTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSender ? "You" : "Other",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                replyHasFile
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          replyFileThumb,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        replyText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: onClose,
          )
        ],
      ),
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 4, top: 2),
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColorTheme.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}

class TypingText extends StatelessWidget {
  final String text;
  const TypingText(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFontStyles.dmSansRegular.copyWith(
        fontSize: 14,
        color: AppColorTheme.dark40,
      ),
    );
  }
}
