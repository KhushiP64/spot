import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:spot/core/responsive_fonts.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/socket/socket_manager.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';

class UserGroupList extends StatefulWidget {
  final String type;
  final String name;
  final String profilePic;
  final String subTitle;
  final List listData;
  final TextEditingController searchValue;
  final Function(String)? onChangedSearchValue;
  final Function(dynamic)? handleOnPressUser;

  const UserGroupList(
      {super.key,
      required this.type,
      required this.name,
      required this.profilePic,
      required this.subTitle,
      required this.searchValue,
      required this.onChangedSearchValue,
      required this.listData,
      required this.handleOnPressUser});

  @override
  State<UserGroupList> createState() => _UserGroupListState();
}

class _UserGroupListState extends State<UserGroupList> {
  final Map<String, bool> _msgFlagVisibleMap = {};

  @override
  void initState() {
    super.initState();
  }

  void checkFlag(String userId) {
    final loginUserData = context.read<DataListProvider>().loginUserData;
    SocketManager socketManager = SocketManager();
    socketManager.on("receive_message", (data) {
      // print("dataaaaaaaaaaaaaaaaaa =================== $data");
      if (data['type'] == 'newMessage' &&
          data['iReceiverId'].toString() ==
              loginUserData['iUserId'].toString()) {
        final senderId = data['iSenderId'].toString();
        final msgFlag = data['msgFlag'];
        // print("New Message From: $senderId | Flag: $msgFlag");
        setState(() {
          _msgFlagVisibleMap[senderId] = msgFlag != null && msgFlag.isNotEmpty;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        bool isPortrait = orientation == Orientation.portrait;

        bool isTablet = 100.w >= 50.w && 100.w < 102.4.w;
        bool isDesktop = 100.w >= 102.4.w;

        EdgeInsets contentPadding = isTablet
            ? EdgeInsets.symmetric(horizontal: 0.w)
            : isDesktop
                ? EdgeInsets.symmetric(horizontal: 5.w)
                : EdgeInsets.symmetric(horizontal: 0);

        return Column(
          children: [
            SizedBox(
              height: isPortrait ? 2.1.h : 4.h,
            ),
            Container(
              height: isPortrait ? 6.h : 17.h,
              margin: EdgeInsets.only(
                  left: isPortrait ? 2.4.h : 12.5.h,
                  right: isPortrait ? 2.4.h : 21.1.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isPortrait ? 3.h : 10.h),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(10, 41, 55, 0.16),
                  ),
                  BoxShadow(
                    color: Color(0xffEEF2F5),
                    offset: Offset(0, 2),
                    spreadRadius: 0.0,
                    blurRadius: 1.0,
                  )
                ],
              ),
              child: Center(
                child: TextField(
                  style: ResponsiveFontStyles.dmSans15Regular(context).copyWith(
                    color: AppColorTheme.inputTitle,
                  ),
                  controller: widget.searchValue,
                  cursorColor: AppColorTheme.black,
                  onChanged: widget.onChangedSearchValue,
                  cursorWidth: 0.9,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(isPortrait ? 1.2.h : 3.h),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        color: AppColorTheme.dark48,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 1.5.h, vertical: 0),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            //remove the bottom shadow
            SizedBox(
              height: isPortrait ? 1.5.h : 5.h,
            ),
            Expanded(child: Consumer<DataListProvider>(
                builder: (context, dataListProvider, child) {
              final listData = widget.type == 'chat'
                  ? dataListProvider.chatsData
                  : dataListProvider.groupsData;
              return ListView.builder(
                itemCount: listData.length,
                itemBuilder: (context, index) {
                  if (index >= listData.length) return const SizedBox();
                  final listItem = listData[index];
                  final userId = listItem['iUserId'].toString();
                  if (!_msgFlagVisibleMap.containsKey(userId)) {
                    checkFlag(userId);
                  }
                  final Color statusColor = listItem["iStatus"] == 0
                      ? AppColorTheme.danger
                      : AppColorTheme.success;
                  return listItem != null
                      ? ListTile(
                          splashColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: isPortrait ? 2.3.h : 11.h,
                              vertical: 0.h),
                          visualDensity: VisualDensity(
                              vertical: isPortrait ? -0.3.h : -0.5.h),
                          leading: ProfileIconStatusDot(
                            profilePic: listItem[widget.profilePic] ?? "",
                            statusColor: statusColor,
                            borderRadius: widget.subTitle == 'chat'
                                ? 10.h
                                : isPortrait
                                    ? 1.h
                                    : 2.5.h,
                            showStatusColor: widget.subTitle == 'chat',
                            statusBorderColor: AppColorTheme.lightPrimary,
                          ),
                          title: Text(
                            listItem[widget.name] ?? "",
                            style: ResponsiveFontStyles.dmSans15Regular(context)
                                .copyWith(
                                    color: AppColorTheme.inputTitle,
                                    fontSize: isPortrait ? 2.2.h : 6.5.h),
                          ),
                          subtitle: Text(
                            widget.subTitle == 'chat'
                                ? listItem['iStatus'] == 1
                                    ? 'Online'
                                    : 'Offline'
                                : "${listItem['grpMemberCount']} ${listItem['grpMemberCount'] == 1 ? 'Member' : 'Members'}",
                            style: ResponsiveFontStyles.dmSans12Regular(context)
                                .copyWith(
                              color: AppColorTheme.grey,
                              fontSize: isPortrait ? 1.85.h : 5.5.h,
                            ),
                          ),
                          trailing: listItem['iTotalUnReadMsg'] > 0
                              ? SvgPicture.asset('assets/images/flag.svg')
                              : const SizedBox.shrink(),
                          onTap: () {
                            widget.handleOnPressUser?.call(listItem);
                          })
                      : Container();
                },
              );
            }))
          ],
        );
      },
    );
  }
}
