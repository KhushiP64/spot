import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/utils.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/providers/data_list_provider.dart';
import 'package:spot/socket/socket_message_events.dart';
import 'package:spot/ui/widgets/common_widgets/button.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:spot/ui/widgets/common_widgets/input.dart';
import 'package:spot/ui/widgets/common_widgets/large_profile_pic.dart';
import 'package:spot/ui/widgets/common_widgets/profile_icon_status_dot.dart';
import 'package:spot/ui/widgets/message_widgets/convert_decoded_text_to_html_style.dart';
import 'package:spot/ui/widgets/message_widgets/message_menu_bottomsheet.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../../core/themes.dart';
import '../../../firebase_helper/fcm_notification_helper.dart';
import 'package:html/parser.dart' show parse;

class UserChatMessageBox extends StatefulWidget {
  final TextEditingController sendMessageText;
  final FocusNode? focusNode;
  final Function(String)? onChangedSendMessageText;
  late String type;
  final String? formattedTime;

  UserChatMessageBox(
    {
      super.key,
      required this.sendMessageText,
      this.focusNode,
      this.onChangedSendMessageText,
      required this.type,
      this.formattedTime
    });

  @override
  State<UserChatMessageBox> createState() => _UserChatMessageBoxState();
}

class _UserChatMessageBoxState extends State<UserChatMessageBox> {
  var showColorBar = false;
  Color selectedColor = const Color(0XFF000000);
  String selectedText = '';
  late quill.QuillController _controller = quill.QuillController.basic();
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
  // late quill.QuillController _controller;
  String htmlContent = ""; // 👈 Declare here
  // @override
  // void initState() {
  //   super.initState();
  //   FcmNotificationHelper.instance.initFcm();
  //   // _controller.addListener(_handleTyping);
  //   _loadAllowedFileTypes();
  //   // _controller = quill.QuillController.basic();
  //   //
  //   // final chatProvider = context.read<ChatProvider>();
  //   //
  //   // _controller = chatProvider.isUserEditing && chatProvider.userEditingText.isNotEmpty
  //   //     ? quill.QuillController(
  //   //   document: quill.Document()..insert(0, chatProvider.userEditingText),
  //   //   selection: const TextSelection.collapsed(offset: 0),
  //   // )
  //   //     : quill.QuillController.basic();
  //
  //   final chatProvider = context.read<ChatProvider>();
  //
  //   if (chatProvider.isUserEditing && chatProvider.userEditingText.isNotEmpty) {
  //     final doc = quill.Document()..insert(0, chatProvider.userEditingText);
  //
  //     _controller = quill.QuillController(
  //       document: doc,
  //       selection: TextSelection.collapsed(offset: doc.length),
  //     );
  //   } else {
  //     _controller = quill.QuillController.basic();
  //   }
  //
  //   startControllerListener();
  // }
  @override
  void initState() {
    super.initState();
    FcmNotificationHelper.instance.initFcm();
    _loadAllowedFileTypes();

    final chatProvider = context.read<ChatProvider>();

    if (chatProvider.isUserEditing && chatProvider.userEditingText.isNotEmpty) {
      final doc = quill.Document()..insert(0, chatProvider.userEditingText);
      _controller = quill.QuillController(
        document: doc,
        selection: TextSelection.collapsed(offset: doc.length),
      );
    } else {
      _controller = quill.QuillController.basic();
    }

    // initializeEditorAndConvertHtml();

    startControllerListener();
  }

