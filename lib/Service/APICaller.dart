import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../Global/GlobalValue.dart';
import '../Utils/Utils.dart';

class APICaller {
  static APICaller _apiCaller = APICaller();
  final String BASE_URL = "http://203.128.244.70:1008/api/";
  final String BASE_URL_MEDIA = "http://203.128.244.70:1008/api/";

  static APICaller getInstance() {
    if (_apiCaller == null) {
      _apiCaller = APICaller();
    }
    return _apiCaller;
  }

  Future<dynamic> get(String endpoint, {dynamic body}) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': GlobalValue.getInstance().getToken(),
    };
    Uri uri = Uri.parse(BASE_URL + endpoint);
    final finalUri = uri.replace(queryParameters: body);

    final response = await http
        .get(finalUri, headers: requestHeaders)
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            return http.Response(
              'Không kết nối được đến máy chủ, bạn vui lòng kiểm tra lại 1.',
              408,
            );
          },
        );
    Utils.backLogin(response.statusCode == 401);
    if (response.statusCode != 200) {
      //Utils.showSnackBar(title: 'Thông báo', message: response.body);
      return null;
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> post(String endpoint, dynamic body) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': GlobalValue.getInstance().getToken(),
    };
    final uri = Uri.parse(BASE_URL + endpoint);

    final response = await http
        .post(uri, headers: requestHeaders, body: jsonEncode(body))
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            return http.Response(
              "timeout.",
              408,
            );
          },
        );
    Utils.backLogin(response.statusCode == 401);
    if (response.statusCode != 200) {
      Utils.showSnackBar(title: 'Thông báo', message: response.body);
      return null;
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> postWithUrl(String domain, dynamic body) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': GlobalValue.getInstance().getToken(),
    };
    final uri = Uri.parse(domain);

    final response = await http
        .post(uri, headers: requestHeaders, body: jsonEncode(body))
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            return http.Response(
              "Không kết nối được đến máy chủ, bạn vui lòng kiểm tra lại 3.",
              408,
            );
          },
        );

    if (response.statusCode != 200) {
      Utils.showSnackBar(title: 'Thông báo', message: response.body);
      return null;
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> postFile(String endpoint, File filePath) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'multipart/form-data',
      'Authorization': GlobalValue.getInstance().getToken(),
    };
    final uri = Uri.parse(BASE_URL_MEDIA + endpoint);

    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', filePath.path));
    request.headers.addAll(requestHeaders);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        return http.Response(
          "Không kết nối được đến máy chủ, bạn vui lòng kiểm tra lại 4.",
          408,
        );
      },
    );
    Utils.backLogin(response.statusCode == 401);
    if (response.statusCode != 200) {
      Utils.showSnackBar(title: 'Thông báo', message: response.body);
      return null;
    }
    if (jsonDecode(response.body)['code'] != 0) {
      Utils.showSnackBar(
        title: 'Thông báo',
        message: jsonDecode(response.body)['message'],
      );
      return null;
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> postFiles(String endpoint, List<File> filePath) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'multipart/form-data',
      'Authorization': GlobalValue.getInstance().getToken(),
    };
    final uri = Uri.parse(BASE_URL_MEDIA + endpoint);

    final request = http.MultipartRequest('POST', uri);
    List<http.MultipartFile> files = [];
    for (File file in filePath) {
      var f = await http.MultipartFile.fromPath('files', file.path);
      files.add(f);
    }
    request.files.addAll(files);
    request.headers.addAll(requestHeaders);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        return http.Response(
          "Không kết nối được đến máy chủ, bạn vui lòng kiểm tra lại 5.",
          408,
        );
      },
    );
    Utils.backLogin(response.statusCode == 401);
    if (response.statusCode != 200) {
      Utils.showSnackBar(title: 'Thông báo', message: response.body);
      return null;
    }
    if (jsonDecode(response.body)['code'] != 0) {
      Utils.showSnackBar(
        title: 'Thông báo',
        message: jsonDecode(response.body)['message'],
      );
      return null;
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> put(String endpoint, dynamic body) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': GlobalValue.getInstance().getToken(),
      'token': GlobalValue.getInstance().getToken().substring(
        GlobalValue.getInstance().getToken().indexOf(' ') + 1,
      ),
    };
    final uri = Uri.parse(BASE_URL + endpoint);

    final response = await http
        .put(uri, headers: requestHeaders, body: jsonEncode(body))
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            return http.Response(
              "Không kết nối được đến máy chủ, bạn vui lòng kiểm tra lại .",
              408,
            );
          },
        );
    Utils.backLogin(response.statusCode == 401);
    if (response.statusCode != 200) {
      Utils.showSnackBar(title: 'Thông báo', message: response.body);
      return null;
    }
    if (jsonDecode(response.body)['code'] != 0) {
      Utils.showSnackBar(
        title: 'Thông báo',
        message: jsonDecode(response.body)['message'],
      );
      return null;
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> delete(String endpoint, {dynamic body}) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': GlobalValue.getInstance().getToken(),
    };
    final uri = Uri.parse(BASE_URL + endpoint);

    final response = await http
        .delete(uri, headers: requestHeaders, body: jsonEncode(body))
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            return http.Response(
              "Không kết nối được đến máy chủ, bạn vui lòng kiểm tra lại.",
              408,
            );
          },
        );
    Utils.backLogin(response.statusCode == 401);
    if (response.statusCode != 200) {
      Utils.showSnackBar(title: 'Thông báo', message: response.body);
      return null;
    }
    if (jsonDecode(response.body)['code'] != 0) {
      Utils.showSnackBar(
        title: 'Thông báo',
        message: jsonDecode(response.body)['message'],
      );
      return null;
    }
    return jsonDecode(response.body);
  }
}
