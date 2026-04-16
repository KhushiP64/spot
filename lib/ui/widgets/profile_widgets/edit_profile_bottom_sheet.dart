import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/ui/widgets/change_password_widgets/change_password_rules.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/modal_header.dart';
import 'package:spot/ui/widgets/profile_widgets/edit_profile_user_details.dart';

class EditProfileBottomSheet extends StatefulWidget {
  final BuildContext context;
  final Function onPressConfirm;
  final VoidCallback closeEditProfileModal;

  const EditProfileBottomSheet(
      {super.key,
      required this.context,
      required this.onPressConfirm,
      required this.closeEditProfileModal});

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModalHeader(
            name: "Edit Profile",
            onTapCloseAction: widget.closeEditProfileModal),
        Expanded(
          child: Scaffold(
            backgroundColor: AppColorTheme.lightPrimary,
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonWidgets.modalMainTitle("User Details"),
                  EditProfileUserDetails(onPressConfirm: widget.onPressConfirm),
                  // *********************** change passowrd ui ***************************
                  CommonWidgets.modalMainTitle("Change Password"),
                  const ChangePasswordRules(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
