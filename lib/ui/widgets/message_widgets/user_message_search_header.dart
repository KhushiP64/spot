import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/providers/chat_provider.dart';
import '../../../core/themes.dart';
import '../../../providers/data_list_provider.dart';

class UserMessageSearchHeader extends StatefulWidget {
  final TextEditingController searchMessage;
  final ScrollController scrollController;
  final Function(List<dynamic>)? onResults;
  final double topPadding;
  final FocusNode? focusNode;

  const UserMessageSearchHeader({
    super.key,
    required this.searchMessage,
    required this.scrollController,
    this.topPadding = 14,
    this.onResults,
    this.focusNode,
  });

  @override
  State<UserMessageSearchHeader> createState() => _UserMessageSearchHeaderState();
}

class _UserMessageSearchHeaderState extends State<UserMessageSearchHeader> {
  bool _showSuffixIcon = false;
  bool hasMore = true;
  bool upArrowClicked = false;
  bool downArrowClicked = false;

  void _searchMessages(String query) {
    final dataListProvider = context.read<DataListProvider>();
    final chatProvider = context.read<ChatProvider>();
    final messages = dataListProvider.userMessagesList;
    final isNotEmpty = chatProvider.searchController.text.isNotEmpty;
    if (isNotEmpty != _showSuffixIcon) {
      setState(() {
        _showSuffixIcon = isNotEmpty;
      });
    }
    // print("searchmessages: $messages");
    chatProvider.matchedIndexes.clear();
    chatProvider.currentMatchIndex = 0;

    if (query.isNotEmpty) {
      for (int i = 0; i < messages.length; i++) {
        if (messages[i]["message"].toLowerCase().contains(query.toLowerCase())) {
          // print("messagesssss in loopp ${messages[i]["message"]}");
          chatProvider.matchedIndexes.add(i);
        }
      }
    }
    chatProvider.currentMatchIndex = chatProvider.matchedIndexes.isNotEmpty ? 0 : -1;
  }

  void _scrollToMessage(int index) {
    // final chatProvider = context.read<ChatProvider>();
    if (widget.scrollController.hasClients) {
      final position = index * 70.0;
      widget.scrollController.jumpTo(position);
    }
  }

