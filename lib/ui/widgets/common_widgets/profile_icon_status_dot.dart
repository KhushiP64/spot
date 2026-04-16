// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:spot/core/themes.dart';
// import 'package:spot/ui/widgets/commonWidgets.dart';
//
// class ProfileIconStatusDot extends StatelessWidget {
//   final String profilePic;
//   final Color statusColor;
//   final bool showStatusColor;
//   final double borderRadius;
//
//   const ProfileIconStatusDot(
//       {super.key,
//       required this.profilePic,
//       required this.statusColor,
//       this.showStatusColor = true,
//       this.borderRadius = 50});
//
//   @override
//   Widget build(BuildContext context) {
//     bool isSvg = (profilePic != null
//         ? profilePic!.toLowerCase().endsWith('.svg')
//         : false);
//
//     return Stack(
//       children: [
//         ClipRRect(
//             borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
//             child: (profilePic != null)
//                 ? CommonWidgets.isSvgProfilePic(isSvg, profilePic)
//                 : Container()),
//         Positioned(
//           bottom: 0.5,
//           right: 2,
//           child: Container(
//             height: 15,
//             width: 15,
//             decoration: BoxDecoration(
//               color: showStatusColor ? statusColor : AppColorTheme.transparent,
//               shape: BoxShape.circle,
//               border: Border.all(
//                   color: showStatusColor
//                       ? Colors.white
//                       : AppColorTheme.transparent,
//                   width: showStatusColor ? 2 : 0),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spot/core/themes.dart';

class ProfileIconStatusDot extends StatelessWidget {
  final String profilePic;
  final Color statusColor;
  final Color statusBorderColor;
  final bool showStatusColor;
  final double borderRadius;
  final double profileSize;
  final double statusSize;
  final double marginTop;

  const ProfileIconStatusDot({
    super.key,
    required this.profilePic,
    required this.statusColor,
    required this.statusBorderColor,
    this.showStatusColor = true,
    this.borderRadius = 50,
    this.profileSize = 45,
    this.statusSize = 14.5,
    this.marginTop = 3,
  });

  @override
  Widget build(BuildContext context) {
    bool isSvg = profilePic.toLowerCase().endsWith('.svg');
    bool isValid = profilePic.trim().isNotEmpty;
    Widget imageWidget;

    if (!isValid) {
      imageWidget = SizedBox(
        width: double.infinity, height: double.infinity,
        // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: 60.w, height: 60.h),
        child: SizedBox(
          width: 60.w,
          height: 60.h,
        ),
      );
    } else if (isSvg) {
      imageWidget = SvgPicture.network(
        profilePic,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholderBuilder: (context) => SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SizedBox(
              width: 60.w,
              height: 60.h,
            )
            // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: 60.w, height: 60.h),
            ),
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SizedBox(
            width: 60.w,
            height: 60.h,
          ),
          // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: 60.w, height: 60.h),
        ),
      );
    } else {
      imageWidget = Image.network(
        profilePic,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => SizedBox(
            width: double.infinity,
            height: double.infinity,
            // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: 60.w, height: 60.h,)),
            child: SizedBox(
              width: 60.w,
              height: 60.h,
            )),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: marginTop.h),
      child: Stack(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius.r),
                child: SizedBox(
                  width: profileSize.w,
                  height: profileSize.h,
                  child: imageWidget,
                ),
              ),
              IgnorePointer(
                child: Container(
                  // margin: ,
                  width: profileSize.w,
                  height: profileSize.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius.r),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.1), // 10% opacity black
                      width: 1.5.w, // border thickness
                    ),
                    color: Colors.transparent, // Very important!
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: -0.7,
            right: 0.5,
            child: Container(
              height: statusSize.h,
              width: statusSize.w,
              decoration: BoxDecoration(
                color:
                    showStatusColor ? statusColor : AppColorTheme.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusBorderColor,
                  width: showStatusColor ? 2.5.w : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
