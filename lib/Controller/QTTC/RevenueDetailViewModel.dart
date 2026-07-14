import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class RevenueDetailViewModel extends GetxController {
  final RxList<double> monthlyTotal = <double>[].obs; // 12 giá trị
  final RxInt selectedMonth = 1.obs; // 1..12
  final RxInt selectedYear = DateTime.now().year.obs;

  final RxList<double> pieValues = <double>[].obs; // ví dụ: [HKQT, HKVN]
  final RxList<String> pieLabels = <String>[].obs; // ["HKQT","HKVN"]

  // ---- toggles cho legend của cả 2 chart ----
  final RxBool showHKQT = true.obs;
  final RxBool showHKVN = true.obs;

  // ---- helpers ----
  final NumberFormat kNum = NumberFormat.decimalPattern('vi');

  String fmt(num? v, {bool suffixTy = false}) {
    if (v == null) return '--';
    final s = kNum.format(v);
    return suffixTy ? '$s TỶ' : s;
  }

  double get maxY {
    if (monthlyTotal.isEmpty) return 1;
    final m = monthlyTotal.whereType<double>().fold<double>(0, math.max);
    // đệm 8% cho đẹp
    return m * 1.08;
  }

  // tổng của pie (chỉ tính phần đang hiển thị theo toggle)
  double get pieSum {
    double s = 0;
    for (int i = 0; i < pieValues.length; i++) {
      final label = (i < pieLabels.length) ? pieLabels[i] : '';
      if (label == 'HKQT' && !showHKQT.value) continue;
      if (label == 'HKVN' && !showHKVN.value) continue;
      s += pieValues[i];
    }
    return s;
  }

  double sectionPercent(int i) {
    final sum = pieSum;
    if (sum <= 0) return 0;
    return (pieValues[i] / sum) * 100.0;
  }

  String get monthLabel => 'Tháng ${selectedMonth.value}/${selectedYear.value}';
  String selectedTime = '';

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    selectedTime = Get.arguments;
    getChartData1();
    getChartData2();
  }

  // ---- API mappers ----
  // chart 1
  void setMonthlyFromApi(Map<String, dynamic> map) {
    final list =
        (map['Data'] as List).cast<num>().map((e) => e.toDouble()).toList();
    monthlyTotal.assignAll(list);
    final m = (map['ThangHienTai'] as num?)?.toInt();
    if (m != null && m >= 1 && m <= 12) selectedMonth.value = m;
  }

  // chart 2
  void setPieFromApi(Map<String, dynamic> map) {
    final vals =
        (map['Data'] as List).cast<num>().map((e) => e.toDouble()).toList();
    final labs = (map['Label'] as List).cast<String>().toList();
    pieValues.assignAll(vals);
    pieLabels.assignAll(labs);
  }

  // khi chạm vào cột trong bar chart
  void pickMonth(int m) {
    if (m >= 1 && m <= 12) selectedMonth.value = m;
  }

  Future<void> getChartData1() async {
    try {
      final formatted =
          selectedTime == ''
              ? DateFormat('yyyy-MM').format(DateTime.now())
              : selectedTime;

      var response = await APICaller.getInstance().get(
        "QuanTriTaiChinh/ThongtinchitietDoanhthu/TheoTungThang/?time=$formatted&sanbay=ALL",
      );
      if (response != null) {
        final map = jsonDecode(response) as Map<String, dynamic>;
        setMonthlyFromApi(map);
      }
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }

  Future<void> getChartData2() async {
    try {
      final formatted =
          selectedTime == ''
              ? DateFormat('yyyy-MM').format(DateTime.now())
              : selectedTime;
      var response = await APICaller.getInstance().get(
        "QuanTriTaiChinh/ThongtinchitietDoanhthu/TheoKhachHang/?time=$formatted&sanbay=ALL",
      );
      if (response != null) {
        final map = jsonDecode(response) as Map<String, dynamic>;
        setPieFromApi(map);
      }
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }
}
