import 'dart:convert';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

/// Điểm dữ liệu theo ngày
class RatePoint {
  final int day; // 1..31
  final double? value; // tỉ giá
  final double? dQuarter; // % so quý trước (optional)
  final double? dStart; // % so đầu kỳ   (optional)
  const RatePoint({
    required this.day,
    required this.value,
    this.dQuarter,
    this.dStart,
  });
}

class RateDetailViewModel extends GetxController {
  // ========= STATE =========
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  final buy = <RatePoint>[].obs; // tỉ giá mua theo ngày
  final sell = <RatePoint>[].obs; // tỉ giá bán theo ngày
  final loading = false.obs;
  final error = ''.obs;

  final buyMin = RxnDouble();
  final buyMax = RxnDouble();
  final sellMin = RxnDouble();
  final sellMax = RxnDouble();

  String get monthYearLabel =>
      'Tháng ${selectedMonth.value}/${selectedYear.value}';

  // format số kiểu vi-VN (26,050)
  final NumberFormat _fmt = NumberFormat('#,##0', 'vi_VN');
  String fmtY(num v) => _fmt.format(v);

  // ========= PUBLIC =========
  Future<void> load() async {
    try {
      loading.value = true;
      error.value = '';
      GetRateData(month: selectedMonth.value, year: selectedYear.value);
    } catch (_) {
    } finally {
      loading.value = false;
    }
  }

  void setMonthYear(int m, int y) {
    selectedMonth.value = m;
    selectedYear.value = y;
    load();
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<(List<RatePoint>, List<RatePoint>)> GetRateData({
    required int month,
    required int year,
  }) async {
    try {
      var response = await APICaller.getInstance().get(
        "QuanTriThongTin/ChitietTigia?thang=$month&nam=$year",
      );
      buy.clear();
      sell.clear();
      if (response != null) {
        final map = jsonDecode(response) as Map<String, dynamic>;
        final (b, s) = _fromApiMap(map);
        buy.assignAll(b);
        sell.assignAll(s);
        return (buy, sell);
      }
      List<RatePoint> s1 = List.empty();
      List<RatePoint> s2 = List.empty();
      return (s1, s2);
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
      List<RatePoint> s1 = List.empty();
      List<RatePoint> s2 = List.empty();
      return (s1, s2);
    }
  }

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  (List<RatePoint>, List<RatePoint>) _fromApiMap(Map<String, dynamic> map) {
    List<RatePoint> buildSeries({
      required List<dynamic>? values, // giá theo ngày
      required List<dynamic>? dqPercent, // % quý trước (ví dụ 1.73 -> 1.73%)
      required List<dynamic>? dyPercent, // % năm trước  (ví dụ 4.51 -> 4.51%)
    }) {
      final n = (values?.length ?? 0);
      final list = <RatePoint>[];
      for (var i = 0; i < n; i++) {
        final val = _asDouble(values?[i]); // Có thể null
        final dq = _asDouble(
          dqPercent != null && i < dqPercent.length ? dqPercent[i] : null,
        );
        final dy = _asDouble(
          dyPercent != null && i < dyPercent.length ? dyPercent[i] : null,
        );

        final dqFrac = dq == null ? null : dq / 100.0;
        final dyFrac = dy == null ? null : dy / 100.0;

        list.add(
          RatePoint(
            day: i + 1,
            value: val, // giữ cả điểm null
            dQuarter: dqFrac,
            dStart: dyFrac,
          ),
        );
      }
      return list;
    }

    final buySeries = buildSeries(
      values: map['TransferWithNulls'] as List<dynamic>?,
      dqPercent: map['TransferQuyTruocWithNulls'] as List<dynamic>?,
      dyPercent: map['TransferNamTruocWithNulls'] as List<dynamic>?,
    );

    final sellSeries = buildSeries(
      values: map['SellWithNulls'] as List<dynamic>?,
      dqPercent: map['SellQuyTruocWithNulls'] as List<dynamic>?,
      dyPercent: map['SellNamTruocWithNulls'] as List<dynamic>?,
    );

    // (Tuỳ chọn) lấy min/max để khoá trục Y
    buyMin.value = _asDouble(map['tg_MIN_mua']);
    buyMax.value = _asDouble(map['tg_MAX_mua']);
    sellMin.value = _asDouble(map['tg_MIN_ban']);
    sellMax.value = _asDouble(map['tg_MAX_ban']);

    return (buySeries, sellSeries);
  }
}
