import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Components/KT/Phantichchiphi/ChiphitranapCard.dart';
import 'package:skypec/Components/KT/Phantichchiphi/ChiphixevantaiCard.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class CNMTPhantichchiphiViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu từ API ======
  final dateStart = ''.obs;
  final dateEnd = ''.obs;
  final tongCPKT = 0.0.obs;
  final tongCPGHD = 0.0.obs;
  final tongCPGHDVC = 0.0.obs;

  final chiPhiTraNapData = <Map<String, dynamic>>[].obs;
  final chiPhiXeVanTaiData = <Map<String, dynamic>>[].obs;
  final bangChiPhiTraNapData = <Map<String, dynamic>>[].obs;
  final bangChiPhiXeVanTaiData = <Map<String, dynamic>>[].obs;
  final bangChiPhiKhoBeData = <Map<String, dynamic>>[].obs;
  final bangChiPhiHangHiemData = <Map<String, dynamic>>[].obs;

  // ====== Getter ======
  String get dateRange => '${dateStart.value} - ${dateEnd.value}';

  // ====== Filter State ======
  final RxInt fromMonth = DateTime.now().month.obs;
  final RxInt fromYear = DateTime.now().year.obs;
  final RxInt toMonth = DateTime.now().month.obs;
  final RxInt toYear = DateTime.now().year.obs;

  final RxInt filterFromMonth = DateTime.now().month.obs;
  final RxInt filterToMonth = DateTime.now().month.obs;
  final RxInt filterYear = DateTime.now().year.obs;

  // ====== Search ======
  final searchCtrl = TextEditingController();
  final allFilterOptions = <String>[].obs;

  // ====== Getter ======
  String get periodLabel => 'Tháng ${fromMonth.value}/${fromYear.value}';

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

  // ====== Gọi API ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "nam": toYear.value.toString(),
        "tuthang": fromMonth.value.toString(),
        "denthang": toMonth.value.toString(),
      };

      final response = await APICaller.getInstance().post(
        "CNKV/KT/Baocao/Phantichchiphi",
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
    dateStart.value = data['start']?.toString() ?? '';
    dateEnd.value = data['end']?.toString() ?? '';
    tongCPKT.value = _parseDouble(data['tongcpkt']);
    tongCPGHD.value = _parseDouble(data['tongcpghd']);
    tongCPGHDVC.value = _parseDouble(data['tongcpghdVC']);

    final chiPhiTraNap = data['chiphitranapchart'] as List? ?? [];
    chiPhiTraNapData.assignAll(chiPhiTraNap.cast<Map<String, dynamic>>());

    final chiPhiXeVanTai = data['chiphixevantaichart'] as List? ?? [];
    chiPhiXeVanTaiData.assignAll(chiPhiXeVanTai.cast<Map<String, dynamic>>());

    final bangChiPhiTraNap = data['bangchiphitranap'] as List? ?? [];
    bangChiPhiTraNapData.assignAll(bangChiPhiTraNap.cast<Map<String, dynamic>>());

    final bangChiPhiXeVanTai = data['bangchiphixevantai'] as List? ?? [];
    bangChiPhiXeVanTaiData.assignAll(bangChiPhiXeVanTai.cast<Map<String, dynamic>>());

    final bangKhoBe = data['bangchiphikhobe'] as List? ?? [];
    bangChiPhiKhoBeData.assignAll(bangKhoBe.cast<Map<String, dynamic>>());

    final bangHangHiem = data['bangchiphihoanghiem'] as List? ?? [];
    bangChiPhiHangHiemData.assignAll(bangHangHiem.cast<Map<String, dynamic>>());
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '');
      if (cleaned.toLowerCase() == 'nan') return 0.0;
      final parsed = double.tryParse(cleaned);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  List<ChiphitranapData> getChiphiTraNapData() {
    final List<Color> colorPalette = [
      Colors.blue.shade700,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
    ];

    final List<ChiphitranapData> result = [];
    for (int i = 0; i < chiPhiTraNapData.length; i++) {
      final item = chiPhiTraNapData[i];
      final label = item['CHINHANH']?.toString() ?? 'Khác';
      final value = (item['TongTongchiphi'] as num?)?.toDouble() ?? 0;
      if (value > 0) {
        result.add(ChiphitranapData(
          label: label,
          value: value,
          color: colorPalette[i % colorPalette.length],
        ));
      }
    }
    return result;
  }

  List<ChiphixevantaiData> getChiphiXeVanTaiData() {
    final List<Color> colorPalette = [
      Colors.blue.shade700,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
    ];

    final List<ChiphixevantaiData> result = [];
    for (int i = 0; i < chiPhiXeVanTaiData.length; i++) {
      final item = chiPhiXeVanTaiData[i];
      final label = item['CHINHANH']?.toString() ?? 'Khác';
      final value = (item['TongTongchiphi'] as num?)?.toDouble() ?? 0;
      if (value > 0) {
        result.add(ChiphixevantaiData(
          label: label,
          value: value,
          color: colorPalette[i % colorPalette.length],
        ));
      }
    }
    return result;
  }

  void setFilterYear(int y) => filterYear.value = y;
  void setFromMonth(int m) {
    filterFromMonth.value = m;
    if (filterToMonth.value < m) filterToMonth.value = m;
  }
  void setToMonth(int m) {
    filterToMonth.value = m;
    if (filterFromMonth.value > m) filterFromMonth.value = m;
  }

  Future<void> applyFilters() async {
    fromMonth.value = filterFromMonth.value;
    toMonth.value = filterToMonth.value;
    toYear.value = filterYear.value;
    await loadData();
  }

  void resetFilters() {
    final now = DateTime.now();
    filterFromMonth.value = now.month;
    filterToMonth.value = now.month;
    filterYear.value = now.year;
  }

  String formatNumber(double value) {
    if (value.isNaN || value.isInfinite || value == 0) {
      return '0 VND';
    }
    return NumberFormat('#,###', 'vi_VN').format(value) + ' VND';
  }

  String formatCurrency(double value) {
    if (value.isNaN || value.isInfinite || value == 0) {
      return '0 VND';
    }
    return NumberFormat('#,###', 'vi_VN').format(value) + ' VND';
  }
}