import 'package:flutter/material.dart';
import 'package:spot/core/utils.dart';

class DataListProvider extends ChangeNotifier {
  List _userChatList = [];
  List _userChatListOriginalData = [];
  List _groupsData = [];
  List _groupsOriginalData = [];
  List _chatsData = [];
  List _chatsOriginalData = [];
  Map<String, dynamic> _singleUserData = {};
  Map<String, dynamic> _loginUserData = {};
  Map<String, dynamic> _userTokenData = {};
  Map<String, dynamic> _userMessages = {};
  Map<String, dynamic> _openedChatUserData = {};
  Map<String, dynamic> _openedChatGroupData = {};
  Map<String, dynamic> _groupInfoData = {};
  Map<String, dynamic> _groupInfoMemberList = {};
  List<dynamic> _userMessagesList = [];
  List<dynamic> _groupMessagesList = [];
  List<dynamic> _groupMemberList = [];
  Map<String, dynamic> _groupMessages = {};
  List<dynamic> _forwardUsers = [];

  List get userChatList => _userChatList;
  List get groupMemberList => _groupMemberList;
  List get userChatListOriginalData => _userChatListOriginalData;
  List get groupsData => _groupsData;
  List get groupsOriginalData => _groupsOriginalData;
  List get chatsData => _chatsData;
  List get chatsOriginalData => _chatsOriginalData;
  // List<dynamic> get forwardUsers => _forwardUsers;
  Map<String, dynamic> get singleUserData => _singleUserData;
  Map<String, dynamic> get loginUserData => _loginUserData;
  Map<String, dynamic> get userMessages => _userMessages;
  Map<String, dynamic> get openedChatUserData => _openedChatUserData;
  Map<String, dynamic> get openedChatGroupData => _openedChatGroupData;
  Map<String, dynamic> get groupInfoData => _groupInfoData;
  Map<String, dynamic> get groupInfoMemberList => _groupInfoMemberList;
  List<dynamic> get userMessagesList => _userMessagesList;
  List<dynamic> get groupMessagesList => _groupMessagesList;
  Map<String, dynamic> get groupMessages => _groupMessages;
  Map<String, dynamic> get userTokenData => _userTokenData;

  List<dynamic> _filteredForwardUsers = [];

  List<dynamic> get forwardUsers => _filteredForwardUsers;

  List<Map<String, dynamic>> _groupUserList = [];
  bool _hasMoreGroupUsers = true;

  List<Map<String, dynamic>> get groupUserList => _groupUserList;

  // *************** get user data *****************
  void getUserData() async {
    final userData = await CommonFunctions.getUserData();
    // (".............userData.............$userData");
    _userTokenData = userData;
    notifyListeners();
  }

  List<Map<String, dynamic>> _userList = []; // Your user list

  List<Map<String, dynamic>> get userList => _userList;

  void setUserList(List<Map<String, dynamic>> users) {
    _userList = users;
    notifyListeners();
  }

  void updateUserMsgFlag(String userId, String msgFlag) {
    for (var user in _userChatList) {
      if (user['iUserId'] == userId) {
        user['msgFlag'] = msgFlag;
        break;
      }
    }
    notifyListeners();
  }

  bool _hasMoreData = true;
  void getUserChatListData({int page = 1, String searchText = ''}) async {
    try {
      // Reset _hasMoreData if it's a new search or first page
      if (page == 1) {
        _hasMoreData = true;
      }

      if (!_hasMoreData) {
        // print("No more data to load.");
        return;
      }

      final response = await CommonFunctions.getUserChatList(
          page: page, searchText: searchText);

      if (response.isNotEmpty) {
        if (page == 1) {
          _userChatList = response;
        } else {
          _userChatList.addAll(response);
        }

        _userChatListOriginalData = _userChatList;
        notifyListeners();
      } else {
        // ✅ Set hasMoreData to false ONLY for pagination (not during search)
        if (searchText.isEmpty) {
          _hasMoreData = false;
        }

        // 👇 Don’t clear existing list unless it's a new search and empty result
        if (page == 1 && searchText.isNotEmpty) {
          _userChatList = [];
          notifyListeners();
        }
      }
    } catch (error) {
      // print("Error while getting user chat list..... $error");
    }
  }

  // ******************* set user chatList *********************
  void setUserChatList(List chatList) {
    _userChatList = chatList;
    notifyListeners();
  }

