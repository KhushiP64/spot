import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/app_sizes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/providers/group_provider.dart';
import 'package:spot/ui/widgets/chat_list_widgets/chat_list_item.dart';
import 'package:spot/ui/widgets/common_widgets/custom_search_bar.dart';
import 'package:spot/ui/widgets/common_widgets/modal_header.dart';
import '../../../core/themes.dart';
import '../common_widgets/button.dart';

// class AddUserBottomSheet {
//   static void show({
//     required BuildContext context,
//     required TabController tabController,
//     required TextEditingController searchAddUser,
//     required Function(String) onSearchChanged,
//     required Function(dynamic) handleOnPressUser,
//     required VoidCallback onNextPressed,
//     required VoidCallback closeListChatGroupModal,
//     required ScrollController controller,
//   }) {
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     bool isTablet = screenWidth > 600 && screenWidth <= 1024;
//     bool isDesktop = screenWidth > 1024;
//
//     // EdgeInsets contentPadding = isTablet ? const EdgeInsets.symmetric(horizontal: 10) : isDesktop ? const EdgeInsets.symmetric(horizontal: 10) : const EdgeInsets.symmetric(horizontal: 0);
//     showModalBottomSheet(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
//         backgroundColor: Color(0xffEEF2F5),
//         context: context,
//         isScrollControlled: true,
//         builder: (BuildContext context) {
//           var filterData = [];
//           final isGroupMode = tabController.index == 1;
//           final searchText = searchAddUser.text.trim().toLowerCase();
//           final provider = context.read<DataListProvider>();
//
//           if (searchText.isEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               provider.setUserChatList(provider.userChatListOriginalData);
//             });
//           } else {
//             filterData = provider.userChatList.where((item) {
//               return item['vFullName'].toString().toLowerCase().contains(searchText);
//             }).toList();
//
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               provider.setUserChatList(filterData);
//             });
//           }

