import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class CUTNViewModel extends GetxController {
  // tab: 0 = Nhóm hàng HK, 1 = Loại bay
  final tab = 0.obs;

  // state
  final loading = false.obs;
  final error = ''.obs;

  // ====== dữ liệu đã parse ======
  // Nhóm hàng HK
  double slHkvn = 0, slHknn = 0;
  double pctHkvn = 0, pctHknn = 0; // % so tháng trước
  double laiHkvn = 0, laiHknn = 0; // Tổng lãi trên biến phí
  double tgHkvn = 0, tgHknn = 0; // Tăng/giảm so tháng trước
  double tongNhomHang = 0;
  double cpcdNhomHang = 0;

  // Loại bay
  double slNd = 0, slQt = 0;
  double pctNd = 0, pctQt = 0;
  double laiNd = 0, laiQt = 0;
  double tgNd = 0, tgQt = 0;
  double tongLoaiBay = 0;
  double cpcdLoaiBay = 0;

  // ====== helper view ======
  void switchTab(int i) => tab.value = i;

  List<SPRow> get currentRows {
    if (tab.value == 0) {
      return [
        SPRow(
          index: 1,
          label: 'HKVN',
          sanLuong: slHkvn,
          pct: pctHkvn,
          lai: laiHkvn,
          tg: tgHkvn,
        ),
        SPRow(
          index: 2,
          label: 'HKNN',
          sanLuong: slHknn,
          pct: pctHknn,
          lai: laiHknn,
          tg: tgHknn,
        ),
      ];
    } else {
      return [
        SPRow(
          index: 1,
          label: 'Nội địa',
          sanLuong: slNd,
          pct: pctNd,
          lai: laiNd,
          tg: tgNd,
        ),
        SPRow(
          index: 2,
          label: 'Quốc tế',
          sanLuong: slQt,
          pct: pctQt,
          lai: laiQt,
          tg: tgQt,
        ),
      ];
    }
  }

  double get currentTotal => tab.value == 0 ? tongNhomHang : tongLoaiBay;

  double get currentFixed => tab.value == 0 ? cpcdNhomHang : cpcdLoaiBay;
  String selectedTime = '';

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    selectedTime = Get.arguments;
    getData();
  }

  Future<void> getData() async {
    try {
      loading.value = true;
      error.value = '';

      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      String time = DateFormat('yyyy-MM').format(lastMonth);
      if (DateFormat('yyyy-MM').format(now) != selectedTime) {
        time = selectedTime;
      }
      final resp = await APICaller.getInstance().get(
        "QuanTriTaiChinh/LoiNhuanCungUngTraNap/?time=$time&sanbay=ALL",
      );
      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      applyResponse(map);
    } catch (e) {
      error.value = 'Lỗi tải dữ liệu: $e';
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    } finally {
      loading.value = false;
    }
  }

  // ====== parse/apply ======
  void applyResponse(Map<String, dynamic> j) {
    try {
      // Nhóm hàng HK
      slHkvn = (j['SanLuong_HKVN'] ?? 0).toDouble();
      slHknn = (j['SanLuong_HKNN'] ?? 0).toDouble();
      pctHkvn = (j['Phan100SanLuongSoThangTruoc_HKVN'] ?? 0).toDouble();
      pctHknn = (j['Phan100SanLuongSoThangTruoc_HKNN'] ?? 0).toDouble();
      laiHkvn = (j['TongLaiTrenBienPhi_HKVN'] ?? 0).toDouble();
      laiHknn = (j['TongLaiTrenBienPhi_HKNN'] ?? 0).toDouble();
      tgHkvn = (j['TangGiamSoThangTruoc_HKVN'] ?? 0).toDouble();
      tgHknn = (j['TangGiamSoThangTruoc_HKNN'] ?? 0).toDouble();
      tongNhomHang = (j['Tong_NhomHangHk'] ?? 0).toDouble();
      cpcdNhomHang = (j['ChiPhiCoDinh_NhomHangHk'] ?? 0).toDouble();

      // Loại bay
      slNd = (j['SanLuong_ND'] ?? 0).toDouble();
      slQt = (j['SanLuong_QT'] ?? 0).toDouble();
      pctNd = (j['Phan100SanLuongSoThangTruoc_ND'] ?? 0).toDouble();
      pctQt = (j['Phan100SanLuongSoThangTruoc_QT'] ?? 0).toDouble();
      laiNd = (j['TongLaiTrenBienPhi_ND'] ?? 0).toDouble();
      laiQt = (j['TongLaiTrenBienPhi_QT'] ?? 0).toDouble();
      tgNd = (j['TangGiamSoThangTruoc_ND'] ?? 0).toDouble();
      tgQt = (j['TangGiamSoThangTruoc_QT'] ?? 0).toDouble();
      tongLoaiBay = (j['Tong_LoaiBay'] ?? 0).toDouble();
      cpcdLoaiBay = (j['ChiPhiCoDinh_LoaiBay'] ?? 0).toDouble();
    } catch (e) {}
  }

  // ====== format ======
  String fmtNum(num v) {
    final s = v.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final ri = s.length - 1 - i;
      b.write(s[ri]);
      if (i % 3 == 2 && ri != 0) b.write('.');
    }
    return b.toString().split('').reversed.join();
  }

  String fmtPct(num v) => '${v.toStringAsFixed(1)}%';
}

class SPRow {
  final int index;
  final String label; // Hãng HK hoặc Loại bay
  final double sanLuong;
  final double pct; // % Sản lượng so với tháng trước
  final double lai; // Tổng lãi trên biến phí (VND)
  final double tg; // Tăng/giảm so với tháng trước (%)

  SPRow({
    required this.index,
    required this.label,
    required this.sanLuong,
    required this.pct,
    required this.lai,
    required this.tg,
  });
}
