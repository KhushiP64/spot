import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';
import 'package:spot/ui/widgets/message_widgets/message_user_name_and_time.dart';

class MsgAcceptDeclineBtn extends StatefulWidget {
  final Map<String, dynamic> messageItem;
  final Function(Map<String, dynamic>) onPressAcceptChatRequest;
  final String formattedTime;
  final String sendUserName;

  const MsgAcceptDeclineBtn(
      {super.key,
      required this.messageItem,
      required this.onPressAcceptChatRequest,
      required this.formattedTime,
      required this.sendUserName});

  @override
  State<MsgAcceptDeclineBtn> createState() => _MsgAcceptDeclineBtnState();
}

class _MsgAcceptDeclineBtnState extends State<MsgAcceptDeclineBtn> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ProfileIconStatusDot(
              profilePic: widget.messageItem['vMsgData']['icon'],
              statusColor: AppColorTheme.transparent,
              statusBorderColor: AppColorTheme.transparent,
              showStatusColor: false,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 12.w),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                        color: AppColorTheme.receiverMsgBg,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(12.r),
                            bottomLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.messageItem['vMsgData']['message'],
                            style: AppFontStyles.dmSansMedium.copyWith(
                              fontSize: 14.w,
                              color: AppColorTheme.inputTitle,
                            )),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...widget.messageItem['vMsgData']['btns']
                                .asMap()
                                .map((index, item) {
                                  return MapEntry(
                                      index,
                                      Expanded(
                                        child: Container(
                                            margin: EdgeInsets.only(
                                                right: index == 0 ? 10.w : 0),
                                            child: Button(
                                                // paddingHorizontal: 18.w,
                                                boxShadow: [],
                                                onPressed: () {
                                                  widget
                                                      .onPressAcceptChatRequest(
                                                          item);
                                                },
                                                title: item['name'],
                                                textColor: Color(int.parse(
                                                    item['fontcolor']
                                                        .replaceFirst(
                                                            '#', '0xFF'))),
                                                backgroundColor: Color(
                                                    int.parse(item['color']
                                                        .replaceFirst(
                                                            '#', '0xFF'))))),
                                      ));
                                })
                                .values
                                .toList(),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 13, top: 5),
                      child: MessageUserNameAndTime(
                        formattedTime: widget.formattedTime,
                        sendUserName: widget.sendUserName,
                        isForwarded:
                            int.parse(widget.messageItem['isForwardMsg']),
                        isEdited: widget.messageItem['iEdited'],
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
