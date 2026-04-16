// import 'dart:io';
//
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_feather_icons/flutter_feather_icons.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:http/http.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:spot/core/themes.dart';
// import 'package:spot/providers/data_list_provider.dart';
// import 'package:spot/providers/profile_provider.dart';
// import 'package:spot/services/api_service.dart';
// import 'package:spot/services/configuration.dart';
// import 'package:spot/ui/widgets/chat_list_widgets/user_status_options.dart';
// import 'package:spot/ui/widgets/commonWidgets.dart';
// import 'package:spot/ui/widgets/confirm_center_modal.dart';
// import 'package:spot/ui/widgets/confirm_bottom_modal.dart';
// import 'package:spot/ui/widgets/header.dart';
// import 'package:top_modal_sheet/top_modal_sheet.dart';
//
// class ProfileModal {
//   static void show(
//       {required BuildContext context,
//       required VoidCallback onPressEditProfile}) {
//     showTopModalSheet(
//         context, _ProfileModal(onPressEditProfile: onPressEditProfile));
//   }
// }
//
// class _ProfileModal extends StatefulWidget {
//   final VoidCallback onPressEditProfile;
//
//   // const _ProfileModal({super.key, required this.onPressEditProfile});
//   const _ProfileModal({
//     Key? key,
//     required this.onPressEditProfile,
//   }) : super(key: key);
//
//   @override
//   State<_ProfileModal> createState() => __ProfileModalState();
// }
//
// class __ProfileModalState extends State<_ProfileModal> {
//   var showProfileStatusOptions = false;
//
//   var statusOptions = [
//     {"id": 0, "label": "Offline", "color": AppColorTheme.danger},
//     {"id": 1, "label": "Online", "color": AppColorTheme.success},
//     {"id": 2, "label": "Automatic", "color": AppColorTheme.primary}
//   ];
//
//   // ************** handle logout ****************
//   void onPressLogout() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.clear();
//       Navigator.pushNamed(context, '/login');
//     } catch (error) {
//       print("Error while logout....$error");
//     }
//   }
//
//   // ******************** handle on Press profile status ******************
//   void handleOnPressProfileStatus() {
//     setState(() {
//       showProfileStatusOptions = !showProfileStatusOptions;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dataListProvider = context.watch<DataListProvider>();
//     final profileProvider = context.watch<ProfileProvider>();
//     final loginUserData = dataListProvider.loginUserData;
//     final statusTitle = profileProvider.selectedStatusId == 0
//         ? "Offline"
//         : profileProvider.selectedStatusId == 1
//             ? "Online"
//             : "Automatic";
//     final Color statusColor = profileProvider.selectedStatusId == 0
//         ? AppColorTheme.danger
//         : profileProvider.selectedStatusId == 1
//             ? AppColorTheme.success
//             : AppColorTheme.primary;
//
//     bool isSvg = (loginUserData['vProfilePic'] != null
//         ? loginUserData['vProfilePic']!.toLowerCase().endsWith('.svg')
//         : false);
//
//     // ******************* call edit profile api *********************
//     void handleEditProfileApi() async {
//       try {
//         final postData = {
//           "eCustStatus": profileProvider.selectedStatusId,
//           "vEditProfileFullName": loginUserData["vFullName"]
//         };
//
//         final response = await ApiService.apiPostData(
//             Configuration.editUserProfile,
//             postData: postData,
//             token: loginUserData['tToken']);
//         // print("Responseeeeee edit profile $response");
//       } catch (error) {
//         print("Error while handle edit profile api $error");
//       }
//     }
//
//     // ******************** handle select user status ******************
//     void handleSelectUserStatus(id) {
//       profileProvider.setSelectedStatusId(id);
//       setState(() {
//         showProfileStatusOptions = false;
//       });
//       handleEditProfileApi();
//     }
//
//     return Container(
//       decoration: const BoxDecoration(
//           color: AppColorTheme.white,
//           borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(16),
//               bottomRight: Radius.circular(16))),
//       child: SafeArea(
//           child: Column(
//         children: [
//           Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//               child: Header(statusColor: statusColor)),
//           SizedBox(
//               height: 0.5,
//               child: Container(
//                 color: AppColorTheme.secondary,
//               )),
//           Container(
//             padding: const EdgeInsets.fromLTRB(15, 30, 15, 26),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 5, bottom: 16),
//                     child: ClipRRect(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(55)),
//                         child: loginUserData['vProfilePic'] != null
//                             ? CommonWidgets.isSvgDetailProfile(
//                                 isSvg, loginUserData['vProfilePic'])
//                             : Container()),
//                   ),
//                 ),
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 24),
//                     child: Text(loginUserData['vFullName'],
//                         style: AppFontStyles.dmSansMedium.copyWith(
//                             fontSize: 18, color: AppColorTheme.dark87)),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     widget.onPressEditProfile();
//                   },
//                   child: Text.rich(
//                     TextSpan(
//                       children: [
//                         const WidgetSpan(
//                             child: Padding(
//                                 padding: EdgeInsets.only(right: 12),
//                                 child: Icon(
//                                   FeatherIcons.edit,
//                                   color: AppColorTheme.muted,
//                                   size: 22.5,
//                                 ))),
//                         TextSpan(
//                             text: 'Edit Profile',
//                             recognizer: TapGestureRecognizer(),
//                             style: AppFontStyles.dmSansRegular.copyWith(
//                                 color: AppColorTheme.dark87, fontSize: 16)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 12,
//                 ),
//                 InkWell(
//                   onTap: handleOnPressProfileStatus,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(left: 3),
//                             child: SizedBox(
//                                 height: 15,
//                                 width: 15,
//                                 child: Container(
//                                     decoration: BoxDecoration(
//                                   borderRadius: const BorderRadius.all(
//                                       Radius.circular(50)),
//                                   color: statusColor,
//                                 ))),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 18),
//                             child: Text(statusTitle,
//                                 style: AppFontStyles.dmSansRegular.copyWith(
//                                     color: AppColorTheme.dark87, fontSize: 16)),
//                           ),
//                         ],
//                       ),
//                       showProfileStatusOptions
//                           ? const Icon(
//                               FeatherIcons.chevronUp,
//                               color: AppColorTheme.muted,
//                               size: 21,
//                             )
//                           : const Icon(
//                               FeatherIcons.chevronDown,
//                               color: AppColorTheme.muted,
//                               size: 21,
//                             )
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 showProfileStatusOptions
//                     ? Container(
//                         margin: EdgeInsets.only(bottom: 8),
//                         padding: const EdgeInsets.all(8),
//                         decoration: const BoxDecoration(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                           color: AppColorTheme.dark06,
//                         ),
//                         child: Consumer<ProfileProvider>(
//                             builder: (ctx, ProfileProvider, child) {
//                           return Column(
//                             children: [
//                               UserStatusOptions(
//                                   title: 'Automatic',
//                                   color: AppColorTheme.primary,
//                                   backgroundColor:
//                                       profileProvider.selectedStatusId == 2
//                                           ? AppColorTheme.white
//                                           : AppColorTheme.transparent,
//                                   handleSelectUserStatus: () =>
//                                       handleSelectUserStatus(2)),
//                               UserStatusOptions(
//                                   title: 'Online',
//                                   color: AppColorTheme.success,
//                                   backgroundColor:
//                                       profileProvider.selectedStatusId == 1
//                                           ? AppColorTheme.white
//                                           : AppColorTheme.transparent,
//                                   handleSelectUserStatus: () =>
//                                       handleSelectUserStatus(1)),
//                               UserStatusOptions(
//                                   title: 'Offline',
//                                   color: AppColorTheme.danger,
//                                   backgroundColor:
//                                       profileProvider.selectedStatusId == 0
//                                           ? AppColorTheme.white
//                                           : AppColorTheme.transparent,
//                                   handleSelectUserStatus: () =>
//                                       handleSelectUserStatus(0)),
//                             ],
//                           );
//                         }),
//                       )
//                     : Container(),
//                 SizedBox(
//                     height: 1.5,
//                     child: Container(color: AppColorTheme.secondary)),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 InkWell(
//                   onTap: () => ConfirmCenterModal.show(context,
//                       headerTitle: 'Logout Confirm',
//                       modalTitle: 'Are you sure you want to logout?',
//                       confirmBtnTitle: 'Confirm',
//                       cancelBtnTitle: 'Cancel',
//                       backgroundColor: AppColorTheme.primary,
//                       textColor: AppColorTheme.white,
//                       onPressConfirm: onPressLogout,
//                       onPressCancel: () => Navigator.of(context).pop()),
//                   child: Text.rich(
//                     TextSpan(
//                       children: [
//                         const WidgetSpan(
//                             child: Padding(
//                                 padding: EdgeInsets.only(right: 12),
//                                 child: Icon(
//                                   FeatherIcons.logOut,
//                                   color: AppColorTheme.muted,
//                                   size: 22.5,
//                                 ))),
//                         TextSpan(
//                             text: 'Logout',
//                             style: AppFontStyles.dmSansRegular.copyWith(
//                                 color: AppColorTheme.dark87, fontSize: 16)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       )),
//     );
//   }
// }

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot/core/app_sizes.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/providers/profile_provider.dart';
import 'package:spot/providers/socket_provider.dart';
import 'package:spot/services/api_service.dart';
import 'package:spot/services/configuration.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:spot/ui/widgets/chat_list_widgets/user_status_options.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/confirm_center_modal.dart';
import 'package:spot/ui/widgets/common_widgets/header.dart';
import 'package:spot/ui/widgets/common_widgets/large_profile_pic.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

