import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/app_sizes.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/ui/widgets/chat_list_widgets/chat_list_item.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';
import 'package:spot/ui/widgets/common_widgets/custom_search_bar.dart';

class ChatsWidget extends StatefulWidget {
  const ChatsWidget({super.key});

  @override
  State<ChatsWidget> createState() => ChatsWidgetState();
}

class ChatsWidgetState extends State<ChatsWidget> {
  TextEditingController searchValue = TextEditingController();

  // ************** handle search user to chat ****************
  void onChangedSearchValue(value) async {
    final dataListProvider = context.read<DataListProvider>();
    final searchText = value.trim().toLowerCase();

    List filterData = dataListProvider.chatsOriginalData.where((item) {
      return item['vFullName'].toString().toLowerCase().contains(searchText);
    }).toList();

    if (searchText.isEmpty) {
      dataListProvider.setChatList(dataListProvider.chatsOriginalData);
    } else {
      dataListProvider.setChatList(filterData);
    }
  }

  //  ********************* clear search value *************************
  void clearSearch() {
    searchValue.clear();
    onChangedSearchValue('');
  }

  // ************** handle on press user ****************
  Future<void> handleOnPressUser(Map<String, dynamic> userData) async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final response = await CommonFunctions.getSingleUser(userData["iUserId"]);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.horizontalAppPadding),
      child: Column(
        children: [
          CustomSearchBar(
              margin: EdgeInsets.only(
                  top: AppSizes.horizontalAppPadding, bottom: 6.h),
              searchValue: searchValue,
              onChangedSearchValue: (value) {
                onChangedSearchValue(value);
              }),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Consumer<DataListProvider>(
                  builder: (context, dataListProvider, child) {
                final listData = dataListProvider.chatsData;
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: listData.length,
                  itemBuilder: (context, index) {
                    if (index >= listData.length) return const SizedBox();
                    final listItem = listData[index];
                    final userId = listItem['iUserId'].toString();
                    // if (!_msgFlagVisibleMap.containsKey(userId)) {checkFlag(userId);}
                    final Color statusColor = listItem["iStatus"] == 0
                        ? AppColorTheme.danger
                        : AppColorTheme.success;

                    return listItem != null
                        ? ChatListItem(
                            verticalPadding: 6,
                            vProfilePic: listItem['vProfilePic'] ?? "",
                            statusColor: statusColor,
                            // showMsgFlagIcon: true,
                            listTitle: listItem['vFullName'] ?? "",
                            listSubTitle:
                                listItem['iStatus'] == 1 ? 'Online' : 'Offline',
                            handleOnPressItem: () {
                              handleOnPressUser?.call(listItem);
                            },
                          )
                        : const SizedBox();
                  },
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
