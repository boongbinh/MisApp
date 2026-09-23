// controllers/mohinhshell_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';
import 'package:skypec/Components/Atcl/Baocaongay/MohinhshellChart.dart';

// Định nghĩa màu sắc
const Color _colorNavy = Color(0xFF003266);
const Color _colorGold = Color(0xFFFDC000);
const Color _colorRed = Color(0xFFE74C3C);
const Color _colorGreen = Color(0xFF2ECC71);

class MohinhshellViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // Dữ liệu từ API
  final mohinhShellThang = <Map<String, dynamic>>[].obs;
  final mohinhShellQuy = <Map<String, dynamic>>[].obs;
  final mohinhShellNam = <Map<String, dynamic>>[].obs;
  
  // Data cho chart
  final mohinhShellThangData = <MohinhshellData>[].obs;
  final mohinhShellQuyData = <MohinhshellData>[].obs;
  final mohinhShellNamData = <MohinhshellData>[].obs;

  // ====== Mapping MohinhShell value to title ======
  String getTitleForShellValue(int value) {
    switch (value) {
      case 0:
        return 'Môi trường';
      case 1:
        return 'QT/QĐ, Kỹ thuật - phương tiện';
      case 2:
        return 'Con người';
      case 3:
        return 'Khách quan';
      default:
        return 'Khác';
    }
  }

  // ====== Lấy màu cho từng loại ======
  Color getColorForShellValue(int value) {
    switch (value) {
      case 0:
        return _colorNavy;      // Môi trường - Xanh navy
      case 1:
        return _colorGold;       // QT/QĐ, Kỹ thuật - Vàng
      case 2:
        return _colorRed;        // Con người - Đỏ
      case 3:
        return _colorGreen;      // Khách quan - Xanh lá
      default:
        return Colors.grey;
    }
  }

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
        "Atcl/Mohinhshell",
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
    // Lấy dữ liệu mô hình shell tháng
    final shellThang = data['Mohinhshellthang'] as List? ?? [];
    mohinhShellThang.assignAll(shellThang.cast<Map<String, dynamic>>());
    
    // Lấy dữ liệu mô hình shell quý
    final shellQuy = data['Mohinhshellquy'] as List? ?? [];
    mohinhShellQuy.assignAll(shellQuy.cast<Map<String, dynamic>>());
    
    // Lấy dữ liệu mô hình shell năm
    final shellNam = data['Mohinhshellnam'] as List? ?? [];
    mohinhShellNam.assignAll(shellNam.cast<Map<String, dynamic>>());
    
    // Chuyển đổi dữ liệu cho chart
    _convertToChartData();
  }

  void _convertToChartData() {
    // ====== Chuyển đổi dữ liệu tháng ======
    _convertShellData(mohinhShellThang, mohinhShellThangData);
    
    // ====== Chuyển đổi dữ liệu quý ======
    _convertShellData(mohinhShellQuy, mohinhShellQuyData);
    
    // ====== Chuyển đổi dữ liệu năm ======
    _convertShellData(mohinhShellNam, mohinhShellNamData);
  }

  void _convertShellData(
    List<Map<String, dynamic>> sourceData,
    RxList<MohinhshellData> targetData,
  ) {
    if (sourceData.isEmpty) {
      targetData.clear();
      return;
    }

    // Gom nhóm dữ liệu theo MohinhShell
    final Map<int, double> groupedData = {};
    
    for (var item in sourceData) {
      final shellValue = (item['MohinhShell'] as num?)?.toInt() ?? 0;
      final soHoSo = (item['SoHoSo'] as num?)?.toDouble() ?? 0;
      
      if (soHoSo > 0) {
        groupedData[shellValue] = (groupedData[shellValue] ?? 0) + soHoSo;
      }
    }

    // Chuyển đổi sang danh sách dữ liệu chart
    final List<MohinhshellData> chartData = [];
    
    for (var entry in groupedData.entries) {
      final shellValue = entry.key;
      final total = entry.value;
      
      chartData.add(MohinhshellData(
        label: getTitleForShellValue(shellValue),
        value: total,
        color: getColorForShellValue(shellValue),
        suffix: 'hồ sơ',
      ));
    }
    
    // Sắp xếp theo value giảm dần
    chartData.sort((a, b) => b.value.compareTo(a.value));
    
    targetData.assignAll(chartData);
  }

  // ====== Helper: Lấy danh sách loại có giá trị cao nhất ======
  List<String> getLoaiNhieuNhat(List<MohinhshellData> data) {
    if (data.isEmpty) return [];
    
    // Tìm giá trị max
    final maxValue = data.reduce((a, b) => a.value > b.value ? a : b).value;
    
    // Lấy tất cả các loại có value == maxValue
    return data
        .where((item) => item.value == maxValue)
        .map((item) => item.label)
        .toList();
  }

  // ====== Helper: Lấy giá trị cao nhất ======
  double getSoLuongNhieuNhat(List<MohinhshellData> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a.value > b.value ? a : b).value;
  }

  // ====== Helper: Lấy danh sách loại có giá trị thấp nhất ======
  List<String> getLoaiItNhat(List<MohinhshellData> data) {
    if (data.isEmpty) return [];
    
    // Tìm giá trị min
    final minValue = data.reduce((a, b) => a.value < b.value ? a : b).value;
    
    // Lấy tất cả các loại có value == minValue
    return data
        .where((item) => item.value == minValue)
        .map((item) => item.label)
        .toList();
  }

  // ====== Helper: Lấy giá trị thấp nhất ======
  double getSoLuongItNhat(List<MohinhshellData> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a.value < b.value ? a : b).value;
  }

  // ====== Helper Methods cho dữ liệu tháng ======
  
  // Lấy tổng số tháng
  double get totalValueThang {
    return mohinhShellThangData.fold(0.0, (sum, item) => sum + item.value);
  }

  // Lấy danh sách loại nhiều nhất tháng
  List<String> get loaiNhieuNhatThang {
    return getLoaiNhieuNhat(mohinhShellThangData.toList());
  }

  // Lấy số lượng nhiều nhất tháng
  double get soLuongNhieuNhatThang {
    return getSoLuongNhieuNhat(mohinhShellThangData.toList());
  }

  // Lấy danh sách loại ít nhất tháng
  List<String> get loaiItNhatThang {
    return getLoaiItNhat(mohinhShellThangData.toList());
  }

  // Lấy số lượng ít nhất tháng
  double get soLuongItNhatThang {
    return getSoLuongItNhat(mohinhShellThangData.toList());
  }

  // ====== Helper Methods cho dữ liệu quý ======
  
  // Lấy tổng số quý
  double get totalValueQuy {
    return mohinhShellQuyData.fold(0.0, (sum, item) => sum + item.value);
  }

  // Lấy danh sách loại nhiều nhất quý
  List<String> get loaiNhieuNhatQuy {
    return getLoaiNhieuNhat(mohinhShellQuyData.toList());
  }

  // Lấy số lượng nhiều nhất quý
  double get soLuongNhieuNhatQuy {
    return getSoLuongNhieuNhat(mohinhShellQuyData.toList());
  }

  // Lấy danh sách loại ít nhất quý
  List<String> get loaiItNhatQuy {
    return getLoaiItNhat(mohinhShellQuyData.toList());
  }

  // Lấy số lượng ít nhất quý
  double get soLuongItNhatQuy {
    return getSoLuongItNhat(mohinhShellQuyData.toList());
  }

  // ====== Helper Methods cho dữ liệu năm ======
  
  // Lấy tổng số năm
  double get totalValueNam {
    return mohinhShellNamData.fold(0.0, (sum, item) => sum + item.value);
  }

  // Lấy danh sách loại nhiều nhất năm
  List<String> get loaiNhieuNhatNam {
    return getLoaiNhieuNhat(mohinhShellNamData.toList());
  }

  // Lấy số lượng nhiều nhất năm
  double get soLuongNhieuNhatNam {
    return getSoLuongNhieuNhat(mohinhShellNamData.toList());
  }

  // Lấy danh sách loại ít nhất năm
  List<String> get loaiItNhatNam {
    return getLoaiItNhat(mohinhShellNamData.toList());
  }

  // Lấy số lượng ít nhất năm
  double get soLuongItNhatNam {
    return getSoLuongItNhat(mohinhShellNamData.toList());
  }

  // Lấy chi tiết theo MohinhShell value từ dữ liệu tháng
  Map<int, double> getDetailByShellValueThang() {
    return _getDetailByShellValue(mohinhShellThang);
  }

  // Lấy chi tiết theo MohinhShell value từ dữ liệu quý
  Map<int, double> getDetailByShellValueQuy() {
    return _getDetailByShellValue(mohinhShellQuy);
  }

  // Lấy chi tiết theo MohinhShell value từ dữ liệu năm
  Map<int, double> getDetailByShellValueNam() {
    return _getDetailByShellValue(mohinhShellNam);
  }

  Map<int, double> _getDetailByShellValue(List<Map<String, dynamic>> sourceData) {
    final Map<int, double> result = {};
    
    for (var item in sourceData) {
      final shellValue = (item['MohinhShell'] as num?)?.toInt() ?? 0;
      final soHoSo = (item['SoHoSo'] as num?)?.toDouble() ?? 0;
      
      if (soHoSo > 0) {
        result[shellValue] = (result[shellValue] ?? 0) + soHoSo;
      }
    }
    
    return result;
  }
}