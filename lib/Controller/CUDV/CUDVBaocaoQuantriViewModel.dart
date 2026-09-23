// controllers/cudv_baocao_quantri_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';
import 'package:flutter/services.dart';

class CUDVBaocaoQuantriViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu ======
  final selectedMonth = DateTime.now().month.obs - 1;
  final selectedYear = DateTime.now().year.obs; // Mặc định năm hiện tại

  // Dữ liệu từ API
  final keHoachNhapHang = <Map<String, dynamic>>[].obs;

  @override
  void onReady() {
    super.onReady();

    loadData();
  }

  @override
  void onClose() {


    super.onClose();
  }

  // ====== Load Data ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "Thang": selectedMonth.value.toString(),
        "Nam": selectedYear.value.toString(),
      };
      final response = await APICaller.getInstance().post(
        "CUDV/BaocaoCUDV/KehoachnhaphangBcqt",
        payload,
      );
      if (response != null) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        applyData(data);
      }
    } catch (e) {
      error.value = e.toString();
      Utils.showSnackBar(title: 'Lỗi', message: e.toString());
    } finally {
      loading.value = false;
    }
  }

  void applyData(Map<String, dynamic> data) {
    // Lấy dữ liệu kế hoạch nhập hàng
    final keHoach = data['KehoachnhaphangBcqt'] as List? ?? [];
    keHoachNhapHang.assignAll(keHoach.cast<Map<String, dynamic>>());
  }

  // ====== Change Month ======
  void changeMonth(int month) {
    if (month < 1 || month > 12) return;
    selectedMonth.value = month;
    loadData();
  }

  // ====== Change Year ======
  void changeYear(int year) {
    selectedYear.value = year;
    loadData();
  }

  void goToPreviousMonth() {
    int newMonth = selectedMonth.value - 1;
    if (newMonth < 1) newMonth = 12;
    changeMonth(newMonth);
  }

  void goToNextMonth() {
    int newMonth = selectedMonth.value + 1;
    if (newMonth > 12) newMonth = 1;
    changeMonth(newMonth);
  }

  void goToCurrentMonth() {
    changeMonth(DateTime.now().month);
  }

  // ====== Helper Methods ======

  // Lấy danh sách tháng để hiển thị
  List<String> getMonthOptions() {
    return List.generate(12, (index) {
      final month = index + 1;
      return 'Tháng $month';
    });
  }

  // Tính tổng theo từng cột
  Map<String, double> getTotals() {
    final totals = <String, double>{};

    for (var item in keHoachNhapHang) {
      totals['HLI'] =
          (totals['HLI'] ?? 0) + ((item['HLI'] as num?)?.toDouble() ?? 0);
      totals['DVU'] =
          (totals['DVU'] ?? 0) + ((item['DVU'] as num?)?.toDouble() ?? 0);
      totals['TLY'] =
          (totals['TLY'] ?? 0) + ((item['TLY'] as num?)?.toDouble() ?? 0);
      totals['LCH'] =
          (totals['LCH'] ?? 0) + ((item['LCH'] as num?)?.toDouble() ?? 0);
      totals['HMO'] =
          (totals['HMO'] ?? 0) + ((item['HMO'] as num?)?.toDouble() ?? 0);
      totals['CLA'] =
          (totals['CLA'] ?? 0) + ((item['CLA'] as num?)?.toDouble() ?? 0);
      totals['TLE'] =
          (totals['TLE'] ?? 0) + ((item['TLE'] as num?)?.toDouble() ?? 0);
      totals['QCH'] =
          (totals['QCH'] ?? 0) + ((item['QCH'] as num?)?.toDouble() ?? 0);
    }

    return totals;
  }

  // Lấy danh sách ghi chú không null
  List<String> getNotes() {
    final notes = <String>[];

    for (var item in keHoachNhapHang) {
      if (item['Ghichu_MB'] != null &&
          item['Ghichu_MB'].toString().isNotEmpty) {
        notes.add(item['Ghichu_MB'].toString());
      }
      if (item['Ghichu_DN'] != null &&
          item['Ghichu_DN'].toString().isNotEmpty) {
        notes.add(item['Ghichu_DN'].toString());
      }
      if (item['Ghichu_CR'] != null &&
          item['Ghichu_CR'].toString().isNotEmpty) {
        notes.add(item['Ghichu_CR'].toString());
      }
      if (item['Ghichu_MN'] != null &&
          item['Ghichu_MN'].toString().isNotEmpty) {
        notes.add(item['Ghichu_MN'].toString());
      }
    }

    return notes;
  }

  // Format số
  String formatNumber(dynamic value) {
    if (value == null) return '';
    try {
      final num = double.tryParse(value.toString());
      if (num == null) return value.toString();
      if (num == 0) return '';
      final formatter = NumberFormat('#,###');
      return formatter.format(num);
    } catch (e) {
      return value.toString();
    }
  }

  // Lấy danh sách các ngày (đã parse)
  List<String> getDateList() {
    return keHoachNhapHang
        .map((e) => e['NgayNhap']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Kiểm tra có dữ liệu không
  bool get hasData => keHoachNhapHang.isNotEmpty;

  // Lấy số lượng bản ghi
  int get recordCount => keHoachNhapHang.length;
}
