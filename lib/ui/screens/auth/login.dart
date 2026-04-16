import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/common_center_modal.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import '../../../core/media.dart';
import '../../../services/api_service.dart';
import '../../../services/configuration.dart';
import '../../widgets/common_widgets/button.dart';
import '../../widgets/common_widgets/confirm_center_modal.dart';
import '../../widgets/common_widgets/input.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController iUserId = TextEditingController();
  final TextEditingController vUserName = TextEditingController();
  final TextEditingController vPassword = TextEditingController();
  final FocusNode userIdFocusNode = FocusNode();

  bool isUserIdNotValid = false;
  bool isPassNotValid = false;
  bool isSubmit = false;
  String userIdErrorText = '';
  int currentYear = DateTime.now().year;
  bool isPassword = false;
  bool isPasswordVisible = false;
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  @override
  void initState() {
    super.initState();
    userIdFocusNode.addListener(() {
      if (!userIdFocusNode.hasFocus) {
        onUserIdSubmit(iUserId.text);
      }
    });
  }

  // ********************** UserID / Username **********************
  void onUserIdChanged(String value) async {
    setState(() {
      isUserIdNotValid = value.isEmpty;
    });

    final response = await ApiService.apiPostData(Configuration.getUserName,
        postData: {"iUserId": value});

    if (response != null && response['status'] == 200) {
      setState(() {
        vUserName.text = response['message'] ?? "";
        userIdErrorText = "";
      });
    } else {
      setState(() {
        vUserName.clear();
        // userIdErrorText = response?['message'] ?? "";
        userIdErrorText = "User ID not exist";
      });
    }
  }

  Future<void> onUserIdSubmit(String value) async {
    final response = await ApiService.apiPostData(Configuration.getUserName,
        postData: {"iUserId": value});
    if (!mounted) return;
    if (response?['status'] == 412) {
      setState(() {
        // userIdErrorText = response?['message'] ?? "";
        userIdErrorText = "User ID not exist";
      });
    }
  }

  // ********************** Password **********************
  void onPasswordChanged(String value) {
    if (isSubmit && value.isNotEmpty) {
      setState(() => isPassNotValid = false);
    } else {
      setState(() => isPassNotValid = true);
    }
  }

  // ********************** LoginScreenResponsive Action **********************
  void onPressLoginScreenResponsive(int loginToUser) async {
    String userId = iUserId.text;
    String userName = vUserName.text;
    String password = vPassword.text;

    setState(() {
      isSubmit = true;
      isUserIdNotValid = userId.isEmpty;
      isPassNotValid = password.isEmpty;
    });

    if (!isUserIdNotValid) await onUserIdSubmit(userId);

    if (!isUserIdNotValid && !isPassNotValid) {
      final postData = {
        "iUserId": userId,
        "Cur_Fname": userName,
        "vPassword": password,
        "loginToUser": loginToUser
      };
      final response =
          await ApiService.apiPostData(Configuration.login, postData: postData);
      if (!mounted) return;

      if (response != null && response['status'] == 200) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        prefs.setString(
          'userData',
          jsonEncode({
            "tToken": response['tToken'],
            "iUserId": response['iUserId'],
          }),
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/chatList');
      } else if (response != null && response['status'] == 411) {
        if (!mounted) return;
        CommonCenterModal.show(
            context: context,
            modalBackgroundColor: AppColorTheme.white,
            child: ConfirmCenterModal(
                headerTitle: response['message'],
                confirmBtnTitle: "Ok",
                cancelBtnTitle: "Cancel",
                onPressConfirm: onPressConfirmOk,
                onPressCancel: onPressCancelLogin,
                backgroundColor: AppColorTheme.primary,
                textColor: AppColorTheme.white));
      } else {
        setState(() {
          userIdErrorText =
              "User ID not exist " ?? "LoginScreenResponsive failed";
        });
      }
    }
  }

  // *********************** handle already login **************************

  void onPressConfirmOk() {
    onPressLoginScreenResponsive(1);
  }

  void onPressCancelLogin() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    iUserId.dispose();
    vUserName.dispose();
    vPassword.dispose();
    userIdFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: AppColorTheme.white,
      appBar: AppBar(
        // toolbarHeight: appBarHeight,
        automaticallyImplyLeading: false,
        systemOverlayStyle: null,
        scrolledUnderElevation: 0.0,
        backgroundColor: AppColorTheme.white,
        elevation: 0,
        titleSpacing: 30.w,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(AppMedia.logo),
            SvgPicture.asset(AppMedia.spotText),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Login',
                  style: AppFontStyles.dmSansMedium
                      .copyWith(color: AppColorTheme.dark87, fontSize: 30.sp)),
              SizedBox(
                height: 40.h,
              ),
              if (userIdErrorText.isNotEmpty)
                CommonWidgets.errorText(userIdErrorText),
              SizedBox(
                height: 16.h,
              ),
              Input(
                title: 'User ID',
                isRequired: true,
                inputValue: iUserId,
                onChanged: onUserIdChanged,
                focusNode: userIdFocusNode,
                isError: isSubmit && isUserIdNotValid,
              ),
              isSubmit && isUserIdNotValid
                  ? CommonWidgets.errorText("Please Enter User ID.")
                  : Container(),
              SizedBox(height: 16.h),
              Input(
                  title: 'User Name', inputValue: vUserName, isEditable: false),
              SizedBox(height: 16.h),
              Input(
                title: 'Password',
                isPassword: true,
                isRequired: true,
                inputValue: vPassword,
                isError: isSubmit && isPassNotValid,
                onChanged: onPasswordChanged,
              ),
              isSubmit && isPassNotValid
                  ? CommonWidgets.errorText("Please Enter Password.")
                  : Container(),
              SizedBox(height: 24.h),
              Button(
                onPressed: () {
                  onPressLoginScreenResponsive(0);
                },
                title: 'Login',
                width: MediaQuery.of(context).size.width,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(30.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("© $currentYear",
                style: AppFontStyles.dmSansRegular.copyWith(
                    color: AppColorTheme.inputTitle, fontSize: 16.sp)),
            Image.asset(AppMedia.enlivenLogo, height: 13.h),
          ],
        ),
      ),
    );
  }
}
