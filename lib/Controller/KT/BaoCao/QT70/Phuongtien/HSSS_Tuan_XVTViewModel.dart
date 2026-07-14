import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

extension DateTimeWeekExtension on DateTime {
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final dayOfYear = difference(firstDayOfYear).inDays + 1;
    return ((dayOfYear + firstDayOfYear.weekday - 1) / 7).ceil();
  }
}

class HSSS_Tuan_XVTViewModel extends GetxController {
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
  final RxInt selectedWeek = DateTime.now().weekOfYear.obs;

  // Filter tạm cho sheet
  final RxInt filterYear = DateTime.now().year.obs;
  final RxInt filterWeek = DateTime.now().weekOfYear.obs;

  // ====== Getter ======
  String get periodLabel => 'Tuần ${selectedWeek.value}/${selectedYear.value}';

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
        "tuan": selectedWeek.value,
      };


      final response = await APICaller.getInstance().post(
        "KT/KTBaocao/HSSS_Tuan_XVT",
        payload,
      );

      if (response != null) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        final res1 = data['res1'] as List? ?? [];
        allData.assignAll(res1.cast<Map<String, dynamic>>());
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

  void setFilterWeek(int week) {
    filterWeek.value = week;
  }

  Future<void> applyFilters() async {
    selectedYear.value = filterYear.value;
    selectedWeek.value = filterWeek.value;
    await loadData();
  }

  void resetFilters() {
    final now = DateTime.now();
    filterYear.value = now.year;
    filterWeek.value = now.weekOfYear;
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
    double tongGioTuan = 0;
    double tongGioNamXuong = 0;
    double tongGioXeTot = 0;
    double tongHSSS = 0;

    for (var item in filteredData) {
      tongXe += (item['Soluongxe'] as num?)?.toDouble() ?? 0;
      tongGioTuan += (item['Giotuan'] as num?)?.toDouble() ?? 0;
      tongGioNamXuong += (item['Gionamxuong'] as num?)?.toDouble() ?? 0;
      tongGioXeTot += (item['Gioxetot'] as num?)?.toDouble() ?? 0;
      tongHSSS += (item['HSSS'] as num?)?.toDouble() ?? 0;
    }

    return {
      'Soluongxe': tongXe,
      'Giotuan': tongGioTuan,
      'Gionamxuong': tongGioNamXuong,
      'Gioxetot': tongGioXeTot,
      'HSSS': filteredData.isNotEmpty ? tongHSSS / filteredData.length : 0,
    };
  }

  // ====== Years options ======
  List<int> getYearOptions() {
    return List.generate(6, (i) => 2023 + i);
  }

  // ====== Weeks options ======
  List<int> getWeekOptions() {
    return List.generate(53, (i) => i + 1);
  }
}