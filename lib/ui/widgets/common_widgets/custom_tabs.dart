import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';

class CustomTabs extends StatefulWidget {
  String label;
  bool activeTab;
  VoidCallback onTabTap;

  CustomTabs(
      {super.key,
      required this.label,
      required this.activeTab,
      required this.onTabTap});

  @override
  State<CustomTabs> createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabs> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: widget.onTabTap,
        child: Padding(
          padding: EdgeInsets.only(
            right: widget.label == "Chats" ? 5.w : 0,
            left: widget.label == "Chats" ? 0 : 8.w,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight:
                    widget.activeTab ? FontWeight.w500 : FontWeight.w400,
                fontSize: 15.sp,
                color: widget.activeTab
                    ? AppColorTheme.black87
                    : AppColorTheme.black66,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
