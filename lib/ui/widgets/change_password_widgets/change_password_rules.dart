import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/constant.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/services/api_service.dart';
import 'package:spot/services/configuration.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/change_password_widgets/password_rule_item.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/input.dart';

class ChangePasswordRules extends StatefulWidget {
  const ChangePasswordRules({super.key});

  @override
  State<ChangePasswordRules> createState() => _ChangePasswordRulesState();
}

class _ChangePasswordRulesState extends State<ChangePasswordRules> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final oldPasswordFocusNode = FocusNode();
  final newPasswordFocusNode = FocusNode();
  bool showValidation = false;
  bool showOldPassError = false;
  bool showNewPassError = false;
  bool isPasswordSubmit = false;
  bool isPasswordChanged = false;
  bool invalidPass = false;

  // ********************** handle save change password ************************
  void onPressChangePasswordSave() async {
    final dataListProvider = context.read<DataListProvider>();
    final newPassword = newPasswordController.text;
    final oldPassword = oldPasswordController.text;
    final isValidNewPass = AppConstants.hasUppercase(newPassword) &&
        AppConstants.hasLowercase(newPassword) &&
        AppConstants.hasNumber(newPassword) &&
        AppConstants.hasSpecialChar(newPassword) &&
        AppConstants.hasMinLength(newPassword);
    setState(() {
      isPasswordSubmit = true;
    });

    if (oldPassword.isEmpty && newPassword.isEmpty) {
      setState(() {
        showOldPassError = true;
        showNewPassError = true;
        showValidation = true;
      });
      return;
    }

    if (oldPassword.isNotEmpty) {
      final postData = {
        "iUserId": dataListProvider.loginUserData['iUserId'],
        "vPassWord": oldPasswordController.text,
      };

      final response = await ApiService.apiPostData(Configuration.checkPassword,
          postData: postData, token: dataListProvider.loginUserData['tToken']);
      if (response?['status'] == 200) {
        if (newPassword.isNotEmpty && isValidNewPass) {
          final postPassData = {
            "iUserId": dataListProvider.loginUserData['iUserId'],
            "vPassWord": newPassword,
            "vOldPassword": oldPassword,
          };

          final passResponse = await ApiService.apiPostData(
              Configuration.newPassword,
              postData: postPassData,
              token: dataListProvider.loginUserData['tToken']);

          if (passResponse?['status'] == 200) {
            setState(() {
              isPasswordChanged = true;
            });
          }
        }
      } else {
        setState(() {
          invalidPass = true;
          showOldPassError = true;
        });
      }
    } else {}
  }

  // ******************* handle on change password ********************
  void handleOnChangeOldPassword(String text) {
    final isValidOldPass = AppConstants.hasUppercase(text) &&
        AppConstants.hasLowercase(text) &&
        AppConstants.hasNumber(text) &&
        AppConstants.hasSpecialChar(text) &&
        AppConstants.hasMinLength(text);
    setState(() {
      showValidation = true;
      showOldPassError = isValidOldPass ? false : true;
    });
  }

  void handleOnChangeNewPassword(String text) {
    final isValidNewPass = AppConstants.hasUppercase(text) &&
        AppConstants.hasLowercase(text) &&
        AppConstants.hasNumber(text) &&
        AppConstants.hasSpecialChar(text) &&
        AppConstants.hasMinLength(text);
    setState(() {
      showValidation = true;
      showNewPassError = isValidNewPass ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final newPassword = newPasswordController.text;
    final oldPassword = oldPasswordController.text;
    final isValidOldPass = (AppConstants.hasUppercase(oldPassword) &&
        AppConstants.hasLowercase(oldPassword) &&
        AppConstants.hasNumber(oldPassword) &&
        AppConstants.hasSpecialChar(oldPassword) &&
        AppConstants.hasMinLength(oldPassword));
    // final isValidNewPass = (AppConstants.hasUppercase(newPassword) && AppConstants.hasLowercase(newPassword) && AppConstants.hasNumber(newPassword) && AppConstants.hasSpecialChar(newPassword) && AppConstants.hasMinLength(newPassword));
    final isOldPasswordFocused = oldPasswordFocusNode.hasFocus;
    // final isNewPasswordFocused = newPasswordFocusNode.hasFocus;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: CommonWidgets.modalCardBoxDecoration(),
      child: isPasswordChanged
          ? Text("Your password has been changed successfully.",
              style: AppFontStyles.dmSansRegular
                  .copyWith(color: AppColorTheme.success, fontSize: 16))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Input(
                    title: 'Old Password',
                    inputValue: oldPasswordController,
                    focusNode: oldPasswordFocusNode,
                    isPassword: true,
                    isRequired: true,
                    showRequiredError: true,
                    requiredErrorMsg:
                        (isPasswordSubmit && !isValidOldPass) || invalidPass
                            ? "Required"
                            : "Required",
                    isError: (oldPasswordController.text.isEmpty &&
                            showOldPassError) ||
                        showOldPassError,
                    onChanged: (text) => handleOnChangeOldPassword(text)),
                SizedBox(
                  height: 16.h,
                ),
                Input(
                    title: 'New Password',
                    isPassword: true,
                    inputValue: newPasswordController,
                    focusNode: newPasswordFocusNode,
                    isRequired: true,
                    showRequiredError: true,
                    isError: (newPasswordController.text.isEmpty &&
                            showNewPassError) ||
                        showNewPassError,
                    onChanged: (text) => handleOnChangeNewPassword(text)),
                SizedBox(height: 2.5.h),
                if (showValidation) ...[
                  Text("Password requirements",
                      style: AppFontStyles.dmSansMedium.copyWith(
                        fontSize: 14,
                        color: AppColorTheme.dark87,
                      )),
                  const SizedBox(height: 10),
                  PasswordRuleItem(
                      "Password must include at least one uppercase letter.",
                      isOldPasswordFocused
                          ? AppConstants.hasUppercase(oldPassword)
                          : AppConstants.hasUppercase(newPassword)),
                  PasswordRuleItem(
                      "Password must include at least one lowercase letter.",
                      isOldPasswordFocused
                          ? AppConstants.hasLowercase(oldPassword)
                          : AppConstants.hasLowercase(newPassword)),
                  PasswordRuleItem(
                      "Password must include at least one number.",
                      isOldPasswordFocused
                          ? AppConstants.hasNumber(oldPassword)
                          : AppConstants.hasNumber(newPassword)),
                  PasswordRuleItem(
                      "Password must include at least one special character.",
                      isOldPasswordFocused
                          ? AppConstants.hasSpecialChar(oldPassword)
                          : AppConstants.hasSpecialChar(newPassword)),
                  PasswordRuleItem(
                      "Password must be at least eight characters long.",
                      isOldPasswordFocused
                          ? AppConstants.hasMinLength(oldPassword)
                          : AppConstants.hasMinLength(newPassword)),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  height: 16.h,
                ),
                Button(
                  onPressed: onPressChangePasswordSave,
                  title: 'Save',
                  backgroundColor: AppColorTheme.primary,
                  textColor: AppColorTheme.white,
                  width: MediaQuery.of(context).size.width,
                )
              ],
            ),
    );
  }
}
