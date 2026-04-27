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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "sendUserNamesendUserNamesendUserNamesendUserNamesendUserNamesendUserNamesendUserNamesendUserNamesendUserNamesendUserName",
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFontStyles.dmSansMedium.copyWith(
            fontSize: 11.sp,
            color: AppColorTheme.dark70,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 6.w),
          child: Text(
            formattedTime,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AppFontStyles.dmSansMedium.copyWith(
              fontSize: 11.sp,
              color: AppColorTheme.dark40,
            ),
          ),
        ),
      ],
    );
  }
}
