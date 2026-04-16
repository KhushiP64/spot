import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';

class UserStatusOptions extends StatelessWidget {
  final String title;
  final Color color;
  final Color backgroundColor;
  final VoidCallback handleSelectUserStatus;
  final double marginTop;
  final double marginBottom;

  const UserStatusOptions(
      {super.key,
      required this.title,
      required this.color,
      required this.backgroundColor,
      required this.handleSelectUserStatus,
      this.marginTop = 4,
      this.marginBottom = 4});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: 8.h, right: 8.h, top: marginTop.h, bottom: marginBottom.h),
      // padding: EdgeInsets.all(6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.r)),
        color: backgroundColor,
      ),
      child: InkWell(
        onTap: handleSelectUserStatus,
        borderRadius: BorderRadius.all(Radius.circular(6.r)),
        child: Padding(
          padding: EdgeInsets.all(6.h),
          child: Row(
            children: [
              Container(
                  margin: EdgeInsets.all(4.h),
                  height: 15.h,
                  width: 15.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50.r)),
                      color: color)),
              Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: Text(title,
                    style: AppFontStyles.dmSansRegular.copyWith(
                        color: AppColorTheme.dark87, fontSize: 17.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