  void initializeEditorAndConvertHtml() {
    final chatProvider = context.read<ChatProvider>();

    // Step 1: Initialize Controller
    if (chatProvider.isUserEditing && chatProvider.userEditingText.isNotEmpty) {
      final doc = quill.Document()..insert(0, chatProvider.userEditingText);
      _controller = quill.QuillController(
        document: doc,
        selection: TextSelection.collapsed(offset: doc.length),
      );
    } else {
      _controller = quill.QuillController.basic();
    }

    ConvertDecodedTextToHtmlStyle(
        message: chatProvider.isUserEditing ? chatProvider.userEditingText : "",
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(14),
            color: AppColorTheme.dark87,
            maxLines: 2,
            textOverflow: TextOverflow.ellipsis
          )
        });
  }

  // void startControllerListener(){
  //   _controller.addListener(() {
  //     final style = _controller.getSelectionStyle();
  //     setState(() {
  //       isBoldSelected = style.attributes.containsKey(quill.Attribute.bold.key);
  //       isItalicSelected = style.attributes.containsKey(quill.Attribute.italic.key);
  //       isUnderlineSelected = style.attributes.containsKey(quill.Attribute.underline.key);
  //       isStrikeThroughSelected = style.attributes.containsKey(quill.Attribute.strikeThrough.key);
  //       isBulletSelected = style.attributes.containsKey(quill.Attribute.ul.key);
  //       isLinkSelected = style.attributes.containsKey(quill.Attribute.link.key);
  //     });
  //
  //     if (style.attributes.isNotEmpty) {
  //       _lastKnownStyle = Map.from(style.attributes);
  //     }
  //     // _handleTyping();
  //     _onTextChanged();
  //     _filterEmojis();
  //   });
  // }

  void startControllerListener() {
    _controller.addListener(() {
      final selection = _controller.selection;
      final style = _controller.getSelectionStyle();

      if (style.attributes.isNotEmpty) {
        _lastKnownStyle = Map.from(style.attributes);
      }
      if (style.attributes.isEmpty && _controller.document.length == 1 && _lastKnownStyle.isNotEmpty && selection.isValid) {
        _lastKnownStyle.forEach((key, attr) {
          _controller.formatSelection(attr);
        });
      }

      final useStyle = (style.attributes.isEmpty && _controller.document.length == 1) ? _lastKnownStyle : style.attributes;

      setState(() {
        isBoldSelected = useStyle.containsKey(quill.Attribute.bold.key);
        isItalicSelected = useStyle.containsKey(quill.Attribute.italic.key);
        isUnderlineSelected = useStyle.containsKey(quill.Attribute.underline.key);
        isStrikeThroughSelected = useStyle.containsKey(quill.Attribute.strikeThrough.key);
        isBulletSelected = useStyle.containsKey(quill.Attribute.ul.key);
        isLinkSelected = useStyle.containsKey(quill.Attribute.link.key);
      });

      _onTextChanged();
      // _filterEmojis();
    });
  }

  void _onTextChanged() {
    // _filterEmojis();
    final plainText = _controller.document.toPlainText().trim();
    if (plainText.isNotEmpty) {
      final now = DateTime.now();
      if (_lastTypingTime == null || now.difference(_lastTypingTime!) > _typingDelay) {
        _handleTyping(plainText);
        _lastTypingTime = now;
      }
    }
  }

  void _handleTyping(String text) async {
    if (text.isNotEmpty && !isMsgExist) {
      setState(() {
        isMsgExist = true;
      });
    } else if (text.isEmpty && isMsgExist) {
      setState(() {
        isMsgExist = false;
      });
    }
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

  _filterEmojis() {
    final plainText = _controller.document.toPlainText().trim();
    final allowedEmojis = emojiToImage.map((e) => e['emoji']).toSet();
    final currentPosition = _controller.selection.baseOffset;

    final filteredChars = plainText.characters.where((char) {
      return allowedEmojis.contains(char) || !isEmoji(char);
    }).toList();

    final filteredText = filteredChars.join();

    if (filteredText != plainText) {
      // Replace document without triggering change events
      _controller.document.delete(0, _controller.document.length);
      _controller.document.insert(0, filteredText);

      int newPosition = currentPosition;
      if (currentPosition > filteredText.length)
        newPosition = filteredText.length;

      _controller.updateSelection(
        TextSelection.collapsed(offset: newPosition),
        quill.ChangeSource.local,
      );
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final chatProvider = context.watch<ChatProvider>();
  //
  //   if (chatProvider.isUserEditing &&
  //       _controller.document.toPlainText().trim() !=
  //           chatProvider.userEditingText.trim()) {
  //     _controller = quill.QuillController(
  //       document: quill.Document()..insert(0, chatProvider.userEditingText),
  //       selection: const TextSelection.collapsed(offset: 0),
  //     );
  //     setState(() {});
  //   }
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final chatProvider = context.read<ChatProvider>();
  //   if (chatProvider.isUserEditing && _controller.document.toPlainText().trim() != chatProvider.userEditingText.trim()) {
  //     final newDoc = quill.Document()..insert(0, ConvertDecodedTextToHtmlStyle(message: chatProvider.userEditingText));
  //     _controller.document = newDoc;
  //     final safeOffset = newDoc.length.clamp(0, newDoc.length);
  //     _controller.updateSelection(
  //       TextSelection.collapsed(offset: safeOffset),
  //       quill.ChangeSource.local,
  //     );
  //   }
  // }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final chatProvider = context.read<ChatProvider>();

    if (chatProvider.isUserEditing &&
        _controller.document.toPlainText().trim() !=
            chatProvider.userEditingText.trim()) {
      final newDoc = quill.Document()..insert(0, chatProvider.userEditingText);
      _controller.document = newDoc;

      // print("newDoc plain: ${newDoc.toPlainText()}");
      // print("newDoc delta: ${newDoc.toDelta()}");
      final safeOffset = newDoc.length.clamp(0, newDoc.length);
      _controller.updateSelection(
        TextSelection.collapsed(offset: safeOffset),
        quill.ChangeSource.local,
      );
    }
    // initializeEditorAndConvertHtml();
  }

  //********************** all allowed file list **********************
  List<String> allowedFileTypes = [];
  Future<void> _loadAllowedFileTypes() async {
    final result = await CommonFunctions.getAllowedFileList();
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        allowedFileTypes = List<String>.from(result['filePermission'] ?? []);
        // log("allowedFileTypes: $allowedFileTypes");
      });
    } else {
      allowedFileTypes = [];
    }
  }

  String escapeHtml(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String escapeHtmlWithAllowedTags(String input,
      {List<String> formatterTags = const []}) {
    String escaped = input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');

    final allowedTags = <String>[
      'ul',
      'li',
      'i',
      'u',
      'a',
      'b',
      'br',
      'font',
      'img',
      ...formatterTags
    ];

    for (final tag in allowedTags.toSet()) {
      final openTagPattern =
          RegExp('&lt;($tag)(\\s+[^&]*)&gt;', caseSensitive: false);
      escaped = escaped.replaceAllMapped(
          openTagPattern, (m) => '<${m[1]}${m[2] ?? ''}>');

      final selfClosingPattern =
          RegExp('&lt;($tag)(\\s+[^&]*)/&gt;', caseSensitive: false);
      escaped = escaped.replaceAllMapped(
          selfClosingPattern, (m) => '<${m[1]}${m[2] ?? ''}/>');

      final closeTagPattern = RegExp('&lt;/($tag)&gt;', caseSensitive: false);
      escaped = escaped.replaceAllMapped(closeTagPattern, (m) => '</${m[1]}>');
    }

    return escaped;
  }

  List<String> getActiveFormatterTags() {
    final tags = <String>[];
    if (isBoldSelected) tags.add('b');
    if (isItalicSelected) tags.add('i');
    if (isUnderlineSelected) tags.add('u');
    if (isStrikeThroughSelected) tags.add('strike');
    if (isBulletSelected) tags.addAll(['ul', 'li']);
    tags.add('a'); // for links
    tags.add('font'); // for colors
    return tags;
  }

  String restoreOnlyAllowedTags(String text,
      {List<String> allowedTags = const []}) {
    String result = text;

    for (final tag in allowedTags) {
      // Restore opening tag
      result = result.replaceAll('&lt;$tag', '<$tag');
      // Restore closing tag
      result = result.replaceAll('&lt;/$tag&gt;', '</$tag>');
      // Restore self-closing tag
      result = result.replaceAll('&lt;$tag/&gt;', '<$tag/>');
      // Fix '>' in opening tags
      result =
          result.replaceAll(RegExp('&gt;(?=(.*</$tag>|.*<$tag[^>]*>))'), '>');
    }

    return result;
  }

  String convertDocumentToHtmlSafe(quill.Document doc,
      {List<String> allowedTags = const [
        'ul',
        'li',
        'i',
        'u',
        'a',
        'b',
        'br',
        'font',
        'img',
        'del',
        'span'
      ]}) {
    final ops = doc.toDelta().toList();
    final buffer = StringBuffer();
    bool isInList = false;
    String? listType;

    for (int i = 0; i < ops.length; i++) {
      final op = ops[i];
      final data = op.data;
      final attrs = op.attributes;
      String formatted = '';

      if (data is String && data != '\n') {
        String rawText = data;
        bool isFormatterTag = false;

        if (attrs != null) {
          final hasLink = attrs.containsKey('link');
          final color = attrs['color'];
          final isBold = attrs['bold'] == true;
          final isItalic = attrs['italic'] == true;
          final isUnderline = attrs['underline'] == true;
          final isStrike = attrs['strike'] == true;

          if (hasLink && allowedTags.contains('a')) {
            isFormatterTag = true;
            final link = attrs['link'];
            rawText =
                '&lt;a href="$link" target="_blank" style="text-decoration: none;"&gt;'
                '&lt;span style="color:#37AFE1; text-decoration: underline; text-decoration-color: #37AFE1; font-weight: 600;"&gt;$rawText&lt;/span&gt;'
                '&lt;/a&gt;';
          } else {
            if (isStrike && allowedTags.contains('del')) {
              isFormatterTag = true;
              rawText = '&lt;del&gt;$rawText&lt;/del&gt;';
            }
            if (isBold && allowedTags.contains('b')) {
              isFormatterTag = true;
              rawText = '&lt;b&gt;$rawText&lt;/b&gt;';
            }

            // ✅ Italic preserve
            if (isItalic && allowedTags.contains('i')) {
              isFormatterTag = true;
              rawText = '&lt;i&gt;$rawText&lt;/i&gt;';
            }

            // ✅ Underline + color in one style (inherit if both exist)
            // if ((isUnderline || color != null) && allowedTags.contains('font')) {
            //   isFormatterTag = true;
            //   final underlineStyle =
            //   isUnderline ? 'text-decoration: underline; ' : '';
            //   final colorStyle = color != null ? 'color:$color; ' : '';
            //   rawText =
            //   '&lt;font style="$underlineStyle$colorStyle"&gt;$rawText&lt;/font&gt;';
            // }
            // if ((isUnderline || color != null || isItalic) && allowedTags.contains('font')) {
            //   isFormatterTag = true;
            //
            //   final underlineStyle = isUnderline ? 'text-decoration: underline; ' : '';
            //   final colorStyle = color != null ? 'color:$color; ' : '';
            //   final italicStyle = isItalic ? 'font-style: italic; ' : '';
            //
            //   rawText =
            //   '&lt;font style="$underlineStyle$colorStyle$italicStyle"&gt;$rawText&lt;/font&gt;';
            // }
            if ((isUnderline ||
                    color != null ||
                    isItalic ||
                    isBold ||
                    isStrike) &&
                allowedTags.contains('font')) {
              isFormatterTag = true;

              final colorStyle = color != null ? 'color:$color; ' : '';
              final italicStyle = isItalic ? 'font-style: italic; ' : '';
              final boldStyle = isBold ? 'font-weight: bold; ' : '';

              // Merge text-decoration styles if underline and strike both exist
              String textDecoration = '';
              if (isUnderline && isStrike) {
                textDecoration = 'text-decoration: underline line-through; ';
              } else if (isUnderline) {
                textDecoration = 'text-decoration: underline; ';
              } else if (isStrike) {
                textDecoration = 'text-decoration: line-through; ';
              }

              // Apply underline/strike color if a color is set
              final textDecorationColor =
                  (color != null && (isUnderline || isStrike))
                      ? 'text-decoration-color: $color; '
                      : '';

              rawText =
                  '&lt;font style="$textDecoration$textDecorationColor$colorStyle$italicStyle$boldStyle"&gt;$rawText&lt;/font&gt;';
            }
          }
        }

        formatted = rawText;

        final nextOp = (i + 1 < ops.length) ? ops[i + 1] : null;
        final nextAttrs = nextOp?.attributes;

        // List handling
        if (nextOp != null &&
            nextOp.data == '\n' &&
            nextAttrs != null &&
            nextAttrs.containsKey('list') &&
            (allowedTags.contains('ul') || allowedTags.contains('li'))) {
          final lt = nextAttrs['list'];

          if (!isInList) {
            if (lt == 'bullet' && allowedTags.contains('ul')) {
              buffer.write('<ul>');
              listType = 'bullet';
            } else if (allowedTags.contains('ol')) {
              buffer.write('<ol>');
              listType = 'ordered';
            }
            isInList = true;
          }

          String? bulletColor;
          if (attrs != null && attrs.containsKey('color')) {
            bulletColor = attrs['color'];
          }
          final colorStyle =
              bulletColor != null ? ' style="color:$bulletColor;"' : '';

          buffer.write('<li$colorStyle>$formatted</li>');
          i++; // skip newline
        } else {
          if (isInList) {
            buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
            isInList = false;
            listType = null;
          }
          buffer.write(formatted);
        }
      } else if (data is String && data == '\n') {
        final lt = attrs?['list'];
        final isLastOp = i == ops.length - 1;

        if (lt == null && !isLastOp) {
          if (isInList) {
            buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
            isInList = false;
            listType = null;
          } else if (allowedTags.contains('br')) {
            buffer.write('<br/>');
          }
        }
      } else if (data is Map &&
          attrs != null &&
          attrs.containsKey('image') &&
          allowedTags.contains('img')) {
        final imageUrl = attrs['image'];
        buffer.write('<img src="$imageUrl" alt=""/>');
      }
    }
    if (isInList) {
      buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
    }
    return buffer.toString();
  }

  // String convertDocumentToHtmlSafe(quill.Document doc, {List<String> allowedTags = const [
  //   'ul', 'li', 'i', 'u', 'a', 'b', 'br', 'font', 'img', 'del', 'span'
  // ]}) {
  //   final ops = doc.toDelta().toList();
  //   final buffer = StringBuffer();
  //   bool isInList = false;
  //   String? listType;
  //
  //   for (int i = 0; i < ops.length; i++) {
  //     final op = ops[i];
  //     final data = op.data;
  //     final attrs = op.attributes;
  //     String formatted = '';
  //
  //     if (data is String && data != '\n') {
  //       String rawText = data;
  //
  //       if (attrs != null) {
  //         final hasLink = attrs.containsKey('link');
  //         final color = attrs['color'] ?? '#000000';
  //         final isBold = attrs['bold'] == true;
  //         final isItalic = attrs['italic'] == true;
  //         final isUnderline = attrs['underline'] == true;
  //         final isStrike = attrs['strike'] == true;
  //
  //         if (hasLink && allowedTags.contains('a')) {
  //           final link = attrs['link'];
  //           rawText =
  //           '<a href="$link" target="_blank" style="text-decoration: none;">'
  //               '<span style="color:#37AFE1; text-decoration: underline; text-decoration-color: #37AFE1; font-weight: 600;">$rawText</span>'
  //               '</a>';
  //         } else {
  //           if (isStrike && allowedTags.contains('del')) rawText = '<del>$rawText</del>';
  //           if (isBold && allowedTags.contains('b')) rawText = '<b>$rawText</b>';
  //           if (isItalic && allowedTags.contains('i')) rawText = '<i>$rawText</i>';
  //           if (isUnderline && allowedTags.contains('u')) {
  //             rawText =
  //             '<span style="text-decoration: underline; text-decoration-color: $color;">$rawText</span>';
  //           }
  //           if (attrs.containsKey('color') && allowedTags.contains('span')) {
  //             rawText = '<span style="color:$color;">$rawText</span>';
  //           }
  //         }
  //       }
  //
  //       formatted = rawText;
  //
  //       final nextOp = (i + 1 < ops.length) ? ops[i + 1] : null;
  //       final nextAttrs = nextOp?.attributes;
  //
  //       // List handling
  //       if (nextOp != null &&
  //           nextOp.data == '\n' &&
  //           nextAttrs != null &&
  //           nextAttrs.containsKey('list') &&
  //           (allowedTags.contains('ul') || allowedTags.contains('li'))) {
  //         final lt = nextAttrs['list'];
  //
  //         if (!isInList) {
  //           if (lt == 'bullet' && allowedTags.contains('ul')) {
  //             buffer.write('<ul>');
  //             listType = 'bullet';
  //           } else if (allowedTags.contains('ol')) {
  //             buffer.write('<ol>');
  //             listType = 'ordered';
  //           }
  //           isInList = true;
  //         }
  //
  //         String? bulletColor;
  //         if (attrs != null && attrs.containsKey('color')) {
  //           bulletColor = attrs['color'];
  //         }
  //         final colorStyle = bulletColor != null ? ' style="color:$bulletColor;"' : '';
  //
  //         buffer.write('<li$colorStyle>$formatted</li>');
  //         i++; // skip newline
  //       } else {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         }
  //         buffer.write(formatted);
  //       }
  //     } else if (data is String && data == '\n') {
  //       final lt = attrs?['list'];
  //       final isLastOp = i == ops.length - 1;
  //
  //       if (lt == null && !isLastOp) {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         } else if (allowedTags.contains('br')) {
  //           buffer.write('<br/>');
  //         }
  //       }
  //     } else if (data is Map && attrs != null && attrs.containsKey('image') && allowedTags.contains('img')) {
  //       final imageUrl = attrs['image'];
  //       buffer.write('<img src="$imageUrl"/>');
  //     }
  //   }
  //
  //   if (isInList) {
  //     buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //   }
  //
  //   return buffer.toString();
  // }

  // void handleOnMessageSend() async {
  //   final chatProvider = context.read<ChatProvider>();
  //   final dataListProvider = context.read<DataListProvider>();
  //   final text = _controller.document.toPlainText().trim();
  //
  //   if (text.isEmpty) return;
  //
  //   final currentUser = await CommonFunctions.getLoginUser();
  //   final String senderChatID = currentUser['_id'];
  //   final String receiverChatID = dataListProvider.openedChatUserData['_id'];
  //   final String receiverName = dataListProvider.openedChatUserData['vFullName'];
  //   final String? receiverFcmToken = dataListProvider.openedChatUserData['tToken'];
  //
  //   // Convert Quill document to HTML-safe string
  //   String content = escapeHtml(convertDocumentToHtmlSafe(_controller.document));
  //   print("Escaped content: $content");
  //
  //   if (content.trim().isEmpty) content = escapeHtml(text);
  //
  //   final isReplying = chatProvider.isUserReplying;
  //   final isEditing = chatProvider.isUserEditing;
  //
  //   final vReplyMsg = isReplying ? chatProvider.userReplyText : '';
  //   final vReplyMsg_id = isReplying && chatProvider.selectedMsgs.isNotEmpty
  //       ? (chatProvider.selectedMsgs.first['id'] ?? '')
  //       : '';
  //   final vReplyFileName = isReplying ? chatProvider.userReplyFileName : '';
  //
  //   // Handle edit case
  //   if (isEditing && chatProvider.editingMessageId != null) {
  //     final updateResponse = await CommonFunctions.updateUserMessage(
  //       content,
  //       '',
  //       receiverChatID,
  //       chatProvider.editingMessageId!,
  //     );
  //
  //     if (updateResponse['status'] == 200) {
  //       final updatedList = CommonFunctions.replaceMatchingItemsById(
  //         context: context,
  //         originalList: dataListProvider.userMessagesList,
  //         updatedList: updateResponse['fullMessageData'],
  //       );
  //       dataListProvider.setUserMessageList(updatedList);
  //       chatProvider.setMsgSelectionMode(false);
  //       chatProvider.clearMsgSelectionIndexes();
  //     }
  //
  //     chatProvider.stopUserChatEditing();
  //     _controller = quill.QuillController.basic();
  //     setState(() {});
  //     return;
  //   }
  //
  //   // Construct unique message ID
  //   final String newMessageId =
  //       "${receiverChatID}_${senderChatID}_${DateTime.now().millisecondsSinceEpoch}";
  //
  //   // Send message over socket
  //   SocketMessageEvents.sendMessageEvent(
  //     receiverChatID: receiverChatID,
  //     senderChatID: senderChatID,
  //     content: content,
  //     imageDataArr: [],
  //     vReplyMsg: vReplyMsg,
  //     vReplyMsg_id: vReplyMsg_id,
  //     vReplyFileName: vReplyFileName,
  //     id: newMessageId,
  //     iRequestMsg: 0,
  //     isForwardMsg: 0,
  //     isForwardMsg_id: '',
  //     isDeleteprofile: 0,
  //     chat: 1,
  //   );
  //
  //   // Send push notification
  //   if (receiverFcmToken != null && receiverFcmToken.isNotEmpty) {
  //     try {
  //       await FcmNotificationHelper.instance.sendFCMPush(
  //         fcmToken: receiverFcmToken,
  //         title: currentUser['vFullName'] ?? "New Message",
  //         body: text,
  //         data: {
  //           "chatId": dataListProvider.openedChatUserData['vChatId'],
  //           "isGroup": "false",
  //           "type": "chat",
  //           "msgType": "text",
  //         },
  //       );
  //       print("Notification send successfully................");
  //     } catch (e) {
  //       print("Notification send failed: $e");
  //     }
  //   }
  //
  //   // Reset state and input box
  //   _controller = quill.QuillController.basic();
  //   _controller.document = quill.Document();
  //   chatProvider.setMsgSelectionMode(false);
  //   chatProvider.clearMsgSelectionIndexes();
  //   chatProvider.stopUserChatReplying();
  //   isMsgExist = false;
  //   setState(() {});
  //
  //   startControllerListener();
  // }
// Your updated send function
//   void handleOnMessageSend() async {
//     final chatProvider = context.read<ChatProvider>();
//     final dataListProvider = context.read<DataListProvider>();
//     final text = _controller.document.toPlainText().trim();
//
//     if (text.isEmpty) return;
//
//     final currentUser = await CommonFunctions.getLoginUser();
//     final String senderChatID = currentUser['_id'];
//     final String receiverChatID = dataListProvider.openedChatUserData['_id'];
//     final String receiverName = dataListProvider.openedChatUserData['vFullName'];
//     final String? receiverFcmToken = dataListProvider.openedChatUserData['tToken'];
//
//     // // Detect active formatter tags (optional, in case you want dynamic preservation)
//     // List<String> activeTags = getActiveFormatterTags();
//     //
//     // // Convert Quill document to HTML-safe string, escape everything, then restore allowed tags
//     // String rawHtml = convertDocumentToHtmlSafe(_controller.document);
//     // String content = escapeHtmlWithAllowedTags(
//     //   rawHtml,
//     //   formatterTags: activeTags,
//     // );
//
//     List<String> activeTags = getActiveFormatterTags();
//
//     String rawHtml = convertDocumentToHtmlSafe(_controller.document);
//
//     String content = restoreOnlyAllowedTags(
//       rawHtml,
//       allowedTags: [
//         'ul', 'li', 'i', 'u', 'a', 'b', 'br', 'font', 'img',
//         ...activeTags
//       ],
//     );
//     print("Final processed content======: $content");
//
//
//     print("Final safe content: $content");
//
//     if (content.trim().isEmpty) {
//       content = escapeHtmlWithAllowedTags(text, formatterTags: activeTags);
//     }
//
//     final isReplying = chatProvider.isUserReplying;
//     final isEditing = chatProvider.isUserEditing;
//
//     final vReplyMsg = isReplying ? chatProvider.userReplyText : '';
//     final vReplyMsg_id = isReplying && chatProvider.selectedMsgs.isNotEmpty
//         ? (chatProvider.selectedMsgs.first['id'] ?? '')
//         : '';
//     final vReplyFileName = isReplying ? chatProvider.userReplyFileName : '';
//
//     // Handle edit case
//     if (isEditing && chatProvider.editingMessageId != null) {
//       final updateResponse = await CommonFunctions.updateUserMessage(
//         content,
//         '',
//         receiverChatID,
//         chatProvider.editingMessageId!,
//       );
//
//       if (updateResponse['status'] == 200) {
//         final updatedList = CommonFunctions.replaceMatchingItemsById(
//           context: context,
//           originalList: dataListProvider.userMessagesList,
//           updatedList: updateResponse['fullMessageData'],
//         );
//         dataListProvider.setUserMessageList(updatedList);
//         chatProvider.setMsgSelectionMode(false);
//         chatProvider.clearMsgSelectionIndexes();
//       }
//
//       chatProvider.stopUserChatEditing();
//       _controller = quill.QuillController.basic();
//       setState(() {});
//       return;
//     }
//
//     // Construct unique message ID
//     final String newMessageId =
//         "${receiverChatID}_${senderChatID}_${DateTime.now().millisecondsSinceEpoch}";
//
//     // Send message over socket
//     SocketMessageEvents.sendMessageEvent(
//       receiverChatID: receiverChatID,
//       senderChatID: senderChatID,
//       content: content,
//       imageDataArr: [],
//       vReplyMsg: vReplyMsg,
//       vReplyMsg_id: vReplyMsg_id,
//       vReplyFileName: vReplyFileName,
//       id: newMessageId,
//       iRequestMsg: 0,
//       isForwardMsg: 0,
//       isForwardMsg_id: '',
//       isDeleteprofile: 0,
//       chat: 1,
//     );
//
//     // Send push notification
//     if (receiverFcmToken != null && receiverFcmToken.isNotEmpty) {
//       try {
//         await FcmNotificationHelper.instance.sendFCMPush(
//           fcmToken: receiverFcmToken,
//           title: currentUser['vFullName'] ?? "New Message",
//           body: text,
//           data: {
//             "chatId": dataListProvider.openedChatUserData['vChatId'],
//             "isGroup": "false",
//             "type": "chat",
//             "msgType": "text",
//           },
//         );
//         print("Notification send successfully................");
//       } catch (e) {
//         print("Notification send failed: $e");
//       }
//     }
//
//     // Reset state and input box
//     _controller = quill.QuillController.basic();
//     _controller.document = quill.Document();
//     chatProvider.setMsgSelectionMode(false);
//     chatProvider.clearMsgSelectionIndexes();
//     chatProvider.stopUserChatReplying();
//     isMsgExist = false;
//     setState(() {});
//
//     startControllerListener();
//   }

  List<Map<String, dynamic>> getStyledChunks(quill.QuillController controller) {
    final delta = controller.document.toDelta();
    final chunks = <Map<String, dynamic>>[];

    for (final op in delta.toList()) {
      final text = op.data;
      if (text is String) {
        chunks.add({
          'text': text,
          'styles': op.attributes ?? {},
        });
      } else {
        chunks.add({
          'embed': text,
          'styles': op.attributes ?? {},
        });
      }
    }

    return chunks;
  }

  void handleOnMessageSend() async {
    final chatProvider = context.read<ChatProvider>();
    final dataListProvider = context.read<DataListProvider>();
    final text = _controller.document.toPlainText().trim();
    _controller = quill.QuillController.basic();

    final delta = _controller.document.toDelta();
    final deltaJson = delta.toJson();
    if (text.isEmpty) return;

    final currentUser = await CommonFunctions.getLoginUser();
    final String senderChatID = currentUser['_id'];
    final String receiverChatID = dataListProvider.openedChatUserData['_id'];
    final String? receiverFcmToken =
        dataListProvider.openedChatUserData['tToken'];

    List<String> activeTags = getActiveFormatterTags();

    String content;
    String encodedText =
        CommonFunctions.encodeMessage(_controller.document.toDelta().toJson());

    if (activeTags.isEmpty) {
      text;
    } else {
      String rawHtml = convertDocumentToHtmlSafe(_controller.document);

      // print("rawHtml ================ $rawHtml");

      content = restoreOnlyAllowedTags(
        rawHtml,
        allowedTags: [
          'ul',
          'li',
          'i',
          'u',
          'a',
          'b',
          'br',
          'font',
          'img',
          ...activeTags
        ],
      );
    }

    final isReplying = chatProvider.isUserReplying;
    final isEditing = chatProvider.isUserEditing;

    // final vReplyMsg = isReplying ? chatProvider.selectedImage.isNotEmpty  && chatProvider.selectedImage['vFiles'] == "" ? chatProvider.selectedImage['message'] : chatProvider.userReplyText : '';
    final vReplyMsg = isReplying
        ? chatProvider.selectedImage.isNotEmpty
            ? chatProvider.selectedImage['message']
            : chatProvider.userReplyText
        : '';

    final vReplyMsgId = isReplying
        ? chatProvider.selectedImage.isNotEmpty
            ? chatProvider.selectedImage['id']
            : chatProvider.selectedMsgs.isNotEmpty
                ? chatProvider.selectedMsgs.first['id']
                : ''
        : "";
    final vReplyFileName = isReplying
        ? chatProvider.selectedImage.isNotEmpty
            ? chatProvider.selectedImage['isOriginalName']
            : chatProvider.userReplyFileName
        : '';

    if (isEditing && chatProvider.editingMessageId != null) {
      final updateResponse = await CommonFunctions.updateUserMessage(
          text, '', receiverChatID, chatProvider.editingMessageId!);

      if (updateResponse['status'] == 200) {
        final updatedList = CommonFunctions.replaceMatchingItemsById(
          context: context,
          originalList: dataListProvider.userMessagesList,
          updatedList: updateResponse['fullMessageData'],
        );
        dataListProvider.setUserMessageList(updatedList);
        chatProvider.setMsgSelectionMode(false);
        chatProvider.clearMsgSelectionIndexes();
      }

      chatProvider.stopUserChatEditing();
      _controller = quill.QuillController.basic();
      setState(() {});
      return;
    }

    chatProvider.clearMsgSelectionIndexes();
    chatProvider.stopUserChatReplying();

    // Construct unique message ID
    final String newMessageId =
        "${receiverChatID}_${senderChatID}_${DateTime.now().millisecondsSinceEpoch}";

    // Send message over socket
    SocketMessageEvents.sendMessageEvent(
      receiverChatID: receiverChatID,
      senderChatID: senderChatID,
      content: text,
      imageDataArr: [],
      vReplyMsg: vReplyMsg,
      vReplyMsgId: vReplyMsgId,
      vReplyFileName: vReplyFileName,
      id: newMessageId,
      iRequestMsg: 0,
      isForwardMsg: 0,
      isForwardMsgId: '',
      isDeleteprofile: 0,
      chat: 1,
    );

    if (receiverFcmToken != null && receiverFcmToken.isNotEmpty) {
      try {
        await FcmNotificationHelper.instance.sendFCMPush(
          fcmToken: receiverFcmToken,
          title: currentUser['vFullName'] ?? "New Message",
          body: text,
          data: {
            "chatId": dataListProvider.openedChatUserData['vChatId'],
            "isGroup": "false",
            "type": "chat",
            "msgType": "text",
          },
        );
        // print("Notification send successfully................");
      } catch (e) {
        // print("Notification send failed: $e");
      }
    }

    // Reset state and input box
    _controller = quill.QuillController.basic();
    _controller.document = quill.Document();
    chatProvider.shouldScrollToBottom = true;
    chatProvider.setMsgSelectionMode(false);
    chatProvider.clearMsgSelectionIndexes();
    chatProvider.stopUserChatReplying();
    chatProvider.stopUserChatEditing();
    isMsgExist = false;
    setState(() {});
    startControllerListener();
  }
//   void handleOnMessageSend() async {
//     final chatProvider = context.read<ChatProvider>();
//     final dataListProvider = context.read<DataListProvider>();
//
//     // Get plain text for validation
//     final plainText = _controller.document.toPlainText().trim();
//     if (plainText.isEmpty) return;
//
//     final currentUser = await CommonFunctions.getLoginUser();
//     final String senderChatID = currentUser['_id'];
//     final String receiverChatID = dataListProvider.openedChatUserData['_id'];
//     final String receiverName = dataListProvider.openedChatUserData['vFullName'];
//     final String? receiverFcmToken = dataListProvider.openedChatUserData['tToken'];
//
//     // Detect active formatter tags (b, i, u, etc.)
//     List<String> activeTags = getActiveFormatterTags();
//
//     String content;
//     if (activeTags.isEmpty) {
//       // No formatting — send as plain text
//       content = CommonFunctions.normalizeWhitespace(
//         CommonFunctions.getEmojiFromText(plainText),
//       );
//     } else {
//       // Convert to HTML but keep only allowed tags (including active ones)
//       String rawHtml = convertDocumentToHtmlSafe(_controller.document);
//
//       content = restoreOnlyAllowedTags(
//         rawHtml,
//         allowedTags: [
//           'ul', 'li', 'i', 'u', 'a', 'b', 'br', 'font', 'img',
//           ...activeTags
//         ],
//       );
//     }
//
//     print("Final processed content======: $content");
//
//     final isReplying = chatProvider.isUserReplying;
//     final isEditing = chatProvider.isUserEditing;
//
//     final vReplyMsg = isReplying ? chatProvider.userReplyText : '';
//     final vReplyMsg_id = isReplying && chatProvider.selectedMsgs.isNotEmpty
//         ? (chatProvider.selectedMsgs.first['id'] ?? '')
//         : '';
//     final vReplyFileName = isReplying ? chatProvider.userReplyFileName : '';
//
//     // Editing existing message
//     if (isEditing && chatProvider.editingMessageId != null) {
//       final updateResponse = await CommonFunctions.updateUserMessage(
//         content,
//         '',
//         receiverChatID,
//         chatProvider.editingMessageId!,
//       );
//
//       if (updateResponse['status'] == 200) {
//         final updatedList = CommonFunctions.replaceMatchingItemsById(
//           context: context,
//           originalList: dataListProvider.userMessagesList,
//           updatedList: updateResponse['fullMessageData'],
//         );
//         dataListProvider.setUserMessageList(updatedList);
//         chatProvider.setMsgSelectionMode(false);
//         chatProvider.clearMsgSelectionIndexes();
//       }
//
//       chatProvider.stopUserChatEditing();
//       _controller = quill.QuillController.basic();
//       setState(() {});
//       return;
//     }
//
//     // Create unique message ID
//     final String newMessageId =
//         "${receiverChatID}_${senderChatID}_${DateTime.now().millisecondsSinceEpoch}";
//
//     // Send over socket
//     SocketMessageEvents.sendMessageEvent(
//       receiverChatID: receiverChatID,
//       senderChatID: senderChatID,
//       content: content,
//       imageDataArr: [],
//       vReplyMsg: vReplyMsg,
//       vReplyMsg_id: vReplyMsg_id,
//       vReplyFileName: vReplyFileName,
//       id: newMessageId,
//       iRequestMsg: 0,
//       isForwardMsg: 0,
//       isForwardMsg_id: '',
//       isDeleteprofile: 0,
//       chat: 1,
//     );
//
//     // Send FCM push
//     if (receiverFcmToken != null && receiverFcmToken.isNotEmpty) {
//       try {
//         await FcmNotificationHelper.instance.sendFCMPush(
//           fcmToken: receiverFcmToken,
//           title: currentUser['vFullName'] ?? "New Message",
//           body: plainText,
//           data: {
//             "chatId": dataListProvider.openedChatUserData['vChatId'],
//             "isGroup": "false",
//             "type": "chat",
//             "msgType": "text",
//           },
//         );
//         print("Notification sent successfully...");
//       } catch (e) {
//         print("Notification send failed: $e");
//       }
//     }
//
//     // Reset state
//     _controller = quill.QuillController.basic();
//     chatProvider.setMsgSelectionMode(false);
//     chatProvider.clearMsgSelectionIndexes();
//     chatProvider.stopUserChatReplying();
//     isMsgExist = false;
//     setState(() {});
//     startControllerListener();
//   }

  void handleOnFileMessageSend() async {
    final chatProvider = context.read<ChatProvider>();
    final dataListProvider = context.read<DataListProvider>();
    final files = chatProvider.uploadFiles;
    final receiverFcmToken = dataListProvider.openedChatUserData['tToken'];
    _controller = quill.QuillController.basic();
    if (files.isEmpty) {
      // print("No files selected.");
      return;
    }

    final currentUser = await CommonFunctions.getLoginUser();
    final senderChatID = currentUser['_id'];
    final receiverChatID = dataListProvider.openedChatUserData['_id'];

    // Load allowed file types if not already loaded
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
        chat: 1,
      );
      // print("Upload Response: $uploadResponse");

      String fileUrl = uploadResponse?['fileUrl'] ?? '';

      if (receiverFcmToken != null &&
          receiverFcmToken.isNotEmpty &&
          fileUrl.isNotEmpty) {
        try {
          String bodyText = CommonFunctions.getNotificationLabel(extension);
          await FcmNotificationHelper.instance.sendFCMPush(
            fcmToken: receiverFcmToken,
            title: currentUser['vFullName'] ?? "New File",
            body: bodyText,
            data: {
              "chatId": receiverChatID,
              "isGroup": "false",
              "type": "chat",
              "msgType": "file",
              "fileUrl": fileUrl,
            },
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
    chatProvider.stopUserChatEditing();
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
    final currntUserData = await CommonFunctions.getLoginUser();
    final dataListProvider = context.read<DataListProvider>();
    // print("UseerCurrentData: ${currntUserData}");
    SocketMessageEvents.messageTyping(
        currntUserData['_id'],
        widget.type == 'chat'
            ? dataListProvider.openedChatUserData['_id']
            : dataListProvider.openedChatGroupData['_id'],
        text,
        widget.type == 'chat' ? 'userChat' : 'groupChat');
  }

  void getSelectedText() {
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
    CommonModal.show(context: context, child: MessageMenuBottomsheet());
  }

  void handleCloseFormatter() {
    final style = _controller.getSelectionStyle();
    isBulletSelected = style.attributes.containsKey(quill.Attribute.ul.key);
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setIsShowFormatter(false);
    chatProvider.setUserReplyingStop(false);
    chatProvider.setFileUploadingStop(false);
    chatProvider.clearShowFormatter();
    setState(() {
      isBoldSelected = false;
      isItalicSelected = false;
      isUnderlineSelected = false;
      isStrikeThroughSelected = false;
      isBulletSelected = isBulletSelected ? true : false;
      isLinkSelected = false;
      selectedColor = const Color(0XFF000000);
      isLinkOptionSheet = false;
    });
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
            offset: selection.start + 2 + selectedText.length + 2));
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
            offset: selection.start + 1 + selectedText.length + 1));
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
            offset: selection.start + 3 + selectedText.length + 4));
  }

  // String convertDocumentToHtmlSafe(quill.Document doc) {
  //   final ops = doc.toDelta().toList();
  //   final buffer = StringBuffer();
  //   bool isInList = false;
  //   String? listType;
  //   for (int i = 0; i < ops.length; i++) {
  //     final op = ops[i];
  //     final data = op.data;
  //     final attrs = op.attributes;
  //     String formatted = '';
  //     if (data is String && data != '\n') {
  //       String rawText = htmlEscape.convert(data);
  //       if (attrs != null) {
  //         if (attrs['bold'] == true) rawText = '<b>$rawText</b>';
  //         if (attrs['italic'] == true) rawText = '<i>$rawText</i>';
  //         if (attrs['underline'] == true) rawText = '<u>$rawText</u>';
  //         if (attrs['strike'] == true) rawText = '<del>$rawText</del>';
  //         if (attrs.containsKey('color')) {
  //           rawText = '<span style="color:${attrs["color"]};">$rawText</span>';
  //         }
  //         if (attrs.containsKey('link')) {
  //           final link = attrs['link'];
  //           rawText = '<a href="$link" target="_blank">$rawText</a>';
  //         }
  //       }
  //       formatted = rawText;
  //       final nextOp = (i + 1 < ops.length) ? ops[i + 1] : null;
  //       final nextAttrs = nextOp?.attributes;
  //       if (nextOp != null && nextOp.data == '\n' && nextAttrs != null && nextAttrs.containsKey('list')) {
  //         final lt = nextAttrs['list'];
  //         if (!isInList) {
  //           if (lt == 'bullet') {
  //             buffer.write('<ul>');
  //             listType = 'bullet';
  //           } else {
  //             buffer.write('<ol>');
  //             listType = 'ordered';
  //           }
  //           isInList = true;
  //         }
  //         String? bulletColor;
  //         if (attrs != null && attrs.containsKey('color')) {
  //           bulletColor = attrs['color'];
  //         }
  //         final colorStyle = bulletColor != null ? ' style="color:$bulletColor;"' : '';
  //         buffer.write('<li$colorStyle>$formatted</li>');
  //         i++;
  //       } else {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         }
  //         buffer.write(formatted);
  //       }
  //     } else if (data is String && data == '\n') {
  //       final lt = attrs?['list'];
  //       if (lt == null) {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         } else {
  //           buffer.write('<br/>');
  //         }
  //       }
  //     } else if (data is Map && attrs != null && attrs.containsKey('image')) {
  //       final imageUrl = attrs['image'];
  //       buffer.write('<img src="$imageUrl"/>');
  //     }
  //   }
  //   if (isInList) {
  //     buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //   }
  //   return buffer.toString();
  // }
  ///remove spacing
