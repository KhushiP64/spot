// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:spot/core/themes.dart';
// import 'package:spot/core/utils.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class ConvertHTMLToText extends StatelessWidget {
//   final String decoded;
//   const ConvertHTMLToText({super.key, required this.decoded});
//
//   @override
//   Widget build(BuildContext context) {
//     return Html(
//       data: CommonFunctions.normalizeWhitespace(CommonFunctions.getEmojiFromText(decoded)),
//       shrinkWrap: true,
//       style: {
//         "*": Style(
//           fontSize: FontSize(14.0),
//           fontFamily: 'DM Sans',
//         ),
//         "ul": Style(
//           padding: HtmlPaddings.zero,
//           margin: Margins.only(left: 12),
//         ),
//         "ol": Style(
//           padding: HtmlPaddings.zero,
//           margin: Margins.only(left: 0),
//         ),
//         "li": Style(
//           padding: HtmlPaddings.only(left: 6),
//           // margin: Margins.only(bottom: 6),
//           listStylePosition: ListStylePosition.outside,
//         ),
//         "a": Style(
//           color: AppColorTheme.primary,
//           textDecoration: TextDecoration.underline,
//           textDecorationColor: AppColorTheme.primary
//         ),
//       },
//       onLinkTap: (url, _, __) {
//         if (url != null) launchUrl(Uri.parse(url));
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:provider/provider.dart';
// import 'package:spot/core/themes.dart';
// import 'package:spot/core/utils.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:html_unescape/html_unescape.dart';
//
// import '../../../providers/chat_provider.dart';
//
// class ConvertHTMLToText extends StatelessWidget {
//   final String decoded;
//   final String? searchText;
//   final int? currentMatchIndex;
//   final int? totalMatches;
//
//   const ConvertHTMLToText({
//     super.key,
//     required this.decoded,
//     this.searchText,
//     this.currentMatchIndex,
//     this.totalMatches,
//   });
//
//   String _highlightText(String html, String search, int? currentMatchIndex, int? totalMatches) {
//     int count = 0;
//     count++;
//     print("object $count");
//     if (search.isEmpty) return html;
//
//     final regex = RegExp(RegExp.escape(search), caseSensitive: false);
//     final matches = regex.allMatches(html).toList();
//     if (matches.isEmpty) return html;
//     int matchCounter = 0;
//     StringBuffer highlighted = StringBuffer();
//     int lastIndex = 0;
//
//     for (var match in matches) {
//       highlighted.write(html.substring(lastIndex, match.start));
//       matchCounter++;
//
//       final isCurrent = matchCounter == currentMatchIndex;
//
//       highlighted.write(
//         // '<span style="background-color: ${isCurrent ? '#ffff00' : '#ffff00'};">${html.substring(match.start, match.end)}</span>',
//         '<span style="background-color: ${'#ffff00'};">${html.substring(match.start, match.end)}</span>',
//       );
//
//       lastIndex = match.end;
//     }
//
//     highlighted.write(html.substring(lastIndex));
//     return highlighted.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     final normalized = CommonFunctions.normalizeWhitespace(
//       CommonFunctions.getEmojiFromText(decoded),
//     );
//
//     final highlightedHtml = (searchText != null && searchText!.isNotEmpty)
//         ? _highlightText(normalized, searchText!, currentMatchIndex, totalMatches)
//         : normalized;
//     final chatProvider = context.watch<ChatProvider>();
//     final matchKey = GlobalKey();
//
//     // chatProvider.matchKeys.add(matchKey);
//     return Html(
//       // key: matchKey,
//       data: highlightedHtml,
//       shrinkWrap: true,
//       style: {
//         "*": Style(
//           fontSize: FontSize(14.0),
//           fontFamily: 'DM Sans',
//         ),
//         "ul": Style(
//           padding: HtmlPaddings.zero,
//           margin: Margins.only(left: 12),
//         ),
//         "ol": Style(
//           padding: HtmlPaddings.zero,
//           margin: Margins.only(left: 0),
//         ),
//         "li": Style(
//           padding: HtmlPaddings.only(left: 6),
//           listStylePosition: ListStylePosition.outside,
//         ),
//         "a": Style(
//           color: AppColorTheme.primary,
//           textDecoration: TextDecoration.underline,
//           textDecorationColor: AppColorTheme.primary,
//         ),
//         "span": Style(
//           padding: HtmlPaddings.all(1),
//           margin: Margins.zero,
//         )
//       },
//       onLinkTap: (url, _, __) {
//         if (url != null) launchUrl(Uri.parse(url));
//       },
//     );
//   }
// }
///original
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/core/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ConvertHTMLToText extends StatelessWidget {
  final String decoded;
  final String? searchText;
  final int? currentMatchIndex;
  final int? totalMatches;

  const ConvertHTMLToText({
    super.key,
    required this.decoded,
    this.searchText,
    this.currentMatchIndex,
    this.totalMatches,
  });

  String _unescapeAllowedTags(String text) {
    final allowedTags = ['ul', 'li', 'u', 'a', 'b', 'br', 'font', 'img', 'i'];

    // Step 1: Sab tags ko escape karo
    String safeText = text.replaceAll('<', '&lt;').replaceAll('>', '&gt;');

    // Step 2: Normal tags restore karo (without attributes)
    for (var tag in allowedTags) {
      safeText = safeText
          .replaceAll('&lt;$tag&gt;', '<$tag>')
          .replaceAll('&lt;/$tag&gt;', '</$tag>')
          .replaceAll('&lt;$tag ', '<$tag ')
          .replaceAll('&lt;/$tag ', '</$tag ');
    }

    // Step 3: Special handling for <font ...> with attributes
    safeText = safeText.replaceAllMapped(
      RegExp(r'&lt;font([^&]*)&gt;', caseSensitive: false),
      (match) => '<font${match.group(1)}>',
    );

    // Step 4: Restore closing font tags
    safeText = safeText.replaceAll('&lt;/font&gt;', '</font>');

    // Step 5: Special handling for <i ...> with attributes
    safeText = safeText.replaceAllMapped(
      RegExp(r'&lt;i([^&]*)&gt;', caseSensitive: false),
      (match) => '<i${match.group(1)}>',
    );

    // Step 6: Restore closing i tags
    safeText = safeText.replaceAll('&lt;/i&gt;', '</i>');

    return safeText;
  }

  String _highlightText(String html, String search) {
    if (search.isEmpty) return html;

    final escapedSearch = RegExp.escape(search);
    final regex = RegExp(escapedSearch, caseSensitive: false);
    final matches = regex.allMatches(html).toList();

    if (matches.isEmpty) return html;

    StringBuffer highlighted = StringBuffer();
    int lastIndex = 0;

    for (var match in matches) {
      final beforeMatch = html.substring(lastIndex, match.start);
      final matchText = html.substring(match.start, match.end);

      // Escape both parts for HTML
      highlighted.write(const HtmlEscape().convert(beforeMatch));
      highlighted.write(
        '<span style="background-color: #ffff00;">${const HtmlEscape().convert(matchText)}</span>',
      );

      lastIndex = match.end;
    }

    highlighted.write(const HtmlEscape().convert(html.substring(lastIndex)));
    return highlighted.toString();
  }

  @override
  Widget build(BuildContext context) {
    final normalized = CommonFunctions.normalizeWhitespace(
      CommonFunctions.getEmojiFromText(decoded),
    );

    final safeHtml = _unescapeAllowedTags(normalized);

    final highlightedHtml = (searchText != null && searchText!.isNotEmpty)
        ? _highlightText(safeHtml, searchText!)
        : safeHtml;

    return Html(
      data: highlightedHtml,
      shrinkWrap: true,
      style: {
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
      },
      onLinkTap: (url, _, __) {
        if (url != null) launchUrl(Uri.parse(url));
      },
    );
  }
}

