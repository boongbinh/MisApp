import 'dart:convert';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';

class RatePoint {
  final int day;
  final double value;
  const RatePoint({required this.day, required this.value});
}

class JETDetailViewModel extends GetxController {
  // state
  final loading = true.obs;
  final error = ''.obs;

  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  final thisRaw = <double?>[].obs;
  final prevRaw = <double?>[].obs;
  final lastRaw = <double?>[].obs;

  // series
  final thisMonth = <RatePoint>[].obs;
  final prevMonth = <RatePoint>[].obs;
  final lastYear = <RatePoint>[].obs;

  // legend visibility
  final showThis = true.obs;
  final showPrev = true.obs;
  final showLast = true.obs;

  // avg label (TB tháng)
  final avgMonth = ''.obs;

  final _minY = 0.0.obs;
  final _maxY = 1.0.obs;

  // ====== helpers ======
  String get monthLabel => 'Tháng ${selectedMonth.value}/${selectedYear.value}';

  final _fmt = NumberFormat('#,##0.00', 'vi_VN');
  String fmt(num v) => _fmt.format(v);

  void setMonthYear(int m, int y) {
    selectedMonth.value = m;
    selectedYear.value = y;
    fetch(); // bạn sẽ thay bằng call thật
  }

  @override
  void onInit() {
    super.onInit();
    fetch(); // load lần đầu
  }

  // ====== Fetch + parse (thay bằng API thật của bạn) ======
  Future<void> fetch() async {
    loading.value = true;
    error.value = '';
    try {
      // TODO: gọi API thật
      var response = await APICaller.getInstance().get(
        "QuanTriThongTin/ChitietGiaJetA1?thang=$selectedMonth&nam=$selectedYear",
      );
      print(response);
      if (response != null) {
        final map = jsonDecode(response) as Map<String, dynamic>;
        _fromApiMap(map);

        // selectedMonth.value = month;
        // selectedYear.value = year;
      }
    } catch (e) {
      error.value = 'Lỗi tải/parse dữ liệu';
    } finally {
      loading.value = false;
    }
  }

  void _fromApiMap(Map<String, dynamic> map) {
    thisRaw.assignAll(_toRaw(map['Thangnay'] as List?));
    prevRaw.assignAll(_toRaw(map['Thangtruoc'] as List?));
    lastRaw.assignAll(_toRaw(map['Thangnaynamngoai'] as List?));

    thisMonth.assignAll(_toPoints(map['Thangnay']));
    prevMonth.assignAll(_toPoints(map['Thangtruoc']));
    lastYear.assignAll(_toPoints(map['Thangnaynamngoai']));

    final avg = map['PlatTBT'];
    avgMonth.value = (avg == null) ? '' : fmt(_asDouble(avg));

    final all = <double>[
      ...thisMonth.map((e) => e.value),
      ...prevMonth.map((e) => e.value),
      ...lastYear.map((e) => e.value),
    ];
    if (all.isEmpty) {
      _minY.value = 0;
      _maxY.value = 1;
    } else {
      final minV = all.reduce(math.min);
      final maxV = all.reduce(math.max);
      final pad = (maxV - minV) * .05;
      _minY.value = minV - pad;
      _maxY.value = maxV + pad;
    }
  }

  List<double?> _toRaw(List? src) =>
      src?.map((e) => e == null ? null : (e as num).toDouble()).toList() ??
      <double?>[];

  List<RatePoint> _toPoints(dynamic list) {
    if (list is! List) return const <RatePoint>[];
    final out = <RatePoint>[];
    for (var i = 0; i < list.length; i++) {
      final v = list[i];
      if (v == null) continue; // bỏ ngày không có dữ liệu
      out.add(RatePoint(day: i + 1, value: _asDouble(v)));
    }
    return out;
  }

  double _asDouble(dynamic v) => v is num ? v.toDouble() : double.parse('$v');

  /// min/max Y theo các series đang hiển thị (để trục Y không “nhảy” lung tung)
  (double minY, double maxY) currentYRange() {
    final vals = <double>[];
    void add(List<RatePoint> pts, bool show) {
      if (!show) return;
      vals.addAll(pts.map((e) => e.value));
    }

    add(thisMonth, showThis.value);
    add(prevMonth, showPrev.value);
    add(lastYear, showLast.value);

    if (vals.isEmpty) return (0, 1);
    final minV = vals.reduce(math.min);
    final maxV = vals.reduce(math.max);
    final pad = (maxV - minV).clamp(0.5, 5.0); // padding nhẹ cho đẹp
    return (minV - pad, maxV + pad);
  }

  // ====== fake data cho demo, bạn bỏ đi khi ghép API thật ======
  Future<Map<String, dynamic>> _fakeApi() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return {
      "Thangnay": [
        83.88,
        84.73,
        85.6,
        85.17,
        null,
        null,
        86.12,
        86.07,
        88.03,
        86.74,
        85.71,
        null,
        null,
        88.42,
        86.03,
        86.2,
        86.19,
        89.25,
        null,
        null,
        87.31,
        88.17,
        87.36,
        88.11,
        87.54,
        null,
        null,
        86.93,
        88.16,
        89.47,
        90.01,
      ],
      "Thangtruoc": [
        null,
        78.16,
        78.3,
        79.17,
        78.29,
        78.97,
        null,
        null,
        80.44,
        80.68,
        80.32,
        82.39,
        85.98,
        null,
        null,
        88.31,
        89.25,
        91.96,
        95.12,
        94.91,
        null,
        null,
        92.05,
        83.9,
        84.7,
        84.38,
        85.43,
        null,
        null,
        84.47,
        null,
      ],
      "Thangnaynamngoai": [
        100.5,
        102.72,
        102.27,
        102.09,
        102.59,
        null,
        null,
        100.52,
        100.0,
        98.67,
        99.57,
        99.74,
        null,
        null,
        98.79,
        98.0,
        96.93,
        98.59,
        97.63,
        null,
        null,
        95.52,
        96.02,
        95.44,
        95.82,
        96.98,
        null,
        null,
        95.72,
        93.85,
        94.49,
      ],
      "PlatTBT": "87.01",
    };
  }
}
