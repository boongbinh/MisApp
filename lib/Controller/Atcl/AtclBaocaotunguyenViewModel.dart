// controllers/atcl_baocaotunguyen_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';
import 'package:skypec/Components/Atcl/Baocaotunguyen/BaocaotunguyenChart.dart';
import 'package:skypec/Components/Atcl/Baocaongay/DanhgiabaocaongayCard.dart';

const Color _colorNavy = Color(0xFF003266);
const Color _colorGold = Color(0xFFFDC000);

// ⭐ Định nghĩa khu vực
enum KhuVuc {
  CNMB('CNMB', 'Miền Bắc'),
  CNMT('CNMT', 'Miền Trung'),
  CNMN('CNMN', 'Miền Nam'),
  CNVT('CNVT', 'Vận tải');

  final String code;
  final String label;
  const KhuVuc(this.code, this.label);
}

class AtclBaocaotunguyenViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Filter (temp - dùng cho sheet) ======
  final filterNgay = DateTime.now().obs;

  // ====== Filter đã áp dụng ======
  final ngay = DateTime.now().obs;

  // ⭐ Danh sách khu vực có data (tự động phát hiện từ API)
  final allowedKhuVucs = <KhuVuc>[].obs;

  // ⭐ Data cho từng khu vực (chart cũ - BaocaotunguyenChart)
  final baoCaoNgayByKhuVuc = <KhuVuc, List<BaocaotunguyenData>>{}.obs;
  final baoCaoThangByKhuVuc = <KhuVuc, List<BaocaotunguyenData>>{}.obs;

  // ⭐ Data cho 2 section mới (DanhgiabaocaongayCard)
  final danhGiaNgayByKhuVuc = <KhuVuc, List<DanhgiabaocaongayData>>{}.obs;
  final danhGiaThangByKhuVuc = <KhuVuc, List<DanhgiabaocaongayData>>{}.obs;

  // ⭐ Tab đang chọn
  final selectedKhuVucNgay = Rx<KhuVuc?>(null);
  final selectedKhuVucThang = Rx<KhuVuc?>(null);
  final selectedKhuVucXuLyNgay = Rx<KhuVuc?>(null);
  final selectedKhuVucXuLyThang = Rx<KhuVuc?>(null);

  // ====== Bảng màu ======
  final List<Color> _colorPalette = [
    _colorNavy,
    _colorGold,
    Colors.red.shade600,
    Colors.green.shade600,
    Colors.purple.shade600,
    Colors.orange.shade600,
    Colors.teal.shade600,
    Colors.pink.shade600,
    Colors.indigo.shade600,
    Colors.cyan.shade600,
    Colors.amber.shade600,
    Colors.brown.shade600,
  ];

  // ====== Khởi tạo ======
  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  // ====== Load Data (POST với ngay) ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      final payload = {
        "ngay": DateFormat('yyyy-MM-dd').format(ngay.value),
      };

      print('Payload: $payload');

      final response = await APICaller.getInstance().post(
        "Atcl/Danhgiabaotunguyen",
        payload,
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
    // Clear dữ liệu cũ
    baoCaoNgayByKhuVuc.clear();
    baoCaoThangByKhuVuc.clear();
    danhGiaNgayByKhuVuc.clear();
    danhGiaThangByKhuVuc.clear();
    allowedKhuVucs.clear();

    // ⭐ Tự động phát hiện khu vực có data
    final detectedKhuVucs = <KhuVuc>{};

    // ====== Chart cũ: Danhgiabaotunguyen{code} & Danhgiabaotunguyenthang{code} ======
    for (final kv in KhuVuc.values) {
      // Ngày
      final ngayKey = 'Danhgiabaotunguyen${kv.code}';
      final ngayList = data[ngayKey] as List? ?? [];
      if (ngayList.isNotEmpty) {
        final chartData = _convertToChartData(ngayList, isThang: false);
        if (chartData.isNotEmpty) {
          baoCaoNgayByKhuVuc[kv] = chartData;
          detectedKhuVucs.add(kv);
        }
      }

      // Tháng
      final thangKey = 'Danhgiabaotunguyenthang${kv.code}';
      final thangList = data[thangKey] as List? ?? [];
      if (thangList.isNotEmpty) {
        final chartData = _convertToChartData(thangList, isThang: true);
        if (chartData.isNotEmpty) {
          baoCaoThangByKhuVuc[kv] = chartData;
          detectedKhuVucs.add(kv);
        }
      }
    }

    // ====== Section mới: DanhgiabaotunguyenHoantat{code} & DanhgiabaotunguyenthangHoantat{code} ======
    for (final kv in KhuVuc.values) {
      // Ngày Hoàn tất
      final ngayHtKey = 'DanhgiabaotunguyenHoantat${kv.code}';
      final ngayHt = data[ngayHtKey];
      if (ngayHt is Map) {
        final dg = _convertHoantatToDanhGia(ngayHt);
        if (dg.any((e) => e.value > 0)) {
          danhGiaNgayByKhuVuc[kv] = dg;
          detectedKhuVucs.add(kv);
        }
      }

      // Tháng Hoàn tất
      final thangHtKey = 'DanhgiabaotunguyenthangHoantat${kv.code}';
      final thangHt = data[thangHtKey];
      if (thangHt is Map) {
        final dg = _convertHoantatToDanhGia(thangHt);
        if (dg.any((e) => e.value > 0)) {
          danhGiaThangByKhuVuc[kv] = dg;
          detectedKhuVucs.add(kv);
        }
      }
    }

    // Sắp xếp theo thứ tự enum
    final sortedList = KhuVuc.values
        .where((kv) => detectedKhuVucs.contains(kv))
        .toList();
    allowedKhuVucs.assignAll(sortedList);

    // Set tab mặc định
    if (allowedKhuVucs.isNotEmpty) {
      final first = allowedKhuVucs.first;
      selectedKhuVucNgay.value = first;
      selectedKhuVucThang.value = first;
      selectedKhuVucXuLyNgay.value = first;
      selectedKhuVucXuLyThang.value = first;
    }

    // Trigger rebuild
    baoCaoNgayByKhuVuc.refresh();
    baoCaoThangByKhuVuc.refresh();
    danhGiaNgayByKhuVuc.refresh();
    danhGiaThangByKhuVuc.refresh();
  }

  // ⭐ Convert chart cũ
  List<BaocaotunguyenData> _convertToChartData(
    List rawList, {
    required bool isThang,
  }) {
    final List<BaocaotunguyenData> chartData = [];
    final offset = isThang ? 3 : 0;

    for (int i = 0; i < rawList.length; i++) {
      final item = rawList[i] as Map<String, dynamic>;
      final boPhan = item['Bophanthuchien']?.toString() ?? 'Khác';
      final soHoSo = (item['SoHoSo'] as num?)?.toDouble() ?? 0;

      if (soHoSo > 0) {
        final color = _colorPalette[(i + offset) % _colorPalette.length];
        chartData.add(BaocaotunguyenData(
          label: boPhan,
          value: soHoSo,
          color: color,
          suffix: 'hồ sơ',
        ));
      }
    }

    chartData.sort((a, b) => b.value.compareTo(a.value));
    return chartData;
  }

  // ⭐ Convert section mới (Hoantat/Chuahoantat → donut)
  List<DanhgiabaocaongayData> _convertHoantatToDanhGia(Map raw) {
    final hoantat = (raw['Hoantat'] as num?)?.toDouble() ?? 0;
    final chuahoantat = (raw['Chuahoantat'] as num?)?.toDouble() ?? 0;

    final data = <DanhgiabaocaongayData>[];
    if (hoantat > 0) {
      data.add(DanhgiabaocaongayData(
        label: 'Hoàn tất',
        value: hoantat,
        color: Colors.green.shade600,
        suffix: 'hồ sơ',
      ));
    }
    if (chuahoantat > 0) {
      data.add(DanhgiabaocaongayData(
        label: 'Chưa hoàn tất',
        value: chuahoantat,
        color: Colors.red.shade600,
        suffix: 'hồ sơ',
      ));
    }
    return data;
  }

  // ====== Filter Actions ======
  void setFilterNgay(DateTime date) {
    filterNgay.value = date;
  }

  void applyFilters() {
    ngay.value = filterNgay.value;
    loadData();
  }

  void resetFilters() {
    filterNgay.value = DateTime.now();
  }

  // ====== Đổi tab ======
  void selectKhuVucNgay(KhuVuc kv) => selectedKhuVucNgay.value = kv;
  void selectKhuVucThang(KhuVuc kv) => selectedKhuVucThang.value = kv;
  void selectKhuVucXuLyNgay(KhuVuc kv) => selectedKhuVucXuLyNgay.value = kv;
  void selectKhuVucXuLyThang(KhuVuc kv) => selectedKhuVucXuLyThang.value = kv;

  // ====== Lấy data cho khu vực đang chọn ======
  List<BaocaotunguyenData> getCurrentDataNgay(KhuVuc kv) {
    return baoCaoNgayByKhuVuc[kv] ?? [];
  }

  List<BaocaotunguyenData> getCurrentDataThang(KhuVuc kv) {
    return baoCaoThangByKhuVuc[kv] ?? [];
  }

  List<DanhgiabaocaongayData> getDanhGiaNgay(KhuVuc kv) {
    return danhGiaNgayByKhuVuc[kv] ?? [];
  }

  List<DanhgiabaocaongayData> getDanhGiaThang(KhuVuc kv) {
    return danhGiaThangByKhuVuc[kv] ?? [];
  }

  // ====== Check có data không ======
  bool hasDataNgay(KhuVuc kv) => (baoCaoNgayByKhuVuc[kv] ?? []).isNotEmpty;
  bool hasDataThang(KhuVuc kv) => (baoCaoThangByKhuVuc[kv] ?? []).isNotEmpty;
  bool hasDanhGiaNgay(KhuVuc kv) => (danhGiaNgayByKhuVuc[kv] ?? []).any((e) => e.value > 0);
  bool hasDanhGiaThang(KhuVuc kv) => (danhGiaThangByKhuVuc[kv] ?? []).any((e) => e.value > 0);

  bool get hasAnyDataNgay => baoCaoNgayByKhuVuc.isNotEmpty || danhGiaNgayByKhuVuc.isNotEmpty;
  bool get hasAnyDataThang => baoCaoThangByKhuVuc.isNotEmpty || danhGiaThangByKhuVuc.isNotEmpty;

  // ====== Helper ======
  String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  String get displayDate => formatDate(filterNgay.value);

  bool get canShowTab => allowedKhuVucs.length > 1;

  // ====== Refresh ======
  void refreshData() {
    loadData();
  }
}