import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:spot/core/responsive_fonts.dart';
import 'package:spot/services/configuration.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot/providers/group_provider.dart';
import 'package:spot/providers/profile_provider.dart';
import 'package:spot/services/api_service.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;

class CommonFunctions {
  // static List<Map<String, dynamic>> cleanQuillDelta(List input) {
  //   List<Map<String, dynamic>> updatedData = [];
  //   Map<String, dynamic>? previousItem;
  //
  //   for (var item in input) {
  //     Map<String, dynamic> styles = item['attributes'] ?? {};
  //     // Skip empty insertions
  //     if (item['insert'] == "") {
  //       continue;
  //     }
  //
  //     // If the current item is a link, handle it separately
  //     if (styles.containsKey('link') && styles['link'] != null && styles['link'] != '') {
  //       Map<String, dynamic> updatedItem = Map<String, dynamic>.from(item);
  //       updatedItem['attributes'] = {"link": item['attributes']['link']};
  //       updatedData.add(updatedItem);
  //       continue;
  //     }
  //
  //     // Check if this item is part of a bullet list
  //     if (styles.containsKey('list') && styles['list'] == 'bullet') {
  //       // If it's the same list as the previous one, merge the current item into the previous one
  //       if (previousItem != null && previousItem['attributes']?['list'] == 'bullet') {
  //         previousItem['insert'] += item['insert']; // Concatenate text for the list item
  //       } else {
  //         // Otherwise, add it as a new list item
  //         updatedData.add(item);
  //         previousItem = item; // Track the current item as the last list item
  //       }
  //     } else {
  //       // For non-list items, just add them to the updated list
  //       updatedData.add(item);
  //       previousItem = item; // Track the current item for future list items
  //     }
  //   }
  //
  //   return updatedData;
  // }

  static List cleanQuillDelta(List input) {
    List updatedData = [];

    for (int i = 0; i < input.length; i++) {
      Map<String, dynamic> styles = input[i]['attributes'] ?? {};

      if (!styles.containsKey('list')) {
        if (i < input.length - 1 &&
            input[i + 1].containsKey('attributes') &&
            !input[i + 1]['attributes'].containsKey("list")) {
          updatedData.add(input[i]);
        }
      }

      if (styles.containsKey('list') && styles['list'] == 'bullet') {
        var updatedItem = input[i - 1]['insert'];
        var updatedStyle = input[i - 1].containsKey('attributes')
            ? {...input[i - 1]['attributes'], ...styles}
            : styles;
        updatedData.add({"insert": updatedItem, "attributes": updatedStyle});
      }

      // Handling list items
      //   if (styles.containsKey('list') && styles['list'] == 'bullet') {
      //     var updatedItem = input[i];
      //     var updatedStyle = input[i-1].containsKey("attributes") ? {...input[i - 1]['attributes'], ...styles} : styles;
      //     updatedItem = {"insert": input[i-1]['insert'], "attributes": updatedStyle};  // Take previous item's insert
      //     updatedData.add(updatedItem);
      //   } else {
      //
      //     // Check next item only if it's within bounds
      //     if (i < input.length - 1 && input[i+1].containsKey("attributes") && !input[i+1]["attributes"].containsKey('list')) {
      //       updatedData.add(input[i]);
      //     }
      //   }
    }
    return updatedData;
  }

