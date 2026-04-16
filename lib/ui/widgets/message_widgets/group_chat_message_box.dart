import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:spot/ui/widgets/message_widgets/message_menu_bottomsheet.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../../core/responsive_fonts.dart';
import '../../../firebase_helper/fcm_notification_helper.dart';
import '../../../providers/group_provider.dart';
import 'package:html/parser.dart' show parse;

class GroupChatMessageBox extends StatefulWidget {
  final TextEditingController sendMessageText;
  final FocusNode? focusNode;
  final Function(String)? onChangedSendMessageText;
  final Map<String, dynamic> messageList;

  late String type;
  final String? formattedTime;

  GroupChatMessageBox(
      {super.key,
      required this.sendMessageText,
      this.focusNode,
      this.onChangedSendMessageText,
      required this.type,
      this.formattedTime,
      required this.messageList});

  @override
  State<GroupChatMessageBox> createState() => _GroupChatMessageBoxState();
}

class _GroupChatMessageBoxState extends State<GroupChatMessageBox> {
  var showColorBar = false;
  Color selectedColor = const Color(0XFF000000);
  String selectedText = '';
  quill.QuillController _controller = quill.QuillController.basic();
  FocusNode focusNode = FocusNode();
  bool isBoldSelected = false;
  bool isItalicSelected = false;
  bool isUnderlineSelected = false;
  bool isStrikeThroughSelected = false;
  bool isBulletSelected = false;
  bool isLinkSelected = false;
  Map<String, quill.Attribute> _lastKnownStyle = {};
  String currentLinkUrl = '';
  String currentLinkText = '';
  String? lastLinkedText;
  String? lastLinkedUrl;
  int? linkBaseOffset;
  int? linkExtentOffset;
  TextEditingController textController = TextEditingController();
  TextEditingController controller = TextEditingController();
  TextEditingController linkController = TextEditingController();
  TextEditingController linkController1 = TextEditingController();
  bool isFormatingOption = false;
  bool isEmojiOptionList = false;
  bool isLinkOptionSheet = false;
  bool isLinkSheet = false;
  bool isTextLinkSheet = false;
  List<Map<String, dynamic>> emojiToImage = [
    {
      "id": 1,
      "emoji": "😁",
      "path": "assets/emojis/beaming-face-with-smiling-eyes.png",
    },
    {"id": 2, "emoji": "😀", "path": "assets/emojis/grinning-face.png"},
    {
      "id": 3,
      "emoji": "😇",
      "path": "assets/emojis/smiling-face-with-halo.png",
    },
    {
      "id": 4,
      "emoji": "👉🏻",
      "path": "assets/emojis/backhand-index-pointing-right.png",
    },
    {
      "id": 5,
      "emoji": "👇🏻",
      "path": "assets/emojis/backhand-index-pointing-down.png",
    },
    {
      "id": 6,
      "emoji": "👈🏻",
      "path": "assets/emojis/backhand-index-pointing-left.png",
    },
    {
      "id": 7,
      "emoji": "👆🏻",
      "path": "assets/emojis/backhand-index-pointing-up.png",
    },
    {"id": 8, "emoji": "☝🏻", "path": "assets/emojis/index-pointing-up.png"},
    {"id": 9, "emoji": "✌🏻", "path": "assets/emojis/victory-hand.png"},
    {"id": 10, "emoji": "👌🏻", "path": "assets/emojis/ok-hand.png"},
    {"id": 11, "emoji": "👍🏻", "path": "assets/emojis/thumbs-up.png"},
    {"id": 12, "emoji": "👎🏻", "path": "assets/emojis/thumbs-down.png"},
    {"id": 13, "emoji": "🙌🏻", "path": "assets/emojis/raising-hands.png"},
    {"id": 14, "emoji": "👏🏻", "path": "assets/emojis/clapping-hands.png"},
    {"id": 15, "emoji": "🙏🏻", "path": "assets/emojis/folded-hands.png"},
    {"id": 16, "emoji": "✉️", "path": "assets/emojis/envelope.png"},
    {"id": 17, "emoji": "☕", "path": "assets/emojis/hot-beverage.png"},
    {
      "id": 18,
      "emoji": "🍽️",
      "path": "assets/emojis/fork-and-knife-with-plate.png",
    },
    {
      "id": 19,
      "emoji": "🌏",
      "path": "assets/emojis/globe-showing-asia-australia.png",
    },
    {"id": 20, "emoji": "⛳", "path": "assets/emojis/flag-in-hole.png"},
    {"id": 21, "emoji": "🎯", "path": "assets/emojis/bullseye.png"},
    {"id": 22, "emoji": "💡", "path": "assets/emojis/light-bulb.png"},
    {"id": 23, "emoji": "✅", "path": "assets/emojis/check-mark-button.png"},
    {"id": 24, "emoji": "☑️", "path": "assets/emojis/check-box-with-check.png"},
    {"id": 25, "emoji": "✔️", "path": "assets/emojis/check-mark.png"},
    {"id": 26, "emoji": "❎", "path": "assets/emojis/cross-mark-button.png"},
    {"id": 27, "emoji": "❌", "path": "assets/emojis/cross-mark.png"},
    {"id": 28, "emoji": "❓", "path": "assets/emojis/red-question-mark.png"},
  ];
  Set<String> newEmojiList = {
    '😀',
    '😁',
    '🫠',
    '🫥',
    '🫡',
    '🫢',
    '🫣',
    '🫤',
    '🫨',
    '😇',
    '⭐',
    '🩵',
    '🩶',
    '🩷',
    '🫂',
    '🫀',
    '🫁',
    '🩸',
    '🫦',
    '🫶',
    '🫳',
    '🫴',
    '🫱',
    '🫲',
    '🫸',
    '🫷',
    '🫰',
    '🫵',
    '🪂',
    '🫅',
    '🫄',
    '🪷',
    '🪻',
    '🪴',
    '🪵',
    '🪹',
    '🪺',
    '🪨',
    '🫧',
    '🪐',
    '🌏',
    '🫎',
    '🫏',
    '🪽',
    '🪶',
    '🪿',
    '🪼',
    '🪸',
    '🪲',
    '🪳',
    '🪰',
    '🪱',
    '🫛',
    '🫑',
    '🫒',
    '🫐',
    '🫚',
    '🫘',
    '🫓',
    '🫔',
    '🫕',
    '🫙',
    '☕',
    '🫖',
    '🫗',
    '🍽️',
    '🩼',
    '🪔',
    '🪅',
    '🪩',
    '🩰',
    '⛳',
    '🎯',
    '🪃',
    '🪁',
    '🪀',
    '🀄',
    '🃏',
    '🪄',
    '🪡',
    '🪕',
    '🪘',
    '🪇',
    '🪈',
    '🪗',
    '🪫',
    '⌨️',
    '🪙',
    '💡',
    '🪟',
    '🪞',
    '🪑',
    '🪠',
    '🪆',
    '🪢',
    '🪥',
    '🪒',
    '🪮',
    '🩱',
    '🩳',
    '🩲',
    '🪖',
    '🪭',
    '🩴',
    '🩹',
    '🩺',
    '🩻',
    '🪓',
    '🪜',
    '🪣',
    '🪝',
    '🪛',
    '🪚',
    '✉️',
    '🪪',
    '⌚',
    '⌛',
    '⏳',
    '⏲️',
    '⏰',
    '⏱️',
    '🪧',
    '🪬',
    '🪦',
    '🪤',
    '🟡',
    '🟠',
    '🟢',
    '🟣',
    '🟤',
    '🟫',
    '🟥',
    '🟧',
    '🟨',
    '🟩',
    '🟦',
    '🟪',
    '⬛',
    '⬜',
    '❌',
    '⭕',
    '‼️',
    '⁉️',
    '❓',
    '🅰️',
    '🆎',
    '🅱️',
    '🅾️',
    '🆑',
    '🆘',
    '🉐',
    '㊙️',
    '㊗️',
    '🈴',
    '🈵',
    '🈹',
    '🈲',
    '🉑',
    '🈶',
    '🈸',
    '🈺',
    '🈚',
    '🈷️',
    '🆚',
    '▶️',
    '⏩',
    '⏭️',
    '⏯️',
    '◀️',
    '⏪',
    '⏮️',
    '⏫',
    '⏬',
    '⏸️',
    '⏹️',
    '⏺️',
    '⏏️',
    '〽️',
    '🈯',
    '❎',
    '✅',
    '✔️',
    '☑️',
    '⬆️',
    '↗️',
    '↘️',
    '⬇️',
    '↙️',
    '⬅️',
    '↖️',
    '↕️',
    '↔️',
    '↩️',
    '↪️',
    '⤴️',
    '⤵️',
    '🆕',
    '🆓',
    '🆙',
    '🆗',
    '🆒',
    '🆖',
    'ℹ️',
    '🅿️',
    '🈁',
    '🈂️',
    '🈳',
    '#️⃣',
    '*️⃣',
    '0️⃣',
    '1️⃣',
    '2️⃣',
    '3️⃣',
    '4️⃣',
    '5️⃣',
    '6️⃣',
    '7️⃣',
    '8️⃣',
    '9️⃣',
    'Ⓜ️',
    '🪯',
    '🆔',
    '🟰',
    '〰️',
    '©️',
    '®️',
    '™️',
    '◼️',
    '◾',
    '▪️',
    '◻️',
    '◽',
    '▫️',
    '🇦🇨',
    '🇦🇩',
    '🇦🇪',
    '🇦🇫',
    '🇦🇬',
    '🇦🇮',
    '🇦🇱',
    '🇦🇲',
    '🇦🇴',
    '🇦🇶',
    '🇦🇷',
    '🇦🇸',
    '🇦🇹',
    '🇦🇺',
    '🇦🇼',
    '🇦🇽',
    '🇦🇿',
    '🇧🇦',
    '🇧🇧',
    '🇧🇩',
    '🇧🇪',
    '🇧🇫',
    '🇧🇬',
    '🇧🇭',
    '🇧🇮',
    '🇧🇯',
    '🇧🇱',
    '🇧🇲',
    '🇧🇳',
    '🇧🇶',
    '🇧🇷',
    '🇧🇸',
    '🇧🇹',
    '🇧🇴',
    '🇧🇻',
    '🇧🇼',
    '🇧🇾',
    '🇧🇿',
    '🇨🇦',
    '🇨🇨',
    '🇨🇩',
    '🇨🇫',
    '🇨🇬',
    '🇨🇭',
    '🇨🇮',
    '🇨🇰',
    '🇨🇱',
    '🇨🇲',
    '🇨🇳',
    '🇨🇴',
    '🇨🇵',
    '🇨🇷',
    '🇨🇺',
    '🇨🇻',
    '🇨🇼',
    '🇨🇽',
    '🇨🇾',
    '🇨🇿',
    '🇩🇪',
    '🇩🇬',
    '🇩🇯',
    '🇩🇰',
    '🇩🇲',
    '🇩🇴',
    '🇩🇿',
    '🇪🇦',
    '🇪🇨',
    '🇪🇪',
    '🇪🇬',
    '🇪🇭',
    '🇪🇷',
    '🇪🇸',
    '🇪🇹',
    '🇪🇺',
    '🇫🇮',
    '🇫🇯',
    '🇫🇰',
    '🇫🇲',
    '🇫🇴',
    '🇫🇷',
    '🇬🇦',
    '🇬🇧',
    '🇬🇩',
    '🇬🇪',
    '🇬🇫',
    '🇬🇬',
    '🇬🇭',
    '🇬🇮',
    '🇬🇱',
    '🇬🇲',
    '🇬🇳',
    '🇬🇵',
    '🇬🇶',
    '🇬🇷',
    '🇬🇸',
    '🇬🇹',
    '🇬🇺',
    '🇬🇼',
    '🇬🇾',
    '🇭🇰',
    '🇭🇲',
    '🇭🇳',
    '🇭🇷',
    '🇭🇹',
    '🇭🇺',
    '🇮🇨',
    '🇮🇩',
    '🇮🇪',
    '🇮🇱',
    '🇮🇲',
    '🇮🇳',
    '🇮🇴',
    '🇮🇶',
    '🇮🇷',
    '🇮🇸',
    '🇮🇹',
    '🇯🇪',
    '🇯🇲',
    '🇯🇴',
    '🇯🇵',
    '🇰🇪',
    '🇰🇬',
    '🇰🇭',
    '🇰🇮',
    '🇰🇲',
    '🇰🇳',
    '🇰🇵',
    '🇰🇷',
    '🇰🇼',
    '🇰🇾',
    '🇰🇿',
    '🇱🇦',
    '🇱🇧',
    '🇱🇨',
    '🇱🇮',
    '🇱🇰',
    '🇱🇷',
    '🇱🇸',
    '🇱🇹',
    '🇱🇺',
    '🇱🇻',
    '🇱🇾',
    '🇲🇦',
    '🇲🇨',
    '🇲🇩',
    '🇲🇪',
    '🇲🇫',
    '🇲🇬',
    '🇲🇭',
    '🇲🇰',
    '🇲🇱',
    '🇲🇲',
    '🇲🇳',
    '🇲🇴',
    '🇲🇵',
    '🇲🇶',
    '🇲🇷',
    '🇲🇸',
    '🇲🇹',
    '🇲🇺',
    '🇲🇻',
    '🇲🇼',
    '🇲🇽',
    '🇲🇾',
    '🇲🇿',
    '🇳🇦',
    '🇳🇨',
    '🇳🇪',
    '🇳🇫',
    '🇳🇬',
    '🇳🇮',
    '🇳🇱',
    '🇳🇴',
    '🇳🇵',
    '🇳🇷',
    '🇳🇺',
    '🇳🇿',
    '🇴🇲',
    '🇵🇦',
    '🇵🇪',
    '🇵🇫',
    '🇵🇬',
    '🇵🇭',
    '🇵🇰',
    '🇵🇱',
    '🇵🇲',
    '🇵🇳',
    '🇵🇷',
    '🇵🇸',
    '🇵🇹',
    '🇵🇼',
    '🇵🇾',
    '🇶🇦',
    '🇷🇪',
    '🇷🇴',
    '🇷🇸',
    '🇷🇺',
    '🇷🇼',
    '🇸🇦',
    '🇸🇧',
    '🇸🇨',
    '🇸🇩',
    '🇸🇪',
    '🇸🇬',
    '🇸🇭',
    '🇸🇮',
    '🇸🇯',
    '🇸🇰',
    '🇸🇱',
    '🇸🇲',
    '🇸🇳',
    '🇸🇴',
    '🇸🇷',
    '🇸🇸',
    '🇸🇹',
    '🇸🇻',
    '🇸🇽',
    '🇸🇾',
    '🇸🇿',
    '🇹🇦',
    '🇹🇨',
    '🇹🇩',
    '🇹🇫',
    '🇹🇬',
    '🇹🇭',
    '🇹🇯',
    '🇹🇰',
    '🇹🇱',
    '🇹🇲',
    '🇹🇳',
    '🇹🇴',
    '🇹🇷',
    '🇹🇹',
    '🇹🇻',
    '🇹🇼',
    '🇹🇿',
    '🇺🇦',
    '🇺🇬',
    '🇺🇲',
    '🇺🇳',
    '🇺🇸',
    '🇺🇾',
    '🇺🇿',
    '🇻🇦',
    '🇻🇨',
    '🇻🇪',
    '🇻🇬',
    '🇻🇮',
    '🇻🇳',
    '🇻🇺',
    '🇼🇫',
    '🇼🇸',
    '🇽🇰',
    '🇾🇪',
    '🇾🇹',
    '🇿🇦',
    '🇿🇲',
    '🇿🇼',
  };
  TextStyle selectedStyle = const TextStyle();
  TextSelection? textSelection;
  bool isEditing = false;
  String selectedMessageContent = "";
  bool isMsgExist = false;
  DateTime? _lastTypingTime;
  final Duration _typingDelay = Duration(seconds: 2);
  bool isTapped = false;
  dynamic lastSentMessage;