class ProfileModal {
  static void show(
      {required BuildContext context,
      required VoidCallback onPressEditProfile,
      required VoidCallback onLogout}) {
    showTopModalSheet(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
        backgroundColor: AppColorTheme.white,
        context,
        _ProfileModal(
          onPressEditProfile: onPressEditProfile,
          onLogout: onLogout,
        ));
  }
}

class _ProfileModal extends StatefulWidget {
  final VoidCallback onPressEditProfile;
  final VoidCallback onLogout;

  const _ProfileModal(
      {super.key, required this.onPressEditProfile, required this.onLogout});

  @override
  State<_ProfileModal> createState() => __ProfileModalState();
}

class __ProfileModalState extends State<_ProfileModal> {
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogoutStatus();
      // final dataListProvider = context.read<DataListProvider>();
      // final profileProvider = context.read<ProfileProvider>();
      // if (dataListProvider.profileData != null && dataListProvider.profileData.isNotEmpty) {
      //   profileProvider.setSelectedStatusId(dataListProvider.profileData['eCustStatus']);
      // }
    });
  }

  var showProfileStatusOptions = false;

  var statusOptions = [
    {"id": 0, "label": "Offline", "color": AppColorTheme.danger},
    {"id": 1, "label": "Online", "color": AppColorTheme.success},
    {"id": 2, "label": "Automatic", "color": AppColorTheme.primary}
  ];

  // ************** handle logout ****************
  void onPressLogout() async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final loginUserData = dataListProvider.loginUserData;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      SocketMessageEvents.logOutStatus(loginUserData['iUserId'], 0);
      prefs.clear();
      checkLogoutStatus();
      widget.onLogout();
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', (Route<dynamic> route) => false);
    } catch (error) {
      // print("Error while logout....$error");
    }
  }

  void checkLogoutStatus() {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final loginUserData = dataListProvider.loginUserData;
      final socketProvider = context.read<SocketProvider>();
      final receiveData = socketProvider.socketReceiveEventData;
      if (receiveData['event'] == 'receive_message' &&
          receiveData['data'].isNotEmpty &&
          receiveData['data']['type'] == 'logout') {
        SocketMessageEvents.allUsersGetNewSts(loginUserData['tToken'], "");
        setState(() {});
      }
    } catch (error) {
      // print("Error while after logout status..... $error");
    }
  }

  // ******************** handle on Press profile status ******************
  void handleOnPressProfileStatus() {
    setState(() {
      showProfileStatusOptions = !showProfileStatusOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataListProvider = context.watch<DataListProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final loginUserData = dataListProvider.loginUserData;
    final statusTitle = profileProvider.selectedStatusId == 0
        ? "Offline"
        : profileProvider.selectedStatusId == 1 ||
                profileProvider.selectedStatusId == 2
            ? "Online"
            : "Online";

    final Color statusColor = profileProvider.selectedStatusId == 0
        ? AppColorTheme.danger
        : AppColorTheme.success;

    bool isSvg = (loginUserData['vProfilePic'] != null
        ? loginUserData['vProfilePic']!.toLowerCase().endsWith('.svg')
        : false);

    // ******************* call edit profile api *********************
    void handleEditProfileApi() async {
      try {
        final postData = {
          "eCustStatus": profileProvider.selectedStatusId,
          "vEditProfileFullName": loginUserData["vFullName"]
        };

        final response = await ApiService.apiPostData(
            Configuration.editUserProfile,
            postData: postData,
            token: loginUserData['tToken']);
        if (response?['status'] == 200) {
          SocketMessageEvents.allUsersGetNewSts(loginUserData['tToken'], "");
        }
        // print("Responseeeeee edit profile $response");
      } catch (error) {
        // print("Error while handle edit profile api $error");
      }
    }

    // ******************** handle select user status ******************
    void handleSelectUserStatus(id) {
      profileProvider.setSelectedStatusId(id);
      setState(() {
        showProfileStatusOptions = false;
      });
      handleEditProfileApi();
    }

    void closeProfileModal() {
      Navigator.pop(context);
    }

    // ********************** handle logout user *******************
    void handleLogout() {
      // ConfirmCenterModal.show(
      //   context,
      //   headerTitle: 'Logout Confirm',
      //   modalTitle: 'Are you sure you want to logout?',
      //   confirmBtnTitle: 'Confirm',
      //   cancelBtnTitle: 'Cancel',
      //   backgroundColor: AppColorTheme.primary,
      //   onPressConfirm: onPressLogout,
      //   onPressCancel: () => Navigator.of(context).pop()
      // );
    }

    // ********************** Setting menu ************************
    Widget menuOptions(String text, String iconPath) {
      return Padding(
        padding:
            EdgeInsets.only(top: 8.h, bottom: 8.h, left: 16.w, right: 8.5.w),
        child: Row(
          children: [
            SvgPicture.asset(iconPath, height: 22.h, width: 22.w),
            SizedBox(width: 12.w),
            Text(text,
                style: AppFontStyles.dmSansRegular
                    .copyWith(fontSize: 17.sp, color: AppColorTheme.black)),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.horizontalAppPadding),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 13.h,
            ),
            Header(
              statusColor: statusColor,
              onPressProfile: closeProfileModal,
              statusBorderColor: AppColorTheme.white,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                children: [
                  LargeProfilePic(profilePic: loginUserData['vProfilePic']),
                  SizedBox(
                    height: 16.h,
                  ),
                  Text(
                    loginUserData['vFullName'],
                    style: AppFontStyles.dmSansMedium
                        .copyWith(fontSize: 18.sp, color: AppColorTheme.dark87),
                  ),
                  SizedBox(
                    height: 24.h,
                  ),
                  Column(
                    children: [
                      InkWell(
                          onTap: widget.onPressEditProfile,
                          child:
                              menuOptions("Edit Profile", AppMedia.editIcon)),
                      InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(6.r)),
                        highlightColor: AppColorTheme.statusList,
                        onTap: handleOnPressProfileStatus,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 6.h, bottom: 6.h, left: 16.w, right: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                      margin: EdgeInsets.all(4.h),
                                      height: 15.h,
                                      width: 15.w,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50)),
                                          color: statusColor)),
                                  SizedBox(width: 12.w),
                                  Text(statusTitle,
                                      style: AppFontStyles.dmSansRegular
                                          .copyWith(
                                              fontSize: 16.sp,
                                              color: AppColorTheme.black)),
                                ],
                              ),
                              showProfileStatusOptions
                                  ? SvgPicture.asset(AppMedia.upArrow,
                                      color: AppColorTheme.muted)
                                  : SvgPicture.asset(AppMedia.downArrow,
                                      color: AppColorTheme.muted)
                            ],
                          ),
                        ),
                      ),
                      showProfileStatusOptions
                          ? Container(
                              margin: EdgeInsets.only(top: 6.h),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.r)),
                                  color: AppColorTheme.statusList),
                              child: Consumer<ProfileProvider>(
                                  builder: (ctx, profileProvider, child) {
                                return Column(
                                  children: [
                                    UserStatusOptions(
                                        marginTop: 8,
                                        title: 'Automatic',
                                        color: AppColorTheme.primary,
                                        backgroundColor:
                                            profileProvider.selectedStatusId ==
                                                    2
                                                ? AppColorTheme.white
                                                : AppColorTheme.transparent,
                                        handleSelectUserStatus: () =>
                                            handleSelectUserStatus(2)),
                                    UserStatusOptions(
                                        title: 'Online',
                                        color: AppColorTheme.success,
                                        backgroundColor:
                                            profileProvider.selectedStatusId ==
                                                    1
                                                ? AppColorTheme.white
                                                : AppColorTheme.transparent,
                                        handleSelectUserStatus: () =>
                                            handleSelectUserStatus(1)),
                                    UserStatusOptions(
                                      title: 'Offline',
                                      color: AppColorTheme.danger,
                                      backgroundColor:
                                          profileProvider.selectedStatusId == 0
                                              ? AppColorTheme.white
                                              : AppColorTheme.transparent,
                                      handleSelectUserStatus: () =>
                                          handleSelectUserStatus(0),
                                      marginBottom: 8,
                                    ),
                                  ],
                                );
                              }),
                            )
                          : Container(),
                      CommonWidgets.divider(),
                      InkWell(
                          onTap: handleLogout,
                          child: menuOptions("Logout", AppMedia.logoutIcon)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