///color orange and yellow
// class ConvertHTMLToText extends StatelessWidget {
//   final String decoded;
//   final String? searchText;
//   final int? currentMatchIndex;
//   final int? totalMatches;
//
//   const ConvertHTMLToText({
//     super.key,
//     required this.decoded,
//     this.searchText,
//     this.currentMatchIndex,
//     this.totalMatches,
//   });
//
//   String _unescapeAllowedTags(String text) {
//     final allowedTags = ['ul', 'li', 'u', 'a', 'b', 'br', 'font', 'img', 'i'];
//
//     String safeText = text.replaceAll('<', '&lt;').replaceAll('>', '&gt;');
//
//     for (var tag in allowedTags) {
//       safeText = safeText
//           .replaceAll('&lt;$tag&gt;', '<$tag>')
//           .replaceAll('&lt;/$tag&gt;', '</$tag>')
//           .replaceAll('&lt;$tag ', '<$tag ')
//           .replaceAll('&lt;/$tag ', '</$tag ');
//     }
//
//     safeText = safeText.replaceAllMapped(
//       RegExp(r'&lt;font([^&]*)&gt;', caseSensitive: false),
//           (match) => '<font${match.group(1)}>',
//     );
//     safeText = safeText.replaceAll('&lt;/font&gt;', '</font>');
//
//     safeText = safeText.replaceAllMapped(
//       RegExp(r'&lt;i([^&]*)&gt;', caseSensitive: false),
//           (match) => '<i${match.group(1)}>',
//     );
//     safeText = safeText.replaceAll('&lt;/i&gt;', '</i>');
//
//     return safeText;
//   }
//
//   /// Highlight all matches (yellow) and current match (blue)
//   String _highlightText(String html, String search) {
//     if (search.isEmpty) return html;
//
//     final regex = RegExp(RegExp.escape(search), caseSensitive: false);
//     final matches = regex.allMatches(html).toList();
//     if (matches.isEmpty) return html;
//
//     StringBuffer highlighted = StringBuffer();
//     int lastIndex = 0;
//
//     for (int i = 0; i < matches.length; i++) {
//       final match = matches[i];
//
//       highlighted.write(html.substring(lastIndex, match.start));
//
//       // Current match ko alag style
//       if (currentMatchIndex != null && i == currentMatchIndex) {
//         highlighted.write(
//           '<span style="background-color: #db7916; color: white;">${html.substring(match.start, match.end)}</span>',
//         );
//       } else {
//         highlighted.write(
//           '<span style="background-color: #ffff00;">${html.substring(match.start, match.end)}</span>',
//         );
//       }
//
//       lastIndex = match.end;
//     }
//
//     highlighted.write(html.substring(lastIndex));
//     return highlighted.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final normalized = CommonFunctions.normalizeWhitespace(
//       CommonFunctions.getEmojiFromText(decoded),
//     );
//
//     final safeHtml = _unescapeAllowedTags(normalized);
//
//     final highlightedHtml = (searchText != null && searchText!.isNotEmpty)
//         ? _highlightText(safeHtml, searchText!)
//         : safeHtml;
//
//     return Html(
//       data: highlightedHtml,
//       shrinkWrap: true,
//       style: {
//         "*": Style(
//           fontSize: FontSize(14.0),
//           fontFamily: 'DM Sans',
//         ),
//         "ul": Style(
//           padding: HtmlPaddings.zero,
//           margin: Margins.only(left: 12),
//         ),
//         "ol": Style(
//           padding: HtmlPaddings.zero,
//           margin: Margins.only(left: 0),
//         ),
//         "li": Style(
//           padding: HtmlPaddings.only(left: 6),
//           listStylePosition: ListStylePosition.outside,
//         ),
//         "a": Style(
//           color: AppColorTheme.primary,
//           textDecoration: TextDecoration.underline,
//           textDecorationColor: AppColorTheme.primary,
//         ),
//         "span": Style(
//           padding: HtmlPaddings.all(1),
//           margin: Margins.zero,
//         )
//       },
//       onLinkTap: (url, _, __) {
//         if (url != null) launchUrl(Uri.parse(url));
//       },
//     );
//   }
// }