//   String convertDocumentToHtmlSafe(quill.Document doc) {
//     final ops = doc.toDelta().toList();
//     final buffer = StringBuffer();
//     bool isInList = false;
//     String? listType;
//
//     for (int i = 0; i < ops.length; i++) {
//       final op = ops[i];
//       final data = op.data;
//       final attrs = op.attributes;
//       String formatted = '';
//
//       if (data is String && data != '\n') {
//         String rawText = htmlEscape.convert(data);
//
//         if (attrs != null) {
//           if (attrs['bold'] == true) rawText = '<b>$rawText</b>';
//           if (attrs['italic'] == true) rawText = '<i>$rawText</i>';
//           if (attrs['underline'] == true) rawText = '<u>$rawText</u>';
//           if (attrs['strike'] == true) rawText = '<del>$rawText</del>';
//           if (attrs.containsKey('color')) {
//             rawText = '<span style="color:${attrs["color"]};">$rawText</span>';
//           }
//           if (attrs.containsKey('link')) {
//             final link = attrs['link'];
//             rawText = '<a href="$link" target="_blank">$rawText</a>';
//           }
//         }
//
//         formatted = rawText;
//
//         final nextOp = (i + 1 < ops.length) ? ops[i + 1] : null;
//         final nextAttrs = nextOp?.attributes;
//
//         // Handle list items
//         if (nextOp != null && nextOp.data == '\n' && nextAttrs != null && nextAttrs.containsKey('list')) {
//           final lt = nextAttrs['list'];
//
//           if (!isInList) {
//             if (lt == 'bullet') {
//               buffer.write('<ul>');
//               listType = 'bullet';
//             } else {
//               buffer.write('<ol>');
//               listType = 'ordered';
//             }
//             isInList = true;
//           }
//
//           String? bulletColor;
//           if (attrs != null && attrs.containsKey('color')) {
//             bulletColor = attrs['color'];
//           }
//           final colorStyle = bulletColor != null ? ' style="color:$bulletColor;"' : '';
//
//           buffer.write('<li$colorStyle>$formatted</li>');
//           i++; // skip the newline op after the list item
//         } else {
//           // Close any open list before continuing
//           if (isInList) {
//             buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
//             isInList = false;
//             listType = null;
//           }
//
//           buffer.write(formatted);
//         }
//
//       } else if (data is String && data == '\n') {
//         final lt = attrs?['list'];
//         final isLastOp = i == ops.length - 1;
//
//         // Only insert <br/> if not the last unstyled \n
//         if (lt == null && !isLastOp) {
//           if (isInList) {
//             buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
//             isInList = false;
//             listType = null;
//           } else {
//             buffer.write('<br/>');
//           }
//         }
//       } else if (data is Map && attrs != null && attrs.containsKey('image')) {
//         final imageUrl = attrs['image'];
//         buffer.write('<img src="$imageUrl"/>');
//       }
//     }
//
//     // Close any unclosed list
//     if (isInList) {
//       buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
//     }
//
//     return buffer.toString();
//   }

  // String convertDocumentToHtmlSafe(quill.Document doc) {
  //   final ops = doc.toDelta().toList();
  //   final buffer = StringBuffer();
  //   bool isInList = false;
  //   String? listType;
  //
  //   for (int i = 0; i < ops.length; i++) {
  //     final op = ops[i];
  //     final data = op.data;
  //     final attrs = op.attributes;
  //     String formatted = '';
  //
  //     if (data is String && data != '\n') {
  //       String rawText = htmlEscape.convert(data); // escape by default
  //
  //       // Unescape for code-like content
  //       final containsHtmlTags = rawText.contains('&lt;') && rawText.contains('&gt;');
  //
  //       if (containsHtmlTags) {
  //         rawText = rawText
  //             .replaceAll('&lt;', '<')
  //             .replaceAll('&gt;', '>')
  //             .replaceAll('&amp;', '&');
  //
  //         rawText = '<code>$rawText</code>';
  //       }
  //
  //       if (attrs != null) {
  //         if (attrs['bold'] == true) rawText = '<b>$rawText</b>';
  //         if (attrs['italic'] == true) rawText = '<i>$rawText</i>';
  //         if (attrs['underline'] == true) rawText = '<u>$rawText</u>';
  //         if (attrs['strike'] == true) rawText = '<del>$rawText</del>';
  //         if (attrs.containsKey('color')) {
  //           rawText = '<span style="color:${attrs["color"]};">$rawText</span>';
  //         }
  //         if (attrs.containsKey('link')) {
  //           final link = attrs['link'];
  //           rawText = '<a href="$link" target="_blank">$rawText</a>';
  //         }
  //       }
  //
  //       formatted = rawText;
  //
  //       final nextOp = (i + 1 < ops.length) ? ops[i + 1] : null;
  //       final nextAttrs = nextOp?.attributes;
  //
  //       // Handle list items
  //       if (nextOp != null && nextOp.data == '\n' && nextAttrs != null && nextAttrs.containsKey('list')) {
  //         final lt = nextAttrs['list'];
  //
  //         if (!isInList) {
  //           if (lt == 'bullet') {
  //             buffer.write('<ul>');
  //             listType = 'bullet';
  //           } else {
  //             buffer.write('<ol>');
  //             listType = 'ordered';
  //           }
  //           isInList = true;
  //         }
  //
  //         String? bulletColor;
  //         if (attrs != null && attrs.containsKey('color')) {
  //           bulletColor = attrs['color'];
  //         }
  //         final colorStyle = bulletColor != null ? ' style="color:$bulletColor;"' : '';
  //
  //         buffer.write('<li$colorStyle>$formatted</li>');
  //         i++; // skip the newline op after the list item
  //       } else {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         }
  //
  //         buffer.write(formatted);
  //       }
  //
  //     } else if (data is String && data == '\n') {
  //       final lt = attrs?['list'];
  //       final isLastOp = i == ops.length - 1;
  //
  //       if (lt == null && !isLastOp) {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         } else {
  //           buffer.write('<br/>');
  //         }
  //       }
  //
  //     } else if (data is Map && attrs != null && attrs.containsKey('image')) {
  //       final imageUrl = attrs['image'];
  //       buffer.write('<img src="$imageUrl"/>');
  //     }
  //   }
  //
  //   if (isInList) {
  //     buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //   }
  //
  //   return buffer.toString();
  // }

  // String convertDocumentToHtmlSafe(quill.Document doc) {
  //   final ops = doc.toDelta().toList();
  //   final buffer = StringBuffer();
  //   bool isInList = false;
  //   String? listType;
  //
  //   for (int i = 0; i < ops.length; i++) {
  //     final op = ops[i];
  //     final data = op.data;
  //     final attrs = op.attributes;
  //     String formatted = '';
  //
  //     if (data is String && data != '\n') {
  //       String rawText = htmlEscape.convert(data); // Default escape
  //
  //       // Check for HTML-like content, convert back for code block
  //       final containsHtmlTags = rawText.contains('&lt;') && rawText.contains('&gt;');
  //
  //       if (containsHtmlTags) {
  //         rawText = rawText
  //             .replaceAll('&lt;', '<')
  //             .replaceAll('&gt;', '>')
  //             .replaceAll('&amp;', '&');
  //         rawText = '<code>$rawText</code>';
  //       }
  //
  //       // Apply text attributes
  //       if (attrs != null) {
  //         if (attrs['bold'] == true) rawText = '<b>$rawText</b>';
  //         if (attrs['italic'] == true) rawText = '<i>$rawText</i>';
  //         if (attrs['underline'] == true) rawText = '<u>$rawText</u>';
  //         if (attrs['strike'] == true) rawText = '<del>$rawText</del>';
  //         if (attrs.containsKey('color')) {
  //           rawText = '<span style="color:${attrs["color"]};">$rawText</span>';
  //         }
  //         if (attrs.containsKey('link')) {
  //           final link = attrs['link'];
  //           rawText = '<a href="$link" target="_blank" style="color:blue; text-decoration: underline;">$rawText</a>';
  //         }
  //       }
  //
  //       formatted = rawText;
  //
  //       // Handle list formatting
  //       final nextOp = (i + 1 < ops.length) ? ops[i + 1] : null;
  //       final nextAttrs = nextOp?.attributes;
  //
  //       if (nextOp != null &&
  //           nextOp.data == '\n' &&
  //           nextAttrs != null &&
  //           nextAttrs.containsKey('list')) {
  //         final lt = nextAttrs['list'];
  //
  //         if (!isInList) {
  //           if (lt == 'bullet') {
  //             buffer.write('<ul>');
  //             listType = 'bullet';
  //           } else {
  //             buffer.write('<ol>');
  //             listType = 'ordered';
  //           }
  //           isInList = true;
  //         }
  //
  //         String? bulletColor;
  //         if (attrs != null && attrs.containsKey('color')) {
  //           bulletColor = attrs['color'];
  //         }
  //         final colorStyle = bulletColor != null ? ' style="color:$bulletColor;"' : '';
  //
  //         buffer.write('<li$colorStyle>$formatted</li>');
  //         i++; // Skip \n op
  //       } else {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         }
  //         buffer.write(formatted);
  //       }
  //     } else if (data is String && data == '\n') {
  //       final lt = attrs?['list'];
  //       final isLastOp = i == ops.length - 1;
  //
  //       if (lt == null && !isLastOp) {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         } else {
  //           buffer.write('<br/>');
  //         }
  //       }
  //     } else if (data is Map && attrs != null && attrs.containsKey('image')) {
  //       final imageUrl = attrs['image'];
  //       buffer.write('<img src="$imageUrl"/>');
  //     }
  //   }
  //
  //   // Close any unclosed list
  //   if (isInList) {
  //     buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //   }
  //
  //   return buffer.toString();
  // }

  // String convertDocumentToHtmlSafe(quill.Document doc) {
  //   final ops = doc.toDelta().toList();
  //   final buffer = StringBuffer();
  //   bool isInList = false;
  //   String? listType;
  //
  //   for (int i = 0; i < ops.length; i++) {
  //     final op = ops[i];
  //     final data = op.data;
  //     final attrs = op.attributes;
  //     String formatted = '';
  //
  //     if (data is String && data != '\n') {
  //       String rawText = htmlEscape.convert(data);
  //
  //       final containsHtmlTags = rawText.contains('&lt;') && rawText.contains('&gt;');
  //       if (containsHtmlTags) {
  //         rawText = rawText
  //             .replaceAll('&lt;', '<')
  //             .replaceAll('&gt;', '>')
  //             .replaceAll('&amp;', '&');
  //         rawText = '<code>$rawText</code>';
  //       }
  //
  //       if (attrs != null) {
  //         if (attrs['bold'] == true) rawText = '<b>$rawText</b>';
  //         if (attrs['italic'] == true) rawText = '<i>$rawText</i>';
  //         if (attrs['underline'] == true) rawText = '<u>$rawText</u>';
  //         if (attrs['strike'] == true) rawText = '<del>$rawText</del>';
  //         if (attrs.containsKey('color')) {
  //           rawText = '<span style="color:${attrs["color"]};">$rawText</span>';
  //         }
  //         if (attrs.containsKey('link')) {
  //           final link = attrs['link'];
  //           rawText = '<a href="$link" target="_blank" style="color:#87CEFA; text-decoration: underline;">$rawText</a>';
  //           print("========rawText======: $rawText");
  //         }
  //       }
  //
  //       formatted = rawText;
  //
  //       final nextOp = (i + 1 < ops.length) ? ops[i + 1] : null;
  //       final nextAttrs = nextOp?.attributes;
  //
  //       if (nextOp != null &&
  //           nextOp.data == '\n' &&
  //           nextAttrs != null &&
  //           nextAttrs.containsKey('list')) {
  //         final lt = nextAttrs['list'];
  //
  //         if (!isInList) {
  //           if (lt == 'bullet') {
  //             buffer.write('<ul>');
  //             listType = 'bullet';
  //           } else {
  //             buffer.write('<ol>');
  //             listType = 'ordered';
  //           }
  //           isInList = true;
  //         }
  //
  //         String? bulletColor;
  //         if (attrs != null && attrs.containsKey('color')) {
  //           bulletColor = attrs['color'];
  //         }
  //         final colorStyle = bulletColor != null ? ' style="color:$bulletColor;"' : '';
  //         print("========colorStyle======: $colorStyle");
  //
  //         buffer.write('<li$colorStyle>$formatted</li>');
  //         i++;
  //       } else {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         }
  //         buffer.write(formatted);
  //       }
  //     } else if (data is String && data == '\n') {
  //       final lt = attrs?['list'];
  //       final isLastOp = i == ops.length - 1;
  //
  //       if (lt == null && !isLastOp) {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         } else {
  //           buffer.write('<br/>');
  //         }
  //       }
  //     } else if (data is Map && attrs != null && attrs.containsKey('image')) {
  //       final imageUrl = attrs['image'];
  //       buffer.write('<img src="$imageUrl"/>');
  //     }
  //   }
  //
  //   if (isInList) {
  //     buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //   }
  //
  //   return buffer.toString();
  // }
  // String convertDocumentToHtmlSafe(quill.Document doc) {
  //   final ops = doc.toDelta().toList();
  //   final buffer = StringBuffer();
  //   bool isInList = false;
  //   String? listType;
  //
  //   for (int i = 0; i < ops.length; i++) {
  //     final op = ops[i];
  //     final data = op.data;
  //     final attrs = op.attributes;
  //     String formatted = '';
  //
  //     if (data is String && data != '\n') {
  //       String rawText = htmlEscape.convert(data);
  //
  //       // Unescape for code-like content
  //       final containsHtmlTags = rawText.contains('&lt;') && rawText.contains('&gt;');
  //       if (containsHtmlTags) {
  //         rawText = rawText
  //             .replaceAll('&lt;', '<')
  //             .replaceAll('&gt;', '>')
  //             .replaceAll('&amp;', '&');
  //         rawText = '<code>$rawText</code>';
  //       }
  //
  //       if (attrs != null) {
  //         if (attrs['bold'] == true) rawText = '<b>$rawText</b>';
  //         if (attrs['italic'] == true) rawText = '<i>$rawText</i>';
  //         if (attrs['underline'] == true) rawText = '<u>$rawText</u>';
  //         if (attrs['strike'] == true) rawText = '<del>$rawText</del>';
  //
  //         // Apply link color and underline only on <a>, no nested color span inside links
  //         // if (attrs.containsKey('link')) {
  //         //   final link = attrs['link'];
  //         //   rawText =
  //         //   '<a href="$link" target="_blank" style="color:#87CEFA; text-decoration: underline; text-decoration-color: #87CEFA; font-weight: 600;">$rawText</a>';
  //         // }
  //         if (attrs.containsKey('link')) {
  //           final link = attrs['link'];
  //           rawText = rawText.replaceAll(RegExp(r'<span[^>]*>|</span>'), '');
  //           rawText =
  //           '<a href="$link" target="_blank" style="text-decoration: none;">'
  //               '<span style="color:#37AFE1; text-decoration: underline; text-decoration-color: #37AFE1; font-weight: 600;">$rawText</span>'
  //               '</a>';
  //         }
  //         else if (attrs.containsKey('color')) {
  //           rawText = '<span style="color:${attrs["color"]};">$rawText</span>';
  //         }
  //       }
  //
  //       formatted = rawText;
  //
  //       final nextOp = (i + 1 < ops.length) ? ops[i + 1] : null;
  //       final nextAttrs = nextOp?.attributes;
  //
  //       // Handle list items
  //       if (nextOp != null && nextOp.data == '\n' && nextAttrs != null && nextAttrs.containsKey('list')) {
  //         final lt = nextAttrs['list'];
  //
  //         if (!isInList) {
  //           if (lt == 'bullet') {
  //             buffer.write('<ul>');
  //             listType = 'bullet';
  //           } else {
  //             buffer.write('<ol>');
  //             listType = 'ordered';
  //           }
  //           isInList = true;
  //         }
  //
  //         String? bulletColor;
  //         if (attrs != null && attrs.containsKey('color')) {
  //           bulletColor = attrs['color'];
  //         }
  //         final colorStyle = bulletColor != null ? ' style="color:$bulletColor;"' : '';
  //
  //         buffer.write('<li$colorStyle>$formatted</li>');
  //         i++; // skip the newline op after the list item
  //       } else {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         }
  //
  //         buffer.write(formatted);
  //       }
  //     } else if (data is String && data == '\n') {
  //       final lt = attrs?['list'];
  //       final isLastOp = i == ops.length - 1;
  //
  //       if (lt == null && !isLastOp) {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         } else {
  //           buffer.write('<br/>');
  //         }
  //       }
  //     } else if (data is Map && attrs != null && attrs.containsKey('image')) {
  //       final imageUrl = attrs['image'];
  //       buffer.write('<img src="$imageUrl"/>');
  //     }
  //   }
  //
  //   if (isInList) {
  //     buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //   }
  //
  //   return buffer.toString();
  // }
  // String convertDocumentToHtmlSafe(quill.Document doc) {
  //   final ops = doc.toDelta().toList();
  //   final buffer = StringBuffer();
  //   bool isInList = false;
  //   String? listType;
  //
  //   for (int i = 0; i < ops.length; i++) {
  //     final op = ops[i];
  //     final data = op.data;
  //     final attrs = op.attributes;
  //     String formatted = '';
  //
  //     if (data is String && data != '\n') {
  //       String rawText = htmlEscape.convert(data);
  //       print("====================rawTextrawText======================: $rawText");
  //
  //       final containsHtmlTags = rawText.contains('&lt;') && rawText.contains('&gt;');
  //       if (containsHtmlTags) {
  //         rawText = rawText
  //             .replaceAll('&lt;', '<')
  //             .replaceAll('&gt;', '>')
  //             .replaceAll('&amp;', '&');
  //         rawText = '<code>$rawText</code>';
  //         print("rawTextrawText: $rawText");
  //       }
  //
  //       if (attrs != null) {
  //         final hasLink = attrs.containsKey('link');
  //         final color = attrs['color'] ?? '#000000';
  //         final isBold = attrs['bold'] == true;
  //         final isItalic = attrs['italic'] == true;
  //         final isUnderline = attrs['underline'] == true;
  //         final isStrike = attrs['strike'] == true;
  //
  //         // Handle link formatting
  //         if (hasLink) {
  //           final link = attrs['link'];
  //           rawText = rawText.replaceAll(RegExp(r'<span[^>]*>|</span>'), '');
  //           rawText =
  //           '<a href="$link" target="_blank" style="text-decoration: none;">'
  //               '<span style="color:#37AFE1; text-decoration: underline; text-decoration-color: #37AFE1; font-weight: 600;">$rawText</span>'
  //               '</a>';
  //         } else {
  //           // Apply standard formatting
  //           if (isStrike) rawText = '<del>$rawText</del>';
  //           if (isBold) rawText = '<b>$rawText</b>';
  //           if (isItalic) rawText = '<i>$rawText</i>';
  //
  //           if (isUnderline) {
  //             rawText =
  //             '<span style="text-decoration: underline; text-decoration-color: $color;">$rawText</span>';
  //           }
  //
  //           if (attrs.containsKey('color')) {
  //             rawText = '<span style="color:$color;">$rawText</span>';
  //           }
  //         }
  //       }
  //
  //       formatted = rawText;
  //
  //       final nextOp = (i + 1 < ops.length) ? ops[i + 1] : null;
  //       final nextAttrs = nextOp?.attributes;
  //
  //       // Handle lists
  //       if (nextOp != null && nextOp.data == '\n' && nextAttrs != null && nextAttrs.containsKey('list')) {
  //         final lt = nextAttrs['list'];
  //
  //         if (!isInList) {
  //           if (lt == 'bullet') {
  //             buffer.write('<ul>');
  //             listType = 'bullet';
  //           } else {
  //             buffer.write('<ol>');
  //             listType = 'ordered';
  //           }
  //           isInList = true;
  //         }
  //
  //         String? bulletColor;
  //         if (attrs != null && attrs.containsKey('color')) {
  //           bulletColor = attrs['color'];
  //         }
  //         final colorStyle = bulletColor != null ? ' style="color:$bulletColor;"' : '';
  //
  //         buffer.write('<li$colorStyle>$formatted</li>');
  //         i++; // Skip newline
  //       } else {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         }
  //         buffer.write(formatted);
  //       }
  //     } else if (data is String && data == '\n') {
  //       final lt = attrs?['list'];
  //       final isLastOp = i == ops.length - 1;
  //
  //       if (lt == null && !isLastOp) {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         } else {
  //           buffer.write('<br/>');
  //         }
  //       }
  //     } else if (data is Map && attrs != null && attrs.containsKey('image')) {
  //       final imageUrl = attrs['image'];
  //       buffer.write('<img src="$imageUrl"/>');
  //     }
  //   }
  //
  //   if (isInList) {
  //     buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //   }
  //
  //   return buffer.toString();
  // }

  // String convertDocumentToHtmlSafe(quill.Document doc) {
  //   final ops = doc.toDelta().toList();
  //   final buffer = StringBuffer();
  //   bool isInList = false;
  //   String? listType;
  //
  //   for (int i = 0; i < ops.length; i++) {
  //     final op = ops[i];
  //     final data = op.data;
  //     final attrs = op.attributes;
  //     String formatted = '';
  //
  //     if (data is String && data != '\n') {
  //       // Directly take text without HTML escaping
  //       String rawText = data;
  //
  //       if (attrs != null) {
  //         final hasLink = attrs.containsKey('link');
  //         final color = attrs['color'] ?? '#000000';
  //         final isBold = attrs['bold'] == true;
  //         final isItalic = attrs['italic'] == true;
  //         final isUnderline = attrs['underline'] == true;
  //         final isStrike = attrs['strike'] == true;
  //
  //         if (hasLink) {
  //           final link = attrs['link'];
  //           rawText =
  //           '<a href="$link" target="_blank" style="text-decoration: none;">'
  //               '<span style="color:#37AFE1; text-decoration: underline; text-decoration-color: #37AFE1; font-weight: 600;">$rawText</span>'
  //               '</a>';
  //         } else {
  //           if (isStrike) rawText = '<del>$rawText</del>';
  //           if (isBold) rawText = '<b>$rawText</b>';
  //           if (isItalic) rawText = '<i>$rawText</i>';
  //           if (isUnderline) {
  //             rawText =
  //             '<span style="text-decoration: underline; text-decoration-color: $color;">$rawText</span>';
  //           }
  //           if (attrs.containsKey('color')) {
  //             rawText = '<span style="color:$color;">$rawText</span>';
  //           }
  //         }
  //       }
  //
  //       formatted = rawText;
  //
  //       // Handle list items
  //       final nextOp = (i + 1 < ops.length) ? ops[i + 1] : null;
  //       final nextAttrs = nextOp?.attributes;
  //
  //       if (nextOp != null &&
  //           nextOp.data == '\n' &&
  //           nextAttrs != null &&
  //           nextAttrs.containsKey('list')) {
  //         final lt = nextAttrs['list'];
  //
  //         if (!isInList) {
  //           if (lt == 'bullet') {
  //             buffer.write('<ul>');
  //             listType = 'bullet';
  //           } else {
  //             buffer.write('<ol>');
  //             listType = 'ordered';
  //           }
  //           isInList = true;
  //         }
  //
  //         String? bulletColor;
  //         if (attrs != null && attrs.containsKey('color')) {
  //           bulletColor = attrs['color'];
  //         }
  //         final colorStyle =
  //         bulletColor != null ? ' style="color:$bulletColor;"' : '';
  //
  //         buffer.write('<li$colorStyle>$formatted</li>');
  //         i++; // Skip newline
  //       } else {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         }
  //         buffer.write(formatted);
  //       }
  //     } else if (data is String && data == '\n') {
  //       final lt = attrs?['list'];
  //       final isLastOp = i == ops.length - 1;
  //
  //       if (lt == null && !isLastOp) {
  //         if (isInList) {
  //           buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //           isInList = false;
  //           listType = null;
  //         } else {
  //           buffer.write('<br/>');
  //         }
  //       }
  //     } else if (data is Map && attrs != null && attrs.containsKey('image')) {
  //       final imageUrl = attrs['image'];
  //       buffer.write('<img src="$imageUrl"/>');
  //     }
  //   }
  //
  //   if (isInList) {
  //     buffer.write(listType == 'bullet' ? '</ul>' : '</ol>');
  //   }
  //
  //   return buffer.toString();
  // }

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
    chatProvider.stopUserChatEditing();
    chatProvider.clearMsgSelectionIndexes();
    chatProvider.setMsgSelectionMode(false);
    _controller = quill.QuillController.basic();
    setState(() {});
  }

  // ************************ handle on press link icon *********************

  void onPressLinkIcon() {
    final selection = _controller.selection;
    String link = linkController.text.trim();
    if (selection.isValid && selection.baseOffset != selection.extentOffset) {
      final baseOffset = selection.baseOffset;
      final extentOffset = selection.extentOffset;
      final length = extentOffset - baseOffset;

      final currentStyle = _controller.getSelectionStyle();

      _controller.formatText(baseOffset, length, quill.LinkAttribute(link));

      if (currentStyle.attributes[quill.Attribute.bold.key] != null) {
        _controller.formatText(baseOffset, length, quill.Attribute.bold);
      }

      if (currentStyle.attributes[quill.Attribute.italic.key] != null) {
        _controller.formatText(baseOffset, length, quill.Attribute.italic);
      }

      if (currentStyle.attributes[quill.Attribute.underline.key] != null) {
        _controller.formatText(baseOffset, length, quill.Attribute.underline);
      }

      String hexColor = currentStyle.attributes['color']?.value ?? '#000000';
      _controller.formatText(
        baseOffset,
        length,
        quill.Attribute.fromKeyValue('color', hexColor),
      );

      lastLinkedText = _controller.document.getPlainText(baseOffset, extentOffset);
      lastLinkedUrl = link;

      _controller.updateSelection(
        TextSelection.collapsed(offset: baseOffset + length),
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
  }

  // ******************* ui components ********************
  // ******************** show color bar for text color *******************
  int selectedColorIndex = -1;
  void onPressSelectColor(int index) {
    setState(() {
      selectedColorIndex = index;
      handleSelectTextColor(AppColorTheme.textFormatColors[index]);
      toggleAttribute(quill.Attribute.color);
    });
    applyTextStyle(TextStyle(color: AppColorTheme.textFormatColors[index]));
  }

  // *************************** handle on click send ************************
  void handleOnClickSend() {
    final chatProvider = context.read<ChatProvider>();
    final text = _controller.document.toPlainText().trim();
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
  }

  Widget messageInputBox() {
    final chatProvider = context.watch<ChatProvider>();
    final isReplying = chatProvider.isUserReplying;
    final isEditing = chatProvider.isUserEditing;
    final isUploadingFile = chatProvider.isUploadingFile;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColorTheme.border, strokeAlign: BorderSide.strokeAlignInside),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 8),
                  blurRadius: 16.r,
                  spreadRadius: 0,
                  color: Color.fromRGBO(10, 41, 55, 0.12)
                ),
                BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 2.r,
                  spreadRadius: 0,
                  color: Color.fromRGBO(10, 41, 55, 0.16)
                ),
              ]),
            padding: EdgeInsets.only(left: 16.w),
            child: Column(
              children: [
                // INPUT ROW
                if (isReplying) replyPreviewWidget(chatProvider),
                if (isEditing) editPreviewWidget(chatProvider),
                if (isUploadingFile)
                  CommonWidgets.uploadPreviewWidget(chatProvider, allowedFileTypes),
                Row(
                  children: [
                    Expanded(
                      child: quill.QuillEditor(
                        controller: _controller,
                        scrollController: ScrollController(),
                        config: quill.QuillEditorConfig(
                          embedBuilders: [
                            MyEmojiEmbedBuilder(),
                          ],
                          maxHeight: 200,
                          customRecognizerBuilder: (attribute, leaf) {
                            if (attribute.key == quill.Attribute.link.key) {
                              final String link = attribute.value;
                              final String text = leaf.toPlainText();
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
                          customStyleBuilder: (quill.Attribute? attribute) {
                            if (attribute != null && attribute.key == quill.Attribute.link.key) {
                              return AppFontStyles.dmSansRegular.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColorTheme.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColorTheme.primary,
                              );
                            }
                            return AppFontStyles.dmSansRegular.copyWith(fontSize: 16.sp);
                          },
                          autoFocus: false,
                          showCursor: true,
                          disableClipboard: true,
                          placeholder: "Type your text here...",
                          customStyles: quill.DefaultStyles(
                            placeHolder: quill.DefaultTextBlockStyle(
                              AppFontStyles.dmSansRegular.copyWith(color: AppColorTheme.dark66, fontSize: 12.sp),
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
                    if (!isEditing)
                      IconButton(
                        padding: isReplying ? const EdgeInsets.only(left: 23) : const EdgeInsets.only(left: 0),
                        onPressed: openMenuBottomSheet,
                        icon: SvgPicture.asset(AppMedia.moreMenu),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),

        /// send button
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: isTapped ? null : handleOnClickSend,
          child: Builder(
            builder: (context) {
              var isAnyAllowedFile = chatProvider.uploadFiles.where((item) {
                final extension = item.name.split('.').last.toLowerCase();
                return allowedFileTypes.contains(extension);
              }).toList();

              final bool isMessageTyped = !_controller.document.isEmpty();

              double opacity = 0.5;
              Color iconColor = AppColorTheme.primaryHover.withOpacity(0.7);

              if ((isUploadingFile && isAnyAllowedFile.isNotEmpty) || isMessageTyped || (isReplying && isMessageTyped)) {
                opacity = 1.0;
                iconColor = AppColorTheme.primaryHover;
              } else {
                opacity = 0.5;
                iconColor = AppColorTheme.primaryHover.withOpacity(0.7);
              }

              return Opacity(
                opacity: opacity,
                child: SvgPicture.asset(AppMedia.send, color: iconColor),
              );
            },
          ),
        )
      ],
    );

    // return Row(
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Container(
    //       padding: isReplying
    //         ? EdgeInsets.only(left: 12, top: 8, right: 12)
    //         : EdgeInsets.only(left: 16.w),
    //       decoration: BoxDecoration(
    //         color: AppColorTheme.white,
    //         border: Border.all(
    //           color: isEditing ? AppColorTheme.primary : AppColorTheme.border,
    //           width: isEditing ? 2 : 1,
    //         ),
    //         borderRadius: BorderRadius.circular(8.r),
    //         boxShadow: [
    //           BoxShadow(color: Color.fromRGBO(10, 41, 55, 0.12), offset: Offset(0, 8), blurRadius: 16.r, spreadRadius: 0),
    //           BoxShadow(color: Color.fromRGBO(10, 41, 55, 0.16), offset: Offset(0, 1), blurRadius: 2.r, spreadRadius: 0),
    //         ],
    //       ),
    //       child: SingleChildScrollView(
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             if (isReplying) replyPreviewWidget(chatProvider),
    //             // if (isEditing) editPreviewWidget(chatProvider),
    //             if (isUploadingFile) uploadPreviewWidget(chatProvider, allowedFileTypes),
    //
    //             // ------------------- Quill Editor Input -------------------
    //             isUploadingFile
    //             ? Container()
    //             : Row(
    //               children: [
    //                 Expanded(
    //                 child: quill.QuillEditor(
    //                   controller: _controller,
    //                   scrollController: ScrollController(),
    //                   config: quill.QuillEditorConfig(maxHeight: 200, customRecognizerBuilder: (attribute, leaf) {
    //                     if (attribute.key == quill.Attribute.link.key) {
    //                       final String link = attribute.value;
    //                       final String text = leaf.toPlainText();
    //                       return TapGestureRecognizer()
    //                         ..onTap = () {
    //                           setState(() {
    //                             currentLinkUrl = link;
    //                             currentLinkText = text;
    //                             linkController.text = link;
    //                             isLinkSheet = true;
    //                           });
    //                         };
    //                     }
    //                     return null;
    //                   },
    //                     customStyleBuilder: (quill.Attribute? attribute) {
    //                       if (attribute != null && attribute.key == quill.Attribute.link.key) {
    //                         return const TextStyle(fontFamily: "Nunito", fontSize: 17, fontWeight: FontWeight.w600, color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue,);
    //                       }
    //                       return const TextStyle(fontFamily: "DMSans", fontSize: 15,);
    //                     },
    //                     autoFocus: false,
    //                     showCursor: true,
    //                     disableClipboard: true,
    //                     placeholder: "Type your text here...",
    //                     customStyles: quill.DefaultStyles(
    //                       placeHolder: quill.DefaultTextBlockStyle(ResponsiveFontStyles.dmSans12Regular(context).copyWith(color: AppColorTheme.dark66, fontSize: 14,), quill.HorizontalSpacing.zero, quill.VerticalSpacing.zero, quill.VerticalSpacing.zero, null,),),),
    //                   focusNode: focusNode,
    //                 ),
    //               ),
    //                 if (isEditing)
    //                   IconButton(
    //                     // padding: const EdgeInsets.only(left: 25,),
    //                     constraints: const BoxConstraints(),
    //                     icon: const Icon(Icons.close, size: 20, color: AppColorTheme.muted,),
    //                     onPressed: () {closeEditIcon();},
    //                   ),
    //                 if(!isEditing)
    //                   IconButton(padding: isReplying ? const EdgeInsets.only(left: 23) : const EdgeInsets.only(left: 0),
    //                   onPressed: openMenuBottomSheet,
    //                   icon: SvgPicture.asset(AppMedia.moreMenu),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       )
    //     ),
    //
    //      /// send Button
    //     InkWell(
    //       splashColor: Colors.transparent,
    //       highlightColor: Colors.transparent,
    //       hoverColor: Colors.transparent,
    //       onTap: isTapped ? null : handleOnClickSend,
    //       child: Builder(
    //         builder: (context) {
    //           var isAnyAllowedFile = chatProvider.uploadFiles.where((item){
    //             final extension = item.name.split('.').last.toLowerCase();
    //             return allowedFileTypes.contains(extension);
    //           }).toList();
    //
    //           final bool isMessageTyped = !_controller.document.isEmpty();
    //
    //           double opacity = 0.5;
    //           Color iconColor = AppColorTheme.primaryHover.withOpacity(0.7);
    //
    //
    //           if ((isUploadingFile && isAnyAllowedFile.isNotEmpty) || isMessageTyped || (isReplying && isMessageTyped)) {
    //             opacity = 1.0;
    //             iconColor = AppColorTheme.primaryHover;
    //           }else{
    //             opacity = 0.5;
    //             iconColor = AppColorTheme.primaryHover.withOpacity(0.7);
    //           }
    //
    //           return Opacity(
    //             opacity: opacity,
    //             child: SvgPicture.asset(AppMedia.send, color: iconColor),
    //           );
    //         },
    //       ),
    //     )
    //   ],
    // );
  }

  void cancelReplyMessage() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.stopUserChatReplying();
    chatProvider.clearMsgSelectionIndexes();
    chatProvider.setMsgSelectionMode(false);
    setState(() {});
  }

  Widget replyPreviewWidget(ChatProvider chatProvider) {
    final dataListProvider = context.read<DataListProvider>();
    Map<String, dynamic> currentUserData = {};
    // final isSender =   dataListProvider.openedChatUserData['iFromUserId'] == dataListProvider.openedChatUserData['iUserId'];
    //  print("dataListProvider.openedChatUserData['iFromUserId'] =========================== ${dataListProvider.openedChatUserData['iFromUserId'] }");
    //  print("dataListProvider.openedChatUserData['iUserId'] =========================== ${dataListProvider.openedChatUserData['iUserId']}");
    // final currentUserId = currentUserData['iUserId'];
    // print("chatProvider.selectedMsgs.first['iFromUserId'] == currentUserId ? dataListProvider.openedChatUserData['vFullName'] ${chatProvider.selectedMsgs.first['iFromUserId'] == currentUserId ? dataListProvider.openedChatUserData['vFullName'] : "You"}");
    final currentUserId = dataListProvider.openedChatUserData['iUserId'];
    final replySenderId = chatProvider.selectedMsgs.isNotEmpty ? chatProvider.selectedMsgs.first['iFromUserId'] : chatProvider.userReplySenderId;

    // print("chatProvider.userReplySenderId: ${chatProvider.userReplySenderId}");

    final isSender = replySenderId == currentUserId;

    // final htmlContent = chatProvider.isUserReplying
    //     ? chatProvider.userReplyText
    //     : chatProvider.userEditingText;

    // String extractPlainTextFromHtml(String htmlString) {
    //   final document = parse(htmlString);
    //   return document.body?.text.trim() ?? '';
    // }
    return Container(
      // padding: EdgeInsets.only(right: 8, top: 5, bottom: 5),
      // margin: EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9.r),
        color: AppColorTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0
          ),
          BoxShadow(
            color: Color.fromRGBO(10, 41, 55, 0.1),
            offset: Offset(0, 1),
            blurRadius: 6,
            spreadRadius: 0
          ),
        ],
        // border: Border.all(color: Colors.grey.shade100),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 2,
              // margin: EdgeInsets.only(right: 8.w, left: 8.w, top: 3.h, bottom: 3.h),
              // padding: EdgeInsets.only(top: 12.h, bottom: 10.h),
              decoration: BoxDecoration(
                color: AppColorTheme.primary,
                borderRadius: BorderRadius.all(Radius.circular(2.r)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 163, 239, 0.5),
                    offset: Offset(2, 0),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (chatProvider.selectedMsgs.isNotEmpty || chatProvider.userReplySenderId != null)
                    Text(
                      isSender
                      ? dataListProvider.openedChatUserData['vFullName'] ?? ""
                      : "You",
                      style: AppFontStyles.dmSansMedium.copyWith(fontSize: 13.sp, color: AppColorTheme.dark70),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (chatProvider.userReplyHasFile && chatProvider.userReplyFileThumb.isNotEmpty) ...[
                        CommonFunctions.isImageFileSvg(chatProvider.userReplyFileThumb)
                          ? SvgPicture.network(
                            chatProvider.userReplyFileThumb,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              chatProvider.userReplyFileThumb,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            chatProvider.userReplyFileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyles.dmSansRegular.copyWith(
                              fontSize: 14.sp,
                              color: AppColorTheme.dark87,
                            ),
                          ),
                        ),
                      ] else
                        Expanded(
                          child: ConvertDecodedTextToHtmlStyle(
                            message: chatProvider.isUserReplying
                            ? chatProvider.userReplyText
                            : "",
                            style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(14),
                              color: AppColorTheme.dark87,
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis
                            )
                          })
                        ),
                      // Expanded(child: Html(data: htmlContent, style: {'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero, fontSize: FontSize(14), color: AppColorTheme.dark87, maxLines: 2, textOverflow: TextOverflow.ellipsis,),},),),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: cancelReplyMessage,
              child: SvgPicture.asset(AppMedia.closeFormatter, color: AppColorTheme.muted,),
            ),
          ],
        ),
      ),
    );
  }

  Widget editPreviewWidget(ChatProvider chatProvider) {
    final dataListProvider = context.read<DataListProvider>();
    final currentUserId = dataListProvider.openedChatUserData['iUserId'];
    final replySenderId = chatProvider.selectedMsgs.isNotEmpty
        ? chatProvider.selectedMsgs.first['iFromUserId']
        : chatProvider.userReplySenderId;

    final isSender = replySenderId == currentUserId;

    // Prepare QuillController from userEditingText
    quill.QuillController getQuillController() {
      try {
        final deltaJson = jsonDecode(chatProvider.userEditingText);
        // print("deltaJson: $deltaJson");
        final doc = quill.Document.fromJson(deltaJson);
        // print("docccc: $doc");

        // Clamp offset to valid range
        final safeOffset = (doc.length > 0) ? doc.length : 0;

        return quill.QuillController(
          document: doc,
          selection: TextSelection.collapsed(offset: safeOffset),
        );
      } catch (e) {
        final doc = quill.Document()..insert(0, chatProvider.userEditingText);

        final safeOffset = (doc.length > 0) ? doc.length : 0;

        return quill.QuillController(
          document: doc,
          selection: TextSelection.collapsed(offset: safeOffset),
        );
      }
    }

    final quillController = chatProvider.isUserEditing ? getQuillController() : null;

    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.only(right: 8, top: 5, bottom: 5),
        margin: EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: AppColorTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(0, 1),
              blurRadius: 1
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
              decoration: const BoxDecoration(
                color: AppColorTheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 163, 239, 0.5),
                    offset: Offset(2, 0),
                    blurRadius: 9,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chatProvider.selectedMsgs.isNotEmpty ||
                        chatProvider.userReplySenderId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          isSender
                              ? (dataListProvider
                                      .openedChatUserData['vFullName'] ??
                                  "")
                              : "You",
                          style: AppFontStyles.dmSansMedium.copyWith(
                            fontSize: 14.sp,
                            color: AppColorTheme.dark70,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (chatProvider.userReplyHasFile &&
                            chatProvider.userReplyFileThumb.isNotEmpty) ...[
                          CommonFunctions.isImageFileSvg(
                                  chatProvider.userReplyFileThumb)
                              ? SvgPicture.network(
                                  chatProvider.userReplyFileThumb,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    chatProvider.userReplyFileThumb,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              chatProvider.userEditingText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyles.dmSansRegular.copyWith(
                                fontSize: 14.sp,
                                color: AppColorTheme.dark87,
                              ),
                            ),
                          ),
                        ] else
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 60, // Limit height of preview
                              ),
                              child: chatProvider.isUserEditing
                                  ? quill.QuillEditor.basic(
                                      controller: quillController!,
                                    )
                                  : ConvertDecodedTextToHtmlStyle(
                                      message: chatProvider.userEditingText,
                                      style: {
                                        "body": Style(
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

  //******* Toggle Attributes *********//
  // void toggleAttribute(quill.Attribute attribute) {
  //   final selection = _controller.selection;
  //   if (!selection.isValid) return;
  //
  //   final currentStyle = _controller.getSelectionStyle();
  //   final isAttributeActive = currentStyle.attributes[attribute.key] != null;
  //
  //   String selectedText = _controller.document.getPlainText(
  //     selection.start,
  //     selection.end - selection.start,
  //   );
  //
  //   final allowedEmojis = emojiToImage.map((e) => e['emoji']).toSet();
  //
  //   bool isOnlyEmojis(String text) {
  //     if (text.isEmpty) return false;
  //     final chars = text.characters.toList();
  //     return chars.every((ch) => allowedEmojis.contains(ch));
  //   }
  //
  //   final onlyEmojisSelected = isOnlyEmojis(selectedText);
  //
  //   setState(() {
  //     if (isAttributeActive) {
  //       if (!onlyEmojisSelected) {
  //         _controller.formatSelection(quill.Attribute.clone(attribute, null));
  //       }
  //       _lastKnownStyle.remove(attribute.key);
  //       _updateToggleState(attribute, false);
  //     } else {
  //       if (!onlyEmojisSelected) {
  //         _controller.formatSelection(attribute);
  //       }
  //       _lastKnownStyle[attribute.key] = attribute;
  //       _updateToggleState(attribute, true);
  //     }
  //   });
  // }

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
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Consumer<ChatProvider>(builder: (context, chatProvider, child) {
          return Column(
            children: [
              chatProvider.isEmojiOptionList
                  ? CommonWidgets.openEmojiOptionList(
                      handleOnCloseEmojiModal, (path) => handleOnTapEmoji(path))
                  : Container()
            ],
          );
        }),
        if (isLinkOptionSheet)
          CommonWidgets.openLinkOptionSheet(
              textController,
              linkController,
              onChangedText,
              onChangedLink,
              handleOnPressApplyLink,
              handleOnTapOutsideLinkModal),
        if (isLinkSheet) openLinkSheet(),
        messageInputBox(),
        GestureDetector(
          onTap: () => setState(() => showColorBar = false),
          child: showColorBar
              ? CommonWidgets.colorBar(
                  (index) => onPressSelectColor(index), selectedColorIndex)
              : CommonWidgets.messageFormatter(
                  isBoldSelected,
                  isItalicSelected,
                  isUnderlineSelected,
                  isStrikeThroughSelected,
                  isBulletSelected,
                  isLinkSelected,
                  selectedColor,
                  onPressLinkIcon,
                  handleOnPressChangeTextColor,
                  handleCloseFormatter,
                  toggleAttribute),
        ),
      ]),
    );
  }

  //************************* Actions performed on link *****************************

  void onChangedText(String value) {
    setState(() {
      textController.text = value;
    });
  }

  void onChangedLink(String value) {
    setState(() {
      linkController.text = value;
    });
  }

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

  void handleOnPressApplyLink() {
    _insertLink();
    setState(() {
      isLinkOptionSheet = !isLinkOptionSheet;
      linkController.clear();
    });
  }

  void handleOnTapOutsideLinkModal() {
    setState(() {
      isLinkOptionSheet = true;
      linkController.clear();
    });
  }

  //******** Insert Link Sheet **********//

  Widget openLinkSheet() {
    print("ca;;;;;;;");
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
                        Text("Link",
                            style: TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            )),
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
                        margin:
                            EdgeInsets.only(top: 14, left: 0, right: 0), //note
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
                            child: Text("Apply",
                                style: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 14.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ))),
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

  //**************************** Emoji Option List ******************************//
  void handleOnCloseEmojiModal() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setEmojiList(false);
  }

  void handleOnTapEmoji(String emojiPath) {
    final selection = _controller.selection;
    final baseOffset = selection.baseOffset;
    // final String emoji = index['vEmojiPath'];
    final currentStyle = _controller.getSelectionStyle();
    // _controller.replaceText(baseOffset, length, emoji,
    //   TextSelection.collapsed(
    //     offset: baseOffset + emoji.length,
    //     affinity: TextAffinity.upstream,
    //     ),
//     );
//     final nextOffset = baseOffset + emoji.length;
//     if (!emoji.contains(RegExp(r'[a-zA-Z0-9]'))) {
//       _controller.formatText(nextOffset - emoji.length, emoji.length, quill.Attribute.clone(quill.Attribute.bold, null),);
//       _controller.formatText(nextOffset - emoji.length, emoji.length, quill.Attribute.clone(quill.Attribute.italic, null),);
//       _controller.formatText(nextOffset - emoji.length, emoji.length, quill.Attribute.clone(quill.Attribute.underline, null,));
//       _controller.formatText(nextOffset - emoji.length, emoji.length, quill.Attribute.clone(quill.Attribute.strikeThrough, null,));
//       _controller.formatText(nextOffset - emoji.length, emoji.length, quill.Attribute.clone(quill.Attribute.ul, null),);
//       _controller.formatText(nextOffset - emoji.length, emoji.length, quill.Attribute.fromKeyValue('color', '#000000'),);
//     }
//     currentStyle.attributes.forEach((key, value) {_controller.formatText(nextOffset, 0, value);});
    // print("Inserted Emoji: $emoji ");
    // print("current Position to emoji: $currentStyle");00000000000000000

    final index = _controller.selection.baseOffset;

    // 2. Determine how many characters to delete if a selection exists
    // 2. Determine how many characters to delete if a selection exists
    final length = _controller.selection.extentOffset - index;

    // 3. Insert the image at the cursor position
    // We use replaceText to handle overwriting selections automatically
    _controller.replaceText(
        index, length, quill.BlockEmbed.image(emojiPath), null);

    // 4. Move the cursor to the position after the newly inserted emoji
    // An embed usually counts as 1 character unit in the document length
    _controller.updateSelection(
      TextSelection.collapsed(offset: index + 1),
      quill.ChangeSource.local,
    );
  }
}

class MyEmojiEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(
    BuildContext context,
    quill.EmbedContext embedContext, // Use EmbedContext here
  ) {
    // Access the data through embedContext.node.value.data
    final String emojiPath = embedContext.node.value.data;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Image.asset(
        emojiPath,
        width: 22,
        height: 22,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 20, color: Colors.red);
        },
      ),
    );
  }
}