  @override
  void initState() {
    final dataProvider = context.read<DataListProvider>();
    super.initState();
    FcmNotificationHelper.instance.initFcm();
    _loadAllowedFileTypes();
    // final chatProvider = context.read<ChatProvider>();
    // _controller = quill.QuillController.basic();
    // _controller = chatProvider.isGroupEditing && chatProvider.groupEditingText.isNotEmpty
    //     ? quill.QuillController(document: quill.Document()..insert(0, chatProvider.groupEditingText), selection: const TextSelection.collapsed(offset: 0),)
    //     : quill.QuillController.basic();
    final chatProvider = context.read<ChatProvider>();

    if (chatProvider.isGroupEditing &&
        chatProvider.groupEditingText.isNotEmpty) {
      final doc = quill.Document()..insert(0, chatProvider.groupEditingText);

      _controller = quill.QuillController(
        document: doc,
        selection: TextSelection.collapsed(offset: doc.length),
      );
    } else {
      _controller = quill.QuillController.basic();
    }

    startControllerListener();
  }

  void startControllerListener() {
    _controller.addListener(() {
      final style = _controller.getSelectionStyle();

      setState(() {
        isBoldSelected = style.attributes.containsKey(quill.Attribute.bold.key);
        isItalicSelected =
            style.attributes.containsKey(quill.Attribute.italic.key);
        isUnderlineSelected =
            style.attributes.containsKey(quill.Attribute.underline.key);
        isStrikeThroughSelected =
            style.attributes.containsKey(quill.Attribute.strikeThrough.key);
        isBulletSelected = style.attributes.containsKey(quill.Attribute.ul.key);
        isLinkSelected = style.attributes.containsKey(quill.Attribute.link.key);
      });

      if (style.attributes.isNotEmpty) {
        _lastKnownStyle = Map.from(style.attributes);
      }

      _onTextChanged();
      // _filterEmojis();
    });
  }

