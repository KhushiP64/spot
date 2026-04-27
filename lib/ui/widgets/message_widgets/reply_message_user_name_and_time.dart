import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';

class ReplyMessageUserNameAndTime extends StatelessWidget {
  final String formattedTime;
  final String sendUserName;
  final bool? isSender;

  const ReplyMessageUserNameAndTime({
    super.key,
    required this.formattedTime,
    required this.sendUserName,
    this.isSender,
  });

  @override
  Widget build(BuildContext context) {

    Widget nameTimeUI(String text, Color txtColor){
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Text(
          text,
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFontStyles.dmSansMedium.copyWith(
            fontSize: 11.sp,
            color: txtColor,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              sendUserName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyles.dmSansMedium.copyWith(
                fontSize: 11.sp,
                color: AppColorTheme.dark70,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            formattedTime,
            style: AppFontStyles.dmSansMedium.copyWith(
              fontSize: 11.sp,
              color: AppColorTheme.dark40,
            ),
          )
        ],
      ),
    );
  }
}
