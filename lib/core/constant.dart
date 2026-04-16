class AppConstants {
  static bool hasUppercase(String text) => text.contains(RegExp(r'[A-Z]'));
  static bool hasLowercase(String text) => text.contains(RegExp(r'[a-z]'));
  static bool hasNumber(String text) => text.contains(RegExp(r'[0-9]'));
  static bool hasSpecialChar(String text) =>
      text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  static bool hasMinLength(String text) => text.length >= 8;
}
