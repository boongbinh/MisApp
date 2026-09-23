// controllers/anninh_theodoi_xnt_sb_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

// ⭐ Class Option giống ANSanluongchuyenbay
class Option {
  final String value;
  final String label;
  const Option(this.value, this.label);
}

class ANNINHTheodoiXNT_SBViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Filter (dùng cho sheet) ======
  final filterNgay = DateTime.now().subtract(const Duration(days: 2)).obs;
  final filterChiNhanh = '%'.obs;

  // ====== Filter đã áp dụng (dùng để load data) ======
  final ngay = DateTime.now().subtract(const Duration(days: 2)).obs;
  final chiNhanh = '%'.obs;

  // ⭐ Options
  final chiNhanhOptions = <Option>[
    const Option('%', 'Tất cả'),
    const Option('CNMB', 'CNMB'),
    const Option('CNMT', 'CNMT'),
    const Option('CNMN', 'CNMN'),
  ].obs;

  // ====== Dữ liệu ======
  final theodoiXNTkhoCang_SB = <Map<String, dynamic>>[].obs;

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
        "chinhanh": chiNhanh.value,
      };


      final response = await APICaller.getInstance().post(
        "AnNinh/BaocaoAnNinh/Xuatnhaptonkhosanbay",
        payload,
      );


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
    final keHoach = data['xuatnhapton_KSB'] as List? ?? [];
    theodoiXNTkhoCang_SB.assignAll(keHoach.cast<Map<String, dynamic>>());
  }

  // ====== Filter Setters (chỉ set giá trị, không load) ======
  void setFilterNgay(DateTime date) {
    filterNgay.value = date;
  }

  void setFilterChiNhanh(String value) {
    filterChiNhanh.value = value;
  }

  // ====== Apply Filters (gán filter → data, rồi load) ======
  void applyFilters() {
    ngay.value = filterNgay.value;
    chiNhanh.value = filterChiNhanh.value;
    loadData();
  }

  // ====== Reset Filters ======
  void resetFilters() {
    final now = DateTime.now().subtract(const Duration(days: 2));
    filterNgay.value = now;
    filterChiNhanh.value = '%';
  }

  // ====== Refresh ======
  void refreshData() {
    loadData();
  }

  // ====== Helper Methods ======
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // ⭐ Dùng filterNgay cho display (giống ANSanluongchuyenbay)
  String get displayDate {
    return formatDate(filterNgay.value);
  }

  bool get hasData => theodoiXNTkhoCang_SB.isNotEmpty;

  int get recordCount => theodoiXNTkhoCang_SB.length;
}