import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class FixCostViewModel extends GetxController {
  // state
  final loading = false.obs;
  final error = ''.obs;

  // dữ liệu đã parse
  final items = <CostItem>[].obs;
  final totalCD = 0.0.obs; // VND (đơn vị gốc từ API)
  double get totalTy => totalCD.value / 1e9; // dùng cho donut center + animate
  String selectedTime = '';

  // palette màu cho các lát donut
  final _palette = const <Color>[
    Color(0xFF5C9CF0), // blue
    Color(0xFF55CDA1), // green
    Color(0xFFF5A33E), // orange
    Color(0xFFEB6A6A), // red
    Color(0xFF8B6DFB),
    Color(0xFF22C5BB),
    Color(0xFFEC9CC3),
  ];

  @override
  void onReady() {
    super.onReady();
    selectedTime = Get.arguments;
    getData();
  }

  /// Parse API -> state
  void applyResponse(Map<String, dynamic> json) {
    try {
      loading.value = true;
      error.value = '';

      final raw = (json['Data'] as List?) ?? const [];
      final list = <CostItem>[];
      int colorIdx = 0;

      for (final e in raw) {
        final m = (e as Map).cast<String, dynamic>();

        final cd = (m['CD'] as num?)?.toDouble() ?? 0.0;
        final pct = (m['Percent'] as num?)?.toDouble() ?? 0.0;
        final delta = (m['HieuPhanTram'] as num?)?.toDouble() ?? 0.0;

        // Ẩn các dòng 0 hoàn toàn (đúng như ảnh)
        if (cd == 0 && pct == 0) continue;

        list.add(
          CostItem(
            name: (m['TenLoaiChiPhi'] ?? '').toString(),
            cd: cd,
            percent: pct, // đã là % của tổng
            delta: delta,
            color: _palette[colorIdx % _palette.length],
          ),
        );
        colorIdx++;
      }

      items.assignAll(list);

      // total theo field totalCD, fallback bằng tổng CD
      final t = (json['totalCD'] as num?)?.toDouble() ?? 0.0;
      totalCD.value = (t > 0) ? t : list.fold<double>(0, (p, e) => p + e.cd);
    } catch (e) {
      error.value = 'Lỗi đọc dữ liệu';
    } finally {
      loading.value = false;
    }
  }

  // ===== format helpers =====
  String fmtNum(num? v) {
    if (v == null) return '--';
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final revI = s.length - 1 - i;
      buf.write(s[revI]);
      if (i % 3 == 2 && revI != 0) buf.write('.');
    }
    return buf.toString().split('').reversed.join();
  }

  Future<void> getData() async {
    try {
      final formatted =
          selectedTime == ''
              ? DateFormat('yyyy-MM').format(DateTime.now())
              : selectedTime;
      final response = await APICaller.getInstance().get(
        "QuanTriTaiChinh/ChiPhiCoDinh/?time=$formatted&sanbay=ALL",
      );
      if (response != null) {
        final map = jsonDecode(response) as Map<String, dynamic>;
        applyResponse(map);
      }
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }
}

class CostItem {
  final String name;
  final double cd; // VND
  final double percent; // %
  final double delta; // % so với tháng trước (âm/dương)
  final Color color;

  CostItem({
    required this.name,
    required this.cd,
    required this.percent,
    required this.delta,
    required this.color,
  });

  double get cdTy => cd / 1e9; // số tiền (Tỷ) dạng double
  bool get up => delta > 0;
  String get pctLabel => '${percent.toStringAsFixed(1)}%';
  String get deltaLabel => '${delta.abs().toStringAsFixed(1)}%';
}
