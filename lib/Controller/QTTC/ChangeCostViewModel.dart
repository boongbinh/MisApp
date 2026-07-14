import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

enum VCtab { tongquan, chiPhiThang, sanLuongThuy, sanLuongBo }

class ChangeCostViewModel extends GetxController {
  // UI state
  final loading = false.obs;
  final error = ''.obs;
  final tab = 0.obs; // 0: Tổng quan, 1: Theo tháng, 2: Đường thủy, 3: Đường bộ

  // helpers
  String fmt(num? v) =>
      v == null ? '--' : NumberFormat.decimalPattern('vi_VN').format(v);
  String fmtTy(num vnd) =>
      NumberFormat.decimalPattern('vi_VN').format(vnd / 1e9);

  double _double(dynamic x) {
    if (x == null) return 0;
    if (x is num) return x.toDouble();
    return double.tryParse(x.toString()) ?? 0;
  }

  /* ---------- Tab 0: Tổng quan ---------- */
  final tqItems = <CCItem>[].obs;
  final totalBD = 0.0.obs;

  final sumTotal = 0.0.obs; // Tổng (VND)
  final deltaAbs = 0.0.obs; // Tăng/giảm so với tháng trước (VND)
  final deltaPct = 0.0.obs; // So sánh % tháng trước
  final refuelFee = 0.0.obs; // Phí tra nạp (VND)

  /* ---------- Tab 1: Theo tháng ---------- */
  final monthly = List<double>.filled(12, 0).obs; // TỶ
  final selectedMonth = DateTime.now().month.obs;
  double get maxY {
    final arr = monthly.toList();
    final m = arr.isEmpty ? 0 : arr.reduce((a, b) => a > b ? a : b);
    return m * 1.1;
  }

  final barAnimTick = 0.obs; // trigger restart tween

  /* ---------- Tab 2: Đường thủy ---------- */
  final waterRows = <WaterRow>[].obs;

  /* ---------- Tab 3: Đường bộ ---------- */
  final roadLabels = <String>[].obs;
  final roadValues = <double>[].obs; // có thể là triệu L / Tấn tuỳ bạn
  double get roadSum => roadValues.fold(0.0, (p, e) => p + e);
  final pieRotateTick = 0.obs;
  String selectedTime = '';

  @override
  void onReady() {
    super.onReady();
    selectedTime = Get.arguments;
    fetchForCurrentTab();
  }

  void switchTab(int i) {
    if (i == tab.value) return;
    tab.value = i;
    fetchForCurrentTab();
  }

  Future<void> fetchForCurrentTab() async {
    switch (tab.value) {
      case 0:
        await fetchTongQuan();
        break;
      case 1:
        await fetchTheoThang();
        break;
      case 2:
        await fetchDuongThuy();
        break;
      case 3:
        await fetchDuongBo();
        break;
    }
  }

  /* -------- API: Tổng quan -------- */
  Future<void> fetchTongQuan() async {
    try {
      loading.value = true;
      error.value = '';

      final time =
          selectedTime == ''
              ? DateFormat('yyyy-MM').format(DateTime.now())
              : selectedTime;
      final resp = await APICaller.getInstance().get(
        "QuanTriTaiChinh/ChiPhiBienDoi/?time=$time&sanbay=ALL",
      );
      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      final raw = (map['Data'] as List?) ?? const [];
      final list = <CCItem>[];

      for (final e in raw) {
        final m = e as Map<String, dynamic>;
        final name = (m['TenLoaiChiPhi'] ?? '').toString();
        final v = _double(m['BD']);
        final pct = _double(m['Percent']);
        final delta = _double(m['HieuPhanTram']);
        if (v == 0 && pct == 0) continue;
        list.add(CCItem(name: name, value: v, percent: pct, delta: delta));
      }

      tqItems.assignAll(list);
      totalBD.value = _double(map['totalBD']);

      double _pick(List<String> keys) {
        for (final k in keys) {
          if (map.containsKey(k)) return _double(map[k]);
        }
        return 0;
      }

      sumTotal.value = _pick(['Tong', 'Total', 'TongBD', 'totalBD']);
      if (sumTotal.value == 0) {
        // fallback: tính tổng từ các mục
        sumTotal.value = list.fold(0.0, (p, e) => p + e.value);
      }
      deltaAbs.value = _pick(['TangGiam', 'SoVoiThangTruoc']);
      deltaPct.value = _pick(['SoSanhThangTruoc', 'Phan100SoVoiThangTruoc']);
      refuelFee.value = _double(map['TraNapNgam'][0]['BD']);
    } catch (e) {
      error.value = 'Lỗi tải dữ liệu: $e';
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    } finally {
      loading.value = false;
    }
  }

