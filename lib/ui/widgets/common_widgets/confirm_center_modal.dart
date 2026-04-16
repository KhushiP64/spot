import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';

class ConfirmCenterModal extends StatelessWidget {
  final String headerTitle;
  final String confirmBtnTitle;
  final String cancelBtnTitle;
  final VoidCallback onPressConfirm;
  final VoidCallback onPressCancel;
  final Color? backgroundColor;
  final Color? textColor;
  final String modalTitle;

  ConfirmCenterModal(
      {super.key,
      required this.headerTitle,
      this.modalTitle = '',
      required this.confirmBtnTitle,
      required this.cancelBtnTitle,
      required this.onPressConfirm,
      required this.onPressCancel,
      this.backgroundColor,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.38;

    return Material(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Title centered
                Text(
                  headerTitle,
                  textAlign: TextAlign.center,
                  style: AppFontStyles.dmSansMedium.copyWith(
                    fontSize: 18.sp,
                    color: AppColorTheme.dark87,
                  ),
                ),
              ],
            ),
            Text(modalTitle,
                textAlign: TextAlign.center,
                style: AppFontStyles.dmSansRegular
                    .copyWith(fontSize: 16.sp, color: AppColorTheme.dark87)),
            modalTitle != "" ? SizedBox(height: 12.h) : Container(),
            // SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Button(
                        width: size,
                        onPressed: onPressConfirm,
                        title: confirmBtnTitle,
                        backgroundColor: backgroundColor,
                        textColor: textColor)),
                SizedBox(
                  width: 12.w,
                ),
                Expanded(
                    child: Button(
                  width: size,
                  onPressed: onPressCancel,
                  title: cancelBtnTitle,
                  backgroundColor: AppColorTheme.secondary,
                  textColor: AppColorTheme.dark50,
                  boxShadow: [],
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