  void _onTextChanged() {
    // _filterEmojis();
    final plainText = _controller.document.toPlainText().trim();
    if (plainText.isNotEmpty && !isMsgExist) {
      setState(() => isMsgExist = true);
    } else if (plainText.isEmpty && isMsgExist) {
      setState(() => isMsgExist = false);
    }
    final now = DateTime.now();
    if (plainText.isNotEmpty &&
        (_lastTypingTime == null ||
            now.difference(_lastTypingTime!) > _typingDelay)) {
      _handleTyping(plainText);
      _lastTypingTime = now;
    }
  }

  void _handleTyping(String text) async {
    if (text.isNotEmpty && !isMsgExist) setState(() => isMsgExist = true);
    if (text.isEmpty && isMsgExist) setState(() => isMsgExist = false);
    if (isMsgExist) {
      final dataListProvider = context.read<DataListProvider>();
      final currntUserData = await CommonFunctions.getLoginUser();
      SocketMessageEvents.messageTyping(
        currntUserData['_id'],
        widget.type == 'chat'
            ? dataListProvider.openedChatUserData['_id']
            : dataListProvider.openedChatGroupData['_id'],
        text,
        widget.type == 'chat' ? 'userChat' : 'groupChat',
      );
    }
  }

  void _filterEmojis() {
    final plainText = _controller.document.toPlainText().trim();
    final allowedEmojis = emojiToImage.map((e) => e['emoji']).toSet();
    final currentPosition = _controller.selection.baseOffset;
    final filteredChars = plainText.characters.where((char) {
      return allowedEmojis.contains(char) || !isEmoji(char);
    }).toList();
    final filteredText = filteredChars.join();
    if (filteredText != plainText) {
      _controller.document.delete(0, _controller.document.length);
      _controller.document.insert(0, filteredText);
      int newPosition = currentPosition;
      if (currentPosition > filteredText.length)
        newPosition = filteredText.length;

      if (currentPosition < plainText.characters.length &&
          isEmoji(plainText.characters.elementAt(currentPosition))) {
        int lastValidIndex =
            filteredChars.lastIndexWhere((char) => !isEmoji(char));
        newPosition = (lastValidIndex >= 0) ? lastValidIndex - 1 : 0;
      }

      if (newPosition == filteredText.length &&
          filteredText.isNotEmpty &&
          isEmoji(filteredText.characters.last)) {
        newPosition = filteredText.length;
      }

      _controller.updateSelection(
        TextSelection.collapsed(offset: newPosition),
        quill.ChangeSource.local,
      );
    }
  }

  List<String> allowedFileTypes = [];

