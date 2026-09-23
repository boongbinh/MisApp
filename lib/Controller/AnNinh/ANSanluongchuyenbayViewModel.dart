// controllers/ansanluongchuyenbay_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class Option {
  final String value, label;
  const Option(this.value, this.label);
}

class ANSanluongchuyenbayViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Selected (đã áp dụng) ======
  final tuNgay = DateTime.now().subtract(const Duration(days: 1)).obs;
  final denNgay = DateTime.now().obs;
  final selectedSanBay = '%'.obs;
  final selectedChiNhanh = '%'.obs;

  // ====== Filter state (tạm trong sheet) ======
  final filterTuNgay = DateTime.now().subtract(const Duration(days: 1)).obs;
  final filterDenNgay = DateTime.now().obs;
  final filterSanBay = '%'.obs;
  final filterChiNhanh = '%'.obs;

  // ====== Dữ liệu ======
  final sanLuongChuyenBay = <Map<String, dynamic>>[].obs;

  // Options
  final sanBayOptions = <Option>[].obs;
  final chiNhanhOptions = <Option>[
    const Option('%', 'Tất cả'),
    const Option('CNKVMB', 'CNKVMB'),
    const Option('CNKVMT', 'CNKVMT'),
    const Option('CNKVMN', 'CNKVMN'),
  ].obs;

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
        "TuNgay": DateFormat('yyyy-MM-dd').format(tuNgay.value),
        "DenNgay": DateFormat('yyyy-MM-dd').format(denNgay.value),
        "SanBay": selectedSanBay.value,
        "Chinhanh": selectedChiNhanh.value,
      };

      final response = await APICaller.getInstance().post(
        "AnNinh/BaocaoAnNinh/Sanluongchuyenbay",
        payload,
      );

      if (response != null && response is String) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        applyData(data);
      } else {
        error.value = 'Không nhận được dữ liệu từ server';
        Utils.showSnackBar(title: 'Lỗi', message: 'Không nhận được dữ liệu từ server');
      }
    } catch (e) {
      error.value = e.toString();
      Utils.showSnackBar(title: 'Lỗi', message: e.toString());
    } finally {
      loading.value = false;
    }
  }

  void applyData(Map<String, dynamic> data) {
    final sanLuong = data['Sanluongchuyenbay'] as List? ?? [];
    sanLuongChuyenBay.assignAll(sanLuong.cast<Map<String, dynamic>>());

    // Cập nhật danh sách sân bay TỪ API này
    final sanBayList = data['sanbay'] as List? ?? [];
    if (sanBayList.isNotEmpty) {
      final List<Option> newOptions = [const Option('%', 'Tất cả')];
      for (var sb in sanBayList) {
        final val = sb.toString();
        newOptions.add(Option(val, val));
      }
      sanBayOptions.assignAll(newOptions);
    } else {
      // Nếu không có sân bay, giữ "Tất cả"
      if (sanBayOptions.isEmpty) {
        sanBayOptions.assignAll([const Option('%', 'Tất cả')]);
      }
    }
  }

  // ====== Filter setters (trong sheet) ======
  void setFilterTuNgay(DateTime d) => filterTuNgay.value = d;
  void setFilterDenNgay(DateTime d) => filterDenNgay.value = d;
  void setFilterSanBay(String v) => filterSanBay.value = v;
  void setFilterChiNhanh(String v) => filterChiNhanh.value = v;

  Future<void> applyFilters() async {
    tuNgay.value = filterTuNgay.value;
    denNgay.value = filterDenNgay.value;
    selectedSanBay.value = filterSanBay.value;
    selectedChiNhanh.value = filterChiNhanh.value;
    await loadData();
  }

  void resetFilters() {
    final now = DateTime.now();
    filterTuNgay.value = now.subtract(const Duration(days: 1));
    filterDenNgay.value = now;
    filterSanBay.value = '%';
    filterChiNhanh.value = '%';
  }

  // ====== Refresh ======
  void refreshData() {
    loadData();
  }

  // ====== Helper ======
  String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  bool get hasData => sanLuongChuyenBay.isNotEmpty;

  // Label hiển thị cho filter
  String getLabelSanBay() {
    if (filterSanBay.value == '%') return 'Tất cả';
    return filterSanBay.value;
  }

  String getLabelChiNhanh() {
    if (filterChiNhanh.value == '%') return 'Tất cả';
    return filterChiNhanh.value;
  }
}