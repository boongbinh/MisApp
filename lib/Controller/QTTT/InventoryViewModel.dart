import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class InventoryInfo {
  final int month; // 1..12
  final int year; // ví dụ 2025
  final double tonDau;
  final double nhap;
  final double ban; // map từ Xuat
  final double chenhLech;

  InventoryInfo({
    required this.month,
    required this.year,
    required this.tonDau,
    required this.nhap,
    required this.ban,
    required this.chenhLech,
  });

  factory InventoryInfo.fromJson(Map<String, dynamic> m) => InventoryInfo(
    month:
        int.tryParse('${m['Thang']}') ?? (m['Thang_123'] as num?)?.toInt() ?? 0,
    year: int.tryParse('${m['NamT']}') ?? DateTime.now().year,
    tonDau: (m['Ton_Dau'] as num?)?.toDouble() ?? 0,
    nhap: (m['Nhap'] as num?)?.toDouble() ?? 0,
    ban: (m['Xuat'] as num?)?.toDouble() ?? 0,
    chenhLech: (m['ChenhLech'] as num?)?.toDouble() ?? 0,
  );
}

class InventoryViewModel extends GetxController {
  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    GetInventoryInfo();
  }

  final rows = <InventoryInfo>[].obs;
  final loading = false.obs;
  final error = ''.obs;

  String monthLabel(InventoryInfo r) =>
      '${r.month.toString().padLeft(2, '0')}/${r.year}';

  // format theo cột
  String fmt3(num v) => NumberFormat('#,##0.###', 'vi_VN').format(v);
  String fmt2(num v) => NumberFormat('#,##0.##', 'vi_VN').format(v);

  /// Gọi thật: thay bằng API của bạn rồi gọi `rows.assignAll(...)`
  Future<void> loadFromJson(Map<String, dynamic> json) async {
    try {
      loading.value = true;
      error.value = '';
      final list =
          (json['HangTon'] as List? ?? [])
              .map((e) => InventoryInfo.fromJson(e as Map<String, dynamic>))
              .toList();
      rows.assignAll(list);
    } catch (e) {
      error.value = 'Không đọc được dữ liệu';
    } finally {
      loading.value = false;
    }
  }

  Future<void> GetInventoryInfo() async {
    try {
      var response = await APICaller.getInstance().get(
        "QuanTriThongTin/HangTon",
      );
      if (response != null) {
        final map = jsonDecode(response) as Map<String, dynamic>;
        loadFromJson(map);
      }
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }
}
