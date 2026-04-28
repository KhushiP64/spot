import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';

class MessageUserNameAndTime extends StatefulWidget {
  final String formattedTime;
  final String sendUserName;
  final int isForwarded;
  final int isEdited;
  final bool? isSender;
  final Widget? statusIndicator;

  const MessageUserNameAndTime({
    super.key,
    required this.formattedTime,
    required this.sendUserName,
    required this.isForwarded,
    required this.isEdited,
    this.isSender,
    this.statusIndicator,
  });

  @override
  State<MessageUserNameAndTime> createState() => _MessageUserNameAndTimeState();
}

class _MessageUserNameAndTimeState extends State<MessageUserNameAndTime> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: (widget.isSender ?? false) ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        SizedBox(width: 4.w),

        /// userName
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.66),
          child: Text(
            widget.sendUserName,
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.userNameInChat
          ),
        ),
        SizedBox(width: 6.w),

        /// Time
        Text(widget.formattedTime, style: AppStyles.timeAndEditedForwardedTextStyle),
        if (widget.isEdited == 1)
          SizedBox(width: 6.5.w),
        if (widget.isEdited == 1)
          Text("Edited", style: AppStyles.timeAndEditedForwardedTextStyle),

        /// Forwarded label
        if (widget.isForwarded == 1 && widget.isEdited != 1)
          SizedBox(width: 6.5.w),
        if (widget.isForwarded == 1 && widget.isEdited != 1)
          Text("Forwarded", style: AppStyles.timeAndEditedForwardedTextStyle),
        SizedBox(width: 6.5.w),

        /// Show statusIndicator
        if (widget.statusIndicator != null) ...[
          widget.statusIndicator!,
          SizedBox(width: 1.w),
        ],
        SizedBox(width: 4.w),
      ],
    );
  }
}
