import 'dart:math';
import 'package:flutter/material.dart' hide InputBorder;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/providers/group_provider.dart';
import 'package:spot/providers/profile_provider.dart';
import 'package:spot/ui/widgets/chat_list_widgets/chat_list_item.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/confirm_bottom_modal.dart';
import 'package:spot/ui/widgets/common_widgets/input.dart';
import 'package:spot/ui/widgets/common_widgets/large_profile_pic.dart';
import 'package:spot/ui/widgets/common_widgets/modal_header.dart';

import '../../../core/responsive_fonts.dart';

// class CreateGroupBottomSheetModal {
//   static void show({
//     required BuildContext context,
//     required TabController tabController,
//     required Map<String, dynamic> loginUserData,
//     required VoidCallback onPressCreateGroup,
//     required VoidCallback onPressEditGroupIcon,
//     required VoidCallback cancelCreateGroupModal,
//     required dynamic Function(String) onGroupNameChange,
//     required Function handleOnPressCancelMember,
//     required TextEditingController vGroupName,
//     required TextEditingController tDescription,
//   }) {
//     final grpProvider = context.read<GroupProvider>();
//     final randomIndex = Random().nextInt(AppMedia.groupImages.length);
//     final svgProfile = AppMedia.groupImages[randomIndex];
//     bool isSvg =
//         (loginUserData['vProfilePic']?.toLowerCase() ?? '').endsWith('.svg');
//     final isGroupMode = tabController.index == 1;
//     grpProvider.setProfileColorOption(svgProfile['iColorId']);
//     final selectedStatusId = Provider.of<ProfileProvider>(context, listen: false).selectedStatusId;
//
//
//     final Color statusColor = selectedStatusId == 0
//         ? AppColorTheme.danger
//         : selectedStatusId == 1
//             ? AppColorTheme.success
//             : AppColorTheme.primary;
//     showModalBottomSheet(
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(14),
//         ),
//       ),
//       backgroundColor: Color(0xffEEF2F5),
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return WillPopScope(
//               onWillPop: () {
//                 cancelCreateGroupModal();
//                 return Future.value(false);
//               },
//               child: Container(
//                 height: MediaQuery.of(context).size.height * 0.85,
//                 decoration: const BoxDecoration(
//                   color: Color(0xffEEF2F5),
//                   borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(14),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.white,
//                       offset: Offset(0, -1),
//                       blurRadius: 0,
//                       spreadRadius: 1,
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.all(15),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(top: 5),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           GestureDetector(
//                               onTap: cancelCreateGroupModal,
//                               child: Icon(
//                                 FeatherIcons.arrowLeft,
//                                 color: Color(0xffAEB9BD).withOpacity(0.7),
//                               )),
//                           Text(
//                             isGroupMode ? "Create New Group" : "New Chat",
//                             style: ResponsiveFontStyles.dmSans18Medium(context)
//                                 .copyWith(
//                               color: AppColorTheme.dark87,
//                               fontSize: 18,
//                             ),
//                           ),
//                           GestureDetector(
//                               onTap: cancelCreateGroupModal,
//                               child: Icon(
//                                 FeatherIcons.x,
//                                 color: const Color(0xffAEB9BD).withOpacity(0.7),
//                               ))
//                         ],
//                       ),
//                     ),
//                     // Scrollable content
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Center(
//                               child: Column(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 16),
//                                     child: Text(
//                                       "Group Picture",
//                                       style:
//                                           ResponsiveFontStyles.dmSans14Medium(
//                                                   context)
//                                               .copyWith(
//                                         color: AppColorTheme.dark40,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 14),
//                                   Stack(
//                                     clipBehavior: Clip.none,
//                                     children: [
//                                       Container(
//                                         clipBehavior: Clip.antiAlias,
//                                         decoration: const BoxDecoration(
//                                             borderRadius: BorderRadius.all(Radius.circular(10))),
//                                         child: Consumer<GroupProvider>(builder:
//                                             (ctx, groupProvider, child) {
//                                           final imageId = groupProvider.profileSelectedColorOption;
//                                           final selectedImage = AppMedia.groupImages.where((item) => item['iColorId'] == imageId);
//                                           return groupProvider.chooseImageFile != null
//                                               ? ClipRRect(
//                                                   borderRadius: BorderRadius.circular(10),
//                                                   child: Image.file(File(groupProvider.chooseImageFile!.path), height: 100, width: 100, fit: BoxFit.cover))
//                                               : SvgPicture.asset(imageId == null ? svgProfile['vColorPick'] : selectedImage.single['vColorPick'], fit: BoxFit.cover);
//                                         }),
//                                       ),
//                                       Positioned(
//                                           right: 5,
//                                           top: 5,
//                                           child: Container(
//                                               padding: const EdgeInsets.all(4),
//                                               decoration: const BoxDecoration(
//                                                 color: AppColorTheme.white,
//                                                 borderRadius: BorderRadius.all(Radius.circular(5)),
//                                                 boxShadow: [
//                                                   BoxShadow(color: Color.fromRGBO(10, 41, 55, 0.08), offset: Offset(0, 3), blurRadius: 4)
//                                                 ],
//                                               ),
//                                               child: InkWell(
//                                                   onTap: onPressEditGroupIcon,
//                                                   child: SvgPicture.asset(AppMedia.edit, color: AppColorTheme.muted,)))),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             // Input(
//                             //   title: 'Group Name',
//                             //   isRequired: true,
//                             //   inputValue: vGroupName,
//                             //   showRequiredError: true,
//                             //   isError: context
//                             //       .watch<GroupProvider>()
//                             //       .isGroupNameError,
//                             //   onChanged: onGroupNameChange,
//                             //   border: Border.fromBorderSide(BorderSide.none),
//                             // ),
//                             //why not use this style please give the solution
//                             Input(
//                               title: 'Group Name',
//                               isRequired: true,
//                               inputValue: vGroupName,
//                               showRequiredError: true,
//                               isError: context.watch<GroupProvider>().isGroupNameError,
//                               textStyles: ResponsiveFontStyles.dmSans15Regular(context).copyWith(color: AppColorTheme.dark87, fontSize: 15),
//                               onChanged: onGroupNameChange,
//                               border: Border.fromBorderSide(BorderSide.none),
//                             ),
//                             const SizedBox(height: 5),
//                             Input(
//                               title: 'Description',
//                               isRequired: false,
//                               inputValue: tDescription,
//                               maxLines: 2,
//                               maxLength: 350,
//                               textStyles: ResponsiveFontStyles.dmSans15Regular(context).copyWith(color: AppColorTheme.dark87, fontSize: 15), border: Border.fromBorderSide(BorderSide.none)),
//                             const SizedBox(height: 5),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Group Message Setting', style: ResponsiveFontStyles.dmSans13Medium(context).copyWith(color: AppColorTheme.dark40, fontSize: 13.5)),
//                                 const SizedBox(height: 15),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 15),
//                                   child: Row(
//                                     children: [
//                                       GestureDetector(
//                                         onTap: () {
//                                           setState(() {
//                                             grpProvider.selectedOption = 'Group Manager';
//                                           });
//                                         },
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               width: 20,
//                                               height: 20,
//                                               decoration: BoxDecoration(
//                                                 shape: BoxShape.circle,
//                                                 border: Border.all(color: grpProvider.selectedOption == 'Group Manager' ? const Color(0xFF00A9E0) : Colors.grey.shade400, width: 1.7),
//                                               ),
//                                               child: grpProvider.selectedOption == 'Group Manager'
//                                                   ? Center(
//                                                       child: Container(width: 20, height: 20,
//                                                         decoration: BoxDecoration(
//                                                           shape: BoxShape.circle,
//                                                           border: Border.all(color: grpProvider.selectedOption == 'Group Manager' ? Color(0xFF00A9E0) : Colors.grey.shade400, width: 4),
//                                                           color: Colors.white,
//                                                         ),
//                                                       ),
//                                                     )
//                                                   : SizedBox(),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Text('Group Admin', style: ResponsiveFontStyles.dmSans15Regular(context).copyWith(color: AppColorTheme.dark87)),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(width: 65),
//                                       GestureDetector(
//                                         onTap: () {
//                                           setState(() {
//                                             grpProvider.selectedOption = 'All';
//                                           });
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(left: 8),
//                                           child: Row(
//                                             children: [
//                                               Container(
//                                                 width: 20,
//                                                 height: 20,
//                                                 decoration: BoxDecoration(
//                                                   shape: BoxShape.circle,
//                                                   border: Border.all(color: grpProvider.selectedOption == 'All' ? Color(0xFF00A9E0) : Colors.grey.shade400, width: 1.7),
//                                                 ),
//                                                 child: grpProvider.selectedOption == 'All'
//                                                     ? Center(
//                                                         child: Container(
//                                                           width: 20,
//                                                           height: 20,
//                                                           decoration: BoxDecoration(shape: BoxShape.circle,
//                                                             border: Border.all(
//                                                               color: grpProvider.selectedOption == 'All' ? Color(0xFF00A9E0) : Colors.grey.shade400, width: 4),
//                                                             color: Colors.white,
//                                                           ),
//                                                         ),
//                                                       )
//                                                     : SizedBox(),
//                                               ),
//                                               SizedBox(width: 8),
//                                               Text('All Members', style: ResponsiveFontStyles.dmSans15Regular(context).copyWith(color: AppColorTheme.dark87))
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 22),
//                             Text("Group Manager", style: ResponsiveFontStyles.dmSans13Medium(context).copyWith(color: AppColorTheme.dark40, fontSize: 13.5)),
//                             ListTile(
//                               contentPadding: const EdgeInsets.all(0),
//                               leading: Stack(
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: const BorderRadius.all(Radius.circular(50)),
//                                     child: (loginUserData['vProfilePic'] != null)
//                                         ? CommonWidgets.isSvgProfilePic(isSvg, loginUserData['vProfilePic'])
//                                         : Container(),
//                                   ),
//                                   Positioned(
//                                     bottom: -1,
//                                     right: 2,
//                                     child: Container(
//                                       height: 15,
//                                       width: 15,
//                                       decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle,
//                                         border: Border.all(color: Colors.white, width: 2),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               title: Text(
//                                 loginUserData['vFullName'],
//                                 style: ResponsiveFontStyles.dmSans15Regular(context).copyWith(color: AppColorTheme.inputTitle, fontSize: 14.5),
//                               ),
//                               subtitle: Text(
//                                 loginUserData['iStatus'] == 1 ? 'Online' : 'Offline',
//                                 style: ResponsiveFontStyles.dmSans12Regular(context).copyWith(color: AppColorTheme.grey, fontSize: 12.2),
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             Text("Group Members", style: ResponsiveFontStyles.dmSans13Medium(context).copyWith(color: AppColorTheme.dark40, fontSize: 13.5)),
//                             Consumer<GroupProvider>(
//                                 builder: (ctx, groupProvider, child) {
//                               final groupMembers = groupProvider.groupMembers;
//                               final selectedUsers = groupProvider.selectedUsers;
//
//                               return ListView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: groupMembers.length,
//                                   itemBuilder: (context, index) {
//                                     final user = groupMembers[index];
//                                     final bool isSelected = selectedUsers.contains(user['iUserId']);
//                                     final Color statusColor = user['iStatus'] == 0 ? AppColorTheme.danger : AppColorTheme.success;
//                                     if (index >= groupMembers.length) {
//                                       return const SizedBox();
//                                     }
//                                     return ListTile(
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//                                       visualDensity: VisualDensity(vertical: -2),
//                                       leading: ProfileIconStatusDot(profilePic: user['vProfilePic'], statusColor: statusColor,  statusBorderColor: AppColorTheme.lightPrimary,),
//                                       // trailing: isGroupMode
//                                       //     ? InkWell(
//                                       //         // onTap: () async {
//                                       //         //   await Future.delayed(
//                                       //         //       const Duration(seconds: 1));
//                                       //         // },
//                                       //         child: Container(
//                                       //           decoration: BoxDecoration(
//                                       //             shape: BoxShape.circle,
//                                       //             color: isSelected
//                                       //                 ? AppColorTheme.border
//                                       //                 : Colors.red,
//                                       //           ),
//                                       //           width: 22,
//                                       //           height: 22,
//                                       //           child: isSelected
//                                       //               ? Icon(Icons.close,
//                                       //                   color: isSelected
//                                       //                       ? Colors.white
//                                       //                       : AppColorTheme
//                                       //                           .white,
//                                       //                   size: 14)
//                                       //               : null,
//                                       //         ),
//                                       //       )
//                                       //     : null,
//                                       trailing: isGroupMode
//                                           ? InkWell(
//                                               onTap: () async {
//                                                 setState(() {
//                                                   if (isSelected) {
//                                                     selectedUsers.remove(user['iUserId']);
//                                                   } else {
//                                                     selectedUsers.add(user['iUserId']);
//                                                   }
//                                                   handleOnPressCancelMember(user);
//                                                 });
//
//                                                 await Future.delayed(
//                                                     const Duration(
//                                                         milliseconds: 1500));
//                                               },
//                                               child: Container(
//                                                 width: 22,
//                                                 height: 22,
//                                                 decoration: BoxDecoration(
//                                                     shape: BoxShape.circle,
//                                                     color: isSelected
//                                                         ? AppColorTheme.border
//                                                         : Colors.red),
//                                                 child: const Icon(
//                                                   Icons.close,
//                                                   size: 14.5,
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                             )
//                                           : null,
//
//                                       title: Text(
//                                         user['vFullName'],
//                                         style: ResponsiveFontStyles
//                                                 .dmSans15Regular(context)
//                                             .copyWith(
//                                                 color: AppColorTheme.inputTitle,
//                                                 fontSize: 14),
//                                       ),
//                                       subtitle: Text(
//                                         user['iStatus'] == 1
//                                             ? 'Online'
//                                             : 'Offline',
//                                         style: ResponsiveFontStyles
//                                                 .dmSans12Regular(context)
//                                             .copyWith(
//                                                 color: AppColorTheme.grey,
//                                                 fontSize: 12.2),
//                                       ),
//                                     );
//                                   });
//                             }),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8),
//                       child: Button(
//                         onPressed: onPressCreateGroup,
//                         title: 'Create',
//                         backgroundColor: AppColorTheme.primary,
//                         textColor: AppColorTheme.white,
//                         width: MediaQuery.of(context).size.width * 0.95,
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

class CreateGroupBottomSheetModal extends StatefulWidget {
  final TabController tabController;
  final Map<String, dynamic> loginUserData;
  final VoidCallback onPressCreateGroup;
  final VoidCallback onPressEditGroupIcon;
  final VoidCallback cancelCreateGroupModal;
  final dynamic Function(String) onGroupNameChange;
  final TextEditingController vGroupName;
  final TextEditingController tDescription;

  const CreateGroupBottomSheetModal({
    super.key,
    required this.tabController,
    required this.loginUserData,
    required this.onPressCreateGroup,
    required this.onPressEditGroupIcon,
    required this.cancelCreateGroupModal,
    required this.onGroupNameChange,
    required this.vGroupName,
    required this.tDescription,
  });

  @override
  State<CreateGroupBottomSheetModal> createState() =>
      _CreateGroupBottomSheetModalState();
}

class _CreateGroupBottomSheetModalState
    extends State<CreateGroupBottomSheetModal> {
  late Map<String, dynamic> svgProfile;
  String selectedUserId = "";

  @override
  void initState() {
    super.initState();
    final randomIndex = Random().nextInt(AppMedia.groupImages.length);
    svgProfile = AppMedia.groupImages[randomIndex];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupProvider = context.read<GroupProvider>();
      groupProvider.setProfileColorOption(svgProfile['iColorId']);
    });
  }

  // ******************** handle cancel selected group members while creating a group *********************
  void handleOnPressCancelMember(dynamic user) {
    CommonModal.show(
        context: context,
        // heightFactor: 0.18,
        child: ConfirmBottomModal(
            headerTitle: 'Delete Confirm',
            modalTitle: 'Are you sure you want to delete member?',
            confirmBtnTitle: 'Delete',
            cancelBtnTitle: 'Cancel',
            backgroundColor: AppColorTheme.darkDanger,
            textColor: AppColorTheme.white,
            onPressConfirm: () => confirmCancelMember(user),
            onPressCancel: () {
              setState(() {
                selectedUserId = "";
              });
              Navigator.of(context).pop();
            }));
  }

  void confirmCancelMember(dynamic user) {
    final provider = context.read<GroupProvider>();
    provider.removeUser(user['iUserId']);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final grpProvider = context.read<GroupProvider>();
    final selectedStatusId =
        Provider.of<ProfileProvider>(context, listen: false).selectedStatusId;

    final Color statusColor = selectedStatusId == 0
        ? AppColorTheme.danger
        : selectedStatusId == 1
            ? AppColorTheme.success
            : AppColorTheme.success;

    return WillPopScope(
      onWillPop: () {
        widget.cancelCreateGroupModal();
        return Future.value(false);
      },
      child: Column(
        children: [
          ModalHeader(
              name: "Create New Group",
              showBackIcon: true,
              onTapBackAction: widget.cancelCreateGroupModal,
              onTapCloseAction: widget.cancelCreateGroupModal),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // ************************** Group Picture ******************************
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 7.h),
                            child:
                                CommonWidgets.modalMainTitle("Group Picture"),
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Consumer<GroupProvider>(
                                  builder: (ctx, groupProvider, child) {
                                final imageId =
                                    groupProvider.profileSelectedColorOption;
                                final selectedImage = AppMedia.groupImages
                                    .where(
                                        (item) => item['iColorId'] == imageId);
                                return groupProvider.chooseImageFile != null
                                    ? LargeProfilePic(
                                        borderRadius: 10.r,
                                        profilePic:
                                            groupProvider.chooseImageFile!.path,
                                        isFilePath: true)
                                    : LargeProfilePic(
                                        borderRadius: 10.r,
                                        profilePic: imageId == null
                                            ? svgProfile['vColorPick']
                                            : selectedImage
                                                .single['vColorPick']);
                              }),
                              CommonWidgets.editPictureIconPosition(
                                  widget.onPressEditGroupIcon),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // *************************** Group Name and Description ***********************
                    Input(
                      title: 'Group Name',
                      isRequired: true,
                      inputValue: widget.vGroupName,
                      showRequiredError: true,
                      isError: context.watch<GroupProvider>().isGroupNameError,
                      textStyles: ResponsiveFontStyles.dmSans15Regular(context)
                          .copyWith(color: AppColorTheme.dark87, fontSize: 15),
                      onChanged: widget.onGroupNameChange,
                      border: Border.fromBorderSide(BorderSide.none),
                    ),
                    const SizedBox(height: 5),
                    Input(
                        title: 'Description',
                        isRequired: false,
                        inputValue: widget.tDescription,
                        maxLines: 2,
                        maxLength: 350,
                        textStyles:
                            ResponsiveFontStyles.dmSans15Regular(context)
                                .copyWith(
                                    color: AppColorTheme.dark87, fontSize: 15),
                        border: Border.fromBorderSide(BorderSide.none)),
                    SizedBox(height: 5.h),

                    // *************************** Group Chat Permissions ***********************
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonWidgets.modalSubTitle('Group Chat Permission'),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                grpProvider.setSelectedOption("All");
                              },
                              child: Row(
                                children: [
                                  CommonWidgets.rightCheckMark(
                                      grpProvider.selectedOption == 'All',
                                      marginRight: 0),
                                  // Container(
                                  //   width: 20,
                                  //   height: 20,
                                  //   decoration: BoxDecoration(
                                  //     shape: BoxShape.circle,
                                  //     border: Border.all(color: grpProvider.selectedOption == 'All' ? Color(0xFF00A9E0) : Colors.grey.shade400, width: 1.7),
                                  //   ),
                                  //   child: grpProvider.selectedOption == 'All'
                                  //       ? Center(
                                  //     child: Container(
                                  //       width: 20,
                                  //       height: 20,
                                  //       decoration: BoxDecoration(shape: BoxShape.circle,
                                  //         border: Border.all(
                                  //             color: grpProvider.selectedOption == 'All' ? Color(0xFF00A9E0) : Colors.grey.shade400, width: 4),
                                  //         color: Colors.white,
                                  //       ),
                                  //     ),
                                  //   )
                                  //       : SizedBox(),
                                  // ),
                                  SizedBox(width: 8),
                                  Text('All Members',
                                      style:
                                          ResponsiveFontStyles.dmSans15Regular(
                                                  context)
                                              .copyWith(
                                                  color: AppColorTheme.dark87))
                                ],
                              ),
                            ),
                            SizedBox(width: 32.w),
                            GestureDetector(
                              onTap: () {
                                grpProvider.setSelectedOption("Group Manager");
                              },
                              child: Row(
                                children: [
                                  CommonWidgets.rightCheckMark(
                                      grpProvider.selectedOption ==
                                          'Group Manager',
                                      marginRight: 0),
                                  const SizedBox(width: 8),
                                  Text('Group Admin',
                                      style:
                                          ResponsiveFontStyles.dmSans15Regular(
                                                  context)
                                              .copyWith(
                                                  color: AppColorTheme.dark87)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),

                    // *************************** Group Admin List ***********************
                    CommonWidgets.modalSubTitle('Group Admin',
                        paddingBottom: 8),
                    ChatListItem(
                      vProfilePic: widget.loginUserData['vProfilePic'] ?? "",
                      statusColor: statusColor,
                      titleStyleRegular: true,
                      listTitle: widget.loginUserData['vFullName'] ?? "",
                      listSubTitle: widget.loginUserData['iStatus'] == 1
                          ? 'Online'
                          : 'Offline',
                      handleOnPressItem: () {},
                    ),
                    SizedBox(height: 16.h),

                    // *************************** Group Members List ***********************
                    CommonWidgets.modalSubTitle('Group Members',
                        paddingBottom: 8),
                    Consumer<GroupProvider>(
                        builder: (ctx, groupProvider, child) {
                      final groupMembers = groupProvider.groupMembers;
                      // final selectedUsers = groupProvider.selectedUsers;

                      return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: groupMembers.length,
                          itemBuilder: (context, index) {
                            final user = groupMembers[index];
                            // final bool isSelected = selectedUsers.contains(user['iUserId']);
                            final Color statusColor = user['iStatus'] == 0
                                ? AppColorTheme.danger
                                : AppColorTheme.success;
                            if (index >= groupMembers.length) {
                              return const SizedBox();
                            }

                            void handleOnPressCloseMember(user) async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                if (selectedUserId != "") {
                                  selectedUserId = "";
                                } else {
                                  selectedUserId = user['iUserId'];
                                }
                              });
                              handleOnPressCancelMember(user);
                              //
                              // await Future.delayed(const Duration(milliseconds: 1500));
                            }

                            return ChatListItem(
                              vProfilePic: user['vProfilePic'] ?? "",
                              statusColor: statusColor,
                              titleStyleRegular: true,
                              listTitle: user['vFullName'] ?? "",
                              listSubTitle:
                                  user['iStatus'] == 1 ? 'Online' : 'Offline',
                              showCloseIcon: true,
                              showUserCheckIcon: false,
                              showActiveBackground: selectedUserId != "" &&
                                      selectedUserId == user['iUserId']
                                  ? true
                                  : false,
                              closeIconColor: selectedUserId != "" &&
                                      selectedUserId == user['iUserId']
                                  ? AppColorTheme.darkDanger
                                  : AppColorTheme.border,
                              handleOnPressClose: () {
                                handleOnPressCloseMember(user);
                              },
                              handleOnPressItem: () {},
                            );

                            // ListTile(
                            //   contentPadding:
                            //   const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            //   visualDensity: VisualDensity(vertical: -2),
                            //   leading: ProfileIconStatusDot(profilePic: user['vProfilePic'], statusColor: statusColor,  statusBorderColor: AppColorTheme.lightPrimary,),
                            //   // trailing: isGroupMode
                            //   //     ? InkWell(
                            //   //         // onTap: () async {
                            //   //         //   await Future.delayed(
                            //   //         //       const Duration(seconds: 1));
                            //   //         // },
                            //   //         child: Container(
                            //   //           decoration: BoxDecoration(
                            //   //             shape: BoxShape.circle,
                            //   //             color: isSelected
                            //   //                 ? AppColorTheme.border
                            //   //                 : Colors.red,
                            //   //           ),
                            //   //           width: 22,
                            //   //           height: 22,
                            //   //           child: isSelected
                            //   //               ? Icon(Icons.close,
                            //   //                   color: isSelected
                            //   //                       ? Colors.white
                            //   //                       : AppColorTheme
                            //   //                           .white,
                            //   //                   size: 14)
                            //   //               : null,
                            //   //         ),
                            //   //       )
                            //   //     : null,
                            //   trailing: isGroupMode
                            //       ? InkWell(
                            //     onTap: () async {
                            //       setState(() {
                            //         if (isSelected) {
                            //           selectedUsers.remove(user['iUserId']);
                            //         } else {
                            //           selectedUsers.add(user['iUserId']);
                            //         }
                            //         widget.handleOnPressCancelMember(user);
                            //       });
                            //
                            //       await Future.delayed(const Duration(milliseconds: 1500));
                            //     },
                            //     child: Container(
                            //       width: 22,
                            //       height: 22,
                            //       decoration: BoxDecoration(
                            //           shape: BoxShape.circle,
                            //           color: isSelected ? AppColorTheme.border : Colors.red),
                            //       child: const Icon(Icons.close, size: 14.5, color: Colors.white),
                            //     ),
                            //   )
                            //       : null,
                            //
                            //   title: Text(
                            //     user['vFullName'],
                            //     style: ResponsiveFontStyles.dmSans15Regular(context).copyWith(color: AppColorTheme.inputTitle, fontSize: 14),
                            //   ),
                            //   subtitle: Text(
                            //     user['iStatus'] == 1 ? 'Online' : 'Offline',
                            //     style: ResponsiveFontStyles.dmSans12Regular(context).copyWith(color: AppColorTheme.grey, fontSize: 12.2),
                            //   ),
                            // );
                          });
                    }),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Button(
              onPressed: widget.onPressCreateGroup,
              title: 'Create',
              backgroundColor: AppColorTheme.primary,
              textColor: AppColorTheme.white,
            ),
          )
        ],
      ),
    );
  }
}
