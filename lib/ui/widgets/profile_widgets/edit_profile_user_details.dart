import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/providers/group_provider.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/input.dart';
import 'package:spot/ui/widgets/common_widgets/large_profile_pic.dart';
import 'package:spot/ui/widgets/profile_widgets/edit_profile_picture.dart';

class EditProfileUserDetails extends StatefulWidget {
  final Function onPressConfirm;

  const EditProfileUserDetails({
    super.key,
    required this.onPressConfirm,
  });

  @override
  State<EditProfileUserDetails> createState() => _EditProfileUserDetailsState();
}

class _EditProfileUserDetailsState extends State<EditProfileUserDetails> {
  static final TextEditingController iUserId = TextEditingController();
  static final TextEditingController vUserName = TextEditingController();
  static final TextEditingController vEmail = TextEditingController();

  bool isUserNameError = false;
  String isEmailError = '';

  @override
  void initState() {
    // ********************* Fetch user data when the screen is loaded ***********************
    final dataListProvider = context.read<DataListProvider>();
    final loginUserData = dataListProvider.loginUserData;

    iUserId.text = loginUserData['iEngId'] ?? '';
    vUserName.text = loginUserData['vFullName'] ?? '';
    vEmail.text = loginUserData['vEmail'] ?? '';
    super.initState();
  }

  void onPressEditProfileIcon() async {
    FocusManager.instance.primaryFocus?.unfocus();
    CommonModal.show(
        context: context,
        heightFactor: 0.71,
        modalBackgroundColor: AppColorTheme.white,
        child: EditProfilePicture(
          headerTitle: 'Edit User Profile',
          onPressConfirm: (id, imageFile) {
            widget.onPressConfirm(id, imageFile);
          },
          isEditingProfile: true,
        ));
  }

  // ******************* handle edit profile save ********************
  void onPressEditProfileSave() async {
    final dataListProvider = context.read<DataListProvider>();

    if (vUserName.text.isNotEmpty &&
        vEmail.text.isNotEmpty &&
        !isUserNameError &&
        isEmailError.isEmpty) {
      final groupProvider = context.read<GroupProvider>();

      final response = await CommonFunctions.setProfileUpdate(
        context,
        vUserName.text,
        vEmail.text,
        iColorOption: groupProvider.profileSelectedColorOption != 0 &&
                groupProvider.profileSelectedColorOption != null
            ? groupProvider.profileSelectedColorOption
            : dataListProvider.loginUserData['iColorOption'] != 0 &&
                    groupProvider.chooseImageFile == null
                ? dataListProvider.loginUserData['iColorOption']
                : 0,
        isDeleteFile: groupProvider.profileSelectedColorOption != 0 &&
                groupProvider.profileSelectedColorOption != null
            ? 1
            : 0,
      );
      if (response['status'] == 200) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop();
        dataListProvider.getLoginUserData();
        final userData = await CommonFunctions.getUserData();
        SocketMessageEvents.allUsersGetNewSts(userData['tToken'], "[]");
      }
    }
  }

  // ****************** handle on Change username ********************
  void handleOnChangeUserName(String text) {
    if (vUserName.text.isEmpty) {
      setState(() {
        isUserNameError = true;
      });
    } else {
      setState(() {
        isUserNameError = false;
      });
    }
  }

  // ****************** handle on Change username ********************
  void handleOnChangeEmail(String text) {
    if (vEmail.text.isEmpty) {
      setState(() {
        isEmailError = 'Required';
      });
    } else if (text.isNotEmpty &&
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(text)) {
      setState(() {
        isEmailError = 'Invalid email';
      });
    } else {
      setState(() {
        isEmailError = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(8.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: CommonWidgets.modalCardBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CommonWidgets.modalSubTitle("Profile Picture"),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Consumer2<GroupProvider, DataListProvider>(
                      builder: (ctx, groupProvider, dataListProvider, child) {
                    final imageId = groupProvider.profileSelectedColorOption;
                    final selectedImage = AppMedia.userImages
                        .where((item) => item['iColorId'] == imageId);

                    final loginUserData = dataListProvider.loginUserData;
                    return groupProvider.chooseImageFile != null
                        ? LargeProfilePic(
                            isFilePath: true,
                            profilePic: groupProvider.chooseImageFile!.path)
                        : imageId != null && selectedImage.isNotEmpty
                            ? LargeProfilePic(
                                profilePic: selectedImage.first['vColorPick'])
                            : LargeProfilePic(
                                profilePic: loginUserData['vProfilePic']);
                  }),
                  CommonWidgets.editPictureIconPosition(onPressEditProfileIcon)
                ],
              ),
              SizedBox(height: 20.h),
              Input(title: 'User Id', inputValue: iUserId, isEditable: false),
              SizedBox(height: 16.h),
              Input(
                  title: 'User Name',
                  inputValue: vUserName,
                  isRequired: true,
                  showRequiredError: true,
                  isError: isUserNameError,
                  onChanged: (text) => handleOnChangeUserName(text)),
              SizedBox(height: 16.h),
              Input(
                  title: 'Email',
                  inputValue: vEmail,
                  isRequired: true,
                  showRequiredError: true,
                  isError: isEmailError.isNotEmpty ? true : false,
                  requiredErrorMsg: isEmailError,
                  onChanged: (text) => handleOnChangeEmail(text)),
              SizedBox(height: 16.h),
              Button(
                onPressed: onPressEditProfileSave,
                title: 'Save',
                backgroundColor: AppColorTheme.primary,
                textColor: AppColorTheme.white,
                width: MediaQuery.of(context).size.width,
              )
            ],
          )
        ],
      ),
    );
  }
}
