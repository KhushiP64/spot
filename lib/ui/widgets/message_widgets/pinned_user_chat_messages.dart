import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/responsive_fonts.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/message_widgets/pinned_user_chat_messages_header.dart';
import 'package:spot/ui/widgets/message_widgets/user_message_search_header.dart';

class PinnedUserChatMessages extends StatefulWidget {
  const PinnedUserChatMessages({super.key});

  @override
  State<PinnedUserChatMessages> createState() => _PinnedUserChatMessagesState();
}

class _PinnedUserChatMessagesState extends State<PinnedUserChatMessages> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    // ***************** handle on click search message *******************
    void handleSearchMessageClick() {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.setIsUserPinChatSearching(true);
    }

    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          color: AppColorTheme.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chatProvider.isUserPinChatSearching
                    ? UserMessageSearchHeader(
                        searchMessage: chatProvider.searchController,
                        scrollController: _scrollController,
                        topPadding: 8,
                      )
                    : PinnedUserChatMessagesHeader(
                        handleSearchMessageClick: handleSearchMessageClick,
                      ),
                CommonWidgets.divider(paddingHorizontal: 0),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22.w),
                        child: CommonWidgets.noMessageFoundText(),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
