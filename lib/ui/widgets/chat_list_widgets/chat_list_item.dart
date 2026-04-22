import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';

class ChatListItem extends StatefulWidget {
  final dynamic vProfilePic;
  final Color statusColor;
  final Color closeIconColor;
  final Color userCheckIconColor;
  final Color statusBorderColor;
  final String listTitle;
  final String listSubTitle;
  final bool showActiveBackground;
  final bool showStatusColor;
  final bool titleStyleRegular;
  final bool showUserCheckIcon;
  final bool showCloseIcon;
  final bool showMsgFlagIcon;
  final bool showCheckMarkIcon;
  final bool isSelectedCheckMark;
  final double borderRadius;
  final double verticalPadding;
  final double profileIconMarginTop;
  final double profileSize;
  final VoidCallback? handleOnPressClose;
  final VoidCallback? handleOnPressUserCheck;
  final VoidCallback handleOnPressItem;

  ChatListItem({
    super.key,
    required this.vProfilePic,
    this.statusColor = AppColorTheme.transparent,
    this.closeIconColor = AppColorTheme.border,
    this.userCheckIconColor = AppColorTheme.border,
    this.statusBorderColor = AppColorTheme.lightPrimary,
    this.showActiveBackground = false,
    this.showStatusColor = true,
    this.titleStyleRegular = false,
    this.showUserCheckIcon = false,
    this.showCloseIcon = false,
    this.showMsgFlagIcon = false,
    this.showCheckMarkIcon = false,
    this.isSelectedCheckMark = false,
    required this.listTitle,
    required this.listSubTitle,
    this.borderRadius = 50,
    this.verticalPadding = 8,
    this.profileIconMarginTop = 0,
    this.profileSize = 45,
    this.handleOnPressClose,
    this.handleOnPressUserCheck,
    required this.handleOnPressItem,
  });

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      child: InkWell(
        onTap: () {
          widget.handleOnPressItem();
        },
        borderRadius: BorderRadius.all(Radius.circular(6.r)),
        highlightColor: AppColorTheme.listHover,
        child: Container(
          padding: EdgeInsets.only(top: widget.verticalPadding.h, bottom: widget.verticalPadding.h, left: 8.h, right: 18.w),
          decoration: widget.showActiveBackground
              ? BoxDecoration(
                color: AppColorTheme.white,
                borderRadius: BorderRadius.all(Radius.circular(6.r)),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 1),
                    blurRadius: 1,
                    spreadRadius: 0,
                    color: Color.fromRGBO(10, 41, 55, 0.16))
                ])
              : BoxDecoration(),
          child: Row(
            children: [
              // *************************** Item Profile Picture ***********************
              ProfileIconStatusDot(
                marginTop: widget.profileIconMarginTop,
                profilePic: widget.vProfilePic,
                profileSize: widget.profileSize,
                statusColor: widget.statusColor,
                showStatusColor: widget.showStatusColor,
                borderRadius: widget.borderRadius,
                statusBorderColor: widget.showStatusColor == true ? widget.statusBorderColor : AppColorTheme.transparent,
              ),

              SizedBox(
                width: 12.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // *************************** Item Title ***********************
                    Text(
                      widget.listTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: widget.titleStyleRegular
                          ? AppFontStyles.dmSansRegular.copyWith(
                              color: AppColorTheme.black87,
                              fontSize: 14.sp,
                            )
                          : AppFontStyles.dmSansMedium.copyWith(
                              color: AppColorTheme.black87,
                              fontSize: 14.sp,
                            ),
                    ),
                    SizedBox(height: 2.h),

                    // *************************** Item Sub Title ***********************
                    Text(
                      widget.listSubTitle,
                      style: AppFontStyles.dmSansRegular.copyWith(
                          color: AppColorTheme.black40, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),

              // *************************** User Check Icon // Close Icon // New Msg Flag Icon // Check M ***********************
              widget.showUserCheckIcon
                  ? InkWell(
                      onTap: widget.handleOnPressUserCheck,
                      child: SvgPicture.asset(
                        AppMedia.userMinusIcon,
                        color: AppColorTheme.border,
                        fit: BoxFit.contain,
                      ))
                  : Container(),
              SizedBox(
                width: widget.showUserCheckIcon ? 16.w : 0,
              ),
              widget.showCloseIcon
                  ? InkWell(
                      onTap: widget.handleOnPressClose,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // color: isSelected ? AppColorTheme.border : Colors.red
                            color: widget.closeIconColor),
                        child: SvgPicture.asset(
                          AppMedia.closeIcon,
                          color: AppColorTheme.white,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : widget.showMsgFlagIcon
                      ? SvgPicture.asset(AppMedia.newMsgFlag,
                          color: AppColorTheme.primary, fit: BoxFit.contain)
                      : widget.showCheckMarkIcon
                          ? CommonWidgets.rightCheckMark(
                              widget.isSelectedCheckMark,
                              marginRight: 0)
                          : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
