import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/themes.dart';

class ChatBottomMenuTitle extends StatelessWidget {
  final String menuTitle;
  final VoidCallback onPressMenuTitle;
  final bool isDisabled;

  const ChatBottomMenuTitle({
    super.key,
    required this.menuTitle,
    required this.onPressMenuTitle,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onPressMenuTitle,
      highlightColor: AppColorTheme.listHover,
      child: Container(
        width: MediaQuery.of(context).size.width,
        // color: AppColorTheme.bgColor,
        padding: EdgeInsets.only(bottom: 8.h, top: 8.h, left: 8.w),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: Text(
          menuTitle,
          style: AppFontStyles.dmSansRegular.copyWith(
            color: isDisabled ? AppColorTheme.dark40 : AppColorTheme.black,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
