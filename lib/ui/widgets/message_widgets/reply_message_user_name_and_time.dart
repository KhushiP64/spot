import 'package:flutter/material.dart';
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
      children: [
        Expanded(
          child: Text(
            sendUserName,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyles.dmSansMedium.copyWith(
              fontSize: 12,
              color: AppColorTheme.dark70,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            formattedTime,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AppFontStyles.dmSansMedium.copyWith(
              fontSize: 12,
              color: AppColorTheme.dark40,
            ),
          ),
        ),
      ],
    );
  }
}
