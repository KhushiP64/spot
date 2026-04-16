import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:spot/providers/chat_provider.dart';
import '../../../core/responsive_fonts.dart';
import '../../../providers/data_list_provider.dart';

class GroupSearchHeader extends StatefulWidget {
  final TextEditingController searchMessage;
  final ScrollController scrollController;
  final Function(List<dynamic>)? onResults;
  final FocusNode? focusNode;

  const GroupSearchHeader({
    super.key,
    required this.searchMessage,
    required this.scrollController,
    this.onResults,
    this.focusNode,
  });

  @override
  State<GroupSearchHeader> createState() => _GroupSearchHeaderState();
}

class _GroupSearchHeaderState extends State<GroupSearchHeader> {
  bool _showSuffixIcon = false;

  void _searchMessages(String query) {
    final dataListProvider = context.read<DataListProvider>();
    final chatProvider = context.read<ChatProvider>();
    final messages = dataListProvider.groupMessagesList;
    final isNotEmpty = chatProvider.groupSearchController.text.isNotEmpty;
    if (isNotEmpty != _showSuffixIcon) {
      setState(() {
        _showSuffixIcon = isNotEmpty;
      });
    }
    // print("searchmessages: $messages");
    chatProvider.matchedGroupIndexes.clear();
    chatProvider.currentGroupMatchIndex = 0;

    if (query.isNotEmpty) {
      for (int i = 0; i < messages.length; i++) {
        if (messages[i]["message"]
            .toLowerCase()
            .contains(query.toLowerCase())) {
          // print("messagesssss in loopp ${messages[i]["message"]}");
          chatProvider.matchedGroupIndexes.add(i);
        }
      }
    }
    chatProvider.currentGroupMatchIndex =
        chatProvider.matchedGroupIndexes.isNotEmpty ? 0 : -1;
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
    if (chatProvider.matchedGroupIndexes.isNotEmpty) {
      chatProvider.currentGroupMatchIndex =
          (chatProvider.currentGroupMatchIndex + 1) %
              chatProvider.matchedGroupIndexes.length;
      _scrollToMessage(chatProvider
          .matchedGroupIndexes[chatProvider.currentGroupMatchIndex]);
      setState(() {});
    }
  }

  void _prevMatch() {
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.matchedGroupIndexes.isNotEmpty) {
      chatProvider.currentGroupMatchIndex =
          (chatProvider.currentGroupMatchIndex -
                  1 +
                  chatProvider.matchedGroupIndexes.length) %
              chatProvider.matchedGroupIndexes.length;
      _scrollToMessage(chatProvider
          .matchedGroupIndexes[chatProvider.currentGroupMatchIndex]);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return SizedBox(
          height: 6.5.h,
          child: Row(
            children: [
              Expanded(
                child: FractionallySizedBox(
                  widthFactor:
                      MediaQuery.of(context).size.width > 600 ? 0.95 : 0.95,
                  child: Container(
                    height: 5.2.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        const BoxShadow(
                            color: Color.fromRGBO(10, 41, 55, 0.16)),
                        BoxShadow(
                          color: const Color(0xffEEF2F5).withOpacity(0.6),
                          offset: const Offset(0, 2),
                          blurRadius: 1.0,
                        ),
                      ],
                    ),
                    child: Center(child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        return TextField(
                          controller: chatProvider.groupSearchController,
                          focusNode: widget.focusNode,
                          cursorColor: AppColorTheme.black,
                          cursorWidth: 0.9,
                          textAlignVertical: TextAlignVertical.center,
                          style: ResponsiveFontStyles.dmSans15Regular(context)
                              .copyWith(color: AppColorTheme.inputTitle),
                          onChanged: _searchMessages,
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
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (chatProvider
                                      .matchedGroupIndexes.isNotEmpty) ...[
                                    Text(
                                      "${(chatProvider.currentGroupMatchIndex >= 0 ? chatProvider.currentGroupMatchIndex + 1 : 0)}/${chatProvider.matchedGroupIndexes.length}",
                                      style: ResponsiveFontStyles
                                              .dmSans15Regular(context)
                                          .copyWith(
                                              color: AppColorTheme.inputTitle),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    InkWell(
                                        onTap: _prevMatch,
                                        child: const Icon(
                                          Icons.keyboard_arrow_up_rounded,
                                          size: 28,
                                          color: AppColorTheme.dark66,
                                        )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    InkWell(
                                        onTap: _nextMatch,
                                        child: const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 28,
                                            color: AppColorTheme.dark66)),
                                  ]
                                ],
                              ),
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        );
                      },
                    )),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: InkWell(
                  onTap: () {
                    chatProvider.clearGroupSearch();
                    chatProvider.groupSearchController.clear();
                    chatProvider.setIsGroupSearching(false);
                  },
                  child: const Icon(
                    FeatherIcons.x,
                    color: AppColorTheme.dark66,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