//           return WillPopScope(
//             onWillPop: () {
//               closeListChatGroupModal();
//               return Future.value(false);
//             },
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.85,
//               width: isDesktop ? 600 : isTablet ? 500 : null,
//               decoration: const BoxDecoration(
//                 color: Color(0xffEEF2F5),
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                 boxShadow: [
//                   BoxShadow(color: Colors.white, offset: Offset(0, -1), blurRadius: 0, spreadRadius: 1),
//                 ],
//               ),
//
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(15, 22, 15, 15),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Align(
//                             alignment: Alignment.center,
//                             child: Padding(
//                               padding: const EdgeInsets.only(left: 20),
//                               child: Text(
//                                 isGroupMode ? "Create New Group" : "New Chat",
//                                 style: AppFontStyles.dmSansMedium.copyWith(color: AppColorTheme.dark87, fontSize: 18),
//                               ),
//                             ),
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: closeListChatGroupModal,
//                           child: Icon(Icons.close, color: Color(0xffAEB9BD).withOpacity(0.7)),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Container(padding: const EdgeInsets.fromLTRB(15, 10, 15, 0), child: SearchBarInput(searchValue: searchAddUser, onChangedSearchValue: onSearchChanged)),
//                   Container(
//                     height: 40,
//                     margin: EdgeInsets.only(left: 15, right: 15),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(color: Color.fromRGBO(10, 41, 55, 0.16)),
//                         BoxShadow(
//                           color: Color(0xffEEF2F5).withOpacity(0.6),
//                           offset: Offset(0, 2),
//                           spreadRadius: 0.0,
//                           blurRadius: 1.0,
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: TextField(
//                         style: AppFontStyles.dmSansRegular.copyWith(color: AppColorTheme.inputTitle),
//                         controller: searchAddUser,
//                         cursorColor: AppColorTheme.black,
//                         onChanged: onSearchChanged,
//                         cursorWidth: 0.9,
//                         textAlignVertical: TextAlignVertical.center,
//                         decoration: InputDecoration(
//                           isCollapsed: true,
//                           prefixIcon: Padding(
//                             padding: const EdgeInsets.all(8),
//                             child: SvgPicture.asset('assets/icons/search.svg', height: 18, width: 18, color: AppColorTheme.dark48),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//                           border: InputBorder.none,
//                           filled: true,
//                           fillColor: Colors.transparent,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: Consumer2<GroupProvider, DataListProvider>(
//                         builder: (ctx, groupProvider, dataListProvider, child) {
//                       final selectedUsers = groupProvider.selectedUsers;
//                       final userChatList = dataListProvider.userChatList;
//
//                       return ListView.builder(
//                           itemCount: userChatList.length,
//                           controller: controller,
//                           itemBuilder: (context, index) {
//                             if (index >= userChatList.length) return SizedBox();
//                             final user = userChatList[index];
//                             final bool isSelected =
//                                 selectedUsers.contains(user['iUserId']);
//                             final Color statusColor = user['iStatus'] == 0 ? AppColorTheme.danger : AppColorTheme.success;
//                             return ListTile(
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//                               visualDensity: const VisualDensity(vertical: -2),
//                               leading: ProfileIconStatusDot(profilePic: user['vProfilePic'], statusColor: statusColor,  statusBorderColor: AppColorTheme.lightPrimary,),
//                               trailing: isGroupMode
//                                   ? InkWell(
//                                       child: Container(
//                                         margin: EdgeInsets.only(left: 0, right: 2),
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           border: Border.all(width: 2, color: isSelected ? AppColorTheme.primary : AppColorTheme.border),
//                                           color: isSelected ? AppColorTheme.primary : AppColorTheme.transparent,
//                                         ),
//                                         width: 20,
//                                         height: 20,
//                                         child: isSelected  ? const Icon(FeatherIcons.check, color: AppColorTheme.white, size: 14) : null,
//                                       ),
//                                     )
//                                   : null,
//                               title: Text(user['vFullName'], style: AppFontStyles.dmSansRegular.copyWith(color: AppColorTheme.inputTitle, fontSize: 14.5)),
//                               subtitle: Text(user['iStatus'] == 1 ? 'Online' : 'Offline', style: AppFontStyles.dmSansRegular.copyWith(color: AppColorTheme.dark40, fontSize: 12.2)),
//                               onTap: () => isGroupMode ? groupProvider.selectMember(user['iUserId']) : handleOnPressUser(userChatList[index]),
//                             );
//                           });
//                     }),
//                   ),
//
//                   isGroupMode
//                       ? Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 24),
//                           child: Button(
//                               onPressed: onNextPressed,
//                               title: 'Next',
//                               backgroundColor: AppColorTheme.primary,
//                               textColor: AppColorTheme.white,
//                               width: MediaQuery.of(context).size.width),
//                         )
//                       : Text("")
//                 ],
//               ),
//             ),
//           );
//         });
//   }
// }

class AddUserBottomSheet extends StatefulWidget {
  final int activeTabIndex;
  final TextEditingController searchAddUser;
  final Function(String) onSearchChanged;
  final VoidCallback onNextPressed;
  final VoidCallback closeListChatGroupModal;
  final ScrollController controller;

  const AddUserBottomSheet({
    super.key,
    required this.activeTabIndex,
    required this.searchAddUser,
    required this.onSearchChanged,
    required this.onNextPressed,
    required this.closeListChatGroupModal,
    required this.controller,
  });

  @override
  State<AddUserBottomSheet> createState() => _AddUserBottomSheetState();
}

class _AddUserBottomSheetState extends State<AddUserBottomSheet> {
  @override
  Widget build(BuildContext context) {
    var filterData = [];
    final isGroupMode = widget.activeTabIndex == 1;
    final searchText = widget.searchAddUser.text.trim().toLowerCase();
    final provider = context.read<DataListProvider>();

    if (searchText.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.setUserChatList(provider.userChatListOriginalData);
      });
    } else {
      filterData = provider.userChatList.where((item) {
        return item['vFullName'].toString().toLowerCase().contains(searchText);
      }).toList();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.setUserChatList(filterData);
      });
    }

    // ************** handle on press user ****************
    Future<void> handleOnPressUser(Map<String, dynamic> userData) async {
      try {
        final dataListProvider = context.read<DataListProvider>();
        final response =
            await CommonFunctions.getSingleUser(userData["iUserId"]);
        // debugPrint("responseresponseresponseresponse $response", wrapWidth: 1024);
        if (!context.mounted) return;
        dataListProvider.setOpenedChatUserData(response);
        final currentUser = await CommonFunctions.getLoginUser();
        Navigator.pushNamed(context, '/userChat',
            arguments: {'type': "chat", "currentUser": currentUser});
      } catch (error) {
        // print("Error while opening user chat-----$error");
      }
    }

    return WillPopScope(
      onWillPop: () {
        widget.closeListChatGroupModal();
        return Future.value(false);
      },
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ****************** modal header *****************
            ModalHeader(
              name: isGroupMode ? "Create New Group" : "New Chat",
              onTapCloseAction: widget.closeListChatGroupModal,
            ),
            // ****************** search bar *****************
            CustomSearchBar(
                margin: EdgeInsets.only(
                    top: AppSizes.horizontalAppPadding, bottom: 6.h),
                searchValue: widget.searchAddUser,
                onChangedSearchValue: widget.onSearchChanged),
            SizedBox(height: 10.h),
            Expanded(
              child: Consumer2<GroupProvider, DataListProvider>(
                  builder: (ctx, groupProvider, dataListProvider, child) {
                final selectedUsers = groupProvider.selectedUsers;
                final userChatList = dataListProvider.userChatList;

                return userChatList.isNotEmpty
                    ? ListView.builder(
                        itemCount: isGroupMode
                            ? userChatList.length
                            : userChatList.length,
                        controller: widget.controller,
                        itemBuilder: (context, index) {
                          if (index >= userChatList.length) return SizedBox();
                          final user = userChatList[index];
                          final bool isSelected =
                              selectedUsers.contains(user['iUserId']);
                          final Color statusColor = user['iStatus'] == 0
                              ? AppColorTheme.danger
                              : AppColorTheme.success;

                          return ChatListItem(
                            vProfilePic: user['vProfilePic'],
                            statusColor: statusColor,
                            listTitle: user['vFullName'],
                            listSubTitle:
                                user['iStatus'] == 1 ? 'Online' : 'Offline',
                            titleStyleRegular: true,
                            showCheckMarkIcon: isGroupMode ? true : false,
                            isSelectedCheckMark: isSelected,
                            showActiveBackground: isSelected ? true : false,
                            handleOnPressItem: () => isGroupMode
                                ? groupProvider.selectMember(user['iUserId'])
                                : handleOnPressUser(userChatList[index]),
                          );
                        })
                    : Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: Text("User Not Found",
                            style: AppFontStyles.dmSansRegular.copyWith(
                                fontSize: 15.sp,
                                color: Color.fromRGBO(33, 37, 41, 0.65))),
                      );
              }),
            ),
            isGroupMode
                ? Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Button(
                        onPressed: widget.onNextPressed,
                        title: 'Next',
                        backgroundColor: AppColorTheme.primary,
                        textColor: AppColorTheme.white,
                        width: MediaQuery.of(context).size.width),
                  )
                : Text("")
          ],
        ),
      ),
    );
  }
}
