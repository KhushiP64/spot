import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ConvertDecodedTextToHtmlStyle extends StatefulWidget {
  final String message;
  final String? highlightText;
  final Map<String, Style>? style;

  const ConvertDecodedTextToHtmlStyle({
    super.key,
    required this.message,
    this.highlightText,
    this.style,
  });

  @override
  State<ConvertDecodedTextToHtmlStyle> createState() =>
      _ConvertDecodedTextToHtmlStyleState();
}

class _ConvertDecodedTextToHtmlStyleState
    extends State<ConvertDecodedTextToHtmlStyle> {
  @override
  Widget build(BuildContext context) {
    final decoded = CommonFunctions.decodeMessage(widget.message);

    final defaultStyle = {
      "body": Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
      ),
      "*": Style(
        fontSize: FontSize(14.0),
        fontFamily: 'DM Sans',
      ),
      "ul": Style(
        padding: HtmlPaddings.zero,
        margin: Margins.only(left: 12),
      ),
      "ol": Style(
        padding: HtmlPaddings.zero,
        margin: Margins.only(left: 0),
      ),
      "li": Style(
        padding: HtmlPaddings.only(left: 6),
        listStylePosition: ListStylePosition.outside,
      ),
      "a": Style(
        color: AppColorTheme.primary,
        textDecoration: TextDecoration.underline,
        textDecorationColor: AppColorTheme.primary,
      ),
      "span": Style(
        padding: HtmlPaddings.all(1),
        margin: Margins.zero,
      )
    };

    final mergedStyle = widget.style != null
        ? {...defaultStyle, ...widget.style!}
        : defaultStyle;

    final highlight = widget.highlightText;
    final isHtml =
        widget.message.contains("&lt;") || widget.message.contains("&gt;");

    if (isHtml) {
      return Html(
        data: decoded,
        shrinkWrap: true,
        style: mergedStyle,
        onLinkTap: (url, _, __) {
          if (url != null) launchUrl(Uri.parse(url));
        },
      );
    }

    /// Highlighted text
    if (highlight != null && highlight.isNotEmpty) {
      final parts =
          decoded.split(RegExp(RegExp.escape(highlight), caseSensitive: false));
      return RichText(
        text: TextSpan(
          children: [
            for (int i = 0; i < parts.length; i++) ...[
              TextSpan(
                  text: parts[i],
                  style: AppFontStyles.dmSansRegular
                      .copyWith(fontSize: 14, color: AppColorTheme.inputTitle)),
              if (i != parts.length - 1)
                TextSpan(
                  text: decoded.substring(
                    parts.sublist(0, i + 1).join().length,
                    parts.sublist(0, i + 1).join().length + highlight.length,
                  ),
                  style: AppFontStyles.dmSansRegular.copyWith(
                    fontSize: 14.sp,
                    backgroundColor: Colors.yellowAccent.withOpacity(0.6),
                    color: AppColorTheme.inputTitle,
                  ),
                ),
            ]
          ],
        ),
      );
    }

    /// Text
    return Text(
      decoded,
      softWrap: true,
      style: AppFontStyles.dmSansRegular
          .copyWith(fontSize: 14.sp, color: AppColorTheme.black87),
    );
  }
}