  static String encodeMessage(List input) {
    if (input.isEmpty) return "";

    final buffer = StringBuffer();

    final updatedData = cleanQuillDelta(input);

    bool insideList = false;
    for (var item in updatedData) {
      // String text = item['insert'] ?? '';
      String text = item['insert'];
      Map<dynamic, dynamic> styles = item['attributes'] ?? {};

      // Escape HTML special characters in text first
      text = htmlEscape(text);

      // Apply styles by wrapping tags
      // bold
      if (styles['bold'] == true) {
        text = "&lt;b&gt;$text&lt;/b&gt;";
      }

      // Italic
      if (styles['italic'] == true) {
        text = "&lt;i&gt;$text&lt;/i&gt;";
      }

      // Underline
      if (styles['underline'] == true) {
        text = "&lt;u&gt;$text&lt;/u&gt;";
      }

      // Strike
      if (styles['strike'] == true) {
        text = "&lt;strike&gt;$text&lt;/strike&gt;";
      }

      // Color
      if (styles.containsKey('color') && styles['color'] != null) {
        text =
            "&lt;font color=&quot;${styles['color']}&quot;&gt;$text&lt;/font&gt;";
      }

      // Check for bullet list
      // Check for bullet list
      if (styles.containsKey('list') &&
          styles['list'] != null &&
          styles['list'] == 'bullet') {
        // Start <ul> tag only if it's the first bullet point
        if (!insideList) {
          buffer.write("&lt;ul&gt;");
          // text = "&lt;ul&gt;";
          insideList = true;
        }

        // Wrap the text in <li> tags
        buffer.write("&lt;li&gt;$text&lt;/li&gt;");
      } else {
        // If not a list, just append the text
        buffer.write(text);
      }

      // Link tag
      if (styles.containsKey('link') &&
          styles['link'] != null &&
          styles['link'] != '') {
        // text = "&lt;u&gt;$text&lt;/u&gt;";
        // text = "&lt;font color=&quot;#37AFE1&quot;&gt;$text&lt;/font&gt;";
        // text = "&lt;a href=&quot;${styles['link']}/&quot; target=&quot;_blank&quot;&gt;$text&lt;/a&gt;";
        text =
            '&lt;a href="${styles['link']}" target="_blank" style="text-decoration: none;"&gt;'
            '&lt;span style="color:#37AFE1; text-decoration: underline; text-decoration-color: #37AFE1; font-weight: 600;"&gt;$text&lt;/span&gt;'
            '&lt;/a&gt;';
        buffer.write(text);
      }
    }
    if (insideList) {
      buffer.write("&lt;/ul&gt;");
    }

    return buffer.toString();
  }

  static String htmlEscape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  // static void encodeMessage(List input) {
  //   if(input.isNotEmpty && input != null) {
  //     final encodedText = input.forEach((item) {
  //       var formattedText = "";
  //       if (item['insert'] != null && item['insert'] != "" && item['insert'].isNotEmpty) {
  //         if (item['attributes']['bold']) {
  //           formattedText = "&lt;b&gt;${item['insert']}&lt;/b&gt;";
  //         }
  //       }
  //     });
  //   }
  // }

