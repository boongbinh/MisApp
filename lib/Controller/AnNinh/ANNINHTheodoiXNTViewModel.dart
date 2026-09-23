// controllers/anninh_theodoi_xnt_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

// ⭐ Class Option (nếu chưa có ở file khác)
class Option {
  final String value;
  final String label;
  const Option(this.value, this.label);
}

class ANNINHTheodoiXNTViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Filter (dùng cho sheet) ======
  final filterNgay = DateTime.now().subtract(const Duration(days: 1)).obs;

  // ====== Filter đã áp dụng (dùng để load data) ======
  final ngay = DateTime.now().subtract(const Duration(days: 1)).obs;

  // ====== Dữ liệu ======
  final theodoiXNTkhoCang = <Map<String, dynamic>>[].obs;

  // ====== Khởi tạo ======
  @override
  void onReady() {
    super.onReady();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    loadData();
  }

  @override
  void onClose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.onClose();
  }

  // ====== Load Data ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "ngay": DateFormat('yyyy-MM-dd').format(ngay.value),
      };

      print('Payload: $payload');

      final response = await APICaller.getInstance().post(
        "AnNinh/BaocaoAnNinh/Xuatnhaptonkhocang",
        payload,
      );

      print('response: $response');

      if (response != null) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        applyData(data);
      } else {
        error.value = 'Không nhận được dữ liệu từ server';
        Utils.showSnackBar(
          title: 'Lỗi',
          message: 'Không nhận được dữ liệu từ server',
        );
      }
    } catch (e) {
      error.value = e.toString();
      Utils.showSnackBar(title: 'Lỗi', message: e.toString());
    } finally {
      loading.value = false;
    }
  }

  void applyData(Map<String, dynamic> data) {
    final keHoach = data['xuatnhapton_KC'] as List? ?? [];
    theodoiXNTkhoCang.assignAll(keHoach.cast<Map<String, dynamic>>());
  }

  // ====== Filter Setters ======
  void setFilterNgay(DateTime date) {
    filterNgay.value = date;
  }

  // ====== Apply Filters ======
  void applyFilters() {
    ngay.value = filterNgay.value;
    loadData();
  }

  // ====== Reset Filters ======
  void resetFilters() {
    filterNgay.value = DateTime.now().subtract(const Duration(days: 1));
  }

  // ====== Refresh ======
  void refreshData() {
    loadData();
  }

  // ====== Helper Methods ======
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // ⭐ Dùng filterNgay cho display
  String get displayDate {
    return formatDate(filterNgay.value);
  }

  bool get hasData => theodoiXNTkhoCang.isNotEmpty;

  int get recordCount => theodoiXNTkhoCang.length;
}