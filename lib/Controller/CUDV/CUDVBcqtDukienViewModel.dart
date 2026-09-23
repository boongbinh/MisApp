// controllers/cudv_bcqt_dukien_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class CUDVBcqtDukienViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Text comments ======
  final commentCanDoi = ''.obs;
  final commentCoCauBan = ''.obs;

  // ====== Dữ liệu bảng ======
  final bangCanDoiHangHoa = <Map<String, dynamic>>[].obs;

  // ====== Pie chart ======
  final sanLuongTheoKV = <Map<String, dynamic>>[].obs;
  final sanLuongTheoKH = <Map<String, dynamic>>[].obs;

  // ====== ⭐ Multi column chart: Ước tính sản lượng bán ======
  final uocTinhSanLuongBan = <Map<String, dynamic>>[].obs;

  // ====== ⭐ Platts ======
  final bieuDoGiaPlatt = <Map<String, dynamic>>[].obs;
  final plattsBQThangTruoc = <Map<String, dynamic>>[].obs;
  final plattsBQHienTai = <Map<String, dynamic>>[].obs;
  final plattsBQDuKien = <Map<String, dynamic>>[].obs;

  final bangBienDongLoiNhuan = <Map<String, dynamic>>[].obs;
  final bangPhanTichLoiNhuan = <Map<String, dynamic>>[].obs;
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
      final response = await APICaller.getInstance().get(
        "CUDV/BaocaoCUDV/BaocaoquantriDukien",
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
    // Text comments
    commentCanDoi.value = data['BCQT_01_1_BangCanDoi']?.toString() ?? '';
    commentCoCauBan.value = data['BCQT_03_CommentCuoi']?.toString() ?? '';

    // Bảng cân đối hàng hóa
    final b1 = data['BangcandoihanghoaBcqt'] as List? ?? [];
    bangCanDoiHangHoa.assignAll(b1.cast<Map<String, dynamic>>());

    // Pie charts
    final b2 = data['SanLuongTheoKV'] as List? ?? [];
    sanLuongTheoKV.assignAll(b2.cast<Map<String, dynamic>>());

    final b3 = data['SanLuongTheoKH'] as List? ?? [];
    sanLuongTheoKH.assignAll(b3.cast<Map<String, dynamic>>());

    // ⭐ Multi column chart
    final b4 = data['UocTinhSanLuongBan'] as List? ?? [];
    uocTinhSanLuongBan.assignAll(b4.cast<Map<String, dynamic>>());

    // ⭐ Platts
    final b5 = data['BieuDoGiaPlatt'] as List? ?? [];
    bieuDoGiaPlatt.assignAll(b5.cast<Map<String, dynamic>>());

    final b6 = data['PlattBQThangTruoc'] as List? ?? [];
    plattsBQThangTruoc.assignAll(b6.cast<Map<String, dynamic>>());

    final b7 = data['PlattBQHienTai'] as List? ?? [];
    plattsBQHienTai.assignAll(b7.cast<Map<String, dynamic>>());

    final b8 = data['PlattBQDuKien'] as List? ?? [];
    plattsBQDuKien.assignAll(b8.cast<Map<String, dynamic>>());

    final b9 = data['BangbiendongloinhuanBcqt'] as List? ?? [];
    bangBienDongLoiNhuan.assignAll(b9.cast<Map<String, dynamic>>());

    final b10 = data['BangphantichloinhuanBcqt'] as List? ?? [];
    bangPhanTichLoiNhuan.assignAll(b10.cast<Map<String, dynamic>>());
  }

  // ====== Helper Platts ======
  double? get plattsThangTruoc {
    if (plattsBQThangTruoc.isEmpty) return null;
    return (plattsBQThangTruoc.first['Platt_BQ_Lastmonth'] as num?)
        ?.toDouble();
  }

  double? get plattsHienTai {
    if (plattsBQHienTai.isEmpty) return null;
    return (plattsBQHienTai.first['Platt_BQ_ToDate'] as num?)?.toDouble();
  }

  double? get plattsDiff {
    final a = plattsThangTruoc;
    final b = plattsHienTai;
    if (a == null || b == null) return null;
    return b - a;
  }

  double? get plattsDiffPercent {
    final a = plattsThangTruoc;
    final diff = plattsDiff;
    if (a == null || diff == null || a == 0) return null;
    return (diff / a) * 100;
  }

  // ====== Refresh ======
  void refreshData() {
    loadData();
  }

  bool get hasData =>
      bangCanDoiHangHoa.isNotEmpty ||
      sanLuongTheoKV.isNotEmpty ||
      sanLuongTheoKH.isNotEmpty ||
      uocTinhSanLuongBan.isNotEmpty ||
      bieuDoGiaPlatt.isNotEmpty;
}