  // *************** get group list *****************
  void getGroupListData() async {
    try {
      final response = await CommonFunctions.getGroupList();
      if (response.isNotEmpty) {
        final sortedList = CommonFunctions.sortListByTime(response);
        _groupsData = sortedList;
        _groupsOriginalData = sortedList;
        notifyListeners();
      } else {
        _groupsData = [];
        _groupsOriginalData = [];
      }
    } catch (error) {
      // print("error while getting group list..... ${error}");
    }
  }

  // ******************* set group List *********************
  void setGroupList(List list) {
    _groupsData = list;
    // _groupsOriginalData = list;
    notifyListeners();
  }

  // *************** get chat list *****************
  void getChatListData() async {
    try {
      final response = await CommonFunctions.getUserList();
      if (response.isNotEmpty) {
        final sortedList = CommonFunctions.sortListByTime(response);
        _chatsData = sortedList;
        _chatsOriginalData = sortedList;
      } else {
        _chatsData = [];
        _chatsOriginalData = [];
      }
      notifyListeners();
    } catch (error) {
      // print("error while getting user list...._____________. ${error}");
    }
  }

  // ******************* set group List *********************
  void setChatList(List list) {
    _chatsData = list;
    notifyListeners();
  }

  // *************** get user list *****************
  void getSingleUserData(String iUserId) async {
    try {
      final response = await CommonFunctions.getSingleUser(iUserId);
      // print("get single userrrr responseresponseresponseresponseresponse ========> $response");
      _singleUserData = response;
      notifyListeners();
    } catch (error) {
      // print("error while getting single user data..... ${error}");
    }
  }

  // *************** get user list *****************
  void getLoginUserData() async {
    try {
      final response = await CommonFunctions.getLoginUser();
      // print("get Login userrrr responseresponseresponseresponseresponse ========> $response");
      _loginUserData = response;
      notifyListeners();
    } catch (error) {
      // print("error while getting login user data..... ${error}");
    }
  }

  // ****************** get opened chat user data *****************
  void setOpenedChatUserData(Map<String, dynamic> userData) {
    _openedChatUserData = userData;
    notifyListeners();
  }

  // ****************** remove opened chat user data *****************
  void removeOpenedChatUserData() {
    _openedChatUserData.clear();
    notifyListeners();
  }

  // ****************** get opened chat user data *****************
  void setOpenedChatGroupData(Map<String, dynamic> groupData) {
    _openedChatGroupData = groupData;
    notifyListeners();
  }

  // ****************** remove opened chat user data *****************
  void removeOpenedChatGroupData() {
    _openedChatGroupData.clear();
    notifyListeners();
  }

  // ****************** get group info data *****************
  void setGroupInfoData(Map<String, dynamic> groupData) {
    _groupInfoData = groupData;
    notifyListeners();
  }

  // ****************** remove group info data *****************
  void removeGroupInfoData() {
    _groupInfoData.clear();
    notifyListeners();
  }

  // ****************** get group info member list *****************
  void setGroupInfoMemberList(Map<String, dynamic> memberList) {
    _groupInfoMemberList = memberList;
    notifyListeners();
  }

  // ****************** remove group info member list *****************
  void removeGroupInfoMemberList() {
    _groupInfoMemberList.clear();
    notifyListeners();
  }

  // *************** get user messages *****************
  Future<void> getUserMessages(String iUserId, String firstMessageId) async {
    try {
      final response =
          await CommonFunctions.getUserMessages(iUserId, firstMessageId);
      // debugPrint("getUserMessages responseresponseresponseresponseresponse ========> $response", wrapWidth: 1024);
      if (response is List && response.isEmpty) {
        return;
      }
      if (response != null) {
        _userMessages = response;
        notifyListeners();
      }
    } catch (error) {
      // print("error while getting user list..... ${error}");
    }
  }

  bool _isLoading = false;
  bool _hasMore = true;

  bool get isLoading => _isLoading;

  Future<void> loadInitialMessages(String iUserId) async {
    _userMessagesList.clear();
    _hasMore = true;
    await fetchMoreMessages(iUserId);
  }

  Future<void> fetchMoreMessages(String iUserId) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    final firstId =
        _userMessagesList.isNotEmpty ? _userMessagesList.first.id : null;

    final newMessages = await CommonFunctions.getUserMessages(iUserId, firstId);