  Future<void> _loadAllowedFileTypes() async {
    final result = await CommonFunctions.getAllowedFileList();
    if (!mounted) return;

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        allowedFileTypes = List<String>.from(result['filePermission'] ?? []);
      });
    } else {
      setState(() {
        allowedFileTypes = [];
      });
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final chatProvider = context.watch<ChatProvider>();
  //
  //   if (chatProvider.isGroupEditing && _controller.document.toPlainText().trim() != chatProvider.groupEditingText.trim()) {
  //     _controller = quill.QuillController(document: quill.Document()..insert(0, chatProvider.groupEditingText), selection: const TextSelection.collapsed(offset: 0),);
  //     setState(() {});}}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.isGroupEditing &&
        _controller.document.toPlainText().trim() !=
            chatProvider.groupEditingText.trim()) {
      final newDoc = quill.Document()..insert(0, chatProvider.groupEditingText);
      _controller.document = newDoc;
      final safeOffset = newDoc.length.clamp(0, newDoc.length);
      _controller.updateSelection(
        TextSelection.collapsed(offset: safeOffset),
        quill.ChangeSource.local,
      );
    }
  }

  List<String> getVMemberIdList(Map<String, dynamic> messageList) {
    final List<dynamic> allMessages = messageList['data'] ?? [];

    if (allMessages.isEmpty) return [];

    final latestMessage = allMessages.first;
    final List<dynamic> vMemberIds = latestMessage['vMemeberList'] ?? [];

    return List<String>.from(vMemberIds.map((e) => e.toString()));
  }

  void handleOnMessageSend() async {
    final chatProvider = context.read<ChatProvider>();
    final dataListProvider = context.read<DataListProvider>();
    final text = _controller.document.toPlainText().trim();
    if (text.isEmpty) return;
    _controller = quill.QuillController.basic();
    // chatProvider.stopGroupChatEditing();

    final currentUser = await CommonFunctions.getLoginUser();
    final String senderChatID = currentUser['_id'];
    final String receiverChatID = dataListProvider.openedChatGroupData['_id'];
    final String id =
        "${receiverChatID}_${senderChatID}_${DateTime.now().millisecondsSinceEpoch}";
    final String? receiverFcmToken =
        dataListProvider.openedChatGroupData['tToken'];

    String content = convertDocumentToHtmlSafe(_controller.document);
    if (content.trim().isEmpty) content = text;

    final isEditing = chatProvider.isGroupEditing;
    final isReplying = chatProvider.isGroupReplying;
    final vReplyMsg = isReplying
        ? chatProvider.selectedImage.isNotEmpty
            ? chatProvider.selectedImage['message']
            : chatProvider.groupReplyText
        : '';
    // print("vReplyMsg: $vReplyMsg");
    // final vReplyMsg_id = isReplying && chatProvider.selectedGroupMsgs.isNotEmpty ? (chatProvider.selectedGroupMsgs.first['id'] ?? '') : '';
    final vReplyMsgId = isReplying
        ? chatProvider.selectedImage.isNotEmpty
            ? chatProvider.selectedImage['id']
            : chatProvider.selectedGroupMsgs.isNotEmpty
                ? chatProvider.selectedGroupMsgs.first['id']
                : ''
        : "";
    // print("vReplyMsgId: $vReplyMsgId");
    // final vReplyFileName = isReplying ? chatProvider.groupReplyFileName : '';
    final vReplyFileName = isReplying
        ? chatProvider.selectedImage.isNotEmpty
            ? chatProvider.selectedImage['isOriginalName']
            : chatProvider.groupReplyFileName
        : '';
    // print("vReplyFileName: $vReplyFileName");
    // final vMemberIds = getVMemberIdList(widget.messageList);
    // chatProvider.setGroupMembersList(vMemberIds);

    if (isEditing && chatProvider.editingGroupMessageId != null) {
      final updateResponse = await CommonFunctions.updateUserMessage(
        text,
        receiverChatID,
        "",
        chatProvider.editingGroupMessageId!,
      );
      if (updateResponse['status'] == 200) {
        final originalList = CommonFunctions.replaceMatchingItemsById(
            context: context,
            originalList: dataListProvider.groupMessagesList,
            updatedList: updateResponse['fullMessageData']);
        // debugPrint("originalList $originalList", wrapWidth: 1024);
        dataListProvider.setGroupMessageList(originalList);
      }
      chatProvider.stopGroupChatEditing();
      _controller = quill.QuillController.basic();
      setState(() {});
      return;
    }

    SocketMessageEvents.sendGroupMessageEvent(
      receiverChatID: receiverChatID,
      senderChatID: senderChatID,
      content: text,
      vReplyFileName: vReplyFileName,
      vReplyMsg: vReplyMsg,
      vReplyMsgId: vReplyMsgId,
      id: id,
      isGreetingMsg: 0,
      vGroupMessageType: "",
      isForwardMsg: 0,
      // isForwardMsg_id: '',
      isDeleteprofile: 0,
      iRequestMsg: 0,
      vDeleteMemberId: "",
      vNewAdminId: "",
      requestMemberId: "",
      chat: 2,
      vMembersList: chatProvider.groupMembersList,
      imageDataArr: [],
    );

    // if (receiverFcmToken != null && receiverFcmToken.isNotEmpty) {
    //   try {
    //     // await FcmNotificationHelper.instance.sendFCMPush(
    //     //   fcmToken: receiverFcmToken,
    //     //   title: currentUser['vGroupName'] ?? "New Message",
    //     //   body: text,
    //     // );
    //     await FcmNotificationHelper.instance.sendFCMPush(
    //       fcmToken: receiverFcmToken,
    //       title: dataListProvider.openedChatGroupData['vGroupName'] ?? "New Group Message",
    //       body: text,
    //     );
    //
    //     print("Notification send successfully................");
    //   } catch (e) {
    //     print("Notification send failed: $e");
    //   }
    // }

    if (receiverFcmToken != null && receiverFcmToken.isNotEmpty) {
      try {
        await FcmNotificationHelper.instance.sendFCMPush(
          fcmToken: receiverFcmToken,
          title: dataListProvider.openedChatGroupData['vGroupName'] ??
              "New Group Message",
          body: text,
          data: {
            "type": "newGrpMessage",
            "iGroupId": dataListProvider.openedChatGroupData['iGroupId'] ?? "",
            "chatId": dataListProvider.openedChatGroupData['vChatId'] ?? "",
            "isGroup": "true",
            "msgType": "text",
          },
        );
      } catch (e) {}
    }

    _controller = quill.QuillController.basic();
    _controller.document = quill.Document();
    chatProvider.setGroupMsgSelectionMode(false);
    chatProvider.clearGroupMsgSelectionIndexes();
    chatProvider.stopGroupChatEditing();
    chatProvider.stopGroupChatReplying();

    isMsgExist = false;
    setState(() {});
    startControllerListener();
  }

  // void handleOnFileMessageSend() async {
  //   final chatProvider = context.read<ChatProvider>();
  //   final dataListProvider = context.read<DataListProvider>();
  //   var files = chatProvider.uploadFiles;
  //
  //   if (files.isEmpty) {
  //     print("No files selected.");
  //     return;
  //   }
  //
  //   final currentUser = await CommonFunctions.getLoginUser();
  //   final senderChatID = currentUser['_id'];
  //   final receiverChatID = dataListProvider.openedChatGroupData['_id'];
  //
  //   for (var pf in files) {
  //     final path = pf.path!;
  //     final fileName = path.split('/').last;
  //     final id = "${receiverChatID}_${senderChatID}_${DateTime.now().millisecondsSinceEpoch}";
  //     final uploadResponse = await CommonFunctions.uploadUserFile(filePath: path, senderChatID: senderChatID, receiverChatID: receiverChatID, content: '', vReplyMsg: '', vReplyMsg_id: '', vReplyFileName: fileName, id: id, isFileUpload: 1, chat: 2,);
  //     print("Upload File Response: $uploadResponse");
  //   }
  //
  //   chatProvider.stopUserChatFileUpload();
  //   chatProvider.stopUserChatReplying();
  //   _controller = quill.QuillController.basic();
  //   setState(() {});
  // }
  void handleOnFileMessageSend() async {
    final chatProvider = context.read<ChatProvider>();
    final dataListProvider = context.read<DataListProvider>();
    final files = chatProvider.uploadFiles;
    final receiverFcmToken = dataListProvider.openedChatGroupData['tToken'];
    _controller = quill.QuillController.basic();
    if (files.isEmpty) {
      // print("No files selected.");
      return;
    }

    final currentUser = await CommonFunctions.getLoginUser();
    final senderChatID = currentUser['_id'];
    final receiverChatID = dataListProvider.openedChatGroupData['_id'];

    // Load allowed file types
    if (allowedFileTypes.isEmpty) await _loadAllowedFileTypes();

    for (var pf in files) {
      final path = pf.path!;
      final fileName = path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      // Skip disallowed file types
      if (!allowedFileTypes.contains(extension)) {
        // print("File type .$extension not allowed. Skipping $fileName");
        continue;
      }

      final id =
          "${receiverChatID}_${senderChatID}_${DateTime.now().millisecondsSinceEpoch}";
      // print('Uploading: $fileName');

      final uploadResponse = await CommonFunctions.uploadUserFile(
        filePath: path,
        senderChatID: senderChatID,
        receiverChatID: receiverChatID,
        content: '',
        vReplyMsg: '',
        vReplyMsgId: '',
        vReplyFileName: fileName,
        id: id,
        isFileUpload: 1,
        chat: 2,
      );
      // print("Upload Response: $uploadResponse");

      if (receiverFcmToken != null && receiverFcmToken.isNotEmpty) {
        try {
          String bodyText = CommonFunctions.getNotificationLabel(extension);
          // await FcmNotificationHelper.instance.sendFCMPush(
          //   fcmToken: receiverFcmToken,
          //   title: currentUser['vGroupName'] ?? "New File",
          //   body: bodyText,
          // );
          await FcmNotificationHelper.instance.sendFCMPush(
            fcmToken: receiverFcmToken,
            title: dataListProvider.openedChatGroupData['vGroupName'] ??
                "New Group Message",
            body: bodyText,
          );
          // print("Notification sent for: $fileName");
        } catch (e) {
          // print("Notification send failed for $fileName: $e");
        }
      }
    }

    chatProvider.stopUserChatFileUpload();
    chatProvider.stopUserChatReplying();
    _controller = quill.QuillController.basic();
    setState(() {});

    startControllerListener();
  }

  void onCancelEdit() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.stopGroupChatEditing();
    _controller = quill.QuillController.basic();
    setState(() {});
  }

  //blocked emojis code
  bool isEmoji(String character) {
    if (newEmojiList.contains(character)) return true;
    //how to open the click the upload file that the open file
    if (character.length == 2) {
      final runes = character.runes.toList();
      if (runes.every((rune) => rune >= 0x1F1E6 && rune <= 0x1F1FF)) {
        return true;
      }
    }

    final int rune = character.runes.first;
    return (rune >= 0x1F600 && rune <= 0x1F64F) || // Emoticons
        (rune >= 0x1F300 && rune <= 0x1F5FF) || // Misc Symbols and Pictographs
        (rune >= 0x1F680 && rune <= 0x1F6FF) || // Transport and Map
        (rune >= 0x2600 && rune <= 0x26FF) || // Misc symbols
        (rune >= 0x2700 && rune <= 0x27BF) || // Dingbats
        (rune >= 0xFE00 && rune <= 0xFE0F) || // Variation Selectors
        (rune >= 0x1F900 && rune <= 0x1F9FF) || // Supplemental Symbols
        (rune >= 65024 && rune <= 65039) || // Variation selector
        (rune >= 8400 && rune <= 8447); // Diacritical marks
  }

  void onTextChanged(String text) async {
    final dataListProvider = context.read<DataListProvider>();
    final currntUserData = await CommonFunctions.getLoginUser();
    SocketMessageEvents.messageTyping(
        currntUserData['_id'],
        widget.type == 'chat'
            ? dataListProvider.openedChatGroupData['_id']
            : dataListProvider.openedChatGroupData['_id'],
        text,
        widget.type == 'chat' ? 'userChat' : 'groupChat');
  }

  void getSelectedText() {
    // final selection = widget.sendMessageText.selection;
    // if (selection.isValid && !selection.isCollapsed) {
    //   final start = selection.start;
    //   final end = selection.end;
    //   setState(() {
    //     selectedText = widget.sendMessageText.text.substring(start, end);
    //   });
    // } else {
    //   setState(() {
    //     selectedText = 'No text selected.';
    //   });
    // }
    // print("selectedTextselectedTextselectedText $selectedText");
    void _changeSelectedTextColorToRed() {
      final selection = widget.sendMessageText.selection;
      if (selection.isValid && !selection.isCollapsed) {
        final start = selection.start;
        final end = selection.end;
        final fullText = widget.sendMessageText.text;
        final selectedText = fullText.substring(start, end);
        // print("selectedTextselectedText $selectedText");
        // Wrap selected text in a tag
        final newText =
            fullText.replaceRange(start, end, '[red]$selectedText[/red]');
        // print("newTextnewTextnewText $newText");
        // Update controller
        widget.sendMessageText.value = widget.sendMessageText.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(
              offset: start +
                  '[red]'.length +
                  selectedText.length +
                  '[/red]'.length),
        );
        // print("widget.sendMessageText.value ${widget.sendMessageText.value}");
      }
    }
  }

  // **************** open menu bottom sheet *******************
  void openMenuBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: MessageMenuBottomsheet(),
          );
        });
  }

  void handleCloseFormatter() {
    final style = _controller.getSelectionStyle();
    isBulletSelected = style.attributes.containsKey(quill.Attribute.ul.key);
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setIsShowFormatter(false);
    chatProvider.clearShowFormatter();
    setState(() {
      isBoldSelected = false;
      isItalicSelected = false;
      isUnderlineSelected = false;
      isStrikeThroughSelected = false;
      isBulletSelected = isBulletSelected ? true : false;
      isLinkSelected = false;
      selectedColor = const Color(0XFF000000);
    });
  }

  void handleEmojiList() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setEmojiList(false);
  }

  // ***************** text convert to bold format *******************
  void applyBoldFormatting() {
    final selection = widget.sendMessageText.selection;
    final text = widget.sendMessageText.text;

    if (selection.start == -1 || selection.start == selection.end) return;

    final selectedText = text.substring(selection.start, selection.end);
    final newText =
        text.replaceRange(selection.start, selection.end, '**$selectedText**');

    widget.sendMessageText.value = widget.sendMessageText.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
          offset: selection.start + 2 + selectedText.length + 2),
    );
  }

  void applyItalicFormatting() {
    final selection = widget.sendMessageText.selection;
    final text = widget.sendMessageText.text;

    if (selection.start == -1 || selection.start == selection.end) return;

    final selectedText = text.substring(selection.start, selection.end);
    final newText =
        text.replaceRange(selection.start, selection.end, '_${selectedText}_');

    widget.sendMessageText.value = widget.sendMessageText.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
          offset: selection.start + 1 + selectedText.length + 1),
    );
  }

  // ***************** text convert to underline format *******************
  void applyUnderlineFormatting() {
    final selection = widget.sendMessageText.selection;
    final text = widget.sendMessageText.text;

    if (selection.start == -1 || selection.start == selection.end) return;

    final selectedText = text.substring(selection.start, selection.end);
    final newText = text.replaceRange(
        selection.start, selection.end, '<u>$selectedText</u>');

    widget.sendMessageText.value = widget.sendMessageText.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
          offset: selection.start + 3 + selectedText.length + 4),
    );
  }

  // *************** html formatter **********************
  String convertDocumentToHtmlSafe(quill.Document document) {
    final deltaOps = document.toDelta().toList();
    final buffer = StringBuffer();
    bool isInList = false;
    String? currentListType;

    for (final option in deltaOps) {
      final data = option.data;
      final attrs = option.attributes;

      if (data is String) {
        String formattedText = data;

        if (attrs != null && attrs.isNotEmpty) {
          if (attrs.containsKey('bold')) {
            formattedText = '<b>$formattedText</b>';
          }
          if (attrs.containsKey('italic')) {
            formattedText = '<i>$formattedText</i>';
          }
          if (attrs.containsKey('underline')) {
            formattedText = '<u>$formattedText</u>';
          }
          if (attrs.containsKey('strike')) {
            formattedText = '<del>$formattedText</del>';
          }
          if (attrs.containsKey('link')) {
            final link = attrs['link'].toString();
            if (link.isNotEmpty) {
              formattedText =
                  '<a href="$link" target="_blank">$formattedText</a>';
            }
          }
          if (attrs.containsKey('color')) {
            final color = attrs['color'].toString();
            formattedText = '<span style="color:$color;">$formattedText</span>';
          }
        }

        if (attrs != null && attrs.containsKey('list')) {
          final listType = attrs['list'].toString();
          if (!isInList) {
            if (listType == 'bullet') {
              buffer.write('<ul>');
              currentListType = 'bullet';
            } else if (listType == 'ordered') {
              buffer.write('<ol>');
              currentListType = 'ordered';
            }
            isInList = true;
          }
          buffer.write('<li>$formattedText</li>');
        } else {
          buffer.write(formattedText);
        }
      } else if (data is Map) {
        // Handle image insertion (optional)
        if (attrs != null && attrs.containsKey('image')) {
          final imageUrl = attrs['image'].toString();
          buffer.write('<img src="$imageUrl"  alt=""/>');
        }
      }
    }

    if (isInList) {
      if (currentListType == 'bullet') {
        buffer.write('</ul>');
      } else if (currentListType == 'ordered') {
        buffer.write('</ol>');
      }
    }
    return buffer.toString();
  }

  void handleSelectTextColor(Color color) {
    getSelectedText();
    setState(() {
      selectedColor = color;
      showColorBar = false;
    });
  }

  // ****************** change text color *********************
  void handleOnPressChangeTextColor() {
    setState(() {
      showColorBar = true;
    });
  }

  // ************** convert color to hex *****************
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  // ***************** cancel edit msg *****************
  void closeEditIcon() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.clearGroupMsgSelectionIndexes();
    chatProvider.setGroupMsgSelectionMode(false);
    chatProvider.stopGroupChatEditing();
    _controller = quill.QuillController.basic();
    setState(() {});
  }

  // ******************* ui components ********************
  // ******************** show color bar for text color *******************
  colorBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 27,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppColorTheme.textFormatColors.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    handleSelectTextColor(
                      AppColorTheme.textFormatColors[index],
                    );
                    toggleAttribute(quill.Attribute.color);
                  });
                  applyTextStyle(
                      TextStyle(color: AppColorTheme.textFormatColors[index]));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 27,
                  width: 27,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    color: AppColorTheme.textFormatColors[index],
                  ),
                ),
              );
            }),
      ),
    );
  }

  // ********************** message formatter *************************
  messageFormatter() {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      return chatProvider.isShowFormatter
          ? Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: InkWell(
                              onTap: () =>
                                  toggleAttribute(quill.Attribute.bold),
                              child: Icon(FeatherIcons.bold,
                                  color: isBoldSelected
                                      ? const Color(0xff4CC9FE)
                                      : AppColorTheme.muted))),
                      Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: InkWell(
                              onTap: () =>
                                  toggleAttribute(quill.Attribute.italic),
                              child: Icon(FeatherIcons.italic,
                                  color: isItalicSelected
                                      ? const Color(0xff4CC9FE)
                                      : AppColorTheme.muted))),
                      Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: InkWell(
                              onTap: () =>
                                  toggleAttribute(quill.Attribute.underline),
                              child: Icon(FeatherIcons.underline,
                                  color: isUnderlineSelected
                                      ? const Color(0xff4CC9FE)
                                      : AppColorTheme.muted))),
                      InkWell(
                          onTap: handleOnPressChangeTextColor,
                          child: Container(
                              margin: const EdgeInsets.only(right: 15),
                              height: 27,
                              width: 27,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
                                  color: selectedColor))),
                      Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: InkWell(
                              onTap: () => toggleAttribute(
                                  quill.Attribute.strikeThrough),
                              child: Icon(FeatherIcons.minus,
                                  color: isStrikeThroughSelected
                                      ? const Color(0xff4CC9FE)
                                      : AppColorTheme.muted))),
                      Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: InkWell(
                              onTap: () => toggleAttribute(quill.Attribute.ul),
                              child: Icon(FeatherIcons.list,
                                  color: isBulletSelected
                                      ? const Color(0xff4CC9FE)
                                      : AppColorTheme.muted))),
                      Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: InkWell(
                            onTap: () {
                              final selection = _controller.selection;
                              String link = linkController.text.trim();

                              if (selection.isValid &&
                                  selection.baseOffset !=
                                      selection.extentOffset) {
                                final baseOffset = selection.baseOffset;
                                final extentOffset = selection.extentOffset;
                                final length = extentOffset - baseOffset;
                                final currentStyle =
                                    _controller.getSelectionStyle();
                                _controller.formatText(
                                  baseOffset,
                                  length,
                                  quill.LinkAttribute(link),
                                );

                                if (currentStyle
                                        .attributes[quill.Attribute.bold.key] !=
                                    null) {
                                  _controller.formatText(
                                      baseOffset, length, quill.Attribute.bold);
                                }

                                if (currentStyle.attributes[
                                        quill.Attribute.italic.key] !=
                                    null) {
                                  _controller.formatText(baseOffset, length,
                                      quill.Attribute.italic);
                                }

                                if (currentStyle.attributes[
                                        quill.Attribute.underline.key] !=
                                    null) {
                                  _controller.formatText(baseOffset, length,
                                      quill.Attribute.underline);
                                }

                                String hexColor =
                                    currentStyle.attributes['color']?.value ??
                                        '#000000';
                                _controller.formatText(
                                  baseOffset,
                                  length,
                                  quill.Attribute.fromKeyValue(
                                      'color', hexColor),
                                );

                                lastLinkedText = _controller.document
                                    .getPlainText(baseOffset, extentOffset);
                                lastLinkedUrl = link;
                                // print("LastLinkText: ${lastLinkedText}");
                                // print("LastLinkURL: ${lastLinkedUrl = link}");
                                _controller.updateSelection(
                                  TextSelection.collapsed(
                                      offset: baseOffset + length),
                                  quill.ChangeSource.local,
                                );
                                setState(() {
                                  isLinkSheet = !isLinkSheet;
                                });
                              } else {
                                setState(() {
                                  isLinkOptionSheet = !isLinkOptionSheet;
                                });
                              }
                            },
                            child: const Icon(
                              FeatherIcons.link2,
                              color: AppColorTheme.muted,
                            ),
                          )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          height: 22,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 0.5, color: AppColorTheme.muted))),
                      InkWell(
                          onTap: handleCloseFormatter,
                          child: const Icon(
                            FeatherIcons.x,
                            color: AppColorTheme.muted,
                          ))
                    ],
                  ),
                ],
              ),
            )
          : Container();
    });
  }

  Widget messageInputBox() {
    final chatProvider = context.watch<ChatProvider>();

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final inputMaxWidth = isTablet ? screenWidth * 0.855 : screenWidth * 0.783;
    final sendButtonSize = isTablet ? 44.0 : 40.0;
    final sendTopPadding = isTablet ? 0.0 : 0.0;

    // print("chatProvider.isGroupEditing ${chatProvider.isGroupEditing}");
    final isReplying = chatProvider.isGroupReplying;
    final isEditing = chatProvider.isGroupEditing;
    final isUploadingFile = chatProvider.isUploadingFile;
    final extension = chatProvider.uploadFileName.split('.').last.toLowerCase();
    final isBlocked = !allowedFileTypes.contains(extension);

    final dataListProvider = context.read<DataListProvider>();
    final Map<String, dynamic> groupMessages = dataListProvider.groupMessages;
    final String currentUserId = dataListProvider.loginUserData['iUserId'];

    final int whoSend = groupMessages['spaceMsgSetting']?['whoSend'] ?? 1;
    final List<dynamic> whoManagers =
        groupMessages['spaceMsgSetting']?['whoManager'] ?? [];

    final bool canSendMessage =
        (whoSend == 1) || (whoSend == 0 && whoManagers.contains(currentUserId));

    if (isEditing) {
      _controller = quill.QuillController(
        document: quill.Document()..insert(0, chatProvider.groupEditingText),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    return canSendMessage
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints:
                    BoxConstraints(maxWidth: inputMaxWidth, maxHeight: 200),
                margin: const EdgeInsets.only(right: 8, bottom: 8),
                padding: isReplying
                    ? const EdgeInsets.only(left: 12, top: 8, right: 12)
                    : const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isEditing
                          ? AppColorTheme.primary
                          : AppColorTheme.border,
                      width: isEditing ? 2 : 1),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColorTheme.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromRGBO(10, 41, 55, 0.12),
                        offset: Offset(0, 8),
                        blurRadius: 16),
                    BoxShadow(
                        color: Color.fromRGBO(10, 41, 55, 0.16),
                        offset: Offset(0, 1),
                        blurRadius: 2),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isReplying) replyPreviewWidget(chatProvider),
                      if (isUploadingFile)
                        uploadPreviewWidget(chatProvider, allowedFileTypes),
                      // === Conditional Input ===
                      if (canSendMessage)
                        isUploadingFile
                            ? Container()
                            : Row(
                                children: [
                                  Expanded(
                                    child: quill.QuillEditor(
                                      controller: _controller,
                                      scrollController: ScrollController(),
                                      config: quill.QuillEditorConfig(
                                        maxHeight: 200,
                                        customRecognizerBuilder:
                                            (attribute, leaf) {
                                          if (attribute.key ==
                                              quill.Attribute.link.key) {
                                            final String link = attribute.value;
                                            final String text =
                                                leaf.toPlainText();
                                            return TapGestureRecognizer()
                                              ..onTap = () {
                                                setState(() {
                                                  currentLinkUrl = link;
                                                  currentLinkText = text;
                                                  linkController.text = link;
                                                  isLinkSheet = true;
                                                });
                                              };
                                          }
                                          return null;
                                        },
                                        customStyleBuilder:
                                            (quill.Attribute? attribute) {
                                          if (attribute != null &&
                                              attribute.key ==
                                                  quill.Attribute.link.key) {
                                            return const TextStyle(
                                              fontFamily: "Nunito",
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.blue,
                                            );
                                          }
                                          return const TextStyle(
                                              fontFamily: "DMSans",
                                              fontSize: 15);
                                        },
                                        autoFocus: false,
                                        showCursor: true,
                                        disableClipboard: true,
                                        placeholder: "Type your text here...",
                                        customStyles: quill.DefaultStyles(
                                          placeHolder:
                                              quill.DefaultTextBlockStyle(
                                            ResponsiveFontStyles
                                                    .dmSans12Regular(context)
                                                .copyWith(
                                                    color: AppColorTheme.dark66,
                                                    fontSize: 14),
                                            quill.HorizontalSpacing.zero,
                                            quill.VerticalSpacing.zero,
                                            quill.VerticalSpacing.zero,
                                            null,
                                          ),
                                        ),
                                      ),
                                      focusNode: focusNode,
                                    ),
                                  ),
                                  if (isEditing)
                                    IconButton(
                                      // padding: const EdgeInsets.only(left: 25),
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.close,
                                          size: 20, color: AppColorTheme.muted),
                                      onPressed: () {
                                        closeEditIcon();
                                      },
                                    ),
                                  if (!isEditing)
                                    IconButton(
                                      padding: isReplying
                                          ? const EdgeInsets.only(left: 23)
                                          : const EdgeInsets.only(left: 0),
                                      onPressed: openMenuBottomSheet,
                                      icon: const Icon(
                                          CupertinoIcons.ellipsis_vertical,
                                          color: AppColorTheme.muted,
                                          size: 20),
                                    ),
                                ],
                              ),
                    ],
                  ),
                ),
              ),
              // === Send Button ===
              if (canSendMessage)
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: isTapped
                      ? null
                      : () {
                          final text =
                              _controller.document.toPlainText().trim();
                          if (chatProvider.isUploadingFile) {
                            final currentFile = chatProvider.isUploadingFile;
                            if (currentFile == lastSentMessage) {
                              return;
                            }
                            setState(() {
                              isTapped = true;
                            });
                            handleOnFileMessageSend();
                            lastSentMessage = currentFile;
                            setState(() {
                              isTapped = false;
                            });
                            return;
                          }
                          if (text.isEmpty || text == lastSentMessage) {
                            return;
                          }
                          setState(() {
                            isTapped = true;
                          });
                          handleOnMessageSend();
                          lastSentMessage = text;
                          setState(() {
                            isTapped = false;
                          });
                        },
                  child: Padding(
                    padding: EdgeInsets.only(top: sendTopPadding, bottom: 8),
                    child: Builder(
                      builder: (context) {
                        var isAnyAllowedFile =
                            chatProvider.uploadFiles.where((item) {
                          final extension =
                              item.name.split('.').last.toLowerCase();
                          return allowedFileTypes.contains(extension);
                        }).toList();

                        final bool isMessageTyped =
                            !_controller.document.isEmpty();

                        double opacity = 0.5;
                        Color iconColor =
                            AppColorTheme.primaryHover.withOpacity(0.7);

                        if ((isUploadingFile && isAnyAllowedFile.isNotEmpty) ||
                            isMessageTyped ||
                            (isReplying && isMessageTyped)) {
                          opacity = 1.0;
                          iconColor = AppColorTheme.primaryHover;
                        } else {
                          opacity = 0.5;
                          iconColor =
                              AppColorTheme.primaryHover.withOpacity(0.7);
                        }

                        return Opacity(
                          opacity: opacity,
                          child: SizedBox(
                            width: sendButtonSize,
                            height: sendButtonSize,
                            child: SvgPicture.asset(
                              AppMedia.send,
                              fit: BoxFit.contain,
                              color: iconColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
            ],
          )
        : Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: AppColorTheme.secondary6,
                borderRadius: BorderRadius.all(Radius.circular(6))),
            alignment: Alignment.center,
            child: const Text(
              "Only Group Manager Can Send The Message",
              style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey),
            ),
          );
  }

  void cancelReplyMessage() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.stopGroupChatReplying();
    chatProvider.clearGroupMsgSelectionIndexes();
    chatProvider.setGroupMsgSelectionMode(false);
    setState(() {});
  }

  Widget replyPreviewWidget(ChatProvider chatProvider) {
    final dataListProvider = context.read<DataListProvider>();
    final currentUserId = dataListProvider.loginUserData['iUserId'];
    // final currentUserId = currentUserData['iUserId'];
    // print("dataListProvider.loginUserData: ${currentUserId}");

    final replySenderId = chatProvider.selectedGroupMsgs.isNotEmpty
        ? chatProvider.selectedGroupMsgs.first['iFromUserId'] ??
            chatProvider.groupReplySenderId
        : chatProvider.groupReplySenderId;
    // print("replySenderId: ${replySenderId}");

    final isSender = replySenderId == currentUserId;
    // print("isSender: ${isSender}");
    final groupMessageData = dataListProvider.groupMessages;
    final userList = groupMessageData['message_user_data'];

    List receiverData = userList != null
        ? userList.where((item) => item['iUserId'] == replySenderId).toList()
        : [];

    final replyUserName = isSender
        ? dataListProvider.loginUserData['vFullName']
        : receiverData.isNotEmpty
            ? receiverData[0]['vFullName']
            : "";
    final htmlContent = chatProvider.isGroupReplying
        ? chatProvider.groupReplyText
        : chatProvider.groupEditingText;

    String extractPlainTextFromHtml(String htmlString) {
      final document = parse(htmlString);
      return document.body?.text.trim() ?? '';
    }

    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: AppColorTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(0, 1),
              blurRadius: 1,
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 2,
              margin:
                  const EdgeInsets.only(right: 8, top: 3, left: 5, bottom: 3),
              decoration: const BoxDecoration(color: AppColorTheme.primary),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chatProvider.selectedGroupMsgs.isNotEmpty ||
                        chatProvider.groupReplySenderId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          replyUserName,
                          style: ResponsiveFontStyles.dmSans13Medium(context)
                              .copyWith(
                            fontSize: 14,
                            color: AppColorTheme.dark70,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (chatProvider.groupReplyHasFile &&
                            chatProvider.groupReplyFileThumb.isNotEmpty) ...[
                          CommonFunctions.isImageFileSvg(
                                  chatProvider.groupReplyFileThumb)
                              ? SvgPicture.network(
                                  chatProvider.groupReplyFileThumb,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    chatProvider.groupReplyFileThumb,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              chatProvider.groupReplyFileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  ResponsiveFontStyles.dmSans15Regular(context)
                                      .copyWith(
                                fontSize: 14,
                                color: AppColorTheme.dark87,
                              ),
                            ),
                          ),
                        ] else
                          Expanded(
                            child: Html(
                              data: htmlContent,
                              style: {
                                'body': Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  fontSize: FontSize(14),
                                  color: AppColorTheme.dark87,
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis,
                                ),
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              constraints: const BoxConstraints(),
              icon:
                  const Icon(Icons.close, size: 18, color: AppColorTheme.muted),
              onPressed: cancelReplyMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget uploadPreviewWidget(
      ChatProvider chatProvider, List<String> allowedFileTypes) {
    if (!chatProvider.isUploadingFile || !chatProvider.uploadHasFile) {
      return const SizedBox.shrink();
    }
    // Multiple files
    if (chatProvider.uploadFiles.isNotEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              children: [
                ...chatProvider.uploadFiles.asMap().entries.map(
                      (e) => _singleFilePreview(
                        thumbPath: e.value.path ?? '',
                        fileName: e.value.name,
                        onRemove: () => chatProvider.removeUploadFile(e.key),
                        allowedFileTypes: allowedFileTypes,
                      ),
                    ),
              ],
            ),
          ),
          InkWell(
            onTap: openMenuBottomSheet,
            child: const Padding(
              padding: EdgeInsets.only(top: 5, right: 6, bottom: 18),
              child: Icon(CupertinoIcons.ellipsis_vertical,
                  color: AppColorTheme.muted, size: 20),
            ),
          ),
        ],
      );
    }

    // Single file
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _singleFilePreview(
            thumbPath: chatProvider.uploadFileThumb,
            fileName: chatProvider.uploadFileName,
            onRemove: () => chatProvider.stopUserChatFileUpload(),
            allowedFileTypes: allowedFileTypes,
          ),
        ),
        InkWell(
          onTap: openMenuBottomSheet,
          child: const Padding(
            padding: EdgeInsets.only(top: 0, right: 6, bottom: 18),
            child: Icon(CupertinoIcons.ellipsis_vertical,
                color: AppColorTheme.muted, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _singleFilePreview(
      {required String thumbPath,
      required String fileName,
      required VoidCallback onRemove,
      required List<String> allowedFileTypes}) {
    final file = File(thumbPath);
    final exists = thumbPath.isNotEmpty && file.existsSync();
    if (!exists) return const SizedBox.shrink();

    final isImage = CommonFunctions.isImage(fileName);
    final extension = fileName.split('.').last.toLowerCase();
    final isBlocked = !allowedFileTypes.contains(extension);
    final fileSizeMB = file.lengthSync() / (1024 * 1024);

    return Container(
      margin: const EdgeInsets.only(top: 8, right: 5, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: isBlocked
                ? SvgPicture.asset("assets/imagethumb.svg")
                : isImage
                    ? Image.file(file, width: 48, height: 48, fit: BoxFit.cover)
                    : SvgPicture.asset(AppMedia.file, width: 50, height: 50),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBlocked
                      ? 'Document ${fileName.split('.').last} not allowed'
                      : fileName,
                  maxLines: isBlocked ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: ResponsiveFontStyles.dmSans15Medium(context).copyWith(
                    fontSize: 16,
                    // fontWeight: FontWeight.w600,
                    color: AppColorTheme.dark70,
                  ),
                ),
                if (!isBlocked) const SizedBox(height: 4),
                if (!isBlocked)
                  Text(
                    '${fileSizeMB.toStringAsFixed(2)} MB',
                    style:
                        ResponsiveFontStyles.dmSans15Regular(context).copyWith(
                      fontSize: 13,
                      color: AppColorTheme.muted,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  //******* Toggle Attributes *********//
  void toggleAttribute(quill.Attribute attribute) {
    final selection = _controller.selection;
    if (!selection.isValid) return;

    final currentStyle = _controller.getSelectionStyle();
    final isAttributeActive = currentStyle.attributes[attribute.key] != null;

    String selectedText = _controller.document.getPlainText(
      selection.start,
      selection.end - selection.start,
    );

    final allowedEmojis = emojiToImage.map((e) => e['emoji']).toSet();

    bool isOnlyEmojis(String text) {
      if (text.isEmpty) return false;
      final chars = text.characters.toList();
      return chars.every((ch) => allowedEmojis.contains(ch));
    }

    final onlyEmojisSelected = isOnlyEmojis(selectedText);

    setState(() {
      if (isAttributeActive) {
        if (!onlyEmojisSelected) {
          _controller.formatSelection(quill.Attribute.clone(attribute, null));
        }
        _lastKnownStyle.remove(attribute.key);
        _updateToggleState(attribute, false);
      } else {
        if (!onlyEmojisSelected) {
          _controller.formatSelection(attribute);
        }
        _lastKnownStyle[attribute.key] = attribute;
        _updateToggleState(attribute, true);
      }
    });
  }

  void _updateToggleState(quill.Attribute attribute, bool enabled) {
    if (attribute.key == quill.Attribute.bold.key) {
      isBoldSelected = enabled;
    } else if (attribute.key == quill.Attribute.italic.key) {
      isItalicSelected = enabled;
    } else if (attribute.key == quill.Attribute.underline.key) {
      isUnderlineSelected = enabled;
    } else if (attribute.key == quill.Attribute.strikeThrough.key) {
      isStrikeThroughSelected = enabled;
    } else if (attribute.key == quill.Attribute.ul.key) {
      isBulletSelected = enabled;
    } else if (attribute.key == quill.Attribute.link.key) {
      isLinkSelected = enabled;
    }
  }

  // apply style to the text color
  void applyTextStyle(TextStyle style) {
    final selection = _controller.selection;
    final hexColor = '#${style.color!.value.toRadixString(16).substring(2)}';
    final colorAttribute = quill.Attribute.fromKeyValue('color', hexColor);
    if (!selection.isCollapsed) {
      _controller.formatSelection(colorAttribute);
    } else {
      _controller.formatSelection(colorAttribute);
    }

    setState(() {
      textSelection = selection;
      selectedStyle = style;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<ChatProvider>(builder: (context, chatProvider, child) {
              return Column(
                children: [
                  chatProvider.isEmojiOptionList
                      ? openEmojiOptionList()
                      : Container()
                ],
              );
            }),
            if (isLinkOptionSheet) openLinkOptionSheet(),
            if (isLinkSheet) openLinkSheet(),
            messageInputBox(),
            messageFormatter(),
          ],
        ),
      ),
      if (showColorBar) ...[
        Positioned.fill(
          child: GestureDetector(
            onTap: () => setState(() => showColorBar = false),
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          bottom: 15,
          left: 20,
          right: 20,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: colorBar(),
          ),
        )
      ],
    ]);
  }

  //******** Insert Link **********//

  void _insertLink() {
    String name = textController.text.trim();
    String link = linkController.text.trim();

    final baseOffset = _controller.selection.baseOffset;
    final length = _controller.selection.extentOffset - baseOffset;

    if (name.isNotEmpty && link.isNotEmpty) {
      final currentStyle = _controller.getSelectionStyle();

      _controller.replaceText(baseOffset, length, name, null);

      _controller.formatText(
        baseOffset,
        name.length,
        quill.LinkAttribute(link),
      );

      if (currentStyle.attributes[quill.Attribute.bold.key] != null) {
        _controller.formatText(
          baseOffset,
          name.length,
          quill.Attribute.bold,
        );
      }

      if (currentStyle.attributes[quill.Attribute.italic.key] != null) {
        _controller.formatText(
          baseOffset,
          name.length,
          quill.Attribute.italic,
        );
      }

      if (currentStyle.attributes[quill.Attribute.underline.key] != null) {
        _controller.formatText(
          baseOffset,
          name.length,
          quill.Attribute.underline,
        );
      }

      String hexColor = currentStyle.attributes['color']?.value ?? '#000000';
      _controller.formatText(
        baseOffset,
        name.length,
        quill.Attribute.fromKeyValue('color', hexColor),
      );

      _controller.updateSelection(
        TextSelection.collapsed(offset: baseOffset + name.length),
        quill.ChangeSource.local,
      );

      // print("Inserted Link: $link with Name: $name");
      setState(() {
        textController.clear();
        // print("Link 1==================================================");
        linkController.clear();
      });
    } else {
      // print("Name and link cannot be empty");
    }
  }

  //******** Insert Text & Link Sheet **********//

  Widget openLinkOptionSheet() {
    return GestureDetector(
      onTap: () {
        // print("linkControllerlinkController ..... ${linkController.text}");
        setState(() {
          isLinkOptionSheet = true;
          linkController.clear();
        });
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                bottom: 15,
                top: 10,
              ),
              height: 220,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.black45.withOpacity(0.4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 12, left: 12, top: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Text",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 14.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: textController,
                              onChanged: (value) {
                                setState(() {
                                  textController.text = value;
                                });
                              },
                              cursorHeight: 15,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Link",
                                hintStyle: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 14.5,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextStyle(height: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "Link",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 14.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: linkController,
                              cursorHeight: 15,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Link",
                                hintStyle: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 14.5,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextStyle(height: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _insertLink();
                        // print("Inserted Link:");
                        setState(() {
                          isLinkOptionSheet = !isLinkOptionSheet;
                          // print("Link 2==================================================");
                          linkController.clear();
                        });
                        // print("linkControllerlinkController after ${linkController.text}");
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 14, left: 0, right: 0),
                        height: 35,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(2, 2),
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Apply",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 14.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //******** Insert Link Sheet **********//

  Widget openLinkSheet() {
    return GestureDetector(
      onTap: () {
        // print("linkControllerlinkController before ${linkController.text}");
        setState(() {
          isLinkSheet = true;
          linkController.text.trim();
          // print("After Link: ${linkController.text}");
        });
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 10,
              ),
              height: 150,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.black45.withOpacity(0.4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 12, left: 12, top: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Link",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(Icons.link_off, color: Colors.red),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: linkController,
                              cursorHeight: 15,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 14.5,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: const TextStyle(height: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // print("Inserted Link : ");
                        setState(() {
                          isLinkSheet = !isLinkSheet;
                          linkController.text.trim();
                          // print("Link:--------------- ${linkController.text}");
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 14, left: 0, right: 0),
                        height: 35,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(2, 2),
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Apply",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 14.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //******** Emoji Option List **********//

  Widget openEmojiOptionList() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isEmojiOptionList = true;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(blurRadius: 4, color: Colors.black26.withOpacity(0.3)),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add emoji",
                        style: TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 15,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            handleEmojiList();
                          });
                        },
                        child: Icon(
                          FeatherIcons.x,
                          size: 19,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  children: emojiToImage.map((index) {
                    // print("index: $index");
                    return GestureDetector(
                      onTap: () {
                        final String emoji = index['emoji'];
                        final selection = _controller.selection;
                        final baseOffset = selection.baseOffset;
                        final length = selection.extentOffset - baseOffset;
                        final currentStyle = _controller.getSelectionStyle();
                        _controller.replaceText(
                          baseOffset,
                          length,
                          emoji,
                          TextSelection.collapsed(
                            offset: baseOffset + emoji.length,
                            affinity: TextAffinity.upstream,
                          ),
                        );

                        final nextOffset = baseOffset + emoji.length;

                        if (!emoji.contains(RegExp(r'[a-zA-Z0-9]'))) {
                          _controller.formatText(
                            nextOffset - emoji.length,
                            emoji.length,
                            quill.Attribute.clone(quill.Attribute.bold, null),
                          );
                          _controller.formatText(
                            nextOffset - emoji.length,
                            emoji.length,
                            quill.Attribute.clone(quill.Attribute.italic, null),
                          );
                          _controller.formatText(
                            nextOffset - emoji.length,
                            emoji.length,
                            quill.Attribute.clone(
                              quill.Attribute.underline,
                              null,
                            ),
                          );
                          _controller.formatText(
                            nextOffset - emoji.length,
                            emoji.length,
                            quill.Attribute.clone(
                              quill.Attribute.strikeThrough,
                              null,
                            ),
                          );
                          _controller.formatText(
                            nextOffset - emoji.length,
                            emoji.length,
                            quill.Attribute.clone(quill.Attribute.ul, null),
                          );
                          _controller.formatText(
                            nextOffset - emoji.length,
                            emoji.length,
                            quill.Attribute.fromKeyValue('color', '#000000'),
                          );
                        }
                        currentStyle.attributes.forEach((key, value) {
                          _controller.formatText(nextOffset, 0, value);
                        });
                        // Preserve and reapply previous formatting
                        //how to convert to the using asMAp.entries though pass the particular emoji index and null the  particular emoji style how can ??
                        // Apply previous formatting dynamically for all emojis
                        // currentStyle.attributes.forEach((key, value) {
                        //   _controller.formatText(
                        //     nextOffset - emoji.length,
                        //     emoji.length,
                        //     value,
                        //   );
                        // });
                        // print("Inserted Emoji: $emoji ");
                        // print("current Position to emoji: $currentStyle");
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          index['emoji'],
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
