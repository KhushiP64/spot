import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spot/core/app_sizes.dart';
import 'package:spot/core/themes.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController searchValue;
  final Function(String)? onChangedSearchValue;
  final margin;

  CustomSearchBar(
      {super.key,
      required this.searchValue,
      required this.onChangedSearchValue,
      required this.margin});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: AppColorTheme.searchBg,
          borderRadius: BorderRadius.all(Radius.circular(55.r)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(10, 41, 55, 0.12),
            ),
            BoxShadow(
              color: Color(0xffEEF2F5),
              offset: Offset(0, 1),
              spreadRadius: 0.0,
              blurRadius: 0.1,
            )
          ],
        ),
        child: TextField(
          style: AppFontStyles.dmSansRegular
              .copyWith(color: AppColorTheme.dark66, fontSize: 14.sp),
          controller: widget.searchValue,
          cursorColor: AppColorTheme.black,
          onChanged: widget.onChangedSearchValue,
          cursorWidth: 0.9.w,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            isCollapsed: true,
            isDense: true,
            prefixIconConstraints:
                BoxConstraints(minWidth: 37.w, minHeight: 37.h),
            prefixIcon: Padding(
              padding: EdgeInsets.only(top: 8.5.w, bottom: 8.5.w, left: 8.5.w),
              child: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 12.w,
                height: 12.h,
              ),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 1.5.h, vertical: 0),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
