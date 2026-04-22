import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/ui/widgets/message_widgets/group_chat_message_box.dart';
import 'package:spot/ui/widgets/message_widgets/group_message_list.dart';
import 'package:spot/ui/widgets/message_widgets/user_chat_message_box.dart';
import 'package:spot/ui/widgets/message_widgets/message_list.dart';
import 'package:spot/ui/widgets/message_widgets/select_group_msg_header.dart';
import 'package:spot/ui/widgets/message_widgets/select_msg_header.dart';
import 'package:spot/ui/widgets/user_chat_widgets/group_search_header.dart';
import 'package:spot/ui/widgets/user_chat_widgets/search_header.dart';
import 'package:spot/ui/widgets/user_chat_widgets/user_chat_header.dart';
import '../../../widgets/common_widgets/commonWidgets.dart';

class UserChats extends StatefulWidget {
  const UserChats({super.key});

  @override
  State<UserChats> createState() => _UserChatsState();
}

class _UserChatsState extends State<UserChats> {
  late String type;
  Map<String, dynamic> userMessageList = {};
  Map<String, dynamic> groupMessageList = {};
  Map<String, dynamic> currentUser = {};
  TextEditingController searchMessage = TextEditingController();
  TextEditingController sendMessageText = TextEditingController();
  late final ScrollController _scrollController;
  late final ScrollController _groupScrollController;
  bool isFetching = false;
  bool isTyping = false;
  Timer? typingTimer;
  Set<String> loadedMessageIds = {};
  Map<String, double> messageHeights = {};
  bool _isLoadingMore = false;
  bool _hasMore = true;

  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _groupScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await didChangeDependencies();
      _scrollToBottom();
      _groupsScrollToBottom();
    });
    _scrollController.addListener(_onScroll);
    _groupScrollController.addListener(_onGroupScroll);
    _loadMoreUserMessages();
    _loadMoreGroupMessages();
  }

  @override
  @override
  void dispose() {
    _scrollController.dispose();
    _groupScrollController.dispose();
    typingTimer?.cancel();
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    final dataListProvider = context.read<DataListProvider>();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    type = args['type'];
    if (type == 'chat' && dataListProvider.openedChatUserData.isNotEmpty) {
      await getUserMessages();
    } else if (type == 'group' &&
        dataListProvider.openedChatGroupData.isNotEmpty) {
      await getGroupMessages();
    }

    print("Current user $currentUser");
  }

  // ******************** get messages ***********************
  Future<void> getUserMessages() async {
    final dataListProvider = context.read<DataListProvider>();
    final userData = dataListProvider.openedChatUserData;
    await dataListProvider.getUserMessages(userData['_id'], "");

    final userMessage = dataListProvider.userMessages;

    if (userMessage.containsKey('data')) {
      final rawData = userMessage['data'];

      List<dynamic> parsedMessages = [];

      if (rawData is String) {
        try {
          parsedMessages = jsonDecode(rawData);
        } catch (e) {
          // print('Error decoding message list: $e');
        }
      } else if (rawData is List) {
        parsedMessages = rawData;
      }

      if (mounted) {
        setState(() {
          userMessageList = {
            ...userMessage,
            'data': parsedMessages,
          };
        });
      }
      fetchUserMessages(page: 1);
    }
  }

  void fetchUserMessages({required int page}) async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final userMsgs = dataListProvider.userMessages;

      if (userMsgs['data'] != null) {
        if (userMsgs['data'] is String) {
          try {
            dataListProvider.setUserMessageList(jsonDecode(userMsgs['data']));
            // handleUserMsgData(jsonDecode(userMsgs['data']));
          } catch (e) {
            // print('Failed to parse user message data: $e');
            dataListProvider.clearUserMessageList();
          }
        } else if (userMsgs['data'] is List) {
          dataListProvider.setUserMessageList(userMsgs['data']);
        }
      }
      // print("dataaaaaaaaaaaaaaaa ${dataListProvider.groupMessagesList}");
    } catch (error) {
      // print("Error while fetching user messages $error");
    }
  }

  Future<void> getGroupMessages() async {
    final dataListProvider = context.read<DataListProvider>();
    final currentLoginUser = await CommonFunctions.getLoginUser();
    // print("currentLoginUser currentLoginUser");

    final isAdmin = currentLoginUser['iUserId'] ==
            dataListProvider.openedChatGroupData['_id']
        ? 1
        : 0;
    await dataListProvider.getGroupMessages(
        dataListProvider.openedChatGroupData['_id'], isAdmin, "");
    final groupMessage = dataListProvider.groupMessages;
    if (groupMessage.containsKey('data')) {
      final rawData = groupMessage['data'];

      List<dynamic> parsedMessages = [];

      if (rawData is String) {
        try {
          parsedMessages = jsonDecode(rawData);
        } catch (e) {
          // print('Error decoding group message list: $e');
        }
      } else if (rawData is List) {
        parsedMessages = rawData;
      }

      if (mounted) {
        setState(() {
          groupMessageList = {
            ...groupMessage,
            'data': parsedMessages,
          };
        });
        fetchGroupMessages();
      }
    }
  }

  void fetchGroupMessages() async {
    try {
      final dataListProvider = context.read<DataListProvider>();
      final groupMsgs = dataListProvider.groupMessages;

      if (groupMsgs['data'] != null) {
        if (groupMsgs['data'] is String) {
          try {
            dataListProvider.setGroupMessageList(jsonDecode(groupMsgs['data']));
          } catch (e) {
            // print('Failed to parse message data: $e');
            dataListProvider.clearGroupMessageList();
          }
        } else if (groupMsgs['data'] is List) {
          dataListProvider.setGroupMessageList(groupMsgs['data']);
        }
      }

      // print("dataaaaaaaaaaaaaaaa ${dataListProvider.groupMessagesList}");
    } catch (error) {
      // print("Error while fetching group messages $error");
    }
  }

  // ******************* handle search message ********************
  void onChangedSearchMessageValue(String value) {}

  // void handleTypingEvent(Map<String, dynamic> socketEvent) {
  //   final dataListProvider = context.read<DataListProvider>();
  //   final userData = dataListProvider.openedChatUserData;
  //   if (socketEvent['event'] == "MessageTypingStart") {
  //     if (socketEvent['data'] != null && socketEvent['data']['iFromUserId'] == userData['_id'] && currentUser != null && socketEvent['data']['iToUserId'] == currentUser?['iUserId']) {
  //
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         setState(() => isTyping = true);
  //         typingTimer?.cancel();
  //         typingTimer = Timer(const Duration(seconds: 1), () {
  //           if (mounted) setState(() => isTyping = false);
  //         });
  //       });
  //     }
  //   } else if (socketEvent['event'] == "MessageTypingGroupStart") {
  //     final groupId = socketEvent['data']['iToUserId'];
  //     final userName = socketEvent['data']['name'];
  //
  //     if (groupId == dataListProvider.openedChatGroupData['_id']) {
  //       Provider.of<SocketProvider>(context, listen: false).addGroupTypingUser(groupId, userName);
  //
  //       Future.delayed(const Duration(seconds: 5), () {
  //       });
  //     }
  //   }
  // }

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

  void _scrollToBottom({int threshold = 5}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final currentOffset = _scrollController.offset;

      final distanceFromBottom = maxScrollExtent - currentOffset;

      if (distanceFromBottom <= threshold * 80) {
        _scrollController.animateTo(
          maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(maxScrollExtent);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
            _scrollController.position.minScrollExtent + 60 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreUserMessages();
    }
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
  //************************* group chat pagination **************************

  void _searchGroupMessages(String query) {
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

  void _groupsScrollToBottom({int threshold = 5}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_groupScrollController.hasClients) return;

      final maxScrollExtent = _groupScrollController.position.maxScrollExtent;
      final currentOffset = _groupScrollController.offset;

      final distanceFromBottom = maxScrollExtent - currentOffset;

      if (distanceFromBottom <= threshold * 80) {
        _groupScrollController.animateTo(
          maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _groupScrollController.jumpTo(maxScrollExtent);
      }
    });
  }

  void _onGroupScroll() {
    if (_groupScrollController.position.pixels <=
            _groupScrollController.position.minScrollExtent + 60 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreGroupMessages();
    }
  }

  /// workable group pagination
  // Future<void> loadMoreGroupMessages(String groupId) async {
  //   final chatProvider = context.read<ChatProvider>();
  //   final dataProvider = context.read<DataListProvider>();
  //   if (!hasMore || isLoading) return;
  //   isLoading = true;
  //
  //   try {
  //     final String firstMessageId = dataProvider.groupMessagesList.first['id'];
  //
  //     final isAdmin = currentUser['iUserId'] == dataProvider.openedChatGroupData['_id'] ? 1 : 0;
  //
  //     final response = await CommonFunctions.getGroupMessages(groupId, isAdmin, firstMessageId);
  //     if(response['message_user_data'] != null){
  //       dataProvider.addGroupMemberList(response['message_user_data']);
  //     }
  //
  //     dynamic rawData = response['data'];
  //     List<Map<String, dynamic>> parsedMessages = [];
  //
  //     if (rawData is List) {
  //       parsedMessages = List<Map<String, dynamic>>.from(rawData);
  //     } else if (rawData is String) {
  //       try {
  //         final decoded = jsonDecode(rawData);
  //         if (decoded is List) {
  //           parsedMessages = List<Map<String, dynamic>>.from(decoded);
  //         }
  //       } catch (e) {
  //         print("Error decoding response: $e");
  //       }
  //     }
  //
  //     if (parsedMessages.isNotEmpty) {
  //       final scrollOffsetBefore = _groupScrollController.offset;
  //
  //       dataProvider.groupMessagesList.insertAll(0, parsedMessages);
  //
  //       setState(() {
  //         loadedMessageIds.addAll(parsedMessages.map((e) => (e['id'] ?? e['_id']).toString()));
  //         hasMore = parsedMessages.length >= 50;
  //       });
  //
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (_groupScrollController.hasClients) {
  //           _groupScrollController.jumpTo(scrollOffsetBefore + 200.0);
  //         }
  //       });
  //
  //
  //       if (chatProvider.IsGroupSearching && chatProvider.groupSearchController.text.isNotEmpty) {
  //         _searchGroupMessages(chatProvider.groupSearchController.text);
  //       }
  //     } else {
  //       setState(() {
  //         hasMore = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("loadMoreGroupMessages error: $e");
  //   } finally {
  //     isLoading = false;
  //   }
  // }

  Future<void> _loadMoreGroupMessages() async {
    final dataProvider = context.read<DataListProvider>();
    final chatProvider = context.read<ChatProvider>();

    setState(() {
      _isLoadingMore = true;
    });

    chatProvider.shouldScrollToBottom = false;

    try {
      final String firstMessageId = dataProvider.groupMessagesList.isNotEmpty
          ? dataProvider.groupMessagesList.first['id']
          : '';

      final isAdmin =
          currentUser['iUserId'] == dataProvider.openedChatGroupData['_id']
              ? 1
              : 0;

      final provider = context.read<DataListProvider>();
      final groupId = provider.openedChatGroupData['_id'];

      final response = await CommonFunctions.getGroupMessages(
          groupId, isAdmin, firstMessageId);

      List<Map<String, dynamic>> newMessage = [];
      final raw = response?['data'];
      if (raw is List) {
        newMessage = List<Map<String, dynamic>>.from(raw);
      } else if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          newMessage = List<Map<String, dynamic>>.from(decoded);
        }
      }
      if (newMessage.isNotEmpty) {
        setState(() {
          dataProvider.groupMessagesList.insertAll(0, newMessage);
          _hasMore = newMessage.length >= 50;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_groupScrollController.hasClients) {
            final offset = newMessage.length * 60.0;
            _groupScrollController.jumpTo(offset);
          }
        });
        if (chatProvider.isGroupSearching &&
            chatProvider.groupSearchController.text.isNotEmpty) {
          _searchGroupMessages(chatProvider.groupSearchController.text);
        }
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasMore = false;
      });
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      color: AppColorTheme.white,
      child: SafeArea(
        top: true,
        minimum: EdgeInsets.only(top: 45),
        child: WillPopScope(
          onWillPop: _handleBackNavigation,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: AppColorTheme.white,
            appBar: AppBar(
              surfaceTintColor: AppColorTheme.white,
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: AppColorTheme.white,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              automaticallyImplyLeading: false,
              backgroundColor: AppColorTheme.white,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                  MediaQuery.of(context).size.height > 700 ? 2.1.h : 3.8.h,
                ),
                child: Container(
                  margin: const EdgeInsets.only(top: 0),
                  color: AppColorTheme.white,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: Column(
                    children: [
                      Consumer2<ChatProvider, DataListProvider>(
                        builder:
                            (context, chatProvider, dataListProvider, child) {
                          return chatProvider.isGroupSearching
                              ? GroupSearchHeader(
                                searchMessage: chatProvider.groupSearchController,
                                scrollController: _groupScrollController,
                              )
                              : chatProvider.isSearching
                                  ? SearchHeader(
                                    searchMessage: chatProvider.searchController,
                                    scrollController: _scrollController,
                                  )
                                  : chatProvider.msgSelectionMode
                                      ? SelectMsgHeader()
                                      : chatProvider.groupMsgSelectionMode
                                        ? SelectGroupMsgHeader()
                                        : UserChatHeader(
                                          currentUser: currentUser,
                                          subTitle: type == 'chat' ? 'chat' : 'group',
                                          groupMessageList: groupMessageList,
                                          userMessageList: userMessageList,
                                        );
                        },
                      ),
                      Divider(color: AppColorTheme.border, thickness: 1, height: 25, indent: 6, endIndent: 6),
                    ],
                  ),
                ),
              ),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<DataListProvider>(
                    builder: (context, dataListProvider, child) {
                  return Expanded(
                    child: type == 'chat'
                    ? MessageList(scrollController: _scrollController)
                    : GroupMessageList(scrollController: _groupScrollController)
                  );
                }),
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    if (type == 'chat' && chatProvider.showUserTyping) {
                      return const Row(
                        children: [
                          Dot(),
                          SizedBox(width: 5),
                          TypingText("typing..."),
                        ],
                      );
                    } else if (type == 'group' && chatProvider.showGroupTyping) {
                      final dataListProvider = context.read<DataListProvider>();
                      final groupId = dataListProvider.openedChatGroupData['_id'] ?? "";
                      final typingUsers = chatProvider.getTypingUsers(groupId).toList();
                      if (typingUsers.isNotEmpty) {
                        String typingMsg;
                        if (typingUsers.length == 1) {
                          typingMsg = "${typingUsers[0]} is typing...";
                        } else if (typingUsers.length == 2) {
                          typingMsg = "${typingUsers[0]}, ${typingUsers[1]} are typing...";
                        } else {
                          typingMsg = "${typingUsers[0]}, ${typingUsers[1]} +${typingUsers.length - 2} more are typing...";
                        }
                        return Row(
                          children: [
                            const Dot(),
                            const SizedBox(width: 5),
                            TypingText(typingMsg),
                          ],
                        );
                      }
                    }
                    return const SizedBox();
                  },
                ),
                Consumer<DataListProvider>(
                  builder: (context, dataListProvider, child) {
                    final userData = dataListProvider.openedChatUserData;
                    final menu = dataListProvider.groupMessages.isNotEmpty
                      ? dataListProvider.groupMessages['menu']
                      : 0;

                    final showUserInput = userData.containsKey('isStartChat') && userData['isStartChat'] == 1 && userData['eStatus'] != 'n';
                    final showGroupInput = dataListProvider.groupMessages.isNotEmpty && (menu == 0 || menu == 2 || menu == 4) && (menu != 1 || menu != 3);

                    if (type == 'chat' && showUserInput) {
                      return UserChatMessageBox(sendMessageText: sendMessageText, type: type);
                    } else if (type == 'group' && showGroupInput) {
                      return GroupChatMessageBox(
                        sendMessageText: sendMessageText,
                        messageList: groupMessageList,
                        type: type
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
