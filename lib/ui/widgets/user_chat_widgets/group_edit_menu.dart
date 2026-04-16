import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/providers/group_provider.dart';
import 'package:spot/services/api_service.dart';
import 'package:spot/services/configuration.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/chat_list_widgets/edit_group_picture.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/confirm_bottom_modal.dart';
import 'package:spot/ui/widgets/common_widgets/input.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';
import '../../../core/responsive_fonts.dart';

class GroupEditMenu extends StatefulWidget {
  final Map<String, dynamic> singleUserData;
  final BuildContext ctx;

  const GroupEditMenu(
      {super.key, required this.singleUserData, required this.ctx});

  @override
  State<GroupEditMenu> createState() => _GroupEditMenuState();
}

class _GroupEditMenuState extends State<GroupEditMenu> {
  final TextEditingController vGroupName = TextEditingController();
  final TextEditingController tDescription = TextEditingController();

  List<dynamic> memberList = [];
  List<dynamic> memberAllList = [];
  TextEditingController searchGroupMember = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  int _currentPage = 1;
  int loadMore = 0;
  bool _isLoading = false;
  Set<String> selectedUsers = {};
  final ScrollController _scrollController = ScrollController();
  bool groupNameError = false;
  bool isSubmit = false;

  @override
  void initState() {
    super.initState();
    final dataListProvider = context.read<DataListProvider>();
    final groupProvider = context.read<GroupProvider>();
    getMemberList(1, '');
    // debugPrint("dataListProvider.openedChatGroupData ${dataListProvider.openedChatGroupData}", wrapWidth: 1024);
    vGroupName.text = dataListProvider.openedChatGroupData['vGroupName'];
    tDescription.text = dataListProvider.openedChatGroupData['tDescription'];
    _scrollController.addListener(_onScroll);
    groupProvider.setSelectedOption(
        dataListProvider.openedChatGroupData['vSpaceSetting'] == 0
            ? "Group Manager"
            : "All");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch member list
  void getMemberList(int page, String searchText) async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      bool hasMoreData = true;

      // Reset _hasMoreData if it's a new search or first page
      if (page == 1) {
        hasMoreData = true;
      }

      if (!hasMoreData) {
        // print("No more data to load.");
        return;
      }
      final list = await CommonFunctions.getEditGroupUserList(
          dataListProvider.openedChatGroupData['_id'],
          searchText,
          page,
          loadMore);
      if (list != null && list.isNotEmpty) {
        if (page == 1) {
          memberList = list['data'];
        } else {
          memberList.addAll(list['data']);
        }

        memberAllList = memberList;
      } else {
        // Set hasMoreData to false ONLY for pagination (not during search)
        if (searchGroupMember.text.isEmpty) {
          hasMoreData = false;
        }

        // Don’t clear existing list unless it's a new search and empty result
        if (page == 1 && searchGroupMember.text.isNotEmpty) {
          memberList = [];
        }
      }

      setState(() {});
    } catch (error) {
      // print("error while getting member list $error");
    }
  }

  // ********************* scroll member list ***********************
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
          _currentPage++;
        });

        getMemberList(_currentPage, searchGroupMember.text);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ********************* cancel edit group menu **************************
  void cancelGroupEditMenu() {
    final groupProvider = context.read<GroupProvider>();
    Navigator.of(context).pop();
    setState(() {
      searchGroupMember.clear();
      loadMore = 0;
    });
    groupProvider.clearGroupMembers();
    groupProvider.clearProfile();
  }

  // *************************** void edit group icon ****************************
  void onPressEditGroupIcon() {
    final dataListProvider = context.read<DataListProvider>();
    if (dataListProvider.openedChatGroupData['vGroupImage'] != '') {}

    CommonModal.show(
        context: context,
        // heightFactor: 0.71,
        modalBackgroundColor: AppColorTheme.white,
        child: EditGroupPicture(
          onPressConfirm: (id, imageFile) {
            onPressSaveGroupProfileIcon(id, imageFile);
          },
          groupExistProfile:
              dataListProvider.openedChatGroupData['vGroupImage'],
          existGroupProfileColorId: dataListProvider
                      .openedChatGroupData['iColorOption'] !=
                  null
              ? int.parse(dataListProvider.openedChatGroupData['iColorOption'])
              : 0,
        ));
  }

  // ******************** EditGroupPicture functions *******************
  Future<void> onPressSaveGroupProfileIcon(
      int? selectedColorId, XFile? selectedImageFile) async {
    Navigator.of(context).pop();
    final provider = context.read<GroupProvider>();

    if (selectedImageFile != null) {
      provider.setChooseProfile(selectedImageFile);
    } else if (selectedColorId != null) {
      provider.setProfileColorOption(selectedColorId);
    }
  }

  // ******************* handle group name changed *******************
  void onGroupNameChange(String value) async {
    if (value.isNotEmpty) {
      setState(() {
        groupNameError = false;
      });
    } else {
      setState(() {
        groupNameError = true;
      });
    }
  }

  // ********************** change search value ********************************
  void onChangedSearchMember({required String value}) {
    final searchText = value.trim().toLowerCase();

    List filterData = memberList.where((item) {
      return item['vFullName'].toString().toLowerCase().contains(searchText);
    }).toList();

    getMemberList(_currentPage, searchText);
  }

  void onPressedSaveGroup() async {
    setState(() {
      isSubmit = true;
    });

    if (vGroupName.text.isEmpty) {
      setState(() {
        groupNameError = true;
      });
    }

    if (isSubmit && groupNameError == false) {
      final provider = context.read<GroupProvider>();
      final dataListProvider = context.read<DataListProvider>();

      // Add vSpaceSetting logic based on selectedOption
      int vSpaceSetting = provider.selectedOption == 'All' ? 1 : 0;
      final Map<String, dynamic> fields = {
        "vGroupName": vGroupName.text,
        "tDescription": tDescription.text,
        "vUsers": "",
        "iUpdateBasic": 1,
        "deleteMemeberStr": "",
        "vActiveGroupId": dataListProvider.openedChatGroupData['_id'],
        "vSpaceSetting": vSpaceSetting,
        "vGrpAdmins": [],
        "ColorOptionSelect": (provider.profileSelectedColorOption != 0 &&
                provider.profileSelectedColorOption != null)
            ? provider.profileSelectedColorOption.toString()
            : (provider.chooseImageFile == null &&
                    dataListProvider.openedChatGroupData['iColorOption'] != 0 &&
                    dataListProvider.openedChatGroupData['iColorOption'] !=
                        null)
                ? dataListProvider.openedChatGroupData['iColorOption']
                : 0,
        "isDeleteFile": (provider.profileSelectedColorOption == 0 &&
                provider.profileSelectedColorOption == null)
            ? 0
            : 1,
        "cancelRequest": ""
      };
      // print("-------Fields---------: $fields");

      final response = await ApiService.apiPostMultipart(
          Configuration.addNewGrp,
          fields: fields,
          file: provider.chooseImageFile,
          fileFieldName: 'vGroupProfile',
          token: dataListProvider.userTokenData['tToken']);

      final responseGroup = await CommonFunctions.getGroupList();

      List filterData = responseGroup.where((item) {
        return item['_id']
            .toString()
            .toLowerCase()
            .contains(dataListProvider.openedChatGroupData['_id']);
      }).toList();

      if (filterData.isNotEmpty && mounted) {
        Navigator.of(context).pop(filterData[0]);
      } else {
        // print("GroupEditMenu: Widget no longer mounted. Cannot return data.");
      }

      vGroupName.text = '';
      tDescription.text = '';
      provider.clearProfile();
      provider.clearGroupMembers();

      setState(() {
        isSubmit = false;
        groupNameError = false;
      });
    }
  }

  // *********************** handle on press add member ***************************
  void onPressedAddMember() {
    if (loadMore == 1) {
      setState(() {
        loadMore = 0;
        selectedUsers = {};
        searchGroupMember.clear();
      });
    } else {
      setState(() {
        loadMore = 1;
      });
    }
    getMemberList(1, searchGroupMember.text);
  }

  // ************************** handle on press delete group *********************
  void handleOnPressDeleteGroup() {
    ConfirmModal.show(context,
        headerTitle: 'Delete Confirm',
        modalTitle:
            'Are you sure you want to delete group? Deleting it will remove the group for all members permanently.',
        confirmBtnTitle: 'Delete',
        cancelBtnTitle: 'Cancel',
        backgroundColor: AppColorTheme.darkDanger,
        textColor: AppColorTheme.white,
        onPressConfirm: () => handleConfirmDeleteGroup(),
        onPressCancel: () => Navigator.of(context).pop());
  }

  void handleConfirmDeleteGroup() async {
    final dataListProvider = context.read<DataListProvider>();
    final chatProvider = context.read<ChatProvider>();

    final response = await CommonFunctions.deleteEditGroup(
        dataListProvider.openedChatGroupData['_id']);

    if (response['status'] == 200) {
      if (!mounted) {
        return;
      }
      Navigator.of(widget.ctx).pop();
      Navigator.of(context).pop();
      chatProvider.setIsGroupChatOpen(false);
      dataListProvider.getGroupListData();
      Navigator.pushNamed(context, '/chatList', arguments: {'tabIndex': 1});
    }
  }

  // ************************ cancel member request ********************
  void handleOnPressCancelRequest(dynamic memberData) {
    ConfirmModal.show(context,
        headerTitle: 'Cancel Request Confirm',
        modalTitle: 'Are you sure you want to cancel request?',
        confirmBtnTitle: 'Cancel Request',
        cancelBtnTitle: 'Cancel',
        backgroundColor: AppColorTheme.warning,
        textColor: AppColorTheme.white,
        onPressConfirm: () => handleConfirmCancelRequest(memberData),
        onPressCancel: () => Navigator.of(context).pop());
  }

  void handleOnPressDeleteMember(dynamic memberData) {
    ConfirmModal.show(context,
        headerTitle: 'Delete Confirm',
        modalTitle: 'Are you sure you want to delete member?',
        confirmBtnTitle: 'Delete',
        cancelBtnTitle: 'Cancel',
        backgroundColor: AppColorTheme.darkDanger,
        textColor: AppColorTheme.white,
        onPressConfirm: () => handleConfirmCancelRequest(memberData),
        onPressCancel: () => Navigator.of(context).pop());
  }

  void handleConfirmCancelRequest(dynamic memberData) async {
    final dataListProvider = context.read<DataListProvider>();
    final response = await CommonFunctions.deleteGroupMember(
        dataListProvider.openedChatGroupData['_id'], memberData['iUserId']);
    if (response['status'] == 200) {
      Navigator.of(context).pop();
      getMemberList(1, searchGroupMember.text);
    }
  }

  // *************** add more members *********************
  void selectMember(String userId) {
    if (selectedUsers.contains(userId)) {
      selectedUsers.remove(userId);
    } else {
      selectedUsers.add(userId);
    }
    setState(() {});
  }

  void onPressAddMemberSave() async {
    final dataListProvider = context.read<DataListProvider>();
    final groupProvider = context.read<GroupProvider>();
    int vSpaceSetting = groupProvider.selectedOption == 'All' ? 1 : 0;

    final response = await CommonFunctions.addNewGroupMember(
        dataListProvider.openedChatGroupData['_id'],
        selectedUsers.join(','),
        vSpaceSetting, []);
    // print("Response to messages groupDataaaaa:-------: $response");

    if (response['status'] == 200) {
      setState(() {
        loadMore = 0;
        selectedUsers = {};
        searchGroupMember.clear();
      });
      getMemberList(1, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.read<GroupProvider>();
    final dataListProvider = context.read<DataListProvider>();
    String groupImage = dataListProvider.openedChatGroupData['vGroupImage'];
    bool isSvg = (groupImage.toLowerCase()).endsWith('.svg');
    final Color statusColor = widget.singleUserData["iStatus"] == 0
        ? AppColorTheme.danger
        : AppColorTheme.success;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom * 1),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xffEEF2F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          boxShadow: [
            BoxShadow(
                color: Colors.white,
                offset: Offset(0, -1),
                blurRadius: 0,
                spreadRadius: 1),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text("Edit Group",
                            style: ResponsiveFontStyles.dmSans18Medium(context)
                                .copyWith(
                                    color: AppColorTheme.dark87, fontSize: 18)),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: cancelGroupEditMenu,
                      child: Icon(Icons.close,
                          color: Color(0xffAEB9BD).withOpacity(0.7)))
                ],
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonWidgets.modalMainTitle('Group Basic Details'),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: AppColorTheme.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade400,
                              offset: const Offset(0, 1),
                              blurRadius: 1),
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3, left: 4),
                          child: Text(
                            'Group Picture',
                            style: ResponsiveFontStyles.dmSans13Medium(context)
                                .copyWith(
                                    color: AppColorTheme.dark40, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 18),
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Consumer<GroupProvider>(
                                        builder: (ctx, groupProvider, child) {
                                      final imageId = groupProvider
                                          .profileSelectedColorOption;
                                      final selectedImage = AppMedia.groupImages
                                          .where((item) =>
                                              item['iColorId'] == imageId);

                                      return groupProvider.chooseImageFile !=
                                              null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                  File(groupProvider
                                                      .chooseImageFile!.path),
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover))
                                          : imageId != null && imageId != 0
                                              ? SvgPicture.asset(
                                                  selectedImage
                                                      .single['vColorPick'],
                                                  fit: BoxFit.cover)
                                              : groupImage != ""
                                                  ? isSvg
                                                      ? SvgPicture.network(
                                                          groupImage,
                                                          fit: BoxFit.contain,
                                                          height: 100,
                                                          width: 100)
                                                      : Image.network(
                                                          groupImage,
                                                          fit: BoxFit.contain,
                                                          height: 100,
                                                          width: 100)
                                                  : Container();
                                    }),
                                  ),
                                  Positioned(
                                      right: 5,
                                      top: 5,
                                      child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppColorTheme.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      10, 41, 55, 0.08),
                                                  offset: Offset(0, 3),
                                                  blurRadius: 4)
                                            ],
                                          ),
                                          child: InkWell(
                                              onTap: onPressEditGroupIcon,
                                              child: SvgPicture.asset(
                                                AppMedia.edit,
                                                color: AppColorTheme.muted,
                                              )))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Input(
                            title: 'Group Name',
                            isRequired: true,
                            inputValue: vGroupName,
                            showRequiredError: true,
                            isError: groupNameError,
                            onChanged: onGroupNameChange),
                        const SizedBox(height: 4),
                        Input(
                            title: 'Description',
                            isRequired: false,
                            inputValue: tDescription,
                            maxLines: 5,
                            maxLength: 350),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Group Message Setting',
                                style:
                                    ResponsiveFontStyles.dmSans13Medium(context)
                                        .copyWith(
                                            color: AppColorTheme.dark40,
                                            fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 0, top: 5, bottom: 10),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        groupProvider
                                            .setSelectedOption("Group Manager");
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: groupProvider
                                                            .selectedOption ==
                                                        'Group Manager'
                                                    ? const Color(0xFF00A9E0)
                                                    : Colors.grey.shade400,
                                                width: 1.7,
                                              ),
                                            ),
                                            child: groupProvider
                                                        .selectedOption ==
                                                    'Group Manager'
                                                ? Center(
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: groupProvider
                                                                      .selectedOption ==
                                                                  'Group Manager'
                                                              ? Color(
                                                                  0xFF00A9E0)
                                                              : Colors.grey
                                                                  .shade400,
                                                          width: 4,
                                                        ),
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Group Manager',
                                            style: ResponsiveFontStyles
                                                    .dmSans15Regular(context)
                                                .copyWith(
                                              color: AppColorTheme.dark87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 65),
                                    GestureDetector(
                                      onTap: () {
                                        groupProvider.setSelectedOption("All");
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: groupProvider
                                                              .selectedOption ==
                                                          'All'
                                                      ? Color(0xFF00A9E0)
                                                      : Colors.grey.shade400,
                                                  width: 1.7,
                                                ),
                                              ),
                                              child: groupProvider
                                                          .selectedOption ==
                                                      'All'
                                                  ? Center(
                                                      child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: groupProvider
                                                                          .selectedOption ==
                                                                      'All'
                                                                  ? Color(
                                                                      0xFF00A9E0)
                                                                  : Colors.grey
                                                                      .shade400,
                                                              width: 4,
                                                            ),
                                                            color: Colors.white,
                                                          )),
                                                    )
                                                  : SizedBox(),
                                            ),
                                            SizedBox(width: 8),
                                            Text('All',
                                                style: ResponsiveFontStyles
                                                        .dmSans15Regular(
                                                            context)
                                                    .copyWith(
                                                  color: AppColorTheme.dark87,
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text('Group Manager',
                              style:
                                  ResponsiveFontStyles.dmSans13Medium(context)
                                      .copyWith(
                                          color: AppColorTheme.dark40,
                                          fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(4, 14, 4, 15),
                          child: Row(
                            children: [
                              ProfileIconStatusDot(
                                profilePic:
                                    widget.singleUserData['vProfilePic'],
                                statusColor: statusColor,
                                borderRadius: 50,
                                statusBorderColor: AppColorTheme.lightPrimary,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5),
                                        child: Text(
                                          widget.singleUserData['vFullName'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: ResponsiveFontStyles
                                                  .dmSans15Regular(context)
                                              .copyWith(
                                                  color: AppColorTheme.dark87,
                                                  fontSize: 15.5),
                                        )),
                                    Text(
                                        style: AppFontStyles.dmSansRegular
                                            .copyWith(
                                          fontSize: 13,
                                          height: 1.7,
                                          color: AppColorTheme.dark40,
                                        ),
                                        widget.singleUserData['iStatus'] == 1
                                            ? 'Online'
                                            : 'Offline'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Button(
                          onPressed: onPressedSaveGroup,
                          title: 'Save',
                          backgroundColor: AppColorTheme.primary,
                          textColor: AppColorTheme.white,
                          width: MediaQuery.of(context).size.width,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text("Group Members",
                          style: ResponsiveFontStyles.dmSans13Medium(context)
                              .copyWith(
                                  color: AppColorTheme.dark40, fontSize: 14))),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: AppColorTheme.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          )
                        ]),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 36,
                                width: MediaQuery.of(context).size.width * 0.71,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    const BoxShadow(
                                        color:
                                            Color.fromRGBO(10, 41, 55, 0.16)),
                                    BoxShadow(
                                      color: Color(0xffEEF2F5).withOpacity(0.6),
                                      offset: Offset(0, 2),
                                      spreadRadius: 0.0,
                                      blurRadius: 1.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: TextField(
                                    style: ResponsiveFontStyles.dmSans15Regular(
                                            context)
                                        .copyWith(
                                      color: AppColorTheme.inputTitle,
                                    ),
                                    focusNode: searchFocusNode,
                                    controller: searchGroupMember,
                                    cursorColor: AppColorTheme.black,
                                    onChanged: (text) =>
                                        onChangedSearchMember(value: text),
                                    cursorWidth: 0.9,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SvgPicture.asset(
                                            'assets/icons/search.svg',
                                            height: 18,
                                            width: 18,
                                            color: AppColorTheme.dark48),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 0),
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Container(
                                  height: 36,
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  decoration: BoxDecoration(
                                    color: loadMore == 1
                                        ? AppColorTheme.border
                                        : AppColorTheme.primary,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    boxShadow: [
                                      loadMore == 1
                                          ? const BoxShadow()
                                          : const BoxShadow(
                                              color: Color.fromRGBO(
                                                  0, 163, 239, 0.33),
                                              offset: Offset(0, 2),
                                              blurRadius: 5,
                                              spreadRadius: 0.2,
                                            )
                                    ],
                                  ),
                                  child: loadMore == 1
                                      ? IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 1),
                                          onPressed: onPressedAddMember,
                                          color: AppColorTheme.white,
                                          icon: const Icon(Icons.close))
                                      : IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 1),
                                          onPressed: onPressedAddMember,
                                          color: AppColorTheme.white,
                                          icon: const Icon(Icons.add))),
                            ],
                          ),
                        ),

                        // Members List
                        ListView.builder(
                          padding: const EdgeInsets.only(bottom: 12),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: memberList.length,
                          itemBuilder: (context, index) {
                            final groupMember = memberList[index];
                            final Color statusColor =
                                groupMember['iStatus'] == 0
                                    ? AppColorTheme.danger
                                    : AppColorTheme.success;

                            final bool isSelected =
                                selectedUsers.contains(groupMember['iUserId']);

                            return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                visualDensity:
                                    const VisualDensity(vertical: -3),
                                leading: ProfileIconStatusDot(
                                  profilePic: groupMember['vProfilePic'],
                                  statusColor: statusColor,
                                  statusBorderColor: AppColorTheme.lightPrimary,
                                ),
                                title: Text(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    groupMember['vFullName'],
                                    style: ResponsiveFontStyles.dmSans15Regular(
                                            context)
                                        .copyWith(
                                            color: AppColorTheme.dark87,
                                            fontSize: 15.5)),
                                subtitle: Text(
                                    groupMember['iStatus'] == 1
                                        ? 'Online'
                                        : 'Offline',
                                    style: ResponsiveFontStyles.dmSans12Regular(
                                            context)
                                        .copyWith(
                                            color: AppColorTheme.grey,
                                            fontSize: 13.5)),
                                trailing: loadMore == 1
                                    ? InkWell(
                                        onTap: () => selectMember(
                                            groupMember['iUserId']),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                width: 2,
                                                color: isSelected
                                                    ? AppColorTheme.primary
                                                    : AppColorTheme.border),
                                            color: isSelected
                                                ? AppColorTheme.primary
                                                : AppColorTheme.transparent,
                                          ),
                                          width: 20,
                                          height: 20,
                                          child: isSelected
                                              ? const Icon(Icons.check,
                                                  color: AppColorTheme.white,
                                                  size: 14)
                                              : null,
                                        ),
                                      )
                                    : SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.32,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            groupMember['iPending'] == 1
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4),
                                                    margin: const EdgeInsets.only(
                                                        right: 12),
                                                    decoration: const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    7)),
                                                        color: AppColorTheme
                                                            .primary16),
                                                    child: Text("Pending",
                                                        style: AppFontStyles
                                                            .dmSansRegular
                                                            .copyWith(
                                                                fontSize: 13,
                                                                color: AppColorTheme
                                                                    .primary)))
                                                : const SizedBox(),
                                            InkWell(
                                              onTap: () => groupMember[
                                                          'iPending'] ==
                                                      1
                                                  ? handleOnPressCancelRequest(
                                                      groupMember)
                                                  : handleOnPressDeleteMember(
                                                      groupMember),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: AppColorTheme
                                                              .border,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          50))),
                                                  child: const Icon(
                                                    Icons.close_rounded,
                                                    color: AppColorTheme.white,
                                                    size: 17,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ));
                          },
                        ),
                        loadMore == 1
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                child: Button(
                                  onPressed: onPressAddMemberSave,
                                  title: 'Add',
                                  backgroundColor: AppColorTheme.primary,
                                  textColor: AppColorTheme.white,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Group Action',
                      style:
                          ResponsiveFontStyles.dmSans13Medium(context).copyWith(
                        color: AppColorTheme.dark40,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: handleOnPressDeleteGroup,
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: AppColorTheme.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ]),
                        margin: EdgeInsets.only(bottom: 15),
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(15),
                        child: Text("Delete Group",
                            style: AppFontStyles.dmSansMedium.copyWith(
                                color: AppColorTheme.danger, fontSize: 14))),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
