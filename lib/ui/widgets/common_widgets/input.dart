import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/themes.dart';

class Input extends StatefulWidget {
  final String title;
  final bool isRequired;
  final bool isEditable;
  final bool isError;
  final bool isPassword;
  final bool showBorder;
  final bool showRequiredError;
  final String requiredErrorMsg;
  final int maxLines;
  final int? maxLength;
  final Border? border;
  final TextEditingController inputValue;
  final Widget? iconPrefix;
  final Widget? iconSuffix;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function(dynamic)? onTapOutside;
  final FocusNode? focusNode;
  final TextStyle? textStyles;
  final double height;

  const Input(
      {super.key,
      required this.title,
      this.maxLines = 1,
      this.maxLength,
      required this.inputValue,
      this.iconPrefix,
      this.iconSuffix,
      this.isRequired = false,
      this.isEditable = true,
      this.isError = false,
      this.showRequiredError = false,
      this.requiredErrorMsg = 'Required',
      this.onChanged,
      this.onSubmitted,
      this.onTapOutside,
      this.focusNode,
      this.border,
      this.isPassword = false,
      this.showBorder = true,
      this.textStyles,
      this.height = 1.5});

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  late TextEditingController _controller;
  int _currentLength = 0;
  bool isLoggedIn = false;

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  bool isPasswordVisible = false;
  @override
  void initState() {
    super.initState();
    _controller = widget.inputValue;
    _controller.addListener(_updateLength);
  }

  void _updateLength() {
    setState(() {
      _currentLength = _controller.text.length;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateLength);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 1.w),
              child: RichText(
                text: TextSpan(
                  text: widget.title,
                  style: widget.textStyles ??
                      AppFontStyles.dmSansRegular.copyWith(
                        color: AppColorTheme.black87,
                        fontSize: 14.sp,
                      ),
                  children: widget.isRequired
                      ? [
                          TextSpan(
                              text: '*',
                              style: AppFontStyles.dmSansRegular.copyWith(
                                  color: AppColorTheme.requiredStar,
                                  fontSize: 14.sp))
                        ]
                      : [],
                ),
              ),
            ),
            if (widget.isError && widget.showRequiredError)
              Text(
                widget.requiredErrorMsg.isNotEmpty
                    ? widget.requiredErrorMsg
                    : "Required",
                textAlign: TextAlign.end,
                style: AppFontStyles.dmSansMedium
                    .copyWith(color: AppColorTheme.darkDanger, fontSize: 12.sp),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all((widget.isError) ? 2.w : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.r),
            border: Border.all(
              color: (widget.isError)
                  ? AppColorTheme.darkDanger
                  : Colors.transparent,
              width: 2.w,
            ),
          ),
          child: Stack(
            children: [
              // 2. THE INNER SHADOW BACKGROUND
              // We put this in a Positioned.fill so it takes the exact size of the input
              Positioned.fill(
                child: InnerShadow(
                  shadows: widget.isEditable
                      ? [
                          Shadow(
                            color: const Color.fromRGBO(10, 41, 55, 0.25),
                            blurRadius: 3.r,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : [],
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isEditable
                          ? AppColorTheme.white
                          : AppColorTheme.lightInfo,
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(
                        color: const Color.fromRGBO(10, 41, 55, 0.06),
                        width: 1.w,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                  ),
                ),
              ),

              // 3. THE ACTUAL TEXTFIELD
              TextField(
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                enabled: widget.isEditable,
                style: AppFontStyles.dmSansRegular.copyWith(
                    color: widget.isEditable
                        ? AppColorTheme.black87
                        : AppColorTheme.dark40,
                    fontSize: 14.sp),
                obscureText: widget.isPassword && !isPasswordVisible,
                controller: _controller,
                cursorColor: AppColorTheme.black,
                // cursorWidth: 1,
                // cursorHeight: 9,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                onTapOutside: widget.onTapOutside,
                focusNode: widget.focusNode,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  counterText: "",
                  isCollapsed: true,
                  isDense: true,
                  prefixIconConstraints:
                      BoxConstraints(minWidth: 0.w, maxWidth: 31.2.w),
                  suffixIconConstraints: BoxConstraints(minWidth: 0.w),
                  prefixIcon: widget.isEditable
                      ? widget.iconPrefix
                      : Padding(
                          padding: EdgeInsets.only(
                              left: 10.w, right: 10.w, top: 9.h, bottom: 10.h),
                          child: Icon(FeatherIcons.lock,
                              color: AppColorTheme.muted),
                        ),
                  suffixIcon: widget.isPassword
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10.w,
                                right: 10.w,
                                top: 9.h,
                                bottom: 10.h),
                            child: Icon(
                                isPasswordVisible
                                    ? FeatherIcons.eye
                                    : FeatherIcons.eyeOff,
                                color: AppColorTheme.muted),
                          ),
                        )
                      : widget.iconSuffix,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                  border: InputBorder.none,
                  filled: false,
                  // fillColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
        if (widget.maxLength != null)
          Padding(
            padding: EdgeInsets.only(right: 4.h),
            child: Align(
                alignment: Alignment.centerRight,
                child: Text('$_currentLength/${widget.maxLength}',
                    textAlign: TextAlign.right,
                    style: AppFontStyles.dmSansMedium.copyWith(
                        fontSize: 11.5, color: AppColorTheme.dark50))),
          ),
      ],
    );
  }
}
