import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:spot/services/configuration.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static http.Client createSelfSignedClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  static Future<Map<String, dynamic>?> apiPostData(String url,
      {Map<String, dynamic>? postData, String? token}) async {
    try {
      final client = createSelfSignedClient();
      final apiURL = Configuration.baseURL + url;
      final uri = Uri.parse(apiURL);
      // print("uri $uri");
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final response = await client.post(uri,
          headers: headers,
          body: postData != null ? json.encode(postData) : null);

      // print("Response:------------------- ${response}");
      // debugPrint("response.body ${json.decode(response.body).toString()}", wrapWidth: 1024);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        // print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (error) {
      // print("Error while calling post API: $error");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> apiPostMultipart(String url,
      {required Map<String, dynamic>? fields,
      required XFile? file,
      required String fileFieldName,
      String? token}) async {
    try {
      final client = createSelfSignedClient();
      final apiURL = Configuration.baseURL + url;
      final uri = Uri.parse(apiURL);
      final headers = {
        "Authorization": "Bearer $token",
      };

      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(headers);

      fields?.forEach((key, value) {
        // print("valuevaluevaluevalue ${request.fields[key]} ${key} -------${value}");
        request.fields[key] = value.toString();
      });

      // Add file if present
      if (file != null) {
        // print("fileeeeeeeeeeeeeeeee $file");
        final mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';
        final fileExtension = mimeType.split('/').last;

        var multipartFile = await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
          contentType: MediaType(mimeType.split('/')[0], fileExtension),
        );
        request.files.add(multipartFile);
      }

      // var streamedResponse = await request.send();
      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        // print('Upload successful!');
      } else {
        // print('Upload failed. Status Code: ${response.statusCode}');
      }
      return json.decode(response.body);
    } catch (error) {
      // print("Error while calling multipart API: $error");
      return null;
    }
  }
}
