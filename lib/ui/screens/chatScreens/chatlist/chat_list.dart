import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spot/core/app_sizes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/firebase_helper/fcm_notification_helper.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/providers/group_provider.dart';
import 'package:spot/providers/profile_provider.dart';
import 'package:spot/services/api_service.dart';
import 'package:spot/services/configuration.dart';
import 'package:spot/socket/socket_manager.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:spot/ui/widgets/chat_list_widgets/add_user_bottom_sheet.dart';
import 'package:spot/ui/widgets/chat_list_widgets/chats_widget.dart';
import 'package:spot/ui/widgets/chat_list_widgets/create_group_bottom_sheet.dart';
import 'package:spot/ui/widgets/chat_list_widgets/edit_group_picture.dart';
import 'package:spot/ui/widgets/profile_widgets/edit_profile_bottom_sheet.dart';
import 'package:spot/ui/widgets/chat_list_widgets/group_widget.dart';
import 'package:spot/ui/widgets/profile_widgets/profile_modal.dart';
import 'package:provider/provider.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/custom_tabs.dart';
import 'package:spot/ui/widgets/common_widgets/header.dart';
import '../../../../core/themes.dart';

class ChatList extends StatefulWidget {
  final VoidCallback onLogout;
  const ChatList({super.key, required this.onLogout});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController searchValue = TextEditingController();
  final TextEditingController vGroupName = TextEditingController();
  final TextEditingController tDescription = TextEditingController();
  TextEditingController searchAddUser = TextEditingController();

