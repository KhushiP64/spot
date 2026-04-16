import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/permission_handler.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/providers/group_provider.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/confirm_bottom_modal.dart';
import 'package:spot/ui/widgets/common_widgets/large_profile_pic.dart';
import 'package:spot/ui/widgets/common_widgets/modal_header.dart';

import '../../../core/themes.dart';

// class EditGroupPicture {
//   static final groupImages = AppMedia.groupImages;
//   static final userImages = AppMedia.userImages;
//   static void show(BuildContext context,
//       {required String headerTitle,
//         required bool isProfile,
//         required bool isEditingProfile,
//         required String confirmBtnTitle,
//         required String cancelBtnTitle,
//         required Function onPressConfirm,
//         required VoidCallback onPressCancel,
//         String? groupExistProfile,
//         int? existGroupProfileColorId}) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//       builder: (context) => SafeArea(
//         child: _EditGroupPictureModal(
//             headerTitle: headerTitle,
//             confirmBtnTitle: confirmBtnTitle,
//             cancelBtnTitle: cancelBtnTitle,
//             onPressCancel: onPressCancel,
//             onPressConfirm: onPressConfirm,
//             isProfile: isProfile,
//             isEditingProfile: isEditingProfile,
//             groupExistProfile: groupExistProfile,
//             existGroupProfileColorId: existGroupProfileColorId
//         ),
//       ),
//     );
//   }
// }
//
// class _EditGroupPictureModal extends StatefulWidget {
//   final String headerTitle;
//   final String confirmBtnTitle;
//   final String cancelBtnTitle;
//   final Function onPressConfirm;
//   final VoidCallback onPressCancel;
//   final bool isProfile;
//   final bool isEditingProfile;
//   final String? groupExistProfile;
//   final int? existGroupProfileColorId;
//
//   const _EditGroupPictureModal(
//       {super.key,
//         required this.headerTitle,
//         required this.confirmBtnTitle,
//         required this.cancelBtnTitle,
//         required this.onPressConfirm,
//         required this.onPressCancel,
//         required this.isProfile,
//         required this.isEditingProfile,
//         this.groupExistProfile,
//         this.existGroupProfileColorId});
//
//   @override
//   State<_EditGroupPictureModal> createState() => _EditGroupPictureModalState();
// }
//
// class _EditGroupPictureModalState extends State<_EditGroupPictureModal> {
//   int? selectedId;
//   int? _tempSelectedColorId;
//   XFile? _tempChooseImageFile;
//   File? _tempChooseImage;
//   bool isProfileDeleted = false;
//   String? existUserProfile;
//   String? existGroupProfile;
//   int? existGroupProfileColorId;
//
//   @override
//   void initState() {
//     super.initState();
//     // Delay the provider access until the next frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<GroupProvider>();
//       final dataListProvider = context.read<DataListProvider>();
//
//       // Now, safe to access the provider data
//       _tempSelectedColorId = provider.profileSelectedColorOption;
//       _tempChooseImageFile = provider.chooseImageFile;
//       if (provider.profileSelectedColorOption != null &&
//           provider.profileSelectedColorOption != 0) {
//         // print("object");
//         _tempSelectedColorId = provider.profileSelectedColorOption;
//         _tempChooseImage = null;
//         _tempChooseImageFile = null;
//       } else if (dataListProvider.loginUserData['iColorOption'] != null &&
//           dataListProvider.loginUserData['iColorOption'] != 0 &&
//           widget.isEditingProfile) {
//         // print("object1.. ${dataListProvider.loginUserData['iColorOption']}");
//         _tempSelectedColorId = dataListProvider.loginUserData['iColorOption'];
//         _tempChooseImage = null;
//         _tempChooseImageFile = null;
//       } else if (_tempChooseImageFile != null) {
//         // print("object2");
//         _tempChooseImage = File(_tempChooseImageFile!.path);
//         _tempSelectedColorId = null;
//       } else if (dataListProvider.loginUserData['vProfilePic'] != null &&
//           widget.isEditingProfile) {
//         // print("object3");
//         existUserProfile = dataListProvider.loginUserData['vProfilePic'];
//       } else if (widget.groupExistProfile != null) {
//         // print("object4");
//         existGroupProfile = widget.groupExistProfile;
//       }
//       if (widget.existGroupProfileColorId != 0 &&
//           provider.profileSelectedColorOption == null &&
//           widget.isEditingProfile == false) {
//         // print("widget.existGroupProfileColorId ${widget.existGroupProfileColorId}");
//         _tempSelectedColorId = widget.existGroupProfileColorId;
//       }
//
//       // Trigger a rebuild if necessary
//       setState(() {});
//
//       // print("_tempSelectedColorId $_tempSelectedColorId");
//     });
//   }
//
//   // ********************* confirm delete profile ************************
//   void confirmDeleteProfile() {
//     setState(() {
//       _tempChooseImageFile = null;
//       _tempChooseImage = null;
//       existGroupProfile = null;
//     });
//
//     if (widget.isEditingProfile) {
//       setState(() {
//         existUserProfile = null;
//       });
//     }
//     final randomIndex = Random().nextInt(AppMedia.groupImages.length);
//     _tempSelectedColorId = randomIndex;
//     Navigator.of(context).pop();
//   }
//
//   // ******************** choose profile from gallary *******************
//   Future onPressChooseGroupProfile() async {
//     final granted = await reqPermission();
//     if (granted == true) {
//       if (_tempChooseImageFile != null || (existGroupProfile != null && widget.existGroupProfileColorId == 0)) {
//         ConfirmModal.show(context,
//             headerTitle: 'Delete Confirm',
//             modalTitle: 'Are you sure you want to delete profile picture?',
//             confirmBtnTitle: 'Delete',
//             cancelBtnTitle: 'Cancel',
//             backgroundColor: AppColorTheme.darkDanger,
//             textColor: AppColorTheme.white,
//             onPressConfirm: () => confirmDeleteProfile(),
//             onPressCancel: () => Navigator.of(context).pop());
//         return;
//       }
//
//       if (_tempChooseImageFile == null) {
//         final picker = ImagePicker();
//         final pickedImage = await picker.pickImage(source: ImageSource.gallery);
//         if (pickedImage != null) {
//           String fileExtension = pickedImage.name.split('.').last.toLowerCase();
//           if (fileExtension.toLowerCase() == 'jpg' || fileExtension.toLowerCase() == 'jpeg' || fileExtension.toLowerCase() == 'png') {
//             XFile? img = await _cropImage(imgFile: File(pickedImage.path));
//             setState(() {
//               _tempChooseImageFile = img;
//               _tempSelectedColorId = null;
//               _tempChooseImage = File(pickedImage.path);
//             });
//           } else {
//             // Show an error message if file is not jpg or png
//             showDialog(
//               context: context,
//               builder: (context) => AlertDialog(
//                 title: const Text('Invalid File'),
//                 content: const Text('Only JPG and PNG files are allowed.'),
//                 actions: [
//                   TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text('OK')),
//                 ],
//               ),
//             );
//           }
//         }
//       } else {
//         setState(() {
//           _tempChooseImageFile = null;
//           _tempChooseImage = null;
//           final randomIndex = Random().nextInt(AppMedia.groupImages.length);
//           _tempSelectedColorId = randomIndex;
//         });
//       }
//     } else {
//       // print("Permission not granted");
//     }
//   }
//
//   // ******************** choose profile from gallary *******************
//   Future onPressChooseUserProfile() async {
//     final dataListProvider = context.read<DataListProvider>();
//     final isProfileExist = existUserProfile != null &&
//         dataListProvider.loginUserData['iColorOption'] == 0;
//
//     final granted = await reqPermission();
//     if (granted == true) {
//       if (_tempChooseImageFile != null || isProfileExist) {
//         ConfirmModal.show(context,
//             headerTitle: 'Delete Confirm',
//             modalTitle: 'Are you sure you want to delete profile picture?',
//             confirmBtnTitle: 'Delete',
//             cancelBtnTitle: 'Cancel',
//             backgroundColor: AppColorTheme.darkDanger,
//             textColor: AppColorTheme.white,
//             onPressConfirm: () => confirmDeleteProfile(),
//             onPressCancel: () => Navigator.of(context).pop());
//         return;
//       }
//
//       if (_tempChooseImageFile == null && !isProfileExist) {
//         final picker = ImagePicker();
//         final pickedImage = await picker.pickImage(
//           source: ImageSource.gallery,
//         );
//         if (pickedImage != null) {
//           String fileExtension = pickedImage.name.split('.').last.toLowerCase();
//           if (fileExtension.toLowerCase() == 'jpg' ||
//               fileExtension.toLowerCase() == 'jpeg' ||
//               fileExtension.toLowerCase() == 'png') {
//             XFile? img = await _cropImage(imgFile: File(pickedImage.path));
//             setState(() {
//               _tempChooseImageFile = img;
//               _tempSelectedColorId = null;
//               _tempChooseImage = File(pickedImage.path);
//             });
//           } else {
//             // Show an error message if file is not jpg or png
//             showDialog(
//               context: context,
//               builder: (context) => AlertDialog(
//                 title: const Text('Invalid File'),
//                 content: const Text('Only JPG and PNG files are allowed.'),
//                 actions: [
//                   TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text('OK')),
//                 ],
//               ),
//             );
//           }
//         }
//       } else {
//         setState(() {
//           _tempChooseImageFile = null;
//           _tempChooseImage = null;
//           final randomIndex = Random().nextInt(AppMedia.groupImages.length);
//           _tempSelectedColorId = randomIndex;
//         });
//       }
//     } else {
//       // print("Permission not granted");
//     }
//   }
//
//   Future<XFile?> _cropImage({required File imgFile}) async {
//     try {
//       CroppedFile? croppedFile = await ImageCropper().cropImage(
//         sourcePath: imgFile.path,
//
//         aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
//
//         uiSettings: [
//           AndroidUiSettings(
//             toolbarTitle: 'Edit Photo',
//             toolbarColor: AppColorTheme.black,
//             toolbarWidgetColor: Colors.white,
//             initAspectRatio: CropAspectRatioPreset.square,
//             lockAspectRatio: true,
//             hideBottomControls: false,
//             activeControlsWidgetColor: AppColorTheme.primary,
//             statusBarColor: AppColorTheme.primary,   // ✅ fixes status bar overlay
//             backgroundColor: Colors.black,
//           ),
//           IOSUiSettings(
//             title: 'Edit Photo',
//             aspectRatioLockEnabled: true,
//           ),
//         ],
//
//         maxWidth: 300,
//         maxHeight: 300,
//       );
//
//       if (croppedFile == null) return null;
//
//       // ✅ Convert CroppedFile → XFile
//       return XFile(croppedFile.path);
//     } catch (e) {
//       // print("Error cropping image: $e");
//       return null;
//     }
//   }
//
//   // ****************** choose color option *******************
//   void onPressChooseColorOption(int id) {
//     setState(() {
//       _tempSelectedColorId = id;
//       _tempChooseImageFile = null;
//       _tempChooseImage = null;
//       isProfileDeleted = true;
//       existGroupProfile = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<GroupProvider>(context);
//     final dataListProvider = context.read<DataListProvider>();
//     final isProfileExist = existUserProfile != null && dataListProvider.loginUserData['iColorOption'] == 0;
//     bool isSvg = dataListProvider.loginUserData != null ? (existUserProfile?.toLowerCase() ?? '').endsWith('.svg') : false;
//     selectedId = provider.profileSelectedColorOption;
//     bool isSvgGroupImage = widget.groupExistProfile != null ? (widget.groupExistProfile?.toLowerCase() ?? '').endsWith('.svg') : false;
//     bool groupProfileCondition = (_tempSelectedColorId == 0 || _tempSelectedColorId == null) && (provider.profileSelectedColorOption == 0 || provider.profileSelectedColorOption == null);
//
//     return Container(
//       decoration: CommonWidgets.modalCardBoxDecoration(),
//       height: MediaQuery.of(context).size.height * 0.70,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Header
//             Padding(
//               padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                       onTap: widget.onPressCancel,
//                       child: Icon(Icons.arrow_back, color: const Color(0xffAEB9BD).withOpacity(0.7))),
//                   Expanded(
//                       child: Text(widget.headerTitle, textAlign: TextAlign.center, style: AppFontStyles.dmSansMedium.copyWith(color: AppColorTheme.dark87, fontSize: 18),)),
//                   GestureDetector(onTap: widget.onPressCancel, child: Icon(Icons.close, color: Color(0xffAEB9BD).withOpacity(0.7),))
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 15),
//             Text('Custom Profile', style: AppFontStyles.dmSansMedium.copyWith(color: AppColorTheme.dark40, fontSize: 13.5)),
//             const SizedBox(height: 15),
//
//             Row(
//               children: [
//                 widget.isEditingProfile
//                     ? Container(
//                   margin: const EdgeInsets.only(right: 10),
//                   decoration: BoxDecoration(
//                     border: Border.all(width: 1, color: AppColorTheme.secondary),
//                     borderRadius:  BorderRadius.circular(widget.isProfile ? 50 : 10),
//                   ),
//                   child: _tempChooseImageFile != null
//                       ? ClipRRect(
//                       borderRadius: BorderRadius.circular(
//                           widget.isProfile ? 50 : 10),
//                       child: Image.file(File(_tempChooseImageFile!.path), height: 70, width: 70, fit: BoxFit.cover))
//                       : isProfileExist && isProfileDeleted == false
//                       ? isSvg
//                       ? ClipRRect(
//                       borderRadius: BorderRadius.circular(widget.isProfile ? 50 : 10),
//                       child: SvgPicture.network(existUserProfile!, height: 70, width: 70))
//                       : ClipRRect(borderRadius: BorderRadius.circular(widget.isProfile ? 50 : 10),
//                       child: Image.network(existUserProfile!, height: 70, width: 70))
//                       : ClipRRect(
//                       borderRadius: BorderRadius.circular(widget.isProfile ? 50 : 10),
//                       child: SvgPicture.asset(AppMedia.customGroupProfile, height: 70, width: 70)),
//                 )
//                     : Container(
//                   margin: const EdgeInsets.only(right: 10),
//                   decoration: BoxDecoration(
//                       border: Border.all(width: 1, color: AppColorTheme.secondary),
//                       borderRadius: BorderRadius.circular(widget.isProfile ? 50 : 10)),
//                   child: existGroupProfile != null && groupProfileCondition && _tempChooseImage == null
//                       ? ClipRRect(borderRadius: BorderRadius.circular(10),
//                       child: isSvgGroupImage ? SvgPicture.network(existGroupProfile!, height: 70, width: 70)
//                           : Image.network(existGroupProfile!, height: 70, width: 70))
//                       : _tempChooseImage != null
//                       ? ClipRRect(borderRadius: BorderRadius.circular(widget.isProfile ? 50 : 10),
//                       child: Image.file(_tempChooseImage!, height: 70, width: 70, fit: BoxFit.cover))
//                       : ClipRRect(
//                       borderRadius: BorderRadius.circular(widget.isProfile ? 50 : 10),
//                       child: SvgPicture.asset(AppMedia.customGroupProfile, height: 70, width: 70)),
//                 ),
//                 widget.isEditingProfile
//                 ? Button(
//                   boxShadow: [],
//                   onPressed: onPressChooseUserProfile,
//                   title: _tempChooseImage != null || (isProfileExist && !isProfileDeleted) ? 'Delete Profile' : 'Choose Profile',
//                   backgroundColor: _tempChooseImage != null || (isProfileExist && !isProfileDeleted) ? AppColorTheme.darkDanger : AppColorTheme.primary,
//                   textColor: AppColorTheme.white
//                 )
//                 : Button(
//                   boxShadow: [],
//                   onPressed: onPressChooseGroupProfile,
//                   title: _tempChooseImage != null || (existGroupProfile != null && groupProfileCondition)
//                     ? 'Delete Profile' : 'Choose Profile',
//                   backgroundColor: _tempChooseImage != null || (existGroupProfile != null && groupProfileCondition)
//                   ? AppColorTheme.darkDanger
//                   : AppColorTheme.primary,
//                   textColor: AppColorTheme.white
//                 )
//               ],
//             ),
//
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.only(right: 10),
//                     decoration: BoxDecoration(
//                       border:
//                       Border.all(width: 0.5, color: AppColorTheme.dark40),
//                     ),
//                   ),
//                 ),
//                 Text("OR", style: AppFontStyles.dmSansMedium.copyWith(color: AppColorTheme.dark40, fontSize: 16)),
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.only(left: 10),
//                     decoration: BoxDecoration(border: Border.all(width: 0.5, color: AppColorTheme.dark40)),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 15),
//             Text('System Default', style: AppFontStyles.dmSansMedium.copyWith(color: AppColorTheme.dark40, fontSize: 13.5)),
//             const SizedBox(height: 10),
//
//             /// GridView of SVGs
//             Expanded(
//               child: GridView.builder(
//                 itemCount: widget.isEditingProfile
//                     ? EditGroupPicture.userImages.length
//                     : EditGroupPicture.groupImages.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 4,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemBuilder: (context, index) {
//                   final item = widget.isEditingProfile
//                       ? EditGroupPicture.userImages[index]
//                       : EditGroupPicture.groupImages[index];
//                   final isSelected = item['iColorId'] == _tempSelectedColorId;
//                   return GestureDetector(
//                       onTap: () => onPressChooseColorOption(item['iColorId']),
//                       child:
//                       // Container(
//                       //   // decoration: BoxDecoration(
//                       //   //   borderRadius: BorderRadius.circular(12),
//                       //   //   border: isSelected
//                       //   //       ? Border.all(
//                       //   //           color: const Color.fromRGBO(0, 163, 239, 0.5),
//                       //   //           width: 2)
//                       //   //       : null,
//                       //   //   boxShadow: isSelected
//                       //   //       ? [
//                       //   //           const BoxShadow(
//                       //   //             color: Color.fromRGBO(0, 163, 239, 0.5),
//                       //   //             offset: Offset(0, 0),
//                       //   //             blurRadius: 2,
//                       //   //             spreadRadius: 0,
//                       //   //           ),
//                       //   //         ]
//                       //   //       : [],
//                       //   // ),
//                       //   width: 100,
//                       //   height: 100,
//                       //   decoration: BoxDecoration(
//                       //     borderRadius: BorderRadius.circular(12),
//                       //     // border: isSelected
//                       //     //     ? Border.all(
//                       //     //         color: const Color.fromRGBO(0, 163, 239, 0.5),
//                       //     //         width: 2)
//                       //     //     : null,
//                       //     boxShadow: [
//                       //       isSelected
//                       //           ? BoxShadow(
//                       //               color: Color.fromRGBO(0, 163, 239, 0.5),
//                       //               spreadRadius:
//                       //                   0, // control how far outside the glow goes
//                       //               blurRadius: 1, // softness of glow
//                       //               offset: Offset(
//                       //                   0, 0), // no offset, centered shadow
//                       //             )
//                       //           : BoxShadow(
//                       //               color: Colors.transparent,
//                       //               // color: Color.fromRGBO(0, 163, 239, 0.5),
//                       //               spreadRadius:
//                       //                   1, // control how far outside the glow goes
//                       //               blurRadius: 1, // softness of glow
//                       //               offset: Offset(
//                       //                   0, 0), // no offset, centered shadow
//                       //             ),
//                       //     ],
//                       //   ),
//                       //   child: Padding(
//                       //     padding: const EdgeInsets.all(2.5),
//                       //     child: Container(
//                       //       decoration: BoxDecoration(
//                       //           border: Border.all(color: Colors.white)),
//                       //       child: ClipRRect(
//                       //         borderRadius: BorderRadius.circular(
//                       //             widget.isProfile ? 50 : 10),
//                       //         child: SvgPicture.asset(item['vColorPick'],
//                       //             fit: BoxFit.contain, height: 40, width: 40),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       Padding(
//                         padding: const EdgeInsets.all(2),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.transparent,
//                             borderRadius: BorderRadius.circular(
//                                 widget.isProfile ? 50 : 12),
//                             border: isSelected
//                                 ? Border.all(
//                               color: const Color.fromRGBO(0, 163, 239, 1),
//                               width: 2,
//                             )
//                                 : null,
//                             boxShadow: isSelected
//                                 ? [
//                               const BoxShadow(color: Color.fromRGBO(0, 163, 239, 0.5), spreadRadius: 0.5, blurRadius: 2, offset: Offset(0, 0),),
//                             ]
//                                 : [],
//                           ),
//                           child: isSelected
//                               ? Container(
//                             padding: const EdgeInsets.all(2.5), // White inner border
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(widget.isProfile ? 50 : 10),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(widget.isProfile ? 50 : 10),
//                               child: SvgPicture.asset(
//                                 item['vColorPick'],
//                                 fit: BoxFit.contain,
//                                 height: 40,
//                                 width: 40,
//                               ),
//                             ),
//                           )
//                               : ClipRRect(
//                             borderRadius: BorderRadius.circular(widget.isProfile ? 50 : 10),
//                             child: SvgPicture.asset(item['vColorPick'], fit: BoxFit.contain, height: 40, width: 40),
//                           ),
//                         ),
//                       ));
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 24),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Button(
//                       width: 158,
//                       onPressed: () => widget.onPressConfirm(
//                           _tempSelectedColorId, _tempChooseImageFile),
//                       title: widget.confirmBtnTitle,
//                       backgroundColor: AppColorTheme.primary,
//                       elevation: 1,
//                       textColor: AppColorTheme.white
//                   ),
//                   const SizedBox(width: 4),
//                   Button(
//                     boxShadow: [],
//                     width: 158,
//                     onPressed: widget.onPressCancel,
//                     title: widget.cancelBtnTitle,
//                     backgroundColor: AppColorTheme.secondary6,
//                     textColor: AppColorTheme.dark50
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class EditGroupPicture extends StatefulWidget {
  final Function onPressConfirm;
  final String? groupExistProfile;
  final int? existGroupProfileColorId;

  const EditGroupPicture({
    super.key,
    required this.onPressConfirm,
    this.existGroupProfileColorId,
    this.groupExistProfile,
  });

  @override
  State<EditGroupPicture> createState() => _EditGroupPictureState();
}

class _EditGroupPictureState extends State<EditGroupPicture> {
  int? selectedId;
  int? _tempSelectedColorId;
  XFile? _tempChooseImageFile;
  File? _tempChooseImage;
  bool isProfileDeleted = false;
  String? existUserProfile;
  String? existGroupProfile;
  int? existGroupProfileColorId;
  static final groupImages = AppMedia.groupImages;

  @override
  void initState() {
    super.initState();
    // Delay the provider access until the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GroupProvider>();

      // Now, safe to access the provider data
      _tempSelectedColorId = provider.profileSelectedColorOption;
      _tempChooseImageFile = provider.chooseImageFile;
      if (provider.profileSelectedColorOption != null &&
          provider.profileSelectedColorOption != 0) {
        // print("object");
        _tempSelectedColorId = provider.profileSelectedColorOption;
        _tempChooseImage = null;
        _tempChooseImageFile = null;
      } else if (_tempChooseImageFile != null) {
        // print("object2");
        _tempChooseImage = File(_tempChooseImageFile!.path);
        _tempSelectedColorId = null;
      } else if (widget.groupExistProfile != null) {
        // print("object4");
        existGroupProfile = widget.groupExistProfile;
      }
      if (widget.existGroupProfileColorId != 0 &&
          provider.profileSelectedColorOption == null) {
        // print("widget.existGroupProfileColorId ${widget.existGroupProfileColorId}");
        _tempSelectedColorId = widget.existGroupProfileColorId;
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
      existGroupProfile = null;
    });

    final randomIndex = Random().nextInt(AppMedia.groupImages.length);
    _tempSelectedColorId = randomIndex;
    Navigator.of(context).pop();
  }

  // ******************** choose profile from gallary *******************
  Future onPressChooseGroupProfile() async {
    final granted = await reqPermission();
    if (granted == true) {
      if (_tempChooseImageFile != null ||
          (existGroupProfile != null && widget.existGroupProfileColorId == 0)) {
        CommonModal.show(
            context: context,
            // heightFactor: 0.20,
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

      if (_tempChooseImageFile == null) {
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
      existGroupProfile = null;
    });
  }

  // ********************** handle cancel edit group profile ************************
  void onPressCancelEdit() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GroupProvider>();
    selectedId = provider.profileSelectedColorOption;
    bool groupProfileCondition =
        (_tempSelectedColorId == 0 || _tempSelectedColorId == null) &&
            (provider.profileSelectedColorOption == 0 ||
                provider.profileSelectedColorOption == null);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        ModalHeader(
            name: "Create New Group",
            showBackIcon: true,
            onTapCloseAction: onPressCancelEdit,
            onTapBackAction: onPressCancelEdit),
        SizedBox(height: 8.h),
        CommonWidgets.modalSubTitle("Custom Profile"),
        SizedBox(height: 6.h),

        Padding(
          padding: EdgeInsets.all(6.w),
          child: Row(
            children: [
              InkWell(
                onTap: _tempChooseImage != null ||
                        (existGroupProfile != null && groupProfileCondition)
                    ? null
                    : onPressChooseGroupProfile,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  child: existGroupProfile != null &&
                          groupProfileCondition &&
                          _tempChooseImage == null
                      ? LargeProfilePic(
                          profilePic: existGroupProfile!,
                          profileSize: 75.w,
                          borderRadius: 10)
                      : _tempChooseImage != null
                          ? LargeProfilePic(
                              profilePic: _tempChooseImage!.path,
                              profileSize: 75.w,
                              isFilePath: true,
                              borderRadius: 10)
                          : LargeProfilePic(
                              profilePic: AppMedia.customGroupProfile,
                              profileSize: 75.w,
                              borderRadius: 10),
                ),
              ),
              SizedBox(width: 8.w),
              Button(
                  boxShadow: [],
                  onPressed: onPressChooseGroupProfile,
                  title: _tempChooseImage != null ||
                          (existGroupProfile != null && groupProfileCondition)
                      ? 'Delete Profile'
                      : 'Choose Profile',
                  backgroundColor: _tempChooseImage != null ||
                          (existGroupProfile != null && groupProfileCondition)
                      ? AppColorTheme.darkDanger
                      : AppColorTheme.primary,
                  textColor: AppColorTheme.white),
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
          itemCount: groupImages.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 6.w,
            mainAxisSpacing: 6.h,
          ),
          itemBuilder: (context, index) {
            final item = groupImages[index];
            final isSelected = item['iColorId'] == _tempSelectedColorId;
            return GestureDetector(
                onTap: () => onPressChooseColorOption(item['iColorId']),
                child: Container(
                    decoration: BoxDecoration(
                      color: AppColorTheme.transparent,
                      borderRadius: BorderRadius.circular(14.r),
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
                                  offset: Offset(0, 0))
                            ]
                          : [],
                    ),
                    child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppColorTheme.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: LargeProfilePic(
                          profilePic: item['vColorPick'],
                          borderRadius: 12.r,
                        ))));
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
                    onPressed: onPressCancelEdit,
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
