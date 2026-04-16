import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/responsive_fonts.dart';

class Button extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? elevation;
  final double paddingHorizontal;
  final TextStyle? textStyle;
  final bool? isDisabled;
  final List<BoxShadow>? boxShadow;

  const Button({
    super.key,
    required this.onPressed,
    required this.title,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.elevation,
    this.paddingHorizontal = 22,
    this.textStyle,
    this.isDisabled = false,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final btnWidth = MediaQuery.of(context).size.width * 0.40;

    return SizedBox(
      // width: width ?? btnWidth,
      child: GestureDetector(
        onTap: isDisabled! ? null : onPressed,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 1.8.w),
          padding: EdgeInsets.only(
              top: 8.h,
              bottom: 9.h,
              left: paddingHorizontal.w,
              right: paddingHorizontal.w),
          // height: height ?? 38.h,
          decoration: BoxDecoration(
            color: isDisabled!
                ? AppColorTheme.inputTitle
                : (backgroundColor ?? AppColorTheme.primary),
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: boxShadow ??
                (isDisabled!
                    ? []
                    : [
                        BoxShadow(
                          color: Color.fromRGBO(0, 163, 239, 0.33),
                          blurRadius: 5.0,
                          offset: Offset(0, 2),
                        )
                      ]),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: textStyle ??
                AppFontStyles.dmSansMedium.copyWith(
                  color: textColor ?? AppColorTheme.white,
                  // color: isDisabled! ? AppColorTheme.inputTitle : (textColor ?? AppColorTheme.dark50),
                  fontSize: 15.sp,
                ),
          ),
        ),
      ),
    );
  }
}
