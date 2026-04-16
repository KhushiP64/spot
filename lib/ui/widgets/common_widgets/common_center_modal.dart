import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/ui/widgets/common_widgets/modal_header.dart';

class CommonCenterModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double heightFactor = 0.82,
    double modalPadding = 12,
    Color modalBackgroundColor = AppColorTheme.lightPrimary,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => Center(
        child: ModalContainer(
          modalPadding: modalPadding,
          modalBackgroundColor: modalBackgroundColor,
          child: child,
        ),
      ),
    );

    // return showModalBottomSheet<T>(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (_) {
    //     return ModalContainer(
    //       heightFactor: heightFactor,
    //       modalPadding: modalPadding,
    //       modalBackgroundColor: modalBackgroundColor,
    //       child: child,
    //     );
    //   },
    // );
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
    final screenH = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(
        // ✅ sheet won’t exceed this height; if content is bigger, it can scroll
        maxHeight: screenH * 0.30,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          // height: MediaQuery.of(context).size.height * heightFactor.h,
          padding: EdgeInsets.all(modalPadding.w),
          margin: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: modalBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(12.r)),
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
    );
  }
}
