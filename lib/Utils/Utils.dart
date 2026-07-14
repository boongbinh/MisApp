import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skypec/Global/GlobalValue.dart';
import '../Global/Constant.dart';

class Utils {
  static bool isFirstApp = true;
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static Future saveStringWithKey(String key, String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(key, value);
  }

  static Future saveIntWithKey(String key, int value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt(key, value);
  }

  static Future getStringValueWithKey(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key) ?? '';
  }

  static Future getIntValueWithKey(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getInt(key) ?? 0;
  }

  static Future getBoolValueWithKey(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(key) ?? false;
  }

  static Future saveBoolWithKey(String key, bool value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(key, value);
  }

  static String formatCurrency(double value) {
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    String price = value.toString().replaceAll(regex, '');
    String priceInText = "";
    int counter = 0;
    for (int i = (price.length - 1); i >= 0; i--) {
      counter++;
      String str = price[i];
      if ((counter % 3) != 0 && i != 0) {
        priceInText = "$str$priceInText";
      } else if (i == 0) {
        priceInText = "$str$priceInText";
      } else {
        priceInText = ",$str$priceInText";
      }
    }
    return priceInText.trim() + 'đ';
  }

  static String convertMetToKm(double met) {
    return (met / 1000).toStringAsFixed(2);
  }

  static String formatViewCount(int viewCount) {
    if (viewCount < 1000) {
      // Trường hợp nhỏ hơn 1000, không cần chuyển đổi, trả về số lượt xem như cũ.
      return viewCount.toStringAsFixed(0);
    } else if (viewCount < 1000000) {
      // Nếu lượt xem từ 1000 đến 999999, quy đổi thành đơn vị "K" (ngàn).
      double count = viewCount / 1000.0;
      return '${count.toStringAsFixed(1)}K';
    } else {
      // Nếu lượt xem từ 1 triệu trở lên, quy đổi thành đơn vị "M" (triệu).
      double count = viewCount / 1000000.0;
      return '${count.toStringAsFixed(1)}M';
    }
  }

  static void showSnackBar({
    required String title,
    required String message,
    Color? colorText = Colors.white,
    Widget? icon,
    bool isDismissible = true,
    Duration duration = const Duration(seconds: 2),
    Duration animationDuration = const Duration(seconds: 1),
    Color? backgroundColor = Colors.black,
    SnackPosition? direction = SnackPosition.TOP,
    Curve? animation,
  }) {
    Get.snackbar(
      title,
      message,
      colorText: colorText,
      duration: duration,
      animationDuration: animationDuration,
      icon: icon,
      backgroundColor: backgroundColor!.withOpacity(0.3),
      snackPosition: direction,
      forwardAnimationCurve: animation,
    );
  }

  static void showDialog({
    String title = '',
    TextStyle? titleStyle,
    Widget? content,
    String? textCancel,
    String? textConfirm,
    Color? backgroundColor,
    Color? cancelTextColor,
    Color? confirmTextColor,
    Color? buttonColor,
    Widget? customCancel,
    Widget? customConfirm,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
    double radius = 10.0,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: titleStyle,
      content: content,
      textCancel: textCancel,
      textConfirm: textConfirm,
      backgroundColor: backgroundColor,
      cancel: customCancel,
      confirm: customConfirm,
      onCancel: onCancel,
      onConfirm: onConfirm,
      cancelTextColor: cancelTextColor,
      confirmTextColor: confirmTextColor,
      buttonColor: buttonColor,
      radius: radius,
    );
  }

  // static Future<List<File>> getImagePicker(int source, bool multiImage) async {
  //   ImagePicker _picker = ImagePicker();
  //   List<File> files = List.empty(growable: true);
  //   try {
  //     if (multiImage) {
  //       List<XFile> lst = await _picker.pickMultiImage();
  //       for (var file in lst) {
  //         files.add(File(file.path));
  //       }
  //     } else {
  //       await _picker
  //           .pickImage(
  //             source: source == 1 ? ImageSource.camera : ImageSource.gallery,
  //           )
  //           .then((value) {
  //             if (value != null) {
  //               files.add(File(value.path));
  //             }
  //           });
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   return files;
  // }

  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static backLogin(bool isRun) {
    if (!isRun) {
      return;
    }

    Utils.saveStringWithKey(Constant.USERNAME, '');
    Utils.saveStringWithKey(Constant.PASSWORD, '');
    GlobalValue.getInstance().setToken('');
    GlobalValue.getInstance().setUuid(0);
  }
}
