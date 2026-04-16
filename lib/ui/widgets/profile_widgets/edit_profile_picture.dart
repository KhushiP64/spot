import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/permission_handler.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/providers/group_provider.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/confirm_bottom_modal.dart';
import 'package:spot/ui/widgets/common_widgets/large_profile_pic.dart';
import 'package:spot/ui/widgets/common_widgets/modal_header.dart';

class EditProfilePicture extends StatefulWidget {
  final String headerTitle;
  final bool isEditingProfile;
  final Function onPressConfirm;

  const EditProfilePicture({
    super.key,
    required this.headerTitle,
    required this.isEditingProfile,
    required this.onPressConfirm,
  });

  @override
  State<EditProfilePicture> createState() => _EditProfilePictureState();
}

class _EditProfilePictureState extends State<EditProfilePicture> {
  int? selectedId;
  int? _tempSelectedColorId;
  XFile? _tempChooseImageFile;
  File? _tempChooseImage;
  bool isProfileDeleted = false;
  String? existUserProfile;
  static final userImages = AppMedia.userImages;

  @override
  void initState() {
    super.initState();
    // Delay the provider access until the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GroupProvider>();
      final dataListProvider = context.read<DataListProvider>();

      // Now, safe to access the provider data
      _tempSelectedColorId = provider.profileSelectedColorOption;
      _tempChooseImageFile = provider.chooseImageFile;
      if (provider.profileSelectedColorOption != null &&
          provider.profileSelectedColorOption != 0) {
        // print("object");
        _tempSelectedColorId = provider.profileSelectedColorOption;
        _tempChooseImage = null;
        _tempChooseImageFile = null;
      } else if (dataListProvider.loginUserData['iColorOption'] != null &&
          dataListProvider.loginUserData['iColorOption'] != 0 &&
          widget.isEditingProfile) {
        // print("object1.. ${dataListProvider.loginUserData['iColorOption']}");
        _tempSelectedColorId = dataListProvider.loginUserData['iColorOption'];
        _tempChooseImage = null;
        _tempChooseImageFile = null;
      } else if (_tempChooseImageFile != null) {
        // print("object2");
        _tempChooseImage = File(_tempChooseImageFile!.path);
        _tempSelectedColorId = null;
      } else if (dataListProvider.loginUserData['vProfilePic'] != null &&
          widget.isEditingProfile) {
        // print("object3");
        existUserProfile = dataListProvider.loginUserData['vProfilePic'];
      }

      // Trigger a rebuild if necessary
      setState(() {});

      // print("_tempSelectedColorId $_tempSelectedColorId");
    });
  }

  // ********************* confirm delete profile ************************
  void confirmDeleteProfile() {
    setState(() {
      _tempChooseImageFile = null;
      _tempChooseImage = null;
    });

    if (widget.isEditingProfile) {
      setState(() {
        existUserProfile = null;
      });
    }
    final randomIndex = Random().nextInt(AppMedia.groupImages.length);
    _tempSelectedColorId = randomIndex;
    Navigator.of(context).pop();
  }

