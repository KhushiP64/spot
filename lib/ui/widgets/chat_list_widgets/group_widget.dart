import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/app_sizes.dart';
import 'package:spot/core/responsive_fonts.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/ui/widgets/chat_list_widgets/chat_list_item.dart';
import 'package:spot/ui/widgets/common_widgets/custom_search_bar.dart';

class GroupWidget extends StatefulWidget {
  final Function(dynamic)? handleOnPressGroup;
  const GroupWidget({super.key, required this.handleOnPressGroup});

  @override
  State<GroupWidget> createState() => GroupWidgetState();
}

class GroupWidgetState extends State<GroupWidget> {
  TextEditingController searchValue = TextEditingController();

  // ************** handle search user to chat ****************
  void onChangedSearchValue(value) async {
    final dataListProvider = context.read<DataListProvider>();
    final searchText = value.trim().toLowerCase();

    List filterData = dataListProvider.groupsOriginalData.where((item) {
      return item['vGroupName'].toString().toLowerCase().contains(searchText);
    }).toList();

    if (searchText.isEmpty) {
      dataListProvider.setGroupList(dataListProvider.groupsOriginalData);
    } else {
      dataListProvider.setGroupList(filterData);
    }
  }

  //  ********************* clear search value *************************
  void clearSearch() {
    searchValue.clear();
    onChangedSearchValue('');
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
                final listData = dataListProvider.groupsData;
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: listData.length,
                  itemBuilder: (context, index) {
                    if (index >= listData.length) return const SizedBox();
                    final listItem = listData[index];
                    final userId = listItem['iUserId'].toString();
                    // if (!_msgFlagVisibleMap.containsKey(userId)) {checkFlag(userId);}

                    return listItem != null
                        ? ChatListItem(
                            borderRadius: 5.r,
                            vProfilePic: listItem['vGroupImage'] ?? "",
                            listTitle: listItem['vGroupName'] ?? "",
                            showStatusColor: false,
                            statusColor: AppColorTheme.transparent,
                            listSubTitle:
                                "${listItem['grpMemberCount']} ${listItem['grpMemberCount'] == 1 ? 'Member' : 'Members'}",
                            handleOnPressItem: () {},
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
