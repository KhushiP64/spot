import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ***************** color theme **********************
class AppColorTheme {
  static const Color primary = Color(0XFF00A3EF);
  static const Color primaryHover = Color(0XFF0299df);
  static const Color primary16 = Color(0XFFCEE9F5);
  static const Color lightPrimary = Color(0XFFEEF2F5);
  static const Color darkPrimary = Color(0XFFA6BDC2);
  static const Color secondary = Color(0XFFD9D9D9);
  static const Color secondary5 = Color.fromARGB(13, 10, 41, 55);
  static const Color secondary6 = Color.fromARGB(15, 10, 41, 55);
  static const Color secondary30 = Color.fromARGB(77, 10, 41, 55);
  static const Color bgColor = Color.fromRGBO(10, 41, 55, 0.4);
  static const Color receiverMsgBg = Color.fromRGBO(10, 41, 55, 0.05);
  static const Color senderMsgBg = Color.fromRGBO(0, 163, 239, 0.16);
  static const Color success = Color(0XFF55CB1E);
  static const Color danger = Color(0XFFEA3843);
  static const Color danger12 = Color(0XFFFCE7E8);
  static const Color darkDanger = Color(0XFFF33F3F);
  static const Color black = Color(0XFF000000);
  static const Color white = Color(0XFFffffff);
  static const Color border = Color(0XFFC7CCD0);
  static const Color dark87 = Color(0XFF212121);
  static const Color dark70 = Color(0XFF4A4B4B);
  static const Color dark66 = Color(0XFF575757);
  static const Color dark50 = Color(0XFF7F7F7F);
  static const Color dark48 = Color(0XFF858585);
  static const Color dark40 = Color(0XFF999999);
  static const Color dark12 = Color(0XFFBFBFBF);
  static const Color dark06 = Color.fromRGBO(0, 0, 0, 0.06);
  static const Color disabledInput = Color.fromARGB(255, 228, 228, 228);
  static const Color muted = Color(0XFFAEB9BD);
  static const Color lightInfo = Color(0XFFF5F7F7);
  static const Color transparent = Color(0X00000000);
  static const Color inputTitle = Color(0XFF212529);
  static const Color orange = Color(0XFFFF9900);
  static const Color chatListHeader = Color(0XFFE5EAED);
  static const Color searchBg = Color(0x0d0A2937);
  static const Color listHover = Color(0xFFE1E6EA);
  static const Color statusList = Color(0x0F0A2937);
  static const Color requiredStar = Color(0xFFD9486B);
  static Color black87 = Colors.black.withOpacity(0.87);
  static Color black66 = Colors.black.withOpacity(0.66);
  static Color black40 = Colors.black.withOpacity(0.40);
  static Color black50 = Colors.black.withOpacity(0.50);
  static Color black25 = Colors.black.withOpacity(0.25);
  static Color black70 = Colors.black.withOpacity(0.70);
  static Color black48 = Colors.black.withOpacity(0.48);

  static const List<Color> textFormatColors = [
    Color(0XFFEA3843),
    Color(0XFFFF8A00),
    Color(0XFFFFB800),
    Color(0XFF49BA14),
    Color(0XFF398415),
    Color(0XFF00A3EF),
    Color(0XFF263DB8),
    Color(0XFFFF5BA0),
    Color(0XFF212121),
    Color(0XFF808080)
  ];
}

// ***************** font style **********************
class AppFontStyles {
  static const TextStyle dmSansRegular = TextStyle(
    fontFamily: "DMSans",
    fontWeight: FontWeight.w400,
  );

  static const TextStyle dmSansNormal = TextStyle(
    fontFamily: "DMSans",
    fontWeight: FontWeight.normal,
  );

  static const TextStyle dmSansMedium = TextStyle(
    fontFamily: "DMSans",
    fontWeight: FontWeight.w500,
  );

  static const TextStyle dmSansBold = TextStyle(
    fontFamily: "DMSans",
    fontWeight: FontWeight.w700,
  );

  static const TextStyle dmSansItalic = TextStyle(
    fontFamily: "DMSans",
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle dmSansMediumItalic = TextStyle(
    fontFamily: "DMSans",
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle dmSansBoldItalic = TextStyle(
    fontFamily: "DMSans",
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
  );
}

class AppStyles {
  static TextStyle activeTabTextStyle = AppFontStyles.dmSansRegular.copyWith(
    color: AppColorTheme.dark87,
    fontSize: 16.sp,
  );

  static TextStyle modalMainTitleStyle = AppFontStyles.dmSansMedium.copyWith(
    color: AppColorTheme.black40,
    fontSize: 14.sp,
  );

  static TextStyle modalSubTitleStyle = AppFontStyles.dmSansMedium.copyWith(
    color: AppColorTheme.black40,
    fontSize: 13.sp,
  );

  static TextStyle groupInfoValue = AppFontStyles.dmSansMedium.copyWith(
    color: AppColorTheme.black87,
    fontSize: 16.sp,
  );

  static TextStyle modalNameStyle = AppFontStyles.dmSansMedium.copyWith(
    color: AppColorTheme.black87,
    fontSize: 18.sp,
  );

  static TextStyle errorTextStyle = AppFontStyles.dmSansRegular.copyWith(
    color: AppColorTheme.darkDanger,
    fontSize: 16.sp,
  );

  static BoxShadow formatterModalShadow1 = BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 2.r,
    spreadRadius: 0,
    color: Color.fromRGBO(0, 0, 0, 0.16),
  );

  static BoxShadow formatterModalShadow2 = BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 6.r,
    spreadRadius: 0,
    color: Color.fromRGBO(10, 41, 55, 0.10),
  );

  static Decoration formatterModalContainerDecoration = BoxDecoration(
    color: AppColorTheme.white,
    border: Border.all(color: AppColorTheme.border),
    borderRadius: BorderRadius.circular(6.r),
    boxShadow: [
      BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 2.r,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.16),
      ),
      BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 6.r,
        spreadRadius: 0,
        color: Color.fromRGBO(10, 41, 55, 0.10),
      )
    ],
  );

  static TextStyle userNameInChat = AppFontStyles.dmSansMedium
      .copyWith(fontSize: 12.sp, color: AppColorTheme.black70);

  static TextStyle timeAndEditedForwardedTextStyle = AppFontStyles.dmSansMedium
      .copyWith(fontSize: 11.sp, color: AppColorTheme.black48);
}