// ******************** choose profile from gallary *******************
  Future onPressChooseUserProfile() async {
    final dataListProvider = context.read<DataListProvider>();
    final isProfileExist = existUserProfile != null &&
        dataListProvider.loginUserData['iColorOption'] == 0;

    final granted = await reqPermission();
    if (granted == true) {
      if (_tempChooseImageFile != null ||
          (isProfileExist && !isProfileDeleted)) {
        CommonModal.show(
            heightFactor: 0.20,
            context: context,
            child: ConfirmBottomModal(
                headerTitle: 'Delete Confirm',
                modalTitle: 'Are you sure you want to delete profile picture?',
                confirmBtnTitle: 'Delete',
                cancelBtnTitle: 'Cancel',
                backgroundColor: AppColorTheme.darkDanger,
                textColor: AppColorTheme.white,
                onPressConfirm: () => confirmDeleteProfile(),
                onPressCancel: () => Navigator.of(context).pop()));
        return;
      }

      if (_tempChooseImageFile == null && !isProfileExist) {
        XFile? imageGet = await CommonFunctions.pickImage(context);
        if (imageGet != null) {
          setState(() {
            _tempChooseImageFile = imageGet;
            _tempSelectedColorId = null;
            _tempChooseImage = File(imageGet.path);
          });
        } else {
          setState(() {
            _tempChooseImageFile = null;
            _tempChooseImage = null;
            final randomIndex = Random().nextInt(AppMedia.groupImages.length);
            _tempSelectedColorId = _tempSelectedColorId ?? randomIndex;
          });
        }
      } else {
        setState(() {
          _tempChooseImageFile = null;
          _tempChooseImage = null;
          final randomIndex = Random().nextInt(AppMedia.groupImages.length);
          _tempSelectedColorId = randomIndex;
        });
      }
    } else {
      // print("Permission not granted");
    }
  }

  // ****************** choose color option *******************
  void onPressChooseColorOption(int id) {
    setState(() {
      _tempSelectedColorId = id;
      _tempChooseImageFile = null;
      _tempChooseImage = null;
      isProfileDeleted = true;
    });
  }

  // *********************** handle on press cancel ***************************
  void onPressCancelEditProfile() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context);
    final dataListProvider = context.read<DataListProvider>();
    final isProfileExist = existUserProfile != null &&
        dataListProvider.loginUserData['iColorOption'] == 0;
    selectedId = provider.profileSelectedColorOption;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        ModalHeader(
            name: "Edit User Profile",
            showBackIcon: true,
            onTapCloseAction: onPressCancelEditProfile,
            onTapBackAction: onPressCancelEditProfile),
        SizedBox(height: 8.h),
        CommonWidgets.modalSubTitle("Custom Profile"),
        SizedBox(height: 6.h),

        Padding(
          padding: EdgeInsets.all(6.w),
          child: Row(
            children: [
              InkWell(
                onTap: _tempChooseImage != null ||
                        (isProfileExist && !isProfileDeleted)
                    ? null
                    : onPressChooseUserProfile,
                child: Container(
                    padding: EdgeInsets.all(2.w),
                    child: _tempChooseImageFile != null
                        ? LargeProfilePic(
                            profilePic: _tempChooseImageFile!.path,
                            profileSize: 75.w,
                            isFilePath: true)
                        : isProfileExist && isProfileDeleted == false
                            ? LargeProfilePic(
                                profilePic: existUserProfile!,
                                profileSize: 75.w)
                            : LargeProfilePic(
                                profilePic: AppMedia.customGroupProfile,
                                profileSize: 75.w)),
              ),
              SizedBox(width: 8.w),
              Button(
                  boxShadow: [],
                  onPressed: onPressChooseUserProfile,
                  title: _tempChooseImage != null ||
                          (isProfileExist && !isProfileDeleted)
                      ? 'Delete Profile'
                      : 'Choose Profile',
                  backgroundColor: _tempChooseImage != null ||
                          (isProfileExist && !isProfileDeleted)
                      ? AppColorTheme.darkDanger
                      : AppColorTheme.primary,
                  textColor: AppColorTheme.white)
            ],
          ),
        ),

        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonWidgets.seperatorLine(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                child: Text("OR",
                    style: AppFontStyles.dmSansMedium.copyWith(
                        color: AppColorTheme.dark40, fontSize: 13.sp)),
              ),
              CommonWidgets.seperatorLine(),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        CommonWidgets.modalSubTitle("System Default"),
        SizedBox(height: 6.h),

        /// GridView of SVGs
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userImages.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 6.w,
            mainAxisSpacing: 6.h,
          ),
          itemBuilder: (context, index) {
            final item = userImages[index];
            final isSelected = item['iColorId'] == _tempSelectedColorId;
            return GestureDetector(
                onTap: () => onPressChooseColorOption(item['iColorId']),
                child: Container(
                    decoration: BoxDecoration(
                      color: AppColorTheme.transparent,
                      borderRadius: BorderRadius.circular(50.r),
                      border: isSelected
                          ? Border.all(color: AppColorTheme.primary, width: 2.w)
                          : Border.all(
                              color: AppColorTheme.transparent, width: 2.w),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: Color.fromRGBO(0, 163, 239, 0.5),
                                  spreadRadius: 0,
                                  blurRadius: 4.r,
                                  offset: Offset(0, 0)),
                            ]
                          : [],
                    ),
                    child: Container(
                        padding: EdgeInsets.all(2.w), // White inner border
                        decoration: BoxDecoration(
                          color: AppColorTheme.white,
                          shape: BoxShape.circle,
                        ),
                        child: LargeProfilePic(profilePic: item['vColorPick'])
                        // ),
                        )));
          },
        ),

        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Button(
                    onPressed: () => widget.onPressConfirm(
                        _tempSelectedColorId, _tempChooseImageFile),
                    title: "Save",
                    backgroundColor: AppColorTheme.primary,
                    elevation: 1,
                    textColor: AppColorTheme.white),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Button(
                    boxShadow: [],
                    onPressed: onPressCancelEditProfile,
                    title: "Cancel",
                    backgroundColor: AppColorTheme.secondary6,
                    textColor: AppColorTheme.dark50),
              ),
            ],
          ),
        )
      ],
    );
  }
}
