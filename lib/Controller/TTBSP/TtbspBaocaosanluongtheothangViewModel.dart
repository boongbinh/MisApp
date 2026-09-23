// controllers/ttbsp_baocaosanluongtheothang_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class TtbspBaocaosanluongtheothangViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Filter (temp - dùng cho sheet) ======
  final filterTuThang = 1.obs;
  final filterTuNam = DateTime.now().year.obs;
  final filterDenThang = DateTime.now().month.obs;
  final filterDenNam = DateTime.now().year.obs;

  // ====== Filter đã áp dụng (dùng để load data) ======
  final tuThang = 1.obs;
  final tuNam = DateTime.now().year.obs;
  final denThang = DateTime.now().month.obs;
  final denNam = DateTime.now().year.obs;

  // ====== Dữ liệu ======
  final sanLuongTheoThang = <Map<String, dynamic>>[].obs;

  // ====== Khởi tạo ======
  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  // ====== Load Data ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "TuThang": tuThang.value,
        "TuNam": tuNam.value,
        "DenThang": denThang.value,
        "DenNam": denNam.value,
      };

      print('Payload: $payload');

      final response = await APICaller.getInstance().post(
        "TTBSP/BaoCaoSanLuong/baocaosanluong_thang",
        payload,
      );

      print('response: $response');

      if (response != null && response is String) {
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
    final sanLuong = data['sanluongtheothang'] as List? ?? [];
    sanLuongTheoThang.assignAll(sanLuong.cast<Map<String, dynamic>>());
  }

  // ====== Filter Setters (chỉ set giá trị, không load) ======
  void setFilterTuThang(int value) {
    if (value < 1 || value > 12) return;
    filterTuThang.value = value;
  }

  void setFilterTuNam(int value) {
    filterTuNam.value = value;
  }

  void setFilterDenThang(int value) {
    if (value < 1 || value > 12) return;
    filterDenThang.value = value;
  }

  void setFilterDenNam(int value) {
    filterDenNam.value = value;
  }

  // ====== Apply Filters ======
  void applyFilters() {
    tuThang.value = filterTuThang.value;
    tuNam.value = filterTuNam.value;
    denThang.value = filterDenThang.value;
    denNam.value = filterDenNam.value;
    loadData();
  }

  // ====== Reset Filters ======
  void resetFilters() {
    filterTuThang.value = 1;
    filterTuNam.value = DateTime.now().year;
    filterDenThang.value = DateTime.now().month;
    filterDenNam.value = DateTime.now().year;
  }

  // ====== Refresh ======
  void refreshData() {
    loadData();
  }

  // ====== Helper Methods ======
  String get displayDateRange {
    return 'T${filterTuThang.value}/${filterTuNam.value} - T${filterDenThang.value}/${filterDenNam.value}';
  }

  bool get hasData => sanLuongTheoThang.isNotEmpty;

  List<int> get monthOptions => List.generate(12, (i) => i + 1);

  List<int> get yearOptions {
    final nowY = DateTime.now().year;
    return List.generate(10, (i) => nowY - 5 + i);
  }
}