    if (newMessages.isEmpty) {
      _hasMore = false;
    } else {
      _userMessagesList.insertAll(0, newMessages);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ******************* set user message List *********************
  void setUserMessageList(List<dynamic> list) {
    _userMessagesList = list;
    notifyListeners();
  }

  void clearUserMessageList() {
    _userMessagesList.clear();
    notifyListeners();
  }

  // *************** get user messages *****************
  Future<void> getGroupMessages(
      String iGroupId, isAdmin, firstMessageId) async {
    try {
      final response = await CommonFunctions.getGroupMessages(
          iGroupId, isAdmin, firstMessageId);
      _groupMessages = response;

      if (response['message_user_data'].isNotEmpty &&
          response['message_user_data'] != null) {
        _groupMemberList = response['message_user_data'];
      }
      notifyListeners();
    } catch (error) {
      // print("error while getting group messages..... ${error}");
    }
  }

  // ******************** add group member list ********************
  void addGroupMemberList(List<dynamic> memberList) {
    if (_groupMemberList.isNotEmpty) {
      final existingIds =
          _groupMemberList.map((user) => user['iUserId']).toSet();
      final newUsers = memberList
          .where((user) => !existingIds.contains(user['iUserId']))
          .toList();

      // Add them to the original list
      _groupMemberList.addAll(newUsers);
    } else {
      _groupMemberList = memberList;
    }
    notifyListeners();
  }

  // ******************* set group message all data  *********************
  void setGroupMessageAllData(Map<String, dynamic> groupData) {
    _groupMessages = groupData;
    notifyListeners();
  }

  void clearGroupMessageAllData() {
    _groupMessages.clear();
    notifyListeners();
  }

  // ******************* set user message List *********************
  void setGroupMessageList(List<dynamic> list) {
    _groupMessagesList = list;
    notifyListeners();
  }

  void clearGroupMessageList() {
    _groupMessagesList.clear();
    _groupMessages.clear();
    notifyListeners();
  }

  void updateGroupMessageById(
      String messageId, Map<String, dynamic> updatedData) {
    final index =
        _groupMessagesList.indexWhere((msg) => msg['id'] == messageId);
    if (index != -1) {
      _groupMessagesList[index] = {
        ..._groupMessagesList[index],
        ...updatedData,
      };
      notifyListeners();
    }
  }

  // *************** get forward user list *****************

  Future<void> getForwardUsers({String? searchQuery}) async {
    try {
      final mergeArrData = [];
      final response =
          await CommonFunctions.getForwardUserList(searchQuery: searchQuery);
      if (response is List && response.isEmpty) return;

      if (response != null) {
        // print("REsponseeeeeeeeeeeeeeeeeee ${response['users']}");
        if (response['users'].isNotEmpty) {
          mergeArrData.addAll(response['users']);
        }
        if (response['groups'].isNotEmpty) {
          mergeArrData.addAll(response['groups']);
          // debugPrint("REsponse group ${mergeArrData.length}", wrapWidth: 1024);
        }
        _forwardUsers = mergeArrData;
        _filteredForwardUsers = mergeArrData;
        notifyListeners();
      }
    } catch (error) {
      // print("Error while getting forward user list:: $error");
    }
  }

  void setForwardUsersList(List<dynamic> filteredList) {
    _filteredForwardUsers = filteredList;
    notifyListeners();
  }

  void resetForwardUserFilter() {
    _filteredForwardUsers = _forwardUsers;
    notifyListeners();
  }

  List<dynamic> get allForwardUsers => _forwardUsers;

  Future<void> searchGroupUsers(
      String groupId, String searchText, int page) async {
    try {
      if (page == 1) {
        _hasMoreGroupUsers = true;
      }

      if (!_hasMoreGroupUsers) return;

      final response =
          await CommonFunctions.getGroupUserList(groupId, searchText, page);
      if (response == null || response['data'] == null) return;

      final users = List<Map<String, dynamic>>.from(response['data']);

      if (page == 1) {
        _groupUserList = users;
      } else {
        _groupUserList.addAll(users);
      }

      // If response is empty, stop further loading
      if (users.isEmpty) {
        _hasMoreGroupUsers = false;
      }

      notifyListeners();
    } catch (error) {
      // print("Error in searchGroupUsers: $error");
    }
  }
}
