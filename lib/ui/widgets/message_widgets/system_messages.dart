import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/ui/widgets/message_widgets/convert_decoded_text_to_html_style.dart';
import '../../../providers/chat_provider.dart';
import 'convert_html_to_text.dart';

class SystemMessages extends StatefulWidget {
  final Map<String, dynamic> messageItem;
  final String formattedTime;
  final String systemMessageHighlightedText;

  const SystemMessages({
    super.key,
    required this.messageItem,
    required this.formattedTime,
    required this.systemMessageHighlightedText,
  });

  @override
  State<SystemMessages> createState() => _SystemMessagesState();
}

class _SystemMessagesState extends State<SystemMessages> {
  late String type;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    type = args['type'];
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    // final dataListProvider = context.read<DataListProvider>();
    // final messages = dataListProvider.userMessagesList;
    // final messageItem = messages.length;

    var unescape = HtmlUnescape();
    var decoded = unescape.convert(widget.messageItem['vMsgData']['message']);

    return Container(
      constraints: BoxConstraints(
          maxWidth: chatProvider.msgSelectionMode
              ? MediaQuery.of(context).size.width * 0.70
              : MediaQuery.of(context).size.width * 0.85),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.h,
            margin: EdgeInsets.only(right: 8.w),
            child: SvgPicture.network(widget.messageItem['vMsgData']['icon'],
                fit: BoxFit.contain),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ConvertDecodedTextToHtmlStyle(
                    // message: "widget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedTextwidget.systemMessageHighlightedText",
                    message: decoded,
                    highlightText: widget.systemMessageHighlightedText),
                SizedBox(height: 4.h),
                Text(widget.formattedTime,
                    style: AppStyles.timeAndEditedForwardedTextStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
