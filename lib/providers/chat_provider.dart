import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  bool _isGroupChatOpen = false;
  bool _isUserChatOpen = false;

  int _activeTab = 0;
  bool _showTabUserDotIndication = false;
  bool _showTabGroupDotIndication = false;

  bool _showUserTyping = false;
  bool _showGroupTyping = false;

  bool _isShowFormatter = false;
  bool _msgSelectionMode = false;
  bool _groupMsgSelectionMode = false;

  bool _isShowEditIcon = false;
  bool _isShowDeleteIcon = false;
  bool _isShowDownloadIcon = false;
  bool _isShowReplyIcon = false;

  bool _isShowEditGroupIcon = false;
  bool _isShowDeleteGroupIcon = false;
  bool _isShowDownloadGroupIcon = false;
  bool _isShowReplyGroupIcon = false;

  bool shouldScrollToBottom = true;

  bool _isEmojiOptionList = false;
  bool _isUserPinChatSearching = false;
  bool _isGroupPinChatSearching = false;

  List<dynamic> _selectedMsgs = [];
  List<dynamic> _selectedGroupMsgs = [];
  final Map<String, dynamic> _groupMessages = {};

  Map<String, dynamic> _newSentMessage = {};
  Map<String, dynamic> _selectedImage = {};

  int get activeTab => _activeTab;
  bool get showTabUserDotIndication => _showTabUserDotIndication;
  bool get showTabGroupDotIndication => _showTabGroupDotIndication;

  bool get isGroupChatOpen => _isGroupChatOpen;
  bool get isUserChatOpen => _isUserChatOpen;

  bool get showUserTyping => _showUserTyping;
  bool get showGroupTyping => _showGroupTyping;

  bool get isUserPinChatSearching => _isUserPinChatSearching;
  bool get isGroupPinChatSearching => _isGroupPinChatSearching;

  // bool get isSearching => _isSearching;
  // bool get isSearchingGroup => _isSearchingGroup;

  bool get isShowFormatter => _isShowFormatter;
  bool get msgSelectionMode => _msgSelectionMode;
  bool get groupMsgSelectionMode => _groupMsgSelectionMode;

  bool get isShowEditIcon => _isShowEditIcon;
  bool get isShowDeleteIcon => _isShowDeleteIcon;

  bool get isShowDownloadIcon => _isShowDownloadIcon;
  bool get isShowReplyIcon => _isShowReplyIcon;

  bool get isShowEditGroupIcon => _isShowEditGroupIcon;
  bool get isShowDeleteGroupIcon => _isShowDeleteGroupIcon;
  bool get isShowDownloadGroupIcon => _isShowDownloadGroupIcon;
  bool get isShowReplyGroupIcon => _isShowReplyGroupIcon;
  Map<String, dynamic> get groupMessages => _groupMessages;

  bool get isEmojiOptionList => _isEmojiOptionList;
  List<dynamic> get selectedMsgs => _selectedMsgs;
  List<dynamic> get selectedGroupMsgs => _selectedGroupMsgs;

  Map<String, dynamic> get newSentMessage => _newSentMessage;
  Map<String, dynamic> get selectedImage => _selectedImage;
  List<String> _groupMembersList = [];
  List<String> get groupMembersList => _groupMembersList;

  void setGroupMembersList(List<String> ids) {
    _groupMembersList = ids;
    notifyListeners();
  }

  List<dynamic> _messages = [];
  List<dynamic> get messages => _messages;

  set messages(List<dynamic> newMessages) {
    _messages = newMessages;
    notifyListeners();
  }

  // *************** start & stop Editing user chat*******************

  bool isUserReplying = false;
  bool isImage = false;
  String userReplyText = '';
  bool userReplyHasFile = false;
  String userReplyFileThumb = '';
  String userReplyFileName = '';
  String? userReplySenderId;
  String? userReplySenderName;

  // editing message
  String? editingMessageId;

  bool isUserEditing = false;
  String userEditingText = '';

  // ***************** inactive tab new message dot indication ****************
  void setActiveTab(int tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setShowTabUserDotIndication(bool isDot) {
    _showTabUserDotIndication = isDot;
    notifyListeners();
  }

  void setShowTabGroupDotIndication(bool isDot) {
    _showTabGroupDotIndication = isDot;
    notifyListeners();
  }

  void startUserChatEditing() {
    if (selectedMsgs.isNotEmpty) {
      final selectedMsg = selectedMsgs.first;
      if (selectedMsg is Map<String, dynamic>) {
        final messageContent = selectedMsg['message'];
        // print("Selected message Content: $messageContent");
        userEditingText = messageContent?.toString() ?? '';
        editingMessageId = selectedMsg['id'];
        // print("selected Editing message id: $editingMessageId");
      } else {
        userEditingText = '';
      }
      isUserEditing = true;
      notifyListeners();
    }
  }

  void stopUserChatEditing() {
    isUserEditing = false;
    userEditingText = '';
    editingMessageId = null;
    notifyListeners();
  }

  void startUserChatReplying() {
    if (selectedMsgs.isNotEmpty) {
      final selectedMsg = selectedMsgs.first;
      if (selectedMsg is Map<String, dynamic>) {
        userReplyText = selectedMsg['message']?.toString() ?? '';
        userReplyHasFile = (selectedMsg['vFiles'] ?? '').toString().isNotEmpty;
        userReplyFileThumb = selectedMsg['vFilesThumb']?.toString() ?? '';
        userReplyFileName = selectedMsg['isOriginalName']?.toString() ?? '';
      } else {
        userReplyText = '';
        userReplyHasFile = false;
        userReplyFileThumb = '';
        userReplyFileName = '';
      }
      isUserReplying = true;
      notifyListeners();
    }
  }

  void startUserChatImageReply({
    required String replyText,
    required String replyFileThumb,
    required String replyFileName,
    String? senderId,
    String? senderName,
    bool hasFile = true,
  }) {
    userReplyText = replyText;
    userReplyFileThumb = replyFileThumb;
    userReplyFileName = replyFileName;
    userReplyHasFile = hasFile;
    userReplySenderId = senderId;
    userReplySenderName = senderName;
    isUserReplying = true;
    // print("userReplySenderName============== $senderName $userReplySenderName");
    notifyListeners();
  }

  void stopUserChatReplying() {
    isUserReplying = false;
    userReplyHasFile = false;
    userReplyText = '';
    userReplyFileThumb = '';
    userReplyFileName = '';
    userReplySenderId = null;
    userReplySenderName = null;
    notifyListeners();
  }

  // *********************** start & stop Replying group chat *************************

  bool isGroupReplying = false;
  String groupReplyText = '';
  bool groupReplyHasFile = false;
  String groupReplyFileThumb = '';
  String groupReplyFileName = '';
  String? groupReplySenderId;
  String? groupReplySenderName;
  bool isGroupEditing = false;
  String groupEditingText = '';
  String? editingGroupMessageId;

  void startGroupChatEditing() {
    if (selectedGroupMsgs.isNotEmpty) {
      final selectedGroupMsg = selectedGroupMsgs.first;
      if (selectedGroupMsg is Map<String, dynamic>) {
        groupEditingText = selectedGroupMsg['message']?.toString() ?? '';
        editingGroupMessageId = selectedGroupMsg['id'];
      } else {
        groupEditingText = '';
      }
      isGroupEditing = true;
      notifyListeners();
    }
  }

  void stopGroupChatEditing() {
    isGroupEditing = false;
    groupEditingText = '';
    notifyListeners();
  }

  // void startGroupChatReplying() {
  //   if (selectedGroupMsgs.isNotEmpty) {
  //     final selectedGroupMsg = selectedGroupMsgs.first;
  //     if (selectedGroupMsg is Map<String, dynamic>) {
  //       groupReplyText = selectedGroupMsg['message']?.toString() ?? '';
  //       groupReplyHasFile = (selectedGroupMsg['vFiles'] ?? '').toString().isNotEmpty;
  //       groupReplyFileThumb = selectedGroupMsg['vFilesThumb']?.toString() ?? '';
  //       groupReplyFileName = selectedGroupMsg['isOriginalName']?.toString() ?? '';
  //       // print("groupReplyFileName: ${selectedGroupMsg['isOriginalName']}");
  //     } else {
  //       groupReplyText = '';
  //       groupReplyHasFile = false;
  //       groupReplyFileThumb = '';
  //       groupReplyFileName = '';
  //     }
  //     isGroupReplying = true;
  //     notifyListeners();}}
  void startGroupChatReplying() {
    if (selectedGroupMsgs.isNotEmpty) {
      final selectedGroupMsg = selectedGroupMsgs.first;
      if (selectedGroupMsg is Map<String, dynamic>) {
        groupReplyText = selectedGroupMsg['message']?.toString() ?? '';
        groupReplyHasFile =
            (selectedGroupMsg['vFiles'] ?? '').toString().isNotEmpty;
        groupReplyFileThumb = selectedGroupMsg['vFilesThumb']?.toString() ?? '';
        groupReplyFileName =
            selectedGroupMsg['isOriginalName']?.toString() ?? '';
        groupReplySenderId = selectedGroupMsg['iFromUserId'];
      } else {
        groupReplyText = '';
        groupReplyHasFile = false;
        groupReplyFileThumb = '';
        groupReplyFileName = '';
        groupReplySenderId = null;
      }
      isGroupReplying = true;
      notifyListeners();
    }
  }

  void startGroupChatImageReply({
    required String replyText,
    required String replyFileThumb,
    required String replyFileName,
    String? senderId,
    String? senderName,
    bool hasFile = true,
  }) {
    groupReplyText = replyText;
    groupReplyFileThumb = replyFileThumb;
    groupReplyFileName = replyFileName;
    groupReplyHasFile = hasFile;
    groupReplySenderId = senderId;
    groupReplySenderName = senderName;
    isGroupReplying = true;
    selectedGroupMsgs.clear();
    notifyListeners();
  }

  void stopGroupChatReplying() {
    isGroupReplying = false;
    groupReplyHasFile = false;
    groupReplyText = '';
    groupReplyFileThumb = '';
    groupReplyFileName = '';
    groupReplySenderId = null;
    groupReplySenderName = null;
    notifyListeners();
  }

  // ****************** Upload Image ***************************
  bool isUploadingFile = false;
  String uploadFileThumb = '';
  String uploadFileName = '';
  bool uploadHasFile = false;
  String uploadFilePath = '';
  List<PlatformFile> uploadFiles = [];

  void startUserChatFileUpload({
    required String filePath,
    required String fileName,
  }) {
    uploadFilePath = filePath;
    uploadFileName = fileName;
    uploadHasFile = true;
    isUploadingFile = true;
    uploadFiles = [
      PlatformFile(path: filePath, name: fileName, size: 0),
    ];
    notifyListeners();
  }

// Handle multiple files as before
  void startUserChatFileUploadMultiple({
    required List<PlatformFile> files,
  }) {
    uploadFiles = files;
    uploadHasFile = files.isNotEmpty;
    isUploadingFile = true;
    uploadFilePath = '';
    uploadFileName = '';
    notifyListeners();
  }

  void stopUserChatFileUpload() {
    uploadFiles = [];
    isUploadingFile = false;
    uploadFilePath = '';
    uploadFileName = '';
    uploadHasFile = false;
    notifyListeners();
  }

  void removeUploadFile(int index) {
    if (index >= 0 && index < uploadFiles.length) {
      uploadFiles.removeAt(index);
      if (uploadFiles.isEmpty) {
        stopUserChatFileUpload();
      } else {
        notifyListeners();
      }
    }
  }

  void setMsgSelectionMode(bool value) {
    _msgSelectionMode = value;
    notifyListeners();
  }

  void setUserEditingStop(bool value) {
    isUserEditing = value;
    notifyListeners();
  }

  void setGroupEditingStop(bool value) {
    isGroupEditing = value;
    notifyListeners();
  }

  void setUserReplyingStop(bool value) {
    isUserReplying = value;
    notifyListeners();
  }

  void setGroupReplyingStop(bool value) {
    isGroupReplying = value;
    notifyListeners();
  }

  void setFileUploadingStop(bool value) {
    uploadHasFile = value;
    isUploadingFile = value;
    notifyListeners();
  }

  void setGroupMsgSelectionMode(bool value) {
    _groupMsgSelectionMode = value;
    notifyListeners();
  }

  final List<String> _selectedMessageIds = [];

  void toggleSelectedMessage(String id) {
    if (_selectedMessageIds.contains(id)) {
      _selectedMessageIds.remove(id);
    } else {
      _selectedMessageIds.add(id);
    }
    notifyListeners();
  }

  bool isSelected(String id) => _selectedMessageIds.contains(id);

  void clearSelectedMessages() {
    _selectedMessageIds.clear();
    _msgSelectionMode = false;
    notifyListeners();
  }

  // ******************* show formatter *********************
  void setIsShowFormatter(bool isShowFormatter) {
    _isShowFormatter = isShowFormatter;
    notifyListeners();
  }

  void setEmojiList(bool isShowEmojiList) {
    _isEmojiOptionList = isShowEmojiList;
    notifyListeners();
  }

  void clearShowFormatter() {
    _isShowFormatter = false;
    notifyListeners();
  }

  // ***************** msg selection mode ********************
  void setIsMsgSelectionMode(bool selectionMode) {
    _msgSelectionMode = selectionMode;
    if (selectionMode) {
      isSearching = false;
    }
    notifyListeners();
  }

  // ***************** msg selection mode ********************
  void setSelectedMsgs(Map<String, dynamic> msgData) {
    _selectedMsgs.add(msgData);
    notifyListeners();
  }

  void removeSelectedMsgs(String msgId) {
    final filterData = _selectedMsgs.where((item) {
      return item['_id'] != msgId;
    }).toList();
    _selectedMsgs = filterData;
    notifyListeners();
  }

  void clearMsgSelectionIndexes() {
    _selectedMsgs.clear();
    notifyListeners();
  }

  // ***************** msg selection mode ********************
  void setIsGroupMsgSelectionMode(bool selectionMode) {
    _groupMsgSelectionMode = selectionMode;
    if (selectionMode) {
      isGroupSearching = false;
    }
    notifyListeners();
  }

  // ***************** msg selection mode ********************
  void setSelectedGroupMsgs(Map<String, dynamic> msgData) {
    _selectedGroupMsgs.add(msgData);
    notifyListeners();
  }

  void removeSelectedGroupMsgs(String msgId) {
    final filterData = _selectedGroupMsgs.where((item) {
      return item['_id'] != msgId;
    }).toList();
    _selectedGroupMsgs = filterData;
    notifyListeners();
  }

  void clearGroupMsgSelectionIndexes() {
    _selectedGroupMsgs.clear();
    notifyListeners();
  }

  // ******************* handle show/hide header selection personal chat msg icons ********************

  void setShowEditIcon(bool value) {
    _isShowEditIcon = value;
    notifyListeners();
  }

  void setShowDeleteIcon(bool value) {
    _isShowDeleteIcon = value;
    notifyListeners();
  }

  void setShowDownloadIcon(bool value) {
    _isShowDownloadIcon = value;
    notifyListeners();
  }

  void setShowReplyIcon(bool value) {
    _isShowReplyIcon = value;
    notifyListeners();
  }

  // ******************* handle show/hide header selection group chat msg icons ********************

  void setShowEditGroupIcon(bool value) {
    _isShowEditGroupIcon = value;
    notifyListeners();
  }

  void setShowDeleteGroupIcon(bool value) {
    _isShowDeleteGroupIcon = value;
    notifyListeners();
  }

  void setShowDownloadGroupIcon(bool value) {
    _isShowDownloadGroupIcon = value;
    notifyListeners();
  }

  void setShowReplyGroupIcon(bool value) {
    _isShowReplyGroupIcon = value;
    notifyListeners();
  }

  // ***************** sent new message ********************
  void setSentNewMessage(Map<String, dynamic> msgData) {
    _newSentMessage = msgData;
    notifyListeners();
  }

  void clearSentNewMessage() {
    _newSentMessage.clear();
    notifyListeners();
  }

  // ***************** add selected image ********************
  void setSelectedImage(Map<String, dynamic> imageData) {
    _selectedImage = imageData;
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage.clear();
    notifyListeners();
  }

  // ***************** check is group chat open *******************
  void setIsGroupChatOpen(bool isOpen) {
    _isGroupChatOpen = isOpen;
    notifyListeners();
  }

  // ***************** check is user chat open *******************
  void setIsUserChatOpen(bool isOpen) {
    _isUserChatOpen = isOpen;
    notifyListeners();
  }

  // ***************** check is user typing *******************
  void setIsShowUserTyping(bool isTyping) {
    _showUserTyping = isTyping;
    notifyListeners();
  }

  // ***************** check is group typing *******************
  void setIsShowGroupTyping(bool isTyping) {
    _showGroupTyping = isTyping;
    notifyListeners();
  }

  final Map<String, Set<String>> _typingUsersInGroup = {};

  void addTypingUser(String groupId, String userName) {
    if (!_typingUsersInGroup.containsKey(groupId)) {
      _typingUsersInGroup[groupId] = {};
    }
    _typingUsersInGroup[groupId]!.add(userName);
    notifyListeners();
  }

  void removeTypingUser(String groupId, String userName) {
    if (_typingUsersInGroup.containsKey(groupId)) {
      _typingUsersInGroup[groupId]!.remove(userName);
      notifyListeners();
    }
  }

  Set<String> getTypingUsers(String groupId) {
    return _typingUsersInGroup[groupId] ?? {};
  }

  //****************************************** searching in user chat *********************************
  final TextEditingController searchController = TextEditingController();

  List<int> matchedIndexes = [];
  int currentMatchIndex = 0;
  bool isSearching = false;

  void clearSearch() {
    matchedIndexes.clear();
    currentMatchIndex = 0;
    notifyListeners();
  }

  void setIsSearching(bool isSearch) {
    isSearching = isSearch;
    notifyListeners();
  }

  void clearSearching() {
    isSearching = false;
    notifyListeners();
  }

  // ************************************ searching in group chat  ************************************

  final TextEditingController groupSearchController = TextEditingController();

  List<int> matchedGroupIndexes = [];
  int currentGroupMatchIndex = 0;
  bool isGroupSearching = false;

  void clearGroupSearch() {
    matchedGroupIndexes.clear();
    currentGroupMatchIndex = 0;
    notifyListeners();
  }

  void setIsGroupSearching(bool isGroupSearch) {
    isGroupSearching = isGroupSearch;
    notifyListeners();
  }

  void clearGroupSearching() {
    isGroupSearching = false;
    notifyListeners();
  }

  void setIsUserPinChatSearching(bool isSearch) {
    _isUserPinChatSearching = isSearch;
    notifyListeners();
  }

  void clearUserPinChatSearching() {
    _isUserPinChatSearching = false;
    notifyListeners();
  }

  void setIsGroupPinChatSearching(bool isSearch) {
    _isGroupPinChatSearching = isSearch;
    notifyListeners();
  }

  void clearGroupPinChatSearching() {
    _isGroupPinChatSearching = false;
    notifyListeners();
  }
}