  void _nextMatch() {
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.matchedIndexes.isNotEmpty) {
      chatProvider.currentMatchIndex = (chatProvider.currentMatchIndex + 1) % chatProvider.matchedIndexes.length;
      _scrollToMessage(chatProvider.matchedIndexes[chatProvider.currentMatchIndex]);
      upArrowClicked = false;
      downArrowClicked = true;
      setState(() {});
    }
  }

  void _prevMatch() {
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.matchedIndexes.isNotEmpty) {
      chatProvider.currentMatchIndex = (chatProvider.currentMatchIndex - 1 + chatProvider.matchedIndexes.length) % chatProvider.matchedIndexes.length;
      _scrollToMessage(chatProvider.matchedIndexes[chatProvider.currentMatchIndex]);
      downArrowClicked = false;
      upArrowClicked = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      return Container(
        margin: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h, top: widget.topPadding.h),
        child: Row(
          children: [
            /// search bar
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(10, 41, 55, 0.03),
                  borderRadius: BorderRadius.all(Radius.circular(55.r)),
                  border: Border(top: BorderSide(color: Color.fromRGBO(10, 41, 55, 0.15), width: 1)),
                  boxShadow: [
                    // BoxShadow(color: Color.fromRGBO(10, 41, 55, 0.12),),
                    BoxShadow(
                      color: Color.fromRGBO(10, 41, 55, 0.03),
                      offset: Offset(0, 1),
                      spreadRadius: 0.0,
                      blurRadius: 0.1,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    /// search input
                    Expanded(
                      child: TextField(
                        style: AppFontStyles.dmSansRegular.copyWith(color: AppColorTheme.dark66, fontSize: 14.sp),
                        controller: chatProvider.searchController,
                        cursorColor: AppColorTheme.black,
                        onChanged: _searchMessages,
                        cursorWidth: 0.9.w,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          isDense: true,
                          prefixIconConstraints:
                          BoxConstraints(minWidth: 37.w, minHeight: 37.h),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(top: 8.5.w, bottom: 8.5.w, left: 8.5.w),
                            child: SvgPicture.asset(AppMedia.search, color: AppColorTheme.black40),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 1.5.h, vertical: 0),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),

                    /// searches count
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.5.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (chatProvider.matchedIndexes.isNotEmpty) ...[
                            Text(
                              "${(chatProvider.currentMatchIndex >= 0 ? chatProvider.currentMatchIndex + 1 : 0)} / ${chatProvider.matchedIndexes.length}",
                              style: AppFontStyles.dmSansRegular.copyWith(color: AppColorTheme.inputTitle),
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: GestureDetector(
                                  onTap: _prevMatch,
                                  child: SvgPicture.asset(
                                    AppMedia.upArrow,
                                    height: 16.h,
                                    width: 16.w,
                                    color: upArrowClicked ? AppColorTheme.dark66 : AppColorTheme.muted,
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: GestureDetector(
                                  onTap: _nextMatch,
                                  child: SvgPicture.asset(
                                    AppMedia.downArrow,
                                    height: 16.h,
                                    width: 16.w,
                                    color: downArrowClicked ? AppColorTheme.dark66 : AppColorTheme.muted,
                                  )
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// close icon
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: InkWell(
                onTap: () {
                  chatProvider.clearSearch();
                  chatProvider.searchController.clear();
                  chatProvider.setIsSearching(false);
                  chatProvider.clearUserPinChatSearching();
                  chatProvider.clearGroupPinChatSearching();
                },
                child: SvgPicture.asset(AppMedia.closeFormatter, height: 20.h),
              ),
            ),
          ],
        ),
      );
    });
    // return Consumer<ChatProvider>(
    //   builder: (context, chatProvider, child) {
    //     return SizedBox(
    //       height: 6.3.h,
    //       child: Row(
    //         children: [
    //           Expanded(
    //             child: FractionallySizedBox(
    //               widthFactor: MediaQuery.of(context).size.width > 600 ? 0.95 : 0.95,
    //               child: Container(
    //                 height: 5.2.h,
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(20),
    //                   boxShadow: [
    //                     const BoxShadow(color: Color.fromRGBO(10, 41, 55, 0.16)),
    //                     BoxShadow(color: const Color(0xffEEF2F5).withOpacity(0.6), offset: const Offset(0, 2), blurRadius: 1.0,),
    //                   ],
    //                 ),
    //                 child: Center(
    //                     child:
    //                     Consumer<ChatProvider>(
    //                       builder: (context, chatProvider, child) {
    //                         return TextField(
    //                           controller: chatProvider.searchController,
    //                           focusNode: widget.focusNode,
    //                           cursorColor: AppColorTheme.black,
    //                           cursorWidth: 0.9,
    //                           textAlignVertical: TextAlignVertical.center,
    //                           style: AppFontStyles.dmSansRegular.copyWith(color: AppColorTheme.inputTitle),
    //                           onChanged: _searchMessages,
    //                           decoration: InputDecoration(
    //                             isCollapsed: true,
    //                             prefixIcon: Padding(padding: const EdgeInsets.all(8),
    //                               child: SvgPicture.asset('assets/icons/search.svg', height: 18, width: 18, color: AppColorTheme.dark48,),
    //                             ),
    //                             suffixIcon: Padding(padding: const EdgeInsets.only(right: 10),
    //                               child: Row(
    //                                 mainAxisSize: MainAxisSize.min,
    //                                 children: [
    //                                   if (chatProvider.matchedIndexes.isNotEmpty) ...[
    //                                     Text("${(chatProvider.currentMatchIndex >= 0 ? chatProvider.currentMatchIndex + 1 : 0)}/${chatProvider.matchedIndexes.length}", style: AppFontStyles.dmSansRegular.copyWith(color: AppColorTheme.inputTitle),),
    //                                     SizedBox(width: 5,),
    //                                     InkWell(onTap: _prevMatch, child: const Icon(Icons.keyboard_arrow_up_rounded,size: 28,color: AppColorTheme.dark66,)),
    //                                     SizedBox(width: 5,),
    //                                     InkWell(onTap: _nextMatch, child: const Icon(Icons.keyboard_arrow_down_rounded,size: 28,color: AppColorTheme.dark66)),
    //                                   ]
    //                                 ],
    //                               ),
    //                             ),
    //                             border: InputBorder.none,
    //                             filled: true,
    //                             fillColor: Colors.transparent,
    //                           ),
    //                         );
    //                       },
    //                     )
    //
    //                 ),
    //               ),
    //             ),
    //           ),
    //           const SizedBox(width: 2),
    //           Padding(
    //             padding: const EdgeInsets.only(right: 2),
    //             child: InkWell(
    //               onTap: () {
    //                 chatProvider.clearSearch();
    //                 chatProvider.searchController.clear();
    //                 chatProvider.setIsSearching(false);
    //               },
    //               child: const Icon(FeatherIcons.x, color: AppColorTheme.dark66, size: 26,),
    //             ),
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );
  }
}