  bool isGroupNameNotValid = true;
  bool isSubmit = false;
  bool _isLoading = false;
  File? chooseProfile;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    FcmNotificationHelper.instance.initFcm();
    connectSocket();
    print("hello from office windows pc");
    final chatProvider = context.read<ChatProvider>();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('tabIndex')) {
        final passedIndex = args['tabIndex'] as int;
        if (passedIndex >= 0 && passedIndex < _tabController.length) {
          _tabController.index = passedIndex;
          chatProvider.setActiveTab(passedIndex);
        }
      }

      chatProvider.setActiveTab(0);

      if (chatProvider.activeTab == 0) {
        if (chatProvider.showTabUserDotIndication) {
          chatProvider.setShowTabUserDotIndication(false);
        }
      }

      if (chatProvider.activeTab == 1) {
        if (chatProvider.showTabGroupDotIndication) {
          chatProvider.setShowTabGroupDotIndication(false);
        }
      }

      // Moved here to avoid calling notifyListeners during build
      chatProvider.setIsGroupChatOpen(false);
      chatProvider.setIsUserChatOpen(false);
    });

    _tabController.addListener(_onTabChanged);
    final dataListProvider = context.read<DataListProvider>();

    dataListProvider.getUserData();
    dataListProvider.getChatListData();
    dataListProvider.getGroupListData();
    dataListProvider.getUserChatListData(page: _currentPage, searchText: '');
    dataListProvider.getLoginUserData();
    CommonFunctions.getUserProfileData(context);
    _scrollController.addListener(_onScroll);
    SocketMessageEvents.logout(context);
    checkForTabDot();
  }

  void checkForTabDot() async {
    final chatProvider = context.read<ChatProvider>();
    final groupListData = await CommonFunctions.getGroupList();
    if (_tabController.index == 0) {
      final filteredData = groupListData.where((item) {
        return item['iTotalUnReadMsg'] != 0;
      }).toList();

      if (filteredData.isNotEmpty) {
        chatProvider.setShowTabGroupDotIndication(true);
      }
    }
  }

  late ChatProvider _chatProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = context.read<ChatProvider>();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ******************* connecting socket to app *******************
  void connectSocket() {
    final socket = SocketManager();
    socket.connect(context).then((_) {
      if (socket.isConnected) {}
    });
  }

  void _onScroll() {
    final dataListProvider =
        Provider.of<DataListProvider>(context, listen: false);
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
          _currentPage++;
        });
        dataListProvider.getUserChatListData(
            page: _currentPage, searchText: searchAddUser.text);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ****************** handle tab change ****************
  void _onTabChanged() async {
    final dataListprovider = context.read<DataListProvider>();
    final chatProvider = context.read<ChatProvider>();
    setState(() {});
    if (_tabController.index == 0) {
      dataListprovider.getChatListData();
      chatProvider.setActiveTab(0);
    }

    if (_tabController.index == 1) {
      dataListprovider.getGroupListData();
      chatProvider.setActiveTab(1);
    }
    setState(() {
      _currentPage = 1;
      searchValue.clear();
    });

    if (chatProvider.activeTab == 0) {
      if (chatProvider.showTabUserDotIndication) {
        chatProvider.setShowTabUserDotIndication(false);
      }
    }

    if (chatProvider.activeTab == 1) {
      if (chatProvider.showTabGroupDotIndication) {
        chatProvider.setShowTabGroupDotIndication(false);
      }
    }
  }

  // ************** handle on press user ****************
  Future<void> handleOnPressUser(
      Map<String, dynamic> userData, String type) async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final response = await CommonFunctions.getSingleUser(userData["iUserId"]);
      // debugPrint("responseresponseresponseresponse $response", wrapWidth: 1024);
      if (!context.mounted) return;
      dataListProvider.setOpenedChatUserData(response);
      Navigator.pushNamed(context, '/userChat', arguments: {'type': type});
    } catch (error) {
      // print("Error while opening user chat-----$error");
    }
  }

  // ************** handle on press group ****************
  void handleOnPressGroup(Map<String, dynamic> groupData, String type) async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      dataListProvider.setOpenedChatGroupData(groupData);
      Navigator.pushNamed(context, '/userChats', arguments: {'type': type});
    } catch (error) {
      // print("Error while opening user chat-----$error");
    }
  }

  // ****************** handle ProfileModal functions *******************
  // ************** handle on press profile ****************
  void _onPressProfile() async {
    ProfileModal.show(
        context: context,
        onPressEditProfile: onPressEditProfile,
        onLogout: widget.onLogout);
  }

  // *************** handle on Press Edit profile *********************
  void onPressEditProfile() {
    CommonModal.show(
        context: context,
        child: EditProfileBottomSheet(
            context: context,
            closeEditProfileModal: closeEditProfileModal,
            onPressConfirm: (id, imageFile) {
              onPressSaveGroupProfileIcon(id, imageFile, true);
            }));
  }

  // ****************** close edit profile modal **********************
  void closeEditProfileModal() {
    final groupProvider = context.read<GroupProvider>();
    Navigator.of(context).pop();
    groupProvider.clearProfile();
  }

  // ****************** AddUserBottomSheet functions *****************
  // ****************** handle on Press next ******************
  void handleOnPressNext() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final dataListProvider = context.read<DataListProvider>();
    final groupProvider = context.read<GroupProvider>();
    groupProvider.selectedUserListData();
    CommonModal.show(
        context: context,
        modalBackgroundColor: AppColorTheme.lightPrimary,
        child: CreateGroupBottomSheetModal(
          vGroupName: vGroupName,
          tDescription: tDescription,
          onPressCreateGroup: onPressCreateGroup,
          loginUserData: dataListProvider.loginUserData,
          tabController: _tabController,
          onPressEditGroupIcon: onPressEditGroupIcon,
          onGroupNameChange: onGroupNameChanged,
          cancelCreateGroupModal: cancelCreateGroupModal,
        ));
  }

  // ******************* handle close List Chat Group Modal ******************
  void closeListChatGroupModal() {
    final provider = context.read<GroupProvider>();
    closeCreateGroupModal();
    vGroupName.text = '';
    tDescription.text = '';
    provider.clearProfile();
    provider.clearGroupMembers();

    setState(() {
      _currentPage = 1;
      searchAddUser.clear();
    });
  }

  // ******************* handle close Create Group Modal *******************
  void closeCreateGroupModal() async {
    Navigator.of(context).pop();
    setState(() {
      isSubmit = true;
      isGroupNameNotValid = false;
    });
  }

  // ****************** CreateGroupBottomSheetModal functions **********************
  // ******************* handle group name changed *******************
  void onGroupNameChanged(String value) async {
    final provider = context.read<GroupProvider>();
    if (value.isNotEmpty) {
      provider.setGroupNameError(false);
    } else {
      provider.setGroupNameError(true);
    }
  }

  // ****************** cancel create group modal *******************
  void cancelCreateGroupModal() {
    final provider = context.read<GroupProvider>();
    vGroupName.text = '';
    tDescription.text = '';
    provider.clearProfile();
    searchAddUser.clear();
    // provider.clearGroupMembers();
    provider.setGroupNameError(false);
    Navigator.of(context).pop();
    setState(() {
      isSubmit = false;
      isGroupNameNotValid = false;
    });
  }

  // **************** handle create group *******************
  void onPressCreateGroup() async {
    final provider = context.read<GroupProvider>();

    setState(() {
      isSubmit = true;
    });

    if (vGroupName.text.isEmpty) {
      provider.setGroupNameError(true);
    }

    if (isSubmit && provider.isGroupNameError == false) {
      addGroupApiCall();
    }
  }

  // ****************** call api for create group ********************
  void addGroupApiCall({
    int iUpdateBasic = 0,
    vActiveGroupId = 0,
    isDeleteFile = 0,
  }) async {
    final provider = context.read<GroupProvider>();
    final dataProvider = context.read<DataListProvider>();
    int vSpaceSetting = provider.selectedOption == 'All' ? 1 : 0;
    final Map<String, dynamic> fields = {
      "vGroupName": vGroupName.text,
      "tDescription": tDescription.text,
      "vUsers": provider.selectedUsers.join(',').toString(),
      "iUpdateBasic": iUpdateBasic.toString(),
      "deleteMemeberStr": "",
      "vActiveGroupId": vActiveGroupId.toString(),
      "ColorOptionSelect": provider.profileSelectedColorOption.toString(),
      "vSpaceSetting": vSpaceSetting,
      "vGrpAdmins": [],
      "isDeleteFile": isDeleteFile.toString(),
      "cancelRequest": "",
    };

    final response = await ApiService.apiPostMultipart(
      Configuration.addNewGrp,
      fields: fields,
      file: provider.chooseImageFile,
      fileFieldName: 'vGroupProfile',
      token: dataProvider.userTokenData['tToken'],
    );

    dataProvider.getGroupListData();
    Navigator.of(context).pop();
    cancelCreateGroupModal();
    provider.clearGroupMembers();
  }

  // ********************** handle edit group profile icon ***********************
  void onPressEditGroupIcon() {
    CommonModal.show(
        context: context,
        // heightFactor: 0.71,
        modalBackgroundColor: AppColorTheme.white,
        child: EditGroupPicture(
          onPressConfirm: (id, imageFile) {
            onPressSaveGroupProfileIcon(id, imageFile, false);
          },
        ));
  }

  // ******************** EditGroupPicture functions *******************
  Future<void> onPressSaveGroupProfileIcon(
      int? selectedColorId, XFile? selectedImageFile, isEditProfile) async {
    Navigator.of(context).pop();
    final provider = context.read<GroupProvider>();
    final dataListProvider = context.read<DataListProvider>();
    if (selectedImageFile != null) {
      provider.setChooseProfile(selectedImageFile);
    } else if (selectedColorId != null) {
      provider.setProfileColorOption(selectedColorId);
      dataListProvider.getLoginUserData();
    }
    // final userData = await CommonFunctions.getUserData();
    // SocketMessageEvents.allUsersGetNewSts(userData['tToken'], vUsers)
  }

  // ************** handle search value ****************
  void onChangedSearchValue(
      {required String value,
      required List listData,
      required String name}) async {
    final provider = context.read<DataListProvider>();
    final searchText = value.trim().toLowerCase();

    List filterData = listData.where((item) {
      return item[name].toString().toLowerCase().contains(searchText);
    }).toList();

    if (searchText.isEmpty) {
      if (_tabController.index == 0) {
        provider.setChatList(provider.chatsOriginalData);
      }
      if (_tabController.index == 1) {
        provider.setGroupList(provider.groupsOriginalData);
      }
    } else {
      if (_tabController.index == 0) {
        provider.setChatList(filterData);
      }
      if (_tabController.index == 1) {
        provider.setGroupList(filterData);
      }
    }
  }

  // ************** handle search add user value ****************
  void onChangedSearchAddUser(
      {required String value,
      required List listData,
      required String name}) async {
    final provider = context.read<DataListProvider>();
    final searchText = value.trim().toLowerCase();

    setState(() {
      if (searchText.isEmpty) {
        // provider.setUserChatList(provider.userChatListOriginalData);
        provider.getUserChatListData(page: 1, searchText: '');
      } else {
        // provider.setUserChatList(filterData);
        //to responsive mobile tablet etc
        provider.getUserChatListData(page: 1, searchText: searchText);
      }
    });
  }

  final PageController _pageController = PageController();
  int _activeTabIndex = 0;

  final GlobalKey<ChatsWidgetState> chatsWidgetKey =
      GlobalKey<ChatsWidgetState>();
  final GlobalKey<GroupWidgetState> groupWidgetKey =
      GlobalKey<GroupWidgetState>();

  void handleOnChangeTab(int index) {
    setState(() => _activeTabIndex = index);

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    chatsWidgetKey.currentState?.clearSearch();
    groupWidgetKey.currentState?.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final dataListProvider = context.watch<DataListProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final loginUserData = dataListProvider.loginUserData;
    final selectedStatusId = profileProvider.selectedStatusId;

    final Color statusColor =
        selectedStatusId == 0 ? AppColorTheme.danger : AppColorTheme.success;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColorTheme.lightPrimary,
        body: Column(
          children: [
            Container(
                color: AppColorTheme.chatListHeader,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.horizontalAppPadding),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 13.h,
                        ),
                        // ******************** header logo & profile pic *************************
                        Header(
                          statusColor: statusColor,
                          onPressProfile: _onPressProfile,
                          statusBorderColor: AppColorTheme.chatListHeader,
                        ),

                        // ***************** tab bar ************************
                        SizedBox(
                          height: 11.h,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 40.h,
                              child: Stack(
                                children: [
                                  // Sliding background + underline
                                  AnimatedAlign(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    alignment: _activeTabIndex == 0
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          2.2,
                                      height: 35.h,
                                      decoration: BoxDecoration(
                                        color: AppColorTheme.white,
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0x140A2937),
                                            offset: const Offset(0, 3),
                                            blurRadius: 4,
                                          ),
                                          BoxShadow(
                                            color: const Color(0x290A2937),
                                            offset: const Offset(0, 1),
                                            blurRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: 2.h,
                                          width: 35.w,
                                          decoration: BoxDecoration(
                                            color: AppColorTheme.primary,
                                            borderRadius:
                                                BorderRadius.circular(2.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF00A3EF)
                                                    .withOpacity(0.5),
                                                offset: const Offset(2, 0),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Static tab labels
                                  Row(
                                    children: [
                                      CustomTabs(
                                          label: "Chats",
                                          activeTab: _activeTabIndex == 0
                                              ? true
                                              : false,
                                          onTabTap: () {
                                            handleOnChangeTab(0);
                                          }),
                                      CustomTabs(
                                          label: "Groups",
                                          activeTab: _activeTabIndex == 1
                                              ? true
                                              : false,
                                          onTabTap: () {
                                            handleOnChangeTab(1);
                                          })
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                )),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _activeTabIndex = index);
                },
                children: [
                  ChatsWidget(key: chatsWidgetKey),
                  GroupWidget(
                      key: groupWidgetKey,
                      handleOnPressGroup: (item) =>
                          handleOnPressUser(item, 'group')),
                ],
              ),
            ),
          ],
        ),

        // ********************* Add user / group button ********************
        floatingActionButton:
            Consumer<DataListProvider>(builder: (ctx, dataListProvider, child) {
          return Container(
            height: 52.h,
            width: 52.w,
            decoration: const BoxDecoration(
              color: AppColorTheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 163, 239, 0.33),
                  offset: Offset(0, 2),
                  blurRadius: 7,
                ),
              ],
            ),
            child: FloatingActionButton(
              backgroundColor: AppColorTheme.primary,
              elevation: 0,
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                searchAddUser.clear();
                dataListProvider.getUserChatListData(page: 1, searchText: '');
                CommonModal.show(
                    context: context,
                    child: AddUserBottomSheet(
                      onNextPressed: handleOnPressNext,
                      searchAddUser: searchAddUser,
                      onSearchChanged: (text) {
                        onChangedSearchAddUser(
                          value: text,
                          listData: dataListProvider.userChatListOriginalData,
                          name: 'vFullName',
                        );
                      },
                      activeTabIndex: _activeTabIndex,
                      closeListChatGroupModal: closeListChatGroupModal,
                      controller: _scrollController,
                    ));
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.h)),
              child: SvgPicture.asset("assets/icons/union.svg"),
            ),
          );
        })

        // appBar: AppBar(
        //   elevation: 0,
        //   systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: AppColorTheme.lightPrimary, statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.light),
        //   automaticallyImplyLeading: false,
        //   backgroundColor: AppColorTheme.lightPrimary,
        //   title: Padding(
        //     padding: EdgeInsets.symmetric(horizontal: AppSizes.horizontalAppPadding),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Padding(
        //           padding: EdgeInsets.only(left: 0),
        //           child: Row(
        //             children: [
        //               SvgPicture.asset(AppMedia.logo, height: 5.4.h, width: 6.h),
        //               SizedBox(width: 3.w),
        //               SvgPicture.asset(AppMedia.spotText, height: 3.h),
        //             ],
        //           ),
        //         ),
        //         // Profile pic + status
        //         InkWell(
        //           onTap: _onPressProfile,
        //           child:
        //           Stack(
        //             children: [
        //               ClipRRect(
        //                 borderRadius: BorderRadius.circular(6.h),
        //                 child: (loginUserData['vProfilePic'] != null)
        //                     ? CommonWidgets.isSvgProfilePic(isSvg, loginUserData['vProfilePic'])
        //                     : Container(),
        //               ),
        //               Positioned(
        //                 bottom: 0.2.h,
        //                 right: 0.2.h,
        //                 child: Container(
        //                   height:1.9.h,
        //                   width:1.9.h,
        //                   decoration: BoxDecoration(
        //                     color: statusColor,
        //                     shape: BoxShape.circle,
        //                     border:
        //                     Border.all(color: AppColorTheme.lightPrimary, width:0.3.h),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         )
        //       ],
        //     ),
        //   ),
        //   bottom: PreferredSize(
        //     preferredSize: Size.fromHeight(7 .h),
        //     child: Consumer<ChatProvider>(
        //       builder: (context, chatProvider, child) {
        //         return
        //           Stack(
        //             children: [
        //               Positioned.fill(
        //                 child: Row(
        //                   children: [
        //                     Expanded(
        //                       flex: 1,
        //                       child: Container(
        //                         padding: EdgeInsets.only(right: 5),
        //                         margin: EdgeInsets.only(left: 2.1.h, right: 0.7.h,  bottom: 1.h),
        //                         decoration: BoxDecoration(
        //                           color: _tabController.index == 0 ? AppColorTheme.white :
        //                           chatProvider.activeTab == 1 && chatProvider.showTabUserDotIndication ? Colors.white60 : AppColorTheme.transparent,
        //                           borderRadius: BorderRadius.circular(0.61.h),
        //                           boxShadow: [
        //                             if (_tabController.index == 0)
        //                               BoxShadow(color: Color.fromRGBO(10, 41, 55, 0.08), offset: Offset(0, 3), blurRadius: 0.4.h),
        //                             if (_tabController.index == 0)
        //                               BoxShadow(color: Colors.grey.shade400, offset: const Offset(0, 2), blurRadius: 1,),
        //                           ],
        //                         ),
        //                         child: Stack(
        //                           children: [
        //                             Center(
        //                               child: Text("Chats", style: ResponsiveFontStyles.dmSans15Medium(context).copyWith(color: AppColorTheme.dark87, fontSize: 16.sp),),
        //                             ),
        //                             _tabController.index == 0 ?
        //                             Center(
        //                               child: Column(
        //                                 crossAxisAlignment: CrossAxisAlignment.center,
        //                                 mainAxisAlignment: MainAxisAlignment.end,
        //                                 children: [
        //                                   Container(
        //                                     height: 0.4.h,
        //                                     width: 6.h,
        //                                     decoration: BoxDecoration(
        //                                       color: AppColorTheme.primary,
        //                                       boxShadow: [BoxShadow(color: Color.fromRGBO(0, 163, 239, 0.33), offset: Offset(0, -1), blurRadius: 4, spreadRadius: 0,)],
        //                                       borderRadius: BorderRadius.all(Radius.circular(25)),
        //                                     ),
        //                                   )
        //                                 ],
        //                               ),
        //                             ):Container(),
        //
        //                             // Blinking Dot
        //                             if (chatProvider.activeTab == 1 && chatProvider.showTabUserDotIndication)
        //                               Positioned(
        //                                 bottom:3.5.h,
        //                                 right:0.5.h,
        //                                 child: BlinkingDot(
        //                                   size:0.7.h,
        //                                   color: AppColorTheme.primary,
        //                                 ),
        //                               ),
        //                           ],
        //                         ),
        //                       ),
        //                     ),
        //                     Expanded(
        //                       flex: 1,
        //                       child: Container(
        //                         margin: EdgeInsets.only(left: 0.7.h, right: 2.1.h, bottom: 1.h),
        //                         decoration: BoxDecoration(
        //                           color: _tabController.index == 1 ? AppColorTheme.white : chatProvider.activeTab == 0 && chatProvider.showTabGroupDotIndication ? Colors.white60 : AppColorTheme.transparent,
        //                           borderRadius: BorderRadius.circular(0.6.h),
        //                           boxShadow: [
        //                             if (_tabController.index == 1)
        //                               BoxShadow(color: Color.fromRGBO(10, 41, 55, 0.08), offset: Offset(0, 3), blurRadius: 0.4.h),
        //                             if (_tabController.index == 1)
        //                               BoxShadow(color: Colors.grey.shade400, offset: Offset(0, 2), blurRadius: 1, spreadRadius: 0),
        //                           ],
        //                         ),
        //                         child:  Stack(
        //                           children: [
        //                             Center(
        //                               child: Text(
        //                                 "Group",
        //                                 style: ResponsiveFontStyles.dmSans15Medium(context).copyWith(
        //                                   color: AppColorTheme.dark87,
        //                                   fontSize: 16.sp,
        //                                 ),
        //                               ),
        //                             ),
        //                             _tabController.index == 1 ?
        //                             Center(
        //                               child: Column(
        //                                 crossAxisAlignment: CrossAxisAlignment.center,
        //                                 mainAxisAlignment: MainAxisAlignment.end,
        //                                 children: [
        //                                   Container(
        //                                     height: 0.4.h,
        //                                     width: 6.h,
        //                                     decoration: BoxDecoration(
        //                                       color: AppColorTheme.primary,
        //                                       boxShadow: [BoxShadow(color: Color.fromRGBO(0, 163, 239, 0.33), offset: Offset(0, -1), blurRadius: 4, spreadRadius: 0,)],
        //                                       borderRadius: BorderRadius.all(Radius.circular(25)),
        //                                     ),
        //                                   ),
        //
        //                                 ],
        //                               ),
        //                             ):Container(),
        //                             // Blinking Dot
        //                             if (chatProvider.activeTab == 0 &&
        //                                 chatProvider.showTabGroupDotIndication)
        //                               Positioned(
        //                                 bottom: 3.5.h,
        //                                 right:0.5.h,
        //                                 child: BlinkingDot(
        //                                   size: 0.7.h,
        //                                   color: AppColorTheme.primary,
        //                                 ),
        //                               ),
        //                           ],
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //               TabBar(
        //                 controller: _tabController,
        //                 overlayColor: MaterialStateProperty.all(Colors.transparent),
        //                 dividerColor: Colors.transparent,
        //                 indicatorColor: AppColorTheme.transparent,
        //                 labelColor: AppColorTheme.dark87,
        //                 unselectedLabelColor: AppColorTheme.dark87,
        //                 tabs: [
        //                   Tab(child: SizedBox()),
        //                   Tab(child: SizedBox()),
        //                 ],
        //               )],
        //           );
        //       },
        //     ),
        //   ),
        // ),
        // body: Padding(
        //   padding: EdgeInsets.all(5),
        //   child: Consumer<DataListProvider>(
        //     builder: (ctx, dataListProvider, child) {
        //       return TabBarView(
        //         controller: _tabController,
        //         children: [
        //           UserGroupList(
        //             type: 'chat',
        //             listData: dataListProvider.chatsData,
        //             searchValue: searchValue,
        //             name: 'vFullName',
        //             profilePic: 'vProfilePic',
        //             subTitle: 'chat',
        //             onChangedSearchValue: (text) {
        //               onChangedSearchValue(
        //                 value: text,
        //                 listData: dataListProvider.chatsOriginalData,
        //                 name: 'vFullName',
        //               );
        //             },
        //             handleOnPressUser: (item) =>
        //                 handleOnPressUser(item, 'chat'),
        //           ),
        //           UserGroupList(
        //             type: 'group',
        //             listData: dataListProvider.groupsData,
        //             searchValue: searchValue,
        //             name: 'vGroupName',
        //             profilePic: 'vGroupImage',
        //             subTitle: 'subTitle',
        //             onChangedSearchValue: (text) {
        //               onChangedSearchValue(
        //                 value: text,
        //                 listData: dataListProvider.groupsOriginalData,
        //                 name: 'vGroupName',
        //               );
        //             },
        //             handleOnPressUser: (item) =>
        //                 handleOnPressGroup(item, 'group'),
        //           ),
        //         ],
        //       );
        //     },
        //   ),
        // ),

        // Floating Action Button
        // floatingActionButton: Consumer<DataListProvider>(
        //   builder: (ctx, dataListProvider, child) {
        //     return Container(
        //       height: 55.h,
        //       width: 55.w,
        //       decoration: const BoxDecoration(
        //         color: AppColorTheme.primary,
        //         shape: BoxShape.circle,
        //         boxShadow: [
        //           BoxShadow(
        //             color: Color.fromRGBO(0, 163, 239, 0.33),
        //             offset: Offset(0, 2),
        //             blurRadius: 3,
        //           ),
        //         ],
        //       ),
        //       child: FloatingActionButton(
        //         backgroundColor: AppColorTheme.primary,
        //         onPressed: () {
        //           searchAddUser.clear();
        //           dataListProvider.getUserChatListData(page: 1, searchText: '');
        //           AddUserBottomSheet.show(
        //             context: context,
        //             onNextPressed: handleOnPressNext,
        //             searchAddUser: searchAddUser,
        //             onSearchChanged: (text) {
        //               onChangedSearchAddUser(
        //                 value: text,
        //                 listData:
        //                 dataListProvider.userChatListOriginalData,
        //                 name: 'vFullName',
        //               );
        //             },
        //             handleOnPressUser: (item) =>
        //                 handleOnPressUser(item, 'chat'),
        //             tabController: _tabController,
        //             closeListChatGroupModal: closeListChatGroupModal,
        //             controller: _scrollController,
        //           );
        //         },
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(28.h),
        //         ),
        //         child: SvgPicture.asset("assets/icons/union.svg"),
        //       ),
        //     );
        //   },
        // ),

        );
  }
}
