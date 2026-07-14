import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class HSSS_Thang_XVTViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu ======
  final allData = <Map<String, dynamic>>[].obs;
  final filteredData = <Map<String, dynamic>>[].obs;

  // ====== Search ======
  final searchCtrl = TextEditingController();
  final searchKeyword = ''.obs;

  // ====== Filter ======
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;

  // Filter tạm cho sheet
  final RxInt filterYear = DateTime.now().year.obs;
  final RxInt filterMonth = DateTime.now().month.obs;

  // ====== Getter ======
  String get periodLabel => 'Tháng ${selectedMonth.value}/${selectedYear.value}';

  // ====== Khởi tạo ======
  @override
  void onInit() {
    super.onInit();
    searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  @override
  void onClose() {
    searchCtrl.removeListener(_onSearchChanged);
    searchCtrl.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchKeyword.value = searchCtrl.text.trim().toLowerCase();
    _applySearchAndFilter();
  }

  // ====== Load Data ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "nam": selectedYear.value,
        "thang": selectedMonth.value,
      };

      print('===== LOAD HSSS_Thang_XVT DATA =====');
      print('Payload: $payload');
      print('====================================');

      final response = await APICaller.getInstance().post(
        "KT/KTBaocao/HSSS_Thang_XVT",
        payload,
      );

      if (response != null) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        final res1 = data['res1'] as List? ?? [];
        allData.assignAll(res1.cast<Map<String, dynamic>>());
        print('Data loaded: ${allData.length} records');
        _applySearchAndFilter();
      }
    } catch (e) {
      error.value = e.toString();
      Utils.showSnackBar(title: 'Lỗi', message: e.toString());
    } finally {
      loading.value = false;
    }
  }

  void _applySearchAndFilter() {
    final keyword = searchKeyword.value.toLowerCase();
    List<Map<String, dynamic>> filtered;

    if (keyword.isEmpty) {
      filtered = allData.toList();
    } else {
      filtered = allData.where((item) {
        final searchText = item.values
            .where((v) => v != null)
            .map((v) => v.toString().toLowerCase())
            .join(' ');
        return searchText.contains(keyword);
      }).toList();
    }

    filteredData.assignAll(filtered);
  }

  // ====== Filter functions ======
  void setFilterYear(int year) {
    filterYear.value = year;
  }

  void setFilterMonth(int month) {
    filterMonth.value = month;
  }

  Future<void> applyFilters() async {
    selectedYear.value = filterYear.value;
    selectedMonth.value = filterMonth.value;
    await loadData();
  }

  void resetFilters() {
    final now = DateTime.now();
    filterYear.value = now.year;
    filterMonth.value = now.month;
  }

  // ====== Helper Format Number ======
  String formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is num) {
      if (value == value.toInt()) {
        return NumberFormat('#,##0', 'vi_VN').format(value.toInt());
      }
      return NumberFormat('#,##0.00', 'vi_VN').format(value);
    }
    return value.toString();
  }

  // Format HSSS với 2 số thập phân
  String formatHSSS(dynamic value) {
    if (value == null) return '0';
    if (value is num) {
      return NumberFormat('#,##0.00', 'vi_VN').format(value);
    }
    return value.toString();
  }

  // ====== Calculate totals ======
  Map<String, double> calculateTotals() {
    double tongXe = 0;
    double tongGioThang = 0;
    double tongGioNamXuong = 0;
    double tongGioXeTot = 0;
    double tongHSSS = 0;

    for (var item in filteredData) {
      tongXe += (item['Soluongxe'] as num?)?.toDouble() ?? 0;
      tongGioThang += (item['Giothang'] as num?)?.toDouble() ?? 0;
      tongGioNamXuong += (item['Gionamxuong'] as num?)?.toDouble() ?? 0;
      tongGioXeTot += (item['Gioxetot'] as num?)?.toDouble() ?? 0;
      tongHSSS += (item['HSSS'] as num?)?.toDouble() ?? 0;
    }

    return {
      'Soluongxe': tongXe,
      'Giothang': tongGioThang,
      'Gionamxuong': tongGioNamXuong,
      'Gioxetot': tongGioXeTot,
      'HSSS': filteredData.isNotEmpty ? tongHSSS / filteredData.length : 0,
    };
  }

  // ====== Years options ======
  List<int> getYearOptions() {
    return List.generate(6, (i) => 2023 + i);
  }

  // ====== Months options ======
  List<int> getMonthOptions() {
    return List.generate(12, (i) => i + 1);
  }
}