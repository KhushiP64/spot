import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/modal_header.dart';

class ConfirmModal {
  static void show(BuildContext context,
      {required String headerTitle,
      String modalTitle = '',
      required String confirmBtnTitle,
      required String cancelBtnTitle,
      required VoidCallback onPressConfirm,
      required VoidCallback onPressCancel,
      Color? backgroundColor,
      Color? textColor}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (BuildContext context) {
        return Container(
          color: AppColorTheme.white,
          padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 35.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModalHeader(name: headerTitle, onTapCloseAction: onPressCancel),
              SizedBox(height: 12.h),
              Text(
                modalTitle,
                textAlign: TextAlign.center,
                style: AppFontStyles.dmSansRegular
                    .copyWith(fontSize: 16.sp, color: AppColorTheme.dark87),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Button(
                      onPressed: onPressConfirm,
                      title: confirmBtnTitle,
                      backgroundColor: backgroundColor,
                      textColor: textColor,
                      boxShadow: [],
                    ),
                  ),
                  Expanded(
                    child: Button(
                      onPressed: onPressCancel,
                      title: cancelBtnTitle,
                      backgroundColor: AppColorTheme.secondary,
                      textColor: AppColorTheme.dark50,
                      boxShadow: [],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class ConfirmBottomModal extends StatefulWidget {
  final String headerTitle;
  final String modalTitle;
  final String confirmBtnTitle;
  final String cancelBtnTitle;
  final VoidCallback onPressConfirm;
  final VoidCallback onPressCancel;
  final Color? backgroundColor;
  final Color? textColor;

  const ConfirmBottomModal({
    super.key,
    required this.headerTitle,
    this.modalTitle = "",
    required this.confirmBtnTitle,
    required this.cancelBtnTitle,
    required this.onPressConfirm,
    required this.onPressCancel,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  State<ConfirmBottomModal> createState() => _ConfirmBottomModalState();
}

class _ConfirmBottomModalState extends State<ConfirmBottomModal> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModalHeader(
            name: widget.headerTitle, onTapCloseAction: widget.onPressCancel),
        SizedBox(height: 12.h),
        Text(
          widget.modalTitle,
          textAlign: TextAlign.center,
          style: AppFontStyles.dmSansRegular
              .copyWith(fontSize: 16.sp, color: AppColorTheme.dark87),
        ),
        SizedBox(height: 24.h),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Button(
                  onPressed: widget.onPressConfirm,
                  title: widget.confirmBtnTitle,
                  backgroundColor: widget.backgroundColor,
                  textColor: widget.textColor),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Button(
                  onPressed: widget.onPressCancel,
                  title: widget.cancelBtnTitle,
                  backgroundColor: AppColorTheme.secondary,
                  textColor: AppColorTheme.dark50,
                  boxShadow: [],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
