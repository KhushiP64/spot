import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LargeProfilePic extends StatelessWidget {
  final String profilePic;
  final double borderRadius;
  final double profileSize;
  final bool isFilePath;

  const LargeProfilePic({
    super.key,
    required this.profilePic,
    this.borderRadius = 55,
    this.profileSize = 100,
    this.isFilePath = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isSvg = profilePic.toLowerCase().endsWith('.svg');
    bool isSvgNetwork = profilePic.toLowerCase().startsWith('http') &&
        profilePic.toLowerCase().endsWith('.svg');
    bool isAssetImage = profilePic.toLowerCase().startsWith('assets') &&
        !profilePic.toLowerCase().endsWith('.svg');
    bool isValid = profilePic.trim().isNotEmpty;
    Widget imageWidget;

    if (!isValid) {
      imageWidget = SizedBox(
        width: double.infinity, height: double.infinity,
        // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: profileSize.w, height: profileSize.h,),
        child: SizedBox(width: profileSize.w, height: profileSize.h),
      );
    } else if (isSvg && !isSvgNetwork) {
      imageWidget = SvgPicture.asset(
        profilePic,
        fit: BoxFit.cover,
        width: profileSize.w,
        height: profileSize.h,
        placeholderBuilder: (context) => SizedBox(
          width: profileSize.w, height: profileSize.h,
          // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: profileSize.w, height: profileSize.h),
          child: SizedBox(width: profileSize.w, height: profileSize.h),
        ),
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: profileSize.w,
          height: profileSize.h,
          // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: profileSize.w, height: profileSize.h,),
          child: SizedBox(width: profileSize.w, height: profileSize.h),
        ),
      );
    } else if (isAssetImage) {
      imageWidget = Image.asset(
        profilePic,
        fit: BoxFit.cover,
        width: profileSize.w,
        height: profileSize.h,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: profileSize.w,
          height: profileSize.h,
          // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: profileSize.w, height: profileSize.h,),
          child: SizedBox(width: profileSize.w, height: profileSize.h),
        ),
      );
    } else if (isSvgNetwork) {
      imageWidget = SvgPicture.network(
        profilePic,
        fit: BoxFit.cover,
        width: profileSize.w,
        height: profileSize.h,
        placeholderBuilder: (context) => SizedBox(
          width: profileSize.w, height: profileSize.h,
          // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: profileSize.w, height: profileSize.h),
          child: SizedBox(width: profileSize.w, height: profileSize.h),
        ),
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: profileSize.w,
          height: profileSize.h,
          // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: profileSize.w, height: profileSize.h,),
          child: SizedBox(width: profileSize.w, height: profileSize.h),
        ),
      );
    } else if (isFilePath) {
      imageWidget = Image.file(
        File(profilePic),
        fit: BoxFit.cover,
        width: profileSize.w,
        height: profileSize.h,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: profileSize.w,
          height: profileSize.h,
          // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: profileSize.w, height: profileSize.h,),
          child: SizedBox(width: profileSize.w, height: profileSize.h),
        ),
      );
    } else {
      imageWidget = Image.network(
        profilePic,
        // fit: BoxFit.cover,
        width: profileSize.w,
        height: profileSize.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => SizedBox(
            width: profileSize.w,
            height: profileSize.h,
            // child: Image.asset('assets/images/person.jpg', fit: BoxFit.cover, width: 110.w, height: 110.h,)),
            child: SizedBox(
              width: 110.w,
              height: 110.h,
            )),
      );
    }

    return Stack(
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
    );
  }
}
