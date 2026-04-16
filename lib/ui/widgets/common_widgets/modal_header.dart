import 'package:flutter/cupertino.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/responsive_fonts.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';

class ModalHeader extends StatelessWidget {
  final String name;
  final bool showBackIcon;
  final bool showCloseIcon;
  final VoidCallback? onTapBackAction;
  final VoidCallback? onTapCloseAction;

  const ModalHeader(
      {super.key,
      required this.name,
      this.showBackIcon = false,
      this.showCloseIcon = true,
      this.onTapBackAction,
      this.onTapCloseAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackIcon)
            GestureDetector(
                onTap: onTapBackAction,
                child: Icon(FeatherIcons.arrowLeft, color: AppColorTheme.muted))
          else
            SizedBox(width: 24.w),
          CommonWidgets.modalName(name),
          if (showCloseIcon)
            GestureDetector(
                onTap: onTapCloseAction,
                child: Icon(FeatherIcons.x, color: AppColorTheme.muted))
          else
            SizedBox(width: 24.w)
        ],
      ),
    );
  }
}
