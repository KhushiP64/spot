import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final httpClient = super.createHttpClient(context);
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return httpClient;
  }
}
