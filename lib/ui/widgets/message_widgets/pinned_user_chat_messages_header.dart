import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/user_chat_widgets/user_chat_header_menu.dart';

class PinnedUserChatMessagesHeader extends StatefulWidget {
  final VoidCallback handleSearchMessageClick;
  PinnedUserChatMessagesHeader(
      {super.key, required this.handleSearchMessageClick});

  @override
  State<PinnedUserChatMessagesHeader> createState() =>
      _PinnedUserChatMessagesHeaderState();
}

class _PinnedUserChatMessagesHeaderState
    extends State<PinnedUserChatMessagesHeader> {
  @override
  Widget build(BuildContext context) {
    final dataListProvider = context.read<DataListProvider>();
    final userData = dataListProvider.openedChatUserData;

    // ********************* on back action ****************************
    void handleBackPress() {
      Navigator.pop(context);
    }

    // ********************** handle on press more menu ***********************
    void handleOnPressOpenMoreMenus() async {
      final currentUser = await CommonFunctions.getLoginUser();
      CommonModal.show(
          context: context,
          child: UserChatHeaderMenu(currentUser: currentUser));
    }

    return WillPopScope(
      onWillPop: () {
        handleBackPress();
        return Future.value(false);
      },
      child: Container(
          color: AppColorTheme.white,
          padding: EdgeInsets.only(right: 20.w, top: 20.3.h, bottom: 12.h),
          child: dataListProvider.openedChatUserData.isNotEmpty
              ? Consumer<DataListProvider>(
                  builder: (context, dataListProvider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              /// Back Arrow for go to user chat screen
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: InkWell(
                                  onTap: handleBackPress,
                                  child: SvgPicture.asset(AppMedia.leftArrow),
                                ),
                              ),
                              Text(
                                "Pinned Messages",
                                style: AppFontStyles.dmSansMedium.copyWith(
                                    fontSize: 18.sp,
                                    color: AppColorTheme.inputTitle),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: widget.handleSearchMessageClick,
                              child: SvgPicture.asset(
                                AppMedia.searchMsg,
                                height: 22.h,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            InkWell(
                              // onTap: handleShowPinnedMessages,
                              child: SvgPicture.asset(
                                AppMedia.pinChat,
                                color: AppColorTheme.orange,
                              ),
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