///with converting html tags
// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:provider/provider.dart';
// import 'package:spot/core/themes.dart';
// import 'package:spot/core/utils.dart';
// import '../../../providers/chat_provider.dart';
//
// class ConvertHTMLToText extends StatelessWidget {
//   final String decoded;
//   final String? searchText;
//   final int? currentMatchIndex;
//   final int? totalMatches;
//
//   const ConvertHTMLToText({
//     super.key,
//     required this.decoded,
//     this.searchText,
//     this.currentMatchIndex,
//     this.totalMatches,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final chatProvider = context.watch<ChatProvider>();
//
//     // 1️⃣ Decode + filter tags + emoji replace + whitespace normalize
//     final cleanHtml = CommonFunctions.normalizeWhitespace(
//       CommonFunctions.getEmojiFromText(
//         CommonFunctions.htmlDecodeWithAllowedTags(decoded),
//       ),
//     );
//
//     // 2️⃣ Optionally highlight search text
//     final highlightedHtml = (searchText != null && searchText!.isNotEmpty)
//         ? _highlightText(cleanHtml, searchText!, currentMatchIndex, totalMatches)
//         : cleanHtml;
//
//     // 3️⃣ Render HTML safely
//     return Html(
//       data: highlightedHtml,
//       style: {
//         'body': Style(
//           fontSize: FontSize(15),
//           color: AppColorTheme.dark87,
//           margin: Margins.zero,
//           padding: HtmlPaddings.zero,
//         ),
//       },
//     );
//   }
//
//   String _highlightText(String html, String keyword, int? currentIndex, int? total) {
//     final regex = RegExp(RegExp.escape(keyword), caseSensitive: false);
//     int matchIndex = 0;
//     return html.replaceAllMapped(regex, (match) {
//       matchIndex++;
//       final isCurrent = (matchIndex == (currentIndex ?? -1));
//       final color = isCurrent ? '#2196F3' : '#FFFF00'; // blue for current, yellow for others
//       return '<span style="background-color: $color">${match.group(0)}</span>';
//     });
//   }
// }
