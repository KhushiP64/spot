import 'package:flutter/material.dart';

// ***************** Color Theme **********************
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
  static const Color grey = Color(0XFF999999);
  static const Color dark06 = Color.fromRGBO(0, 0, 0, 0.06);
  static const Color disabledInput = Color.fromARGB(255, 228, 228, 228);
  static const Color muted = Color(0XFFAEB9BD);
  static const Color lightInfo = Color(0XFFF5F7F7);
  static const Color transparent = Color(0X00000000);
  static const Color inputTitle = Color(0XFF212529);
  static const Color warning = Color(0XFFFF9900);
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

// ***************** Font Styles **********************
class AppFontStyles {
  static const TextStyle dmSansRegular = TextStyle(
    fontFamily: "DMSans",
    fontWeight: FontWeight.w400,
  );

  static const TextStyle dmSansMedium = TextStyle(
    fontFamily: "DMSans",
    fontWeight: FontWeight.w500,
  );

  static const TextStyle dmSansBold = TextStyle(
    fontFamily: "DMSans",
    fontWeight: FontWeight.w700,
  );
}

// ***************** Responsive Font Size Utility **********************
class FontSizeUtil {
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 480) {
      return baseSize; // Mobile
    } else if (width <= 960) {
      return baseSize * 1.2; // Tablet
    } else {
      return baseSize * 1.5; // Desktop
    }
  }
}

// ***************** Responsive Font Styles **********************
class ResponsiveFontStyles {
  static TextStyle dmSans12Regular(BuildContext context) =>
      AppFontStyles.dmSansRegular.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 12.0),
      );

  static TextStyle dmSans14Regular(BuildContext context) =>
      AppFontStyles.dmSansRegular.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 14.0),
      );
  static TextStyle dmSans15Regular(BuildContext context) =>
      AppFontStyles.dmSansRegular.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 15.0),
      );

  static TextStyle dmSans16Regular(BuildContext context) =>
      AppFontStyles.dmSansRegular.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 16.0),
      );
  static TextStyle dmSans17Regular(BuildContext context) =>
      AppFontStyles.dmSansRegular.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 17.0),
      );

  static TextStyle dmSans18Regular(BuildContext context) =>
      AppFontStyles.dmSansRegular.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 18.0),
      );

  static TextStyle dmSans20Regular(BuildContext context) =>
      AppFontStyles.dmSansRegular.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 20.0),
      );

  static TextStyle dmSans12Medium(BuildContext context) =>
      AppFontStyles.dmSansMedium.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 12.0),
      );

  static TextStyle dmSans13Medium(BuildContext context) =>
      AppFontStyles.dmSansMedium.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 13.0),
      );

  static TextStyle dmSans14Medium(BuildContext context) =>
      AppFontStyles.dmSansMedium.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 14.0),
      );
  static TextStyle dmSans15Medium(BuildContext context) =>
      AppFontStyles.dmSansMedium.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 15.0),
      );

  static TextStyle dmSans16Medium(BuildContext context) =>
      AppFontStyles.dmSansMedium.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 16.0),
      );

  static TextStyle dmSans18Medium(BuildContext context) =>
      AppFontStyles.dmSansMedium.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 18.0),
      );

  static TextStyle dmSans20Medium(BuildContext context) =>
      AppFontStyles.dmSansMedium.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 20.0),
      );

  static TextStyle dmSans26Medium(BuildContext context) =>
      AppFontStyles.dmSansMedium.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 26.0),
      );

  static TextStyle dmSans28Medium(BuildContext context) =>
      AppFontStyles.dmSansMedium.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 28.0),
      );

  static TextStyle dmSans30Medium(BuildContext context) =>
      AppFontStyles.dmSansMedium.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 30.0),
      );

  static TextStyle dmSans12Bold(BuildContext context) =>
      AppFontStyles.dmSansBold.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 12.0),
      );

  static TextStyle dmSans14Bold(BuildContext context) =>
      AppFontStyles.dmSansBold.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 14.0),
      );

  static TextStyle dmSans16Bold(BuildContext context) =>
      AppFontStyles.dmSansBold.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 16.0),
      );

  static TextStyle dmSans18Bold(BuildContext context) =>
      AppFontStyles.dmSansBold.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 18.0),
      );

  static TextStyle dmSans20Bold(BuildContext context) =>
      AppFontStyles.dmSansBold.copyWith(
        fontSize: FontSizeUtil.getResponsiveFontSize(context, 20.0),
      );
}
