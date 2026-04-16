import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> reqPermission() async {
  if (Platform.isAndroid) {
    final build = await DeviceInfoPlugin().androidInfo;

    if (build.version.sdkInt >= 33) {
      var photos = await Permission.photos.request();
      var videos = await Permission.videos.request();
      var audio = await Permission.audio.request();
      return photos.isGranted || videos.isGranted || audio.isGranted;
    } else {
      var storage = await Permission.storage.request();
      return storage.isGranted;
    }
  } else if (Platform.isIOS) {
    var photos = await Permission.photos.request();
    return photos.isGranted;
  } else {
    return false;
  }
}
