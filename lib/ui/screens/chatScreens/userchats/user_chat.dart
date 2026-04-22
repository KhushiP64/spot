import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/responsive_fonts.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/message_widgets/chat_message_header.dart';
import 'package:spot/ui/widgets/message_widgets/message_list.dart';
import 'package:spot/ui/widgets/message_widgets/select_msg_header.dart';
import 'package:spot/ui/widgets/message_widgets/user_chat_message_box.dart';
import 'package:spot/ui/widgets/message_widgets/user_message_search_header.dart';

class UserChat extends StatefulWidget {
  const UserChat({super.key});

  @override
  State<UserChat> createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  late Map<String, dynamic> currentUser;
  TextEditingController sendMessageText = TextEditingController();
  late final ScrollController _scrollController;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
    _scrollController = ScrollController();
    _loadMoreUserMessages();
  }

  // ******************** get single user data *******************
  Future<void> getCurrentUserData() async {
    final user = await CommonFunctions.getLoginUser();
    if (!mounted) return;
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _loadMoreUserMessages() async {
    final dataProvider = context.read<DataListProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    chatProvider.shouldScrollToBottom = false;

    final String lastMsgId = dataProvider.userMessagesList.isNotEmpty
        ? dataProvider.userMessagesList.first['id']
        : '';
    final userId = dataProvider.openedChatUserData['_id'] ?? '';

    final response = await CommonFunctions.getUserMessages(userId, lastMsgId);

    List<Map<String, dynamic>> newMessages = [];

    if (response != null && response['data'] != null) {
      final raw = response['data'];
      if (raw is List) {
        newMessages = List<Map<String, dynamic>>.from(raw);
      } else if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            newMessages = List<Map<String, dynamic>>.from(decoded);
          }
        } catch (e) {
          debugPrint('Decoding error: $e');
        }
      }
    }

    if (newMessages.isNotEmpty) {
      setState(() {
        dataProvider.userMessagesList.insertAll(0, newMessages);
        _hasMore = newMessages.length >= 50;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final offset = newMessages.length * 60.0;
          _scrollController.jumpTo(offset);
        }
      });

      if (chatProvider.isSearching &&
          chatProvider.searchController.text.isNotEmpty) {
        _searchMessages(chatProvider.searchController.text);
      }
    } else {
      setState(() => _hasMore = false);
    }

    setState(() => _isLoadingMore = false);
  }

  //************************* user chat pagination ****************************
  bool _showSuffixIcon = false;
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
        if (messages[i]["message"]
            .toLowerCase()
            .contains(query.toLowerCase())) {
          // print("messagesssss in loopp ${messages[i]["message"]}");
          chatProvider.matchedIndexes.add(i);
        }
      }
    }
    chatProvider.currentMatchIndex =
        chatProvider.matchedIndexes.isNotEmpty ? 0 : -1;
  }

  Future<bool> _handleBackNavigation() async {
    final chatProvider = context.read<ChatProvider>();
    final dataListProvider = context.read<DataListProvider>();

    if (chatProvider.msgSelectionMode) {
      chatProvider.setMsgSelectionMode(false);
      chatProvider.setUserEditingStop(false);
      chatProvider.setUserReplyingStop(false);
      chatProvider.setFileUploadingStop(false);
      // return false;
    }
    if (chatProvider.groupMsgSelectionMode) {
      chatProvider.setGroupMsgSelectionMode(false);
      chatProvider.setGroupEditingStop(false);
      chatProvider.setGroupReplyingStop(false);
      chatProvider.setFileUploadingStop(false);
      // return false;
    }
    if (chatProvider.isSearching) {
      chatProvider.setIsSearching(false);
      return false;
    }
    chatProvider.clearMsgSelectionIndexes();
    dataListProvider.clearUserMessageList();
    dataListProvider.clearGroupMessageList();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColorTheme.white,
        body: SafeArea(
          child: Consumer<ChatProvider>(builder: (context, chatProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                chatProvider.isSearching
                    ? UserMessageSearchHeader(searchMessage: chatProvider.searchController, scrollController: _scrollController,)
                    : chatProvider.msgSelectionMode
                    ? SelectMsgHeader()
                    : ChatMessageHeader(currentUser: args['currentUser'], subTitle: "chat",),
                CommonWidgets.divider(paddingHorizontal: 0, paddingTop: 0),

                /// Chats
                Consumer<DataListProvider>(
                    builder: (context, dataListProvider, child) {
                  return Expanded(
                    child: MessageList(scrollController: _scrollController)
                  );
                }),

                /// typing.... flag
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    if (chatProvider.showUserTyping) {
                      return const Row(
                        children: [
                          Dot(),
                          SizedBox(width: 5),
                          TypingText("typing..."),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),

                /// message input box
                Consumer<DataListProvider>(
                  builder: (context, dataListProvider, child) {
                    final userData = dataListProvider.openedChatUserData;

                    final showUserInput = userData.containsKey('isStartChat') && userData['isStartChat'] == 1 && userData['eStatus'] != 'n';

                    if (showUserInput) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: UserChatMessageBox(sendMessageText: sendMessageText, type: "chat"),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
