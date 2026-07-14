import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Components/KT/Phantichchiphi/ChiphitranapCard.dart';
import 'package:skypec/Components/KT/Phantichchiphi/ChiphixevantaiCard.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class PhantichchiphiViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu từ API ======
  final dateStart = ''.obs;
  final dateEnd = ''.obs;
  final tongCPKT = 0.0.obs;
  final tongCPGHD = 0.0.obs;
  final tongCPGHDVC = 0.0.obs;
  final tongCPXeTN = 0.0.obs;
  final tongCPXeVC = 0.0.obs;

  final chiPhiTraNapData = <Map<String, dynamic>>[].obs;
  final chiPhiXeVanTaiData = <Map<String, dynamic>>[].obs;
  final bangChiPhiTraNapData = <Map<String, dynamic>>[].obs;
  final bangChiPhiXeVanTaiData = <Map<String, dynamic>>[].obs;
  final bangChiPhiKhoBeData = <Map<String, dynamic>>[].obs;
  final bangChiPhiHangHiemData = <Map<String, dynamic>>[].obs;


  // ====== Getter hiển thị ======
  String get dateRange => '${dateStart.value} - ${dateEnd.value}';

  // ====== Filter State ======
  final RxInt fromMonth = DateTime.now().month.obs;
  final RxInt fromYear = DateTime.now().year.obs;
  final RxInt toMonth = DateTime.now().month.obs;
  final RxInt toYear = DateTime.now().year.obs;

  // Filter tạm cho sheet
  final RxInt filterFromMonth = DateTime.now().month.obs;
  final RxInt filterToMonth = DateTime.now().month.obs;
  final RxInt filterYear = DateTime.now().year.obs;

  // ====== Search ======
  final searchCtrl = TextEditingController();
  final allFilterOptions = <String>[].obs;

  // ====== Getter hiển thị label ======
  String get periodLabel => 'Tháng ${fromMonth.value}/${fromYear.value}';

  // ====== Khởi tạo ======
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
        "KT/Phantichchiphi",
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

  // ====== Parse dữ liệu ======
  void applyData(Map<String, dynamic> data) {
    dateStart.value = data['start']?.toString() ?? '';
    dateEnd.value = data['end']?.toString() ?? '';
    tongCPKT.value = (data['tongcpkt'] as num?)?.toDouble() ?? 0;
    tongCPGHD.value = (data['tongcpghd'] as num?)?.toDouble() ?? 0;
    tongCPGHDVC.value = (data['tongcpghdVC'] as num?)?.toDouble() ?? 0;
    tongCPXeTN.value = (data['tongcpxetn'] as num?)?.toDouble() ?? 0;
    tongCPXeVC.value = (data['tongcpxevc'] as num?)?.toDouble() ?? 0;

   // Chi phí tra nạp chart
    final chiPhiTraNap = data['chiphitranapchart'] as List? ?? [];
    chiPhiTraNapData.assignAll(chiPhiTraNap.cast<Map<String, dynamic>>());
    // Chi phí xe vận tải chart
    final chiPhiXeVanTai = data['chiphixevantaichart'] as List? ?? [];
    chiPhiXeVanTaiData.assignAll(chiPhiXeVanTai.cast<Map<String, dynamic>>());
    // Bảng chi phí tra nạp
    final bangChiPhiTraNap = data['bangchiphitranap'] as List? ?? [];
    bangChiPhiTraNapData.assignAll(bangChiPhiTraNap.cast<Map<String, dynamic>>());
    // Bảng chi phí xe vận tải
    final bangChiPhiXeVanTai = data['bangchiphixevantai'] as List? ?? [];
    bangChiPhiXeVanTaiData.assignAll(bangChiPhiXeVanTai.cast<Map<String, dynamic>>());
    // Bảng chi phí kho bể
    final bangKhoBe = data['bangchiphikhobe'] as List? ?? [];
    bangChiPhiKhoBeData.assignAll(bangKhoBe.cast<Map<String, dynamic>>());
    // Bảng chi phí hàng hiểm
    final bangHangHiem = data['bangchiphihoanghiem'] as List? ?? [];
    bangChiPhiHangHiemData.assignAll(bangHangHiem.cast<Map<String, dynamic>>());
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

  // ====== Filter functions ======
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

  // ====== Helper ======
  String formatNumber(double value) {
    
    return NumberFormat('#,###', 'vi_VN').format(value)+ ' VND';
  }

  String formatCurrency(double value) {
    
    return NumberFormat('#,###', 'vi_VN').format(value) + ' VND';
  }
}