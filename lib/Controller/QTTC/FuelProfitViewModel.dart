import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class FuelProfitViewModel extends GetxController {
  // state
  final loading = false.obs;
  final error = ''.obs;

  // data
  final rows = <FuelRow>[].obs;
  final totalLuongXuat = 0.0.obs; // VND? -> dữ liệu là đơn vị lượng
  final totalLoiNhuan = 0.0.obs; // VND
  String selectedTime = '';

  @override
  void onReady() {
    super.onReady();
    selectedTime = Get.arguments;
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      loading.value = true;
      error.value = '';

      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      String time = DateFormat('yyyy-MM').format(lastMonth);
      if (DateFormat('yyyy-MM').format(now) != selectedTime) {
        time = selectedTime;
      }
      final res = await APICaller.getInstance().get(
        "QuanTriTaiChinh/PhanTichLuongHangBan/?time=$time&sanbay=ALL",
      );
      if (res == null) return;


print(res);
      final map = jsonDecode(res) as Map<String, dynamic>;
      final list = (map['Data'] as List?) ?? const [];

      final parsed = <FuelRow>[];
      double sumXuat = 0, sumLN = 0;

      for (final e in list) {
        final m = e as Map<String, dynamic>;
        final r = FuelRow(
          thangNhap: (m['ThangNhap'] ?? '').toString(),
          platts: (m['Platts'] ?? 0).toDouble(),
          luongXuat: (m['LuongXuat'] ?? 0).toDouble(),
          loiNhuan: (m['LoiNhuan'] ?? 0).toDouble(),
        );
        parsed.add(r);
        sumXuat += r.luongXuat;
        sumLN += r.loiNhuan;
      }

      rows.assignAll(parsed);
      totalLuongXuat.value = sumXuat;
      totalLoiNhuan.value = sumLN;
    } catch (e) {
      error.value = 'Lỗi tải dữ liệu';
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    } finally {
      loading.value = false;
    }
  }

  // ===== format helpers =====
  // nhóm 3 dấu chấm (1.234.567)
  String fmtInt(num? v) {
    if (v == null) return '--';
    final s = v.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final ri = s.length - 1 - i;
      b.write(s[ri]);
      if (i % 3 == 2 && ri != 0) b.write('.');
    }
    return b.toString().split('').reversed.join();
  }

  // thập phân dùng dấu chấm (41.891)
  String fmtDec(num? v, [int digits = 3]) {
    if (v == null) return '--';
    return v.toStringAsFixed(digits);
  }
}

class FuelRow {
  final String thangNhap;
  final double platts;
  final double luongXuat;
  final double loiNhuan;

  const FuelRow({
    required this.thangNhap,
    required this.platts,
    required this.luongXuat,
    required this.loiNhuan,
  });
}
