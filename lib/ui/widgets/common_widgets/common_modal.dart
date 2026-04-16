import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/ui/widgets/common_widgets/modal_header.dart';

class CommonModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double heightFactor = 0.82,
    double modalPadding = 12,
    Color modalBackgroundColor = AppColorTheme.lightPrimary,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ModalContainer(
          heightFactor: heightFactor,
          modalPadding: modalPadding,
          modalBackgroundColor: modalBackgroundColor,
          child: child,
        );
      },
    );
  }
}

class ModalContainer extends StatelessWidget {
  final Widget child;
  final double heightFactor;
  final double modalPadding;
  final Color modalBackgroundColor;

  ModalContainer({
    required this.child,
    this.heightFactor = 0.82,
    this.modalPadding = 12,
    this.modalBackgroundColor = AppColorTheme.lightPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(16.r);
    final screenH = MediaQuery.of(context).size.height;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      child: Material(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // ✅ sheet won’t exceed this height; if content is bigger, it can scroll
            maxHeight: screenH * 0.80,
          ),
          child: ColoredBox(
            color: modalBackgroundColor,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                // height: MediaQuery.of(context).size.height * heightFactor.h,
                padding: EdgeInsets.symmetric(horizontal: modalPadding.w),
                decoration: BoxDecoration(
                  color: modalBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: radius),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white,
                        offset: Offset(0, -1),
                        blurRadius: 0,
                        spreadRadius: 1),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
