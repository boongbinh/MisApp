import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class ThongtinchungViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Filter State ======
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  // Filter tạm cho sheet
  final RxInt filterMonth = DateTime.now().month.obs;
  final RxInt filterYear = DateTime.now().year.obs;

  // ====== Dữ liệu từ API ======
  // Dữ liệu cho biểu đồ cột nhóm
  final chartGioHoatDongData = <Map<String, dynamic>>[].obs;
  final chartGioHoatDongXeVTData = <Map<String, dynamic>>[].obs;
  final chartTonkhoData = <Map<String, dynamic>>[].obs;

  final hsssXeTNData = <Map<String, dynamic>>[].obs;
  final hsssXeVTData = <Map<String, dynamic>>[].obs;
  final hsssKhobeData = <Map<String, dynamic>>[].obs;
  final hsssCNTTData = <Map<String, dynamic>>[].obs;

  final bangChiphiData = <Map<String, dynamic>>[].obs;
  final bangBDSCtranapData = <Map<String, dynamic>>[].obs;
  final bangBDSCvantaiData = <Map<String, dynamic>>[].obs;



  // Dữ liệu cho bảng tổng hợp
  final bangBDSCData = <Map<String, dynamic>>[].obs;

  // ====== Getter ======
  String get periodLabel => 'Tháng ${selectedMonth.value}/${selectedYear.value}';

  // ====== Khởi tạo ======
  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  // ====== Gọi API ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "chonnam": selectedYear.value,
        "chonthang": selectedMonth.value,
      };

      final response = await APICaller.getInstance().post(
        "KT/Thongtinquantri/Thongtinchung",
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
    // 1. Biểu đồ giờ hoạt động xe tra nạp  
    final chartData = data['ChartGiohoatdongxetranapCard'] as List? ?? [];
    chartGioHoatDongData.assignAll(chartData.cast<Map<String, dynamic>>());

  // 2. Biểu đồ tồn kho 
    final tonkhoData = data['ChartTonkho'] as List? ?? [];
    chartTonkhoData.assignAll(tonkhoData.cast<Map<String, dynamic>>());
  // 3. HSSS XeTN
    final hsssXeTN = data['HSSSXetn'] as List? ?? [];
    hsssXeTNData.assignAll(hsssXeTN.cast<Map<String, dynamic>>());

  // 4. HSSS XeVT
    final hsssXeVT = data['HSSSXeVT'] as List? ?? [];
    hsssXeVTData.assignAll(hsssXeVT.cast<Map<String, dynamic>>());
  // 5. HSSS Khobe
    final hsssKhobe = data['HSSSKhobe'] as List? ?? [];
    hsssKhobeData.assignAll(hsssKhobe.cast<Map<String, dynamic>>());
    // 6. HSSS CNTT
    final hsssCNTT = data['HSSSCNTT'] as List? ?? [];
    hsssCNTTData.assignAll(hsssCNTT.cast<Map<String, dynamic>>());

    // 7. Chart giờ hoạt động xe vận tải
    final chartVTData = data['ChartGiohoatdongxevantaiCard'] as List? ?? [];
    chartGioHoatDongXeVTData.assignAll(chartVTData.cast<Map<String, dynamic>>());

  // Bang chi phí
    final bangChiphi = data['Bangchiphi'] as List? ?? [];
    bangChiphiData.assignAll(bangChiphi.cast<Map<String, dynamic>>());  
    // Bang BĐSC trần
    final bangBDSC = data['Bang_BDSC_tranap'] as List? ?? [];
    bangBDSCtranapData.assignAll(bangBDSC.cast<Map<String, dynamic>>());
    // Bang BĐSC vận tải
    final bangBDSCVT = data['Bang_BDSC_vantai'] as List? ?? [];
    bangBDSCvantaiData.assignAll(bangBDSCVT.cast<Map<String, dynamic>>());
  }

  // ====== Filter functions ======
  void setFilterMonth(int m) {
    filterMonth.value = m;
  }

  void setFilterYear(int y) {
    filterYear.value = y;
  }

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

  // ====== Helper ======
  String fmt(num v) {
    if (v == null) return '0';
    return NumberFormat('#,###', 'vi_VN').format(v);
  }

  // Lấy danh sách các tháng có trong dữ liệu
  List<int> getAvailableMonths() {
    final Set<int> months = {};
    for (var item in chartGioHoatDongData) {
      final thang = item['Thang'] as int?;
      if (thang != null) {
        months.add(thang);
      }
    }
    return months.toList()..sort();
  }

  // Lấy danh sách các chi nhánh có trong dữ liệu
  List<String> getAvailableChinhanh() {
    final Set<String> chinhanh = {};
    for (var item in chartGioHoatDongData) {
      final cn = item['Chinhanh']?.toString();
      if (cn != null && cn.isNotEmpty) {
        chinhanh.add(cn);
      }
    }
    return chinhanh.toList()..sort();
  }

  // Lấy dữ liệu GioHD theo chi nhánh và tháng
  double getGioHD(String chinhanh, int thang) {
    for (var item in chartGioHoatDongData) {
      if (item['Chinhanh']?.toString() == chinhanh && item['Thang'] == thang) {
        return (item['GioHD'] as num?)?.toDouble() ?? 0;
      }
    }
    return 0;
  }

  // Lấy dữ liệu SoSC theo chi nhánh và tháng
  int getSoSC(String chinhanh, int thang) {
    for (var item in chartGioHoatDongData) {
      if (item['Chinhanh']?.toString() == chinhanh && item['Thang'] == thang) {
        return (item['SoSC'] as num?)?.toInt() ?? 0;
      }
    }
    return 0;
  }
}