  /* -------- API: Theo tháng -------- */
  Future<void> fetchTheoThang() async {
    try {
      loading.value = true;
      error.value = '';

      final time =
          selectedTime == ''
              ? DateFormat('yyyy-MM').format(DateTime.now())
              : selectedTime;
      final resp = await APICaller.getInstance().get(
        "QuanTriTaiChinh/ChiPhiBienDoiTheoThang/?time=$time&sanbay=ALL",
      );
      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      final raw = (map['Data'] as List?) ?? const [];
      final arr = List<double>.filled(12, 0);

      for (final e in raw) {
        final m = e as Map<String, dynamic>;
        final month = (m['TranMonth'] as num?)?.toInt() ?? 0;
        final val = _double(m['CPBD']) / 1e9; // hiển thị TỶ
        if (month >= 1 && month <= 12) arr[month - 1] = val;
      }

      monthly.assignAll(arr);
      barAnimTick.value++; // restart tween
    } catch (e) {
      error.value = 'Lỗi tải dữ liệu: $e';
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    } finally {
      loading.value = false;
    }
  }

  /* -------- API: Đường thủy -------- */
  Future<void> fetchDuongThuy() async {
    try {
      loading.value = true;
      error.value = '';

      final time =
          selectedTime == ''
              ? DateFormat('yyyy-MM').format(DateTime.now())
              : selectedTime;
      final resp = await APICaller.getInstance().get(
        "QuanTriTaiChinh/ThongKeSanLuongVanChuyenDuongThuy/?time=$time&sanbay=ALL",
      );
      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      final raw = (map['CPVCDT'] as List?) ?? const [];
      final list = <WaterRow>[];
      int stt = 1;

      for (final e in raw) {
        final m = e as Map<String, dynamic>;
        list.add(
          WaterRow(
            stt: stt++,
            khuXuat: (m['KhuVucXuat'] ?? '').toString(),
            khoNhap: (m['KhoNhap'] ?? '').toString(),
            soChuyen: (m['SoChuyen'] as num?)?.toInt() ?? 0,
            lit15: _double(m['Lit15']),
            loai: (m['Loai'] ?? '').toString(),
          ),
        );
      }

      waterRows.assignAll(list);
    } catch (e) {
      error.value = 'Lỗi tải dữ liệu: $e';
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    } finally {
      loading.value = false;
    }
  }

  /* -------- API: Đường bộ -------- */
  Future<void> fetchDuongBo() async {
    try {
      loading.value = true;
      error.value = '';

      final time =
          selectedTime == ''
              ? DateFormat('yyyy-MM').format(DateTime.now())
              : selectedTime;
      final resp = await APICaller.getInstance().get(
        "QuanTriTaiChinh/ThongKeSanLuongVanChuyenDuongBo/?time=$time&sanbay=ALL",
      );
      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      final raw = (map['Data'] as List?) ?? const [];
      final labels = <String>[];
      final values = <double>[];

      for (final e in raw) {
        final m = e as Map<String, dynamic>;
        labels.add((m['DonViVanChuyen'] ?? '').toString());
        values.add(_double(m['Lit15']) / 1e6); // ví dụ: triệu L
      }

      roadLabels.assignAll(labels);
      roadValues.assignAll(values);
      pieRotateTick.value++; // xoay donut khi nạp
    } catch (e) {
      error.value = 'Lỗi tải dữ liệu: $e';
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    } finally {
      loading.value = false;
    }
  }
}

/* ===== Models ===== */

class CCItem {
  final String name;
  final double value; // VND
  final double percent; // %
  final double delta; // %
  CCItem({
    required this.name,
    required this.value,
    required this.percent,
    required this.delta,
  });

  bool get up => delta > 0;
  String get pctLabel => '${percent.toStringAsFixed(1)}%';
  String get deltaLabel => '${delta.abs().toStringAsFixed(1)}%';
}

class WaterRow {
  final int stt;
  final String khuXuat;
  final String khoNhap;
  final int soChuyen;
  final double lit15;
  final String loai;
  WaterRow({
    required this.stt,
    required this.khuXuat,
    required this.khoNhap,
    required this.soChuyen,
    required this.lit15,
    required this.loai,
  });
}