  // *********************** hide & show status bar *************************
  static Future<void> hideStatusBar() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
  }

  static Future<void> showStatusBar() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  // **************************** Crop Image ******************************
  static Future<XFile?> cropImage({required File imgFile}) async {
    try {
      await hideStatusBar();
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imgFile.path,
        // aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Photo',
            toolbarColor: AppColorTheme.black,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
              CropAspectRatioPresetCustom(),
            ],
            statusBarColor: Colors.transparent,
            activeControlsWidgetColor: AppColorTheme.primary,
            backgroundColor: Colors.black,
          ),
          IOSUiSettings(
            title: 'Edit Photo',
            aspectRatioLockEnabled: true,
          ),
        ],

        maxWidth: 300,
        maxHeight: 300,
      );

      if (croppedFile == null) {
        return null;
      }

      // ✅ Convert CroppedFile → XFile
      return XFile(croppedFile.path);
    } catch (e) {
      // print("Error cropping image: $e");
      return null;
    } finally {
      showStatusBar();
    }
  }

  // **************************** pic image from gallery **************************
  static Future<XFile?> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    await hideStatusBar();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    await showStatusBar();

    if (pickedImage != null) {
      String fileExtension = pickedImage.name.split('.').last.toLowerCase();
      if (fileExtension.toLowerCase() == 'jpg' ||
          fileExtension.toLowerCase() == 'jpeg' ||
          fileExtension.toLowerCase() == 'png') {
        XFile? img = await cropImage(imgFile: File(pickedImage.path));
        return img;
      } else {
        // Show an error message if file is not jpg or png
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid File'),
            content: const Text('Only JPG and PNG files are allowed.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK')),
            ],
          ),
        );
      }
    }
    return null;
  }

  /// Decode function for received messages
  /// Converts &lt; and &gt; back into < and >
  static String decodeMessage(String input) {
    // Only decode if message actually contains encoded tags
    if (input.contains("&lt;") || input.contains("&gt;")) {
      return input
          .replaceAll("&lt;", "<")
          .replaceAll("&gt;", ">")
          .replaceAll("&quot;", "\"")
          .replaceAll("&amp;", "&");
    }
    return input; // Plain text → return as is
  }

  // ***************** get device infooo ********************
  static Future<String?> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
    } catch (e) {
      // print(" $e");
    }
    return null;
  }

  static String getNotificationLabel(String ext) {
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext))
      return "Image";
    if (['mp4', 'avi', 'mov', 'wmv', 'mkv'].contains(ext)) return "Video";
    if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'csv', 'ppt', 'pptx']
        .contains(ext)) return "Document";
    return "File";
  }

  // ***************** download files *******************
  static Future<bool> downloadFileWithPermission(
      String url, String fileName, BuildContext context) async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) return false;

    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final savePath = '${directory.path}/$fileName';
    final dio = Dio();

    try {
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // print("Downloading: ${(received / total * 100).toStringAsFixed(0)}%");
          } else {
            // print("Downloading...");
          }
        },
      );
      // print("File downloaded to: $savePath");
      return true;
    } catch (e) {
      // print("Download failed: $e");
      return false;
    }
  }

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 11+ (Scoped Storage)
      final isGranted = await Permission.manageExternalStorage.isGranted;
      if (isGranted) return true;

      // For Android < 11, fallback to storage permission
      if (await Permission.storage.request().isGranted) return true;

      // Launch settings intent for all files access (MANAGE_EXTERNAL_STORAGE)
      final intent = AndroidIntent(
        action: 'android.settings.MANAGE_ALL_FILES_ACCESS_PERMISSION',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      await intent.launch();

      // Wait 3 seconds for user to toggle permission manually
      await Future.delayed(Duration(seconds: 3));

      // Check again
      return await Permission.manageExternalStorage.isGranted;
    }

    // On iOS/macOS/etc. always true
    return true;
  }

  // *************** check url is of image *****************
  static bool isImage(String url) {
    // Define common image extensions
    final imageExtensions = ['.jpg', '.jpeg', '.png'];

    // Convert URL to lowercase and check if it ends with any image extension
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  // **************** check for image is svg *******************
  static bool isImageFileSvg(String url) {
    return url.toLowerCase().endsWith('.svg');
  }

  // *************** get emojis from text ********************
  static String getEmojiFromText(String text) {
    final document = parse(text);
    for (final img in document.querySelectorAll("img")) {
      final alt = img.attributes["alt"];
      if (alt != null) {
        img.replaceWith(dom.Text(alt.trim()));
      }
    }
    return document.body?.innerHtml.trim() ?? text;
  }

  // ****************** remove white space from string *******************
  static String normalizeWhitespace(String html) {
    return html.replaceAll(RegExp(r'\s{2,}'), ' ');
  }

  // ****************** sort list by time *******************
  static List<dynamic> sortListByTime(List<dynamic> listData) {
    listData.sort((a, b) {
      final timeA = a['lastTime'];
      final timeB = b['lastTime'];

      if (timeA == null || timeA.toString().isEmpty) return 1;
      if (timeB == null || timeB.toString().isEmpty) return -1;

      final dateA = DateTime.tryParse(timeA.toString());
      final dateB = DateTime.tryParse(timeB.toString());

      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA); // Descending
    });
    return listData;
  }

  // ***************** convert date to dd MMM yyyy h:mm a this format *****************
  static String dateFormat(String? date) {
    try {
      if (date == null || date.trim().isEmpty) return '-';
      DateTime dateTime = DateTime.parse(date);
      return DateFormat('dd MMM yyyy h:mm a').format(dateTime);
    } catch (e) {
      // print('Invalid date format: $date');
      return '-';
    }
  }

  // ************************* get date time ************************
  static String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else {
      return DateFormat('d MMM yyyy').format(date);
    }
  }

  // ************** get user data ****************
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userPref = prefs.getString('userData');
      Map<String, dynamic> userData =
          jsonDecode(userPref!) as Map<String, dynamic>;
      // print('userDatauserDatauserData: $userData');
      return userData;
    } catch (error) {
      // print("Error while getting user data....$error");
      return {};
    }
  }

  // ***************** check for user is admin in group *********************
  static Future<bool> checkIsAdmin(List adminList) async {
    try {
      final currentUser = await CommonFunctions.getUserData();
      final bool check = adminList.contains(currentUser['iUserId']);
      return check;
    } catch (error) {
      // print("Error while checking admin is current user in group $error");
      return false;
    }
  }

  // ******************* replace msg by ids *********************
  static List replaceMatchingItemsById(
      {required List<dynamic> originalList,
      required List<dynamic> updatedList,
      required BuildContext context}) {
    final updatedMap = {
      for (var item in updatedList) item['id']: item,
    };

    // Replace items in originalList if matching id found in updatedMap
    for (int i = 0; i < originalList.length; i++) {
      final id = originalList[i]['id'];
      if (updatedMap.containsKey(id)) {
        originalList[i] = updatedMap[id]!;
      }
    }
    return originalList;
  }

  // ******************* replace msg by ids *********************
  static List addNewMsgInList(
      {required List<dynamic> originalList,
      required List<dynamic> updatedList,
      required BuildContext context}) {
    if (updatedList.isNotEmpty) {
      // debugPrint("updatedList $updatedList", wrapWidth: 1024);
      for (var item in updatedList) {
        // originalList.insert(0, item);
        originalList.add(item);
      }
    }
    return originalList;
  }

  // ******************* remove msg by ids *********************
  static List removeMsgInList({
    required List<dynamic> originalList,
    required Map<String, dynamic> updatedList,
    required BuildContext context,
  }) {
    // print("updatedList['id'] ${updatedList['id']}");
    originalList.removeWhere((item) => item["id"] == updatedList['id']);
    // print('originalList $originalList');
    return originalList;
  }

  // ****************** allowed file list ***********************
  static bool isDisallowedFile(String fileName) {
    final lower = fileName.toLowerCase();
    const disallowed = ['.dart', '.gif', '.avif'];
    return disallowed.any((ext) => lower.endsWith(ext));
  }

  // *********************** get profile dataaa ***********************
  static Future<Map<String, dynamic>> getUserProfileData(
      BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();
    try {
      final userData = await CommonFunctions.getUserData();
      final response = await ApiService.apiPostData(
          Configuration.getProfileData,
          token: userData['tToken']);
      if (response?['status'] == 200) {
        if (response?['data'] != null) {
          profileProvider.setSelectedStatusId(response?['data']['eCustStatus']);
        }
      }
      return response?['data'];
    } catch (error) {
      return {};
      // print("Error while get user profile data.... $error");
    }
  }

  // ************** get user list ****************
  static Future<List> getUserList() async {
    try {
      final userData = await CommonFunctions.getUserData();
      // print("Use dataaaaaaaaaaaaaa $userData");
      final response = await ApiService.apiPostData(Configuration.getUserList,
          token: userData['tToken']);
      // debugPrint("get user list response $response", wrapWidth: 1024);
      return response?['data'];
    } catch (error) {
      return [];
      // print("Error while getting user list from api....$error");
    }
  }

  // ************** get user chat list ****************
  static Future<List> getUserChatList(
      {String searchText = '', int page = 1}) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "searchtext": searchText,
        "page": page,
      };
      final response = await ApiService.apiPostData(
          Configuration.getChatUserList,
          postData: postData,
          token: userData['tToken']);
      return response?['data'];
    } catch (error) {
      return [];
      // print("Error while getting user chat list....$error");
    }
  }

  // ************** get group list ****************
  static Future<List> getGroupList() async {
    try {
      final userData = await CommonFunctions.getUserData();
      // print("userData['tToken'] ${userData['tToken']}");
      final response = await ApiService.apiPostData(Configuration.getGroupList,
          token: userData['tToken']);
      return response?['data'];
    } catch (error) {
      // print("Error while getting group list from api....$error");
      return [];
    }
  }

  // ************** get single user data ****************
  static Future<Map<String, dynamic>> getSingleUser(String iUserId) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "userId": iUserId,
      };
      final response = await ApiService.apiPostData(Configuration.getSingleUser,
          postData: postData, token: userData['tToken']);
      // print("single user responseresponseresponseresponse=================== ${response}");
      return response?['data'];
    } catch (error) {
      // print("Error while getting singleUser data from api....$error");
      return {};
    }
  }

  // ************** get group list ****************
  static Future<Map<String, dynamic>> getLoginUser() async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "userId": userData['iUserId'],
      };
      // print("postDfata $postData");
      final response = await ApiService.apiPostData(Configuration.getSingleUser,
          postData: postData, token: userData['tToken']);
      // print("Login User=================== ${response}");
      return response?['data'];
    } catch (error) {
      return {};
      // print("Error while getting login user user data from api....$error");
    }
  }

  // ************** get group list ****************
  static Future<List> getSelectedUserListData(String ids,
      {String searchTxt = ''}) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "ids": ids,
        "searchTxt": searchTxt,
        "start": 1,
        "end": 50
      };
      final response = await ApiService.apiPostData(
          Configuration.getSelectedUserList,
          postData: postData,
          token: userData['tToken']);
      return response?['data'];
    } catch (error) {
      // print("Error while getting selected user list data from api....$error");
      return [];
    }
  }

  // ************** set edit profile pic ****************
  static Future<Map<String, dynamic>> setProfileUpdate(
      BuildContext context, vEditProfileFullName, String vEditEmailAddrss,
      {int iColorOption = 0, int isDeleteFile = 0}) async {
    try {
      final groupProvider = context.read<GroupProvider>();

      final userData = await CommonFunctions.getUserData();
      final loginUserData = await CommonFunctions.getLoginUser();

      final Map<String, dynamic> fields = {
        "iColorOption": iColorOption,
        "isDeleteFile": isDeleteFile,
        "vEditProfileFullName": vEditProfileFullName,
        "vEditEmailAddrss": vEditEmailAddrss,
        if (loginUserData['vProfilePic'] != null &&
            groupProvider.chooseImageFile == null)
          "vImage": loginUserData['vProfilePic'],
      };
      // print("groupProvider.chooseImageFileprovider.chooseImageFileprovider.chooseImageFile ${groupProvider.chooseImageFile}");

      if (groupProvider.chooseImageFile != null) {
        final response = await ApiService.apiPostMultipart(
            Configuration.profileUpdate,
            fields: fields,
            file: groupProvider.chooseImageFile,
            fileFieldName: 'vImage',
            token: userData['tToken']);
        return response!;
      } else {
        final response = await ApiService.apiPostData(
            Configuration.profileUpdate,
            postData: fields,
            token: userData['tToken']);
        return response!;
      }
    } catch (error) {
      // print("Error while getting selected user list data from api....$error");
      return {};
    }
  }

  // ************** get group messages ****************
  static Future<Map<String, dynamic>> getGroupMessages(
      String iGroupId, int isAdmin, String firstMessageId) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "iGroupId": iGroupId,
        "filterDateStr": '',
        "isAdmin": isAdmin,
        "first_message_id": firstMessageId,
        "requestFor": "app",
      };
      // print("Post Dataaa $postData");
      // print("userData['tToken'] ${userData['tToken']}");
      final response = await ApiService.apiPostData(Configuration.getGrpMessage,
          postData: postData, token: userData['tToken']);
      // debugPrint("getGroupMessages  ===================> $response", wrapWidth: 1024);
      return response!;
    } catch (error) {
      // print("Error while getting group list from api....$error");
      return {};
    }
  }

  // ************** get user messages ****************
  static getUserMessages(String iUserId, String firstMessageId) async {
    try {
      // print("iUserId chat user id $iUserId");
      final userData = await CommonFunctions.getUserData();
      final response = await ApiService.apiPostData(Configuration.getMessage,
          postData: {
            "iUserId": iUserId,
            "first_message_id": firstMessageId,
            "requestFor": "app"
          },
          token: userData['tToken']);
      return response!;
    } catch (error) {
      // print("Error while getting group list from api....$error");
      return {};
    }
  }

  // ************** delete user chat ****************
  static deleteAllChatUser(String iUserId) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final response = await ApiService.apiPostData(
          Configuration.deleteAllChatUser,
          postData: {"vActiveUserId": iUserId},
          token: userData['tToken']);
      return response;
    } catch (error) {
      // print("Error while deleting user chat from api....$error");
    }
  }

  // ************** cancel chat request ****************
  static cancelUserChatRequest(String iUserId) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final response = await ApiService.apiPostData(
          Configuration.requestCancelSubmit,
          postData: {"vActiveUserId": iUserId},
          token: userData['tToken']);
      ("response cancel chat request $response");
      return response;
    } catch (error) {
      // print("Error while canceling user chat request from api....$error");
    }
  }

  // ************** get group user info ****************
  // static getGroupUserList(String groupId, String searchText, int page) async {
  //   bool _hasMoreData = true;
  //
  //   // Reset _hasMoreData if it's a new search or first page
  //   if (page == 1) {
  //     _hasMoreData = true;
  //   }
  //
  //   if (!_hasMoreData) {
  //     print("No more data to load.");
  //     return;
  //   }
  //   try {
  //     final userData = await CommonFunctions.getUserData();
  //     final postData = {
  //       "group_id": groupId,
  //       "searchTxt": searchText,
  //       "page": page
  //     };
  //
  //     final response = await ApiService.apiPostData(
  //         Configuration.getGroupUserList,
  //         postData: postData,
  //         token: userData['tToken']);
  //     debugPrint("Responseeeeeeeeeeee getGroupUserList ${response}",
  //         wrapWidth: 1024);
  //     return response;
  //   } catch (error) {
  //     print("Error while getting user group info from api....$error");
  //   }
  // }
  static getGroupUserList(String groupId, String searchText, int page) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "group_id": groupId,
        "searchTxt": searchText,
        "page": page
      };

      // print("postData $postData");
      final response = await ApiService.apiPostData(
          Configuration.getGroupUserList,
          postData: postData,
          token: userData['tToken']);
      return response;
    } catch (error) {
      // print("Error while getting user group info from api....$error");
    }
  }

  // ************** get group user info ****************
  static getEditGroupUserList(
      String groupId, String searchText, int page, int loadOther) async {
    bool hasMoreData = true;

    // Reset _hasMoreData if it's a new search or first page
    if (page == 1) {
      hasMoreData = true;
    }

    if (!hasMoreData) {
      // print("No more data to load.");
      return;
    }

    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "group_id": groupId,
        "searchTxt": searchText,
        "page": page,
        "load_other": loadOther,
      };

      final response = await ApiService.apiPostData(
          Configuration.getEditGroupUserList,
          postData: postData,
          token: userData['tToken']);
      // print("response get edit group user info $response");
      return response;
    } catch (error) {
      // print("Error while getting edit group user info from api....$error");
    }
  }

  // ************** delete group all chat ****************
  static deleteGroupAllChat(String activeGroupId, int isMember) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "vActiveGroupId": activeGroupId,
        "isMember": isMember,
      };

      final response = await ApiService.apiPostData(
          Configuration.deleteGroupAllChat,
          postData: postData,
          token: userData['tToken']);
      return response;
    } catch (error) {
      // print("Error while delete all group chat from api....$error");
    }
  }

  // ************** exit group ****************
  static exitGroupChat(String activeGroupId) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "vActiveGroupId": activeGroupId,
      };
      // print("exit post data $postData");

      final response = await ApiService.apiPostData(Configuration.exitGroup,
          postData: postData, token: userData['tToken']);
      return response;
    } catch (error) {
      // print("Error while exit group chat from api....$error");
    }
  }

  // ************** delete group for me ****************
  static deleteGroupForMe(String activeGroupId) async {
    try {
      final userData = await CommonFunctions.getUserData();

      final response = await ApiService.apiPostData(
          Configuration.deleteGroupForMe,
          postData: {"vActiveGroupId": activeGroupId},
          token: userData['tToken']);
      return response;
    } catch (error) {
      // print("Error while exit group chat from api....$error");
    }
  }

  // ************** delete edit group ****************
  static deleteEditGroup(String activeGroupId) async {
    try {
      final userData = await CommonFunctions.getUserData();

      final response = await ApiService.apiPostData(Configuration.deleteGroup,
          postData: {"vActiveGroupId": activeGroupId},
          token: userData['tToken']);
      return response;
    } catch (error) {
      // print("Error while delete edit group from api....$error");
    }
  }

  // ************** delete group member ****************
  static deleteGroupMember(String activeGroupId, String deleteMemberId) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "vActiveGroupId": activeGroupId,
        "DeleteMemberId": deleteMemberId
      };

      final response = await ApiService.apiPostData(Configuration.deleteMember,
          postData: postData, token: userData['tToken']);
      return response;
    } catch (error) {
      // print("Error while delete group member from api....$error");
    }
  }

  // ************** add new group member ****************
  static addNewGroupMember(String activeGroupId, String vNewMemberIds,
      int vSpaceSetting, List? vGrpAdmins) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "vActiveGroupId": activeGroupId,
        "vNewMemberIds": vNewMemberIds,
        "vSpaceSetting": vSpaceSetting,
        "vGrpAdmins": vGrpAdmins,
      };

      final response = await ApiService.apiPostData(
          Configuration.addNewGroupMember,
          postData: postData,
          token: userData['tToken']);
      // print("addNewGroupMemberaddNewGroupMemberaddNewGroupMember: $response");
      // print("postDatapostDatapostData  $postData");
      return response;
    } catch (error) {
      // print("Error while add new group member from api....$error");
    }
  }

  static Future<dynamic> addGroupJoinAcceptRequest(
      {String? iUserId, String? vActiveGroupId}) async {
    try {
      final userData = await CommonFunctions.getUserData();

      final postData = {"iUserId": iUserId, "vActiveGroupId": vActiveGroupId};
      // print("Post dataaaa $postData");
      final response = await ApiService.apiPostData(
        Configuration.grpJoinRequestAccept,
        postData: postData,
        token: userData['tToken'],
      );
      // debugPrint("response?['data'] get group request accept ${response}", wrapWidth: 1024);
      return response?['data'];
    } catch (error) {
      // print("Error while accepting group request ....$error");
      return null;
    }
  }

  static Future<dynamic> addGroupJoinDeclineRequest(
      {String? iUserId, String? vActiveGroupId}) async {
    try {
      final userData = await CommonFunctions.getUserData();

      final response = await ApiService.apiPostData(
        Configuration.grpJoinRequestDecline,
        postData: {"iUserId": iUserId, "vActiveGroupId": vActiveGroupId},
        token: userData['tToken'],
      );
      // debugPrint("response?['data'] get group request decline ${response}", wrapWidth: 1024);
      return response?['data'];
    } catch (error) {
      // print("Error while declining group request ....$error");
      return null;
    }
  }

  // ************** get group info ****************
  static getGroupInfoData(String groupId) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "iGroupId": groupId,
      };
      final response = await ApiService.apiPostData(Configuration.getGrpInfo,
          postData: postData, token: userData['tToken']);
      return response;
    } catch (error) {
      // print("Error while getting user chat list....$error");
    }
  }

  // ************** accept chat request ****************
  static acceptUserChatRequest(String iUserId, String msgId) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final response = await ApiService.apiPostData(
          Configuration.requestAcceptSubmit,
          postData: {"vActiveUserId": iUserId, "msgId": msgId},
          token: userData['tToken']);
      // print("response accept chat request $response");
      return response;
    } catch (error) {
      // print("Error while accepting user chat request from api....$error");
    }
  }

  // ************** decline chat request ****************
  static declineUserChatRequest(String iUserId) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final response = await ApiService.apiPostData(
          Configuration.requestDeclineSubmit,
          postData: {"vActiveUserId": iUserId, "isDelete": 0},
          token: userData['tToken']);
      // print("response decline chat request $response");
      return response;
    } catch (error) {
      // print("Error while declining user chat request from api....$error");
    }
  }

  // ************** delete user message ****************
  static deleteUserMessage(List multipleSelectDel, String vActiveGroupId,
      String vActiveUserId, int isAdmin, String deletedByUserId) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "MultipleSelectDel": multipleSelectDel,
        "vActiveGroupId": vActiveGroupId,
        "vActiveUserId": vActiveUserId,
        "isAdmin": isAdmin,
        "deletedByUserId": deletedByUserId
      };

      final response = await ApiService.apiPostData(Configuration.messageDelete,
          postData: postData, token: userData['tToken']);
      // print("responseeeee $response");
      return response;
    } catch (error) {
      // print("Error while delete user message from api....$error");
    }
  }

  // ************** update user message ****************
  static updateUserMessage(String msg, String vActiveGroupId,
      String vActiveUserId, String id) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final postData = {
        "msg": msg,
        "vActiveGroupId": vActiveGroupId,
        "vActiveUserId": vActiveUserId,
        // "msgId": msgId,
        "id": id
      };
      // print("Post Data: $postData");
      final response = await ApiService.apiPostData(Configuration.messageUpdate,
          postData: postData, token: userData['tToken']);
      // print("Updated Users: $response");
      return response;
    } catch (error) {
      // print("Error while updating user message from api....$error");
    }
  }

  static Future<Map<String, dynamic>?> uploadUserFile(
      {required String filePath,
      required String senderChatID,
      required String receiverChatID,
      required String content,
      required String vReplyMsg,
      required String vReplyMsgId,
      required String vReplyFileName,
      required String id,
      // String fileType = 'file',
      int iRequestMsg = 0,
      int isForwardMsg = 0,
      String isForwardMsgId = '',
      int isDeleteProfile = 0,
      int isFileUpload = 1,
      int chat = 1,
      String attachmentMsg = ""}) async {
    try {
      final userData = await CommonFunctions.getUserData();
      final token = userData['tToken'];

      final fields = {
        "receiverChatID": receiverChatID,
        "senderChatID": senderChatID,
        "content": content,
        "vReplyMsg": vReplyMsg,
        "vReplyMsg_id": vReplyMsgId,
        "vReplyFileName": vReplyFileName,
        "id": id,
        "iRequestMsg": iRequestMsg.toString(),
        "isForwardMsg": isForwardMsg.toString(),
        "isDeleteprofile": isDeleteProfile.toString(),
        "isFileUpload": isFileUpload.toString(),
        "chat": chat.toString(),
        "attachmentMsg": attachmentMsg
        // "isForwardMsg_id": isForwardMsg_id,
        // "fileType": fileType, // <- add this
      };

      // print("fields $fields");
      final XFile uploadFile = XFile(filePath);

      // print('Upload File $uploadFile');
      final response = await ApiService.apiPostMultipart(
          Configuration.uploadFile,
          fields: fields,
          file: uploadFile,
          fileFieldName: "ImageDataArr",
          token: token);

      // print("Upload response: $response");
      return response;
    } catch (e) {
      // print("Upload exception: $e");
      return null;
    }
  }

  static Future<dynamic> getForwardUserList({String? searchQuery}) async {
    try {
      final userData = await CommonFunctions.getUserData();

      final response = await ApiService.apiPostData(
        Configuration.forwardlist,
        postData: {"search": searchQuery},
        token: userData['tToken'],
      );
      // debugPrint("response?['data'] ${response?['data']}", wrapWidth: 1024);
      return response?['data'];
    } catch (error) {
      // print("Error while getting forward user list from api....$error");
      return null;
    }
  }

  // ******************* get all allowed file list
  static Future<dynamic> getAllowedFileList() async {
    try {
      final userData = await CommonFunctions.getUserData();

      final response = await ApiService.apiPostData(
          Configuration.getFileAccessControl,
          token: userData['tToken']);
      // debugPrint("response?['data'] ${response?['data']}", wrapWidth: 1024);
      return response?['data'];
    } catch (error) {
      // print("Error while getting allowed file list from api....$error");
      return null;
    }
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
