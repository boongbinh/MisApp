import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class CNMBThongtinchungViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu từ API ======
  final chartGioHoatDongData = <Map<String, dynamic>>[].obs;
  final chartGioHoatDongXeVTData = <Map<String, dynamic>>[].obs;
  final chartTonkhoData = <Map<String, dynamic>>[].obs;
  final hsssXeTNData = <Map<String, dynamic>>[].obs;
  final hsssXeVTData = <Map<String, dynamic>>[].obs;
  final hsssKhobeData = <Map<String, dynamic>>[].obs;
  final bangBDSCtranapData = <Map<String, dynamic>>[].obs;
  final bangBDSCvantaiData = <Map<String, dynamic>>[].obs;
  final bangChiphiData = <Map<String, dynamic>>[].obs;

  // ====== Filter State ======
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  final RxInt filterMonth = DateTime.now().month.obs;
  final RxInt filterYear = DateTime.now().year.obs;

  // ====== Search ======
  final searchCtrl = TextEditingController();

  // ====== Getter ======
  String get periodLabel => 'Tháng ${selectedMonth.value}/${selectedYear.value}';

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  // ====== Load Data ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "chonnam": selectedYear.value,
        "chonthang": selectedMonth.value,
      };


      final response = await APICaller.getInstance().post(
        "CNKV/KT/Baocao/Thongtinchung",
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
    // Chart giờ hoạt động xé trần
    final chartData = data['ChartGiohoatdongxetranapCard'] as List? ?? [];
    chartGioHoatDongData.assignAll(chartData.cast<Map<String, dynamic>>());

    // Chart giờ hoạt động xe vận tải
    final chartVTData = data['ChartGiohoatdongxevantaiCard'] as List? ?? [];
    chartGioHoatDongXeVTData.assignAll(chartVTData.cast<Map<String, dynamic>>());

    // Chart tồn kho
    final tonkhoData = data['ChartTonkho'] as List? ?? [];
    chartTonkhoData.assignAll(tonkhoData.cast<Map<String, dynamic>>());

    // HSSS XeTN
    final hsssXeTN = data['HSSSXetn'] as List? ?? [];
    hsssXeTNData.assignAll(hsssXeTN.cast<Map<String, dynamic>>());

    // HSSS XeVT
    final hsssXeVT = data['HSSSXeVT'] as List? ?? [];
    hsssXeVTData.assignAll(hsssXeVT.cast<Map<String, dynamic>>());

    // HSSS Khobe
    final hsssKhobe = data['HSSSKhobe'] as List? ?? [];
    hsssKhobeData.assignAll(hsssKhobe.cast<Map<String, dynamic>>());

    // Bang BĐSC trần
    final bangBDSC = data['Bang_BDSC_tranap'] as List? ?? [];
    bangBDSCtranapData.assignAll(bangBDSC.cast<Map<String, dynamic>>());

    // Bang BĐSC vận tải
    final bangBDSCVT = data['Bang_BDSC_vantai'] as List? ?? [];
    bangBDSCvantaiData.assignAll(bangBDSCVT.cast<Map<String, dynamic>>());

    // Bang chi phí
    final bangChiphi = data['Bangchiphi'] as List? ?? [];
    bangChiphiData.assignAll(bangChiphi.cast<Map<String, dynamic>>());
  }

  void setFilterYear(int y) => filterYear.value = y;
  void setFilterMonth(int m) => filterMonth.value = m;

  Future<void> applyFilters() async {
    selectedMonth.value = filterMonth.value;
    selectedYear.value = filterYear.value;
    await loadData();
  }

  void resetFilters() {
    final now = DateTime.now();
    filterMonth.value = now.month;
    filterYear.value = now.year;
  }
}