import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';
import '../../../core/responsive_fonts.dart';

class GroupInfoMenu extends StatefulWidget {
  final String groupId;

  const GroupInfoMenu({super.key, required this.groupId});

  @override
  State<GroupInfoMenu> createState() => _GroupInfoMenuState();
}

class _GroupInfoMenuState extends State<GroupInfoMenu> {
  List<dynamic> memberList = [];
  List<dynamic> memberAllList = [];
  Timer? _debounce; // Timer to implement debouncing
  TextEditingController searchGroupMember =
      TextEditingController(); // Text controller for the search
  FocusNode searchFocusNode = FocusNode();
  int _currentPage = 1;
  bool _isLoading = false;
  bool showPastMembers = false;
  List pastMembersList = [];
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic> groupInfoData = {};
  Map<String, dynamic> creatorsData = {};

  @override
  void initState() {
    super.initState();
    groupInfoAllData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    searchGroupMember.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void groupInfoAllData() async {
    final dataListProvider = context.read<DataListProvider>();

    final groupInfoDataApi =
        await CommonFunctions.getGroupInfoData(widget.groupId);
    // final groupData = dataListProvider.groupInfoData;
    final groupData = groupInfoDataApi;
    final groupMembersList = dataListProvider.groupInfoMemberList;
    // debugPrint("groupData================ $groupData", wrapWidth: 1024);
    // debugPrint("groupMembersList================ $groupMembersList", wrapWidth: 1024);
    if (groupData.containsKey("data") && groupData['data'] != null) {
      groupInfoData = groupData['data'];
      if (groupData['data'].containsKey("creatorDetails") &&
          groupData['data']['creatorDetails'] != null) {
        creatorsData = groupData['data']['creatorDetails'];
      }

      if (groupMembersList.containsKey("vleftMembers") &&
          groupMembersList["vleftMembers"] is List &&
          groupMembersList['vleftMembers'].isNotEmpty) {
        pastMembersList = groupMembersList["vleftMembers"];
      }

      if (groupMembersList.containsKey("data") &&
          groupMembersList['data'] is List &&
          groupMembersList['data'].isNotEmpty) {
        memberList = groupMembersList['data'];
      }
      setState(() {});
    }

    // debugPrint("groupInfoData ------------------- state value ${groupInfoData}", wrapWidth: 1024);
    // if (mounted) {
    // }
  }

  void groupInfoMemberListData() {
    final dataListProvider = context.read<DataListProvider>();
    final groupMembersList = dataListProvider.groupInfoMemberList;
    // debugPrint("groupMembersList================ $groupMembersList", wrapWidth: 1024);
    if (groupMembersList.containsKey("data") &&
        groupMembersList['data'] is List &&
        groupMembersList['data'].isNotEmpty) {
      setState(() {
        memberList = groupMembersList['data'];
      });
    } else {
      setState(() {
        memberList = [];
      });
    }
  }

  // ********************* scroll member list ***********************
  void _onScroll() async {
    final dataListProvider = context.read<DataListProvider>();
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
          _currentPage++;
        });
        final responseList = await CommonFunctions.getGroupUserList(
            dataListProvider.openedChatGroupData['_id'],
            searchGroupMember.text,
            _currentPage);
        if (responseList['status'] == 200) {
          dataListProvider.setGroupInfoMemberList(responseList);
          groupInfoAllData();
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch member list
  // void getMemberList(int page) async {
  //   try {
  //     bool _hasMoreData = true;
  //
  //     // Reset _hasMoreData if it's a new search or first page
  //     if (page == 1) {
  //       _hasMoreData = true;
  //     }
  //
  //     if (!_hasMoreData) {
  //       print("No more data to load.");
  //       return;
  //     }
  //
  //     final list = await CommonFunctions.getGroupUserList(widget.groupId, '', page);
  //
  //     if (list != null && list.isNotEmpty) {
  //       setState(() {
  //         if(list.containsKey("vleftMembers") && list['vleftMembers'] is List){
  //           pastMembersList = list['vleftMembers'];
  //         }
  //       });
  //       if(list.containsKey("data") && list.isNotEmpty)
  //       if (page == 1) {
  //         memberList = list['data'];
  //       } else {
  //         memberList.addAll(list['data']);
  //       }
  //
  //       memberAllList = memberList;
  //     } else {
  //       // Set hasMoreData to false ONLY for pagination (not during search)
  //       if (searchGroupMember.text.isEmpty) {
  //         _hasMoreData = false;
  //       }
  //
  //       // Don’t clear existing list unless it's a new search and empty result
  //       if (page == 1 && searchGroupMember.text.isNotEmpty) {
  //         memberList = [];
  //       }
  //     }
  //
  //     setState(() { });
  //   } catch (error) {
  //     print("error while getting member list $error");
  //   }
  // }

  // Handle search input changes with debouncing
  void onChangedSearchMember({required String value}) async {
    final dataListProvider = context.read<DataListProvider>();

    // Cancel any previous debounce timer
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Set a new debounce timer
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final searchText = value.trim().toLowerCase();

      try {
        dynamic list;
        if (searchText.isNotEmpty) {
          list = await CommonFunctions.getGroupUserList(
              widget.groupId, searchText, 1);
          dataListProvider.setGroupInfoMemberList(list);
        } else {
          list = await CommonFunctions.getGroupUserList(widget.groupId, '', 1);
          dataListProvider.setGroupInfoMemberList(list);
        }
        groupInfoMemberListData();
      } catch (error) {
        // print("Error while searching for members: $error");
      }
    });
  }

  // Handle cancel action
  void cancelGroupInfoMenu() async {
    Navigator.of(context).pop();
    setState(() {
      _currentPage = 1;
      _isLoading = false;
      searchGroupMember.clear();
    });
    // final list = await CommonFunctions.getGroupUserList(widget.groupId, '', 1);
    // debugPrint("list $list", wrapWidth: 1024);

    // dataListProvider.setGroupInfoMemberList(list);
  }

  // ******************** handle show past members ***********************
  void handleShowPastMembers() {
    setState(() {
      showPastMembers = !showPastMembers;
    });
  }

  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  double responsiveFont(BuildContext context, double mobile, double tablet) {
    return isTablet(context) ? tablet : mobile;
  }

  @override
  Widget build(BuildContext context) {
    String? groupImage = groupInfoData['vGroupImage'];
    bool isSvg =
        (groupImage != null && groupImage.toLowerCase().endsWith('.svg'));
    String creatorName = creatorsData['name']?.toString() ?? '';
    String profilePic = creatorsData['ProfilePic']?.toString() ?? '';
    int status = creatorsData['Status'] ?? 0;
    final Color statusColor =
        status == 0 ? AppColorTheme.danger : AppColorTheme.success;
    // debugPrint("memberList $memberList", wrapWidth: 1024);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom * 1),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xffEEF2F5),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(0, -1),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          "Group Info",
                          style: ResponsiveFontStyles.dmSans18Medium(context)
                              .copyWith(
                            color: AppColorTheme.dark87,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: cancelGroupInfoMenu,
                      child: const Icon(
                        Icons.close,
                        color: AppColorTheme.muted,
                      ))
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonWidgets.modalMainTitle('Group Basic Details'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              color: AppColorTheme.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade400,
                                  offset: const Offset(0, 1),
                                  blurRadius: 1,
                                ),
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              groupInfoData['vGroupImage'] != "" &&
                                      groupInfoData['vGroupImage'] != null
                                  ? Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: CommonWidgets.isSvgDetailProfile(
                                          isSvg, groupInfoData['vGroupImage']),
                                    )
                                  : Container(),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 12, 0, 14),
                                  child: groupInfoData['vGroupName'] != "" &&
                                          groupInfoData['vGroupName'] != null
                                      ? Text(
                                          groupInfoData['vGroupName'],
                                          style: ResponsiveFontStyles
                                                  .dmSans18Medium(context)
                                              .copyWith(
                                            color: AppColorTheme.dark87,
                                            fontSize: 18,
                                          ),
                                        )
                                      : Container()),
                              Text(
                                "Created",
                                style:
                                    ResponsiveFontStyles.dmSans13Medium(context)
                                        .copyWith(
                                  color: AppColorTheme.dark40,
                                  fontSize: 14.5,
                                ),
                              ),
                              SizedBox(
                                height: 9,
                              ),
                              Text(
                                CommonFunctions.dateFormat(
                                  groupInfoData['dCreatedDate'] ?? '',
                                ),
                                style:
                                    ResponsiveFontStyles.dmSans14Medium(context)
                                        .copyWith(
                                  color: AppColorTheme.dark87,
                                  fontSize: 15.5,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Description",
                                style:
                                    ResponsiveFontStyles.dmSans13Medium(context)
                                        .copyWith(
                                  color: AppColorTheme.dark40,
                                  fontSize: 14.5,
                                ),
                              ),
                              SizedBox(
                                height: 9,
                              ),
                              Text(
                                (groupInfoData['tDescription'] ?? '').isNotEmpty
                                    ? groupInfoData['tDescription']
                                    : '-',
                                style:
                                    ResponsiveFontStyles.dmSans14Medium(context)
                                        .copyWith(
                                  color: AppColorTheme.dark87,
                                  fontSize: 15.5,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'Group Manager',
                                style:
                                    ResponsiveFontStyles.dmSans13Medium(context)
                                        .copyWith(
                                  color: AppColorTheme.dark40,
                                  fontSize: 14.5,
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 15, 0, 20),
                                child: Row(
                                  children: [
                                    ProfileIconStatusDot(
                                        profilePic: profilePic,
                                        statusColor: statusColor,
                                        borderRadius: 50,
                                        statusBorderColor:
                                            AppColorTheme.lightPrimary),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.5),
                                              child: Text(
                                                creatorName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: ResponsiveFontStyles
                                                        .dmSans15Regular(
                                                            context)
                                                    .copyWith(
                                                        color: AppColorTheme
                                                            .dark87,
                                                        fontSize: 15.5),
                                              )),
                                          Text(
                                              style: ResponsiveFontStyles
                                                      .dmSans12Regular(context)
                                                  .copyWith(
                                                      color: AppColorTheme.grey,
                                                      fontSize: 13.5),
                                              status == 1
                                                  ? 'Online'
                                                  : 'Offline'),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        CommonWidgets.modalMainTitle('Group Members'),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 15),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              color: AppColorTheme.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade400,
                                  offset: const Offset(0, 1),
                                  blurRadius: 1,
                                ),
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 36,
                                margin:
                                    const EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(10, 41, 55, 0.16),
                                    ),
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
                                          color: AppColorTheme.dark48,
                                        ),
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
                              const SizedBox(height: 5),
                              // Members List
                              memberList.isNotEmpty
                                  ? ListView.builder(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: memberList.length,
                                      itemBuilder: (context, index) {
                                        final groupMember = memberList[index];
                                        final Color statusColor =
                                            groupMember['iStatus'] == 0
                                                ? AppColorTheme.danger
                                                : AppColorTheme.success;
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                          visualDensity:
                                              VisualDensity(vertical: -2),
                                          leading: groupMember['vProfilePic'] !=
                                                  ""
                                              ? ProfileIconStatusDot(
                                                  profilePic:
                                                      groupMember['vProfilePic']
                                                              ?.toString() ??
                                                          '',
                                                  statusColor: statusColor,
                                                  statusBorderColor:
                                                      AppColorTheme
                                                          .lightPrimary)
                                              : Container(),
                                          title: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: groupMember['vFullName']
                                                          ?.toString() ??
                                                      '',
                                                  style: ResponsiveFontStyles
                                                          .dmSans15Regular(
                                                              context)
                                                      .copyWith(
                                                    color: AppColorTheme.dark87,
                                                    fontSize: 15.5,
                                                  ),
                                                ),
                                                if (groupMember['isAdmin'] == 1)
                                                  TextSpan(
                                                    text: ' (Group Manager)',
                                                    style: ResponsiveFontStyles
                                                            .dmSans15Regular(
                                                                context)
                                                        .copyWith(
                                                      color:
                                                          AppColorTheme.dark40,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                else if (groupMember[
                                                        'isAdmin'] ==
                                                    2)
                                                  TextSpan(
                                                    text: ' (You)',
                                                    style: ResponsiveFontStyles
                                                            .dmSans15Regular(
                                                                context)
                                                        .copyWith(
                                                      color:
                                                          AppColorTheme.dark87,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Text(
                                            groupMember['iStatus'] == 1
                                                ? 'Online'
                                                : 'Offline',
                                            style: ResponsiveFontStyles
                                                    .dmSans12Regular(context)
                                                .copyWith(
                                                    color: AppColorTheme.grey,
                                                    fontSize: 13.5),
                                          ),
                                          trailing: groupMember['iPending'] == 1
                                              ? SizedBox(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration:
                                                        const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  7)),
                                                      color: AppColorTheme
                                                          .primary16,
                                                    ),
                                                    child: Text(
                                                      "Pending",
                                                      style: ResponsiveFontStyles
                                                              .dmSans12Regular(
                                                                  context)
                                                          .copyWith(
                                                              color:
                                                                  AppColorTheme
                                                                      .primary,
                                                              fontSize: 13),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        );
                                      },
                                    )
                                  : const SizedBox(
                                      height: 0,
                                    ),
                              const SizedBox(
                                height: 5,
                              ),
                              pastMembersList.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 12, bottom: 15),
                                      child: InkWell(
                                          onTap: handleShowPastMembers,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          width: 1.5,
                                                          color: showPastMembers
                                                              ? AppColorTheme
                                                                  .primary
                                                              : AppColorTheme
                                                                  .dark40))),
                                              child: Text("Past members",
                                                  style: ResponsiveFontStyles
                                                          .dmSans16Regular(
                                                              context)
                                                      .copyWith(
                                                          color: showPastMembers
                                                              ? AppColorTheme
                                                                  .primary
                                                              : AppColorTheme
                                                                  .dark40,
                                                          fontSize: 16)))),
                                    )
                                  : Container(),
                              showPastMembers
                                  ? pastMembersList.isNotEmpty
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: pastMembersList.length,
                                          itemBuilder: (context, index) {
                                            final pastMember =
                                                pastMembersList[index];
                                            final Color statusColor =
                                                pastMember['iStatus'] == 0
                                                    ? AppColorTheme.danger
                                                    : AppColorTheme.success;
                                            return ListTile(
                                              leading: ProfileIconStatusDot(
                                                profilePic:
                                                    pastMember['vProfilePic'],
                                                statusColor: statusColor,
                                                statusBorderColor:
                                                    AppColorTheme.lightPrimary,
                                              ),
                                              title: Text(
                                                pastMember['vFullName'],
                                                style: ResponsiveFontStyles
                                                        .dmSans15Regular(
                                                            context)
                                                    .copyWith(
                                                        color: AppColorTheme
                                                            .dark87,
                                                        fontSize: 15.5),
                                              ),
                                              // ignore: prefer_interpolation_to_compose_strings
                                              subtitle: Text(
                                                // '${pastMember['iStatus'] == 1 ? 'Online' : 'Offline'} | ' + CommonFunctions.dateFormat(pastMember['dLeftDate']),
                                                pastMember['iStatus'] == 1
                                                    ? 'Online'
                                                    : 'Offline',
                                                style: ResponsiveFontStyles
                                                        .dmSans12Regular(
                                                            context)
                                                    .copyWith(
                                                        color:
                                                            AppColorTheme.grey,
                                                        fontSize: 13.5),
                                              ),
                                            );
                                          },
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        )
                                  : const SizedBox(
                                      height: 0,
                                    ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
