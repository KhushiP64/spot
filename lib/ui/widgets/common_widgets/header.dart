import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';

import '../../../core/themes.dart';

class Header extends StatelessWidget {
  final Color statusColor;
  final Color statusBorderColor;
  final VoidCallback? onPressProfile;

  const Header(
      {super.key,
      required this.statusColor,
      required this.statusBorderColor,
      this.onPressProfile});

  @override
  Widget build(BuildContext context) {
    final loginUserData = context.read<DataListProvider>().loginUserData;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(AppMedia.spotLogo, width: 46.w, height: 46.h),
            SizedBox(width: 12.w),
            SvgPicture.asset(AppMedia.spotText, width: 55.w, height: 25.h),
          ],
        ),
        (loginUserData['vProfilePic'] != null)
            ? InkWell(
                onTap: onPressProfile,
                child: ProfileIconStatusDot(
                  profilePic: loginUserData['vProfilePic'],
                  statusColor: statusColor,
                  statusBorderColor: statusBorderColor,
                  profileSize: 43,
                  statusSize: 13,
                ))
            : Container(),
      ],
    );
  }
}
