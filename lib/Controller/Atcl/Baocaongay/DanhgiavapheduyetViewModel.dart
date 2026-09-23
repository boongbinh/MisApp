// controllers/danhgiavapheduyet_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';
import 'package:skypec/Components/Atcl/Baocaongay/DanhgiabaocaongayCard.dart';

class DanhgiavapheduyetViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // Dữ liệu từ API
  final danhGiaBaoCaoNgay = <Map<String, dynamic>>[].obs;
  final danhGiaBaoCaoThang = <Map<String, dynamic>>[].obs;
  
  // Data cho card
  final danhGiaBaoCaoNgayData = <DanhgiabaocaongayData>[].obs;
  final danhGiaBaoCaoThangData = <DanhgiabaocaongayData>[].obs;

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
      // API GET - không có request body
      final response = await APICaller.getInstance().get(
        "Atcl/Danhgiabaocaongay",
      );


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
    // Lấy dữ liệu đánh giá ngày
    final danhGiaNgay = data['Danhgiabaocaongay'] as List? ?? [];
    danhGiaBaoCaoNgay.assignAll(danhGiaNgay.cast<Map<String, dynamic>>());
    
    // Lấy dữ liệu đánh giá tháng
    final danhGiaThang = data['DanhgiabaocaoThang'] as List? ?? [];
    danhGiaBaoCaoThang.assignAll(danhGiaThang.cast<Map<String, dynamic>>());
    
    // Chuyển đổi dữ liệu cho card
    _convertToCardData();
  }

  void _convertToCardData() {
    // ====== Chuyển đổi dữ liệu ngày ======
    if (danhGiaBaoCaoNgay.isNotEmpty) {
      final item = danhGiaBaoCaoNgay.first;
      final muon = (item['Muon'] as num?)?.toDouble() ?? 0;
      final som = (item['Som'] as num?)?.toDouble() ?? 0;

      final List<DanhgiabaocaongayData> ngayData = [];
      
      if (muon > 0) {
        ngayData.add(DanhgiabaocaongayData(
          label: 'Chưa đạt',
          value: muon,
          color: Color(0xFF003266),
          suffix: 'hồ sơ',
        ));
      }
      
      if (som > 0) {
        ngayData.add(DanhgiabaocaongayData(
          label: 'Đạt',
          value: som,
          color: Color(0xFFFDC000),
          suffix: 'hồ sơ',
        ));
      }
      
      danhGiaBaoCaoNgayData.assignAll(ngayData);
    } else {
      danhGiaBaoCaoNgayData.clear();
    }

    // ====== Chuyển đổi dữ liệu tháng ======
    if (danhGiaBaoCaoThang.isNotEmpty) {
      final item = danhGiaBaoCaoThang.first;
      final muon = (item['Muon'] as num?)?.toDouble() ?? 0;
      final som = (item['Som'] as num?)?.toDouble() ?? 0;

      final List<DanhgiabaocaongayData> thangData = [];
      
      if (muon > 0) {
        thangData.add(DanhgiabaocaongayData(
          label: 'Chưa đạt',
          value: muon,
          color: Color(0xFF003266),
          suffix: 'hồ sơ',
        ));
      }
      
      if (som > 0) {
        thangData.add(DanhgiabaocaongayData(
          label: 'Đạt',
          value: som,
          color: Color(0xFFFDC000),
          suffix: 'hồ sơ',
        ));
      }
      
      danhGiaBaoCaoThangData.assignAll(thangData);
    } else {
      danhGiaBaoCaoThangData.clear();
    }
  }

  // ====== Refresh ======
  void refreshData() {
    loadData();
  }

  // ====== Helper Methods ======
  
  // Lấy tổng số
  double getTotalValue(List<DanhgiabaocaongayData> data) {
    return data.fold(0.0, (sum, item) => sum + item.value);
  }

  // Lấy số lượng Chưa đạt
  double getChuaDat(List<DanhgiabaocaongayData> data) {
    final found = data.firstWhere(
      (item) => item.label == 'Chưa đạt', 
      orElse: () => DanhgiabaocaongayData(label: '', value: 0, color: Colors.red)
    );
    return found.value;
  }

  // Lấy số lượng Đạt
  double getDat(List<DanhgiabaocaongayData> data) {
    final found = data.firstWhere(
      (item) => item.label == 'Đạt', 
      orElse: () => DanhgiabaocaongayData(label: '', value: 0, color: Colors.green)
    );
    return found.value;
  }

  // Tỷ lệ đạt
  double getTyLeDat(List<DanhgiabaocaongayData> data) {
    final total = getTotalValue(data);
    if (total == 0) return 0;
    return (getDat(data) / total) * 100;
  }

  // Tỷ lệ chưa đạt
  double getTyLeChuaDat(List<DanhgiabaocaongayData> data) {
    final total = getTotalValue(data);
    if (total == 0) return 0;
    return (getChuaDat(data) / total) * 100;
  }
}