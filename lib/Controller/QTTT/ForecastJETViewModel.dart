import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class JetMergedRow {
  final int year;
  final int month;
  final double singaporePrice;
  final DateTime? singaporeModifiedDate;
  final double altViewPrice;
  final DateTime? altViewModifiedDate;
  final double actualPrice;

  JetMergedRow({
    required this.year,
    required this.month,
    required this.singaporePrice,
    required this.singaporeModifiedDate,
    required this.altViewPrice,
    required this.altViewModifiedDate,
    required this.actualPrice,
  });

  String get monthLabel => '${month.toString().padLeft(2, '0')}/$year';

  factory JetMergedRow.fromJson(Map<String, dynamic> j) => JetMergedRow(
    year: j['year'] ?? 0,
    month: j['month'] ?? 0,
    singaporePrice: (j['SingaporePrice'] ?? 0).toDouble(),
    singaporeModifiedDate: _parseNullableDate(j['SingaporeModifiedDate']),
    altViewPrice: (j['AltViewPrice'] ?? 0).toDouble(),
    altViewModifiedDate: _parseNullableDate(j['AltViewModifiedDate']),
    actualPrice: (j['priceThucTe'] ?? 0).toDouble(),
  );

  static DateTime? _parseNullableDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    if (s.isEmpty || s.startsWith('0001-01-01')) return null;
    return DateTime.tryParse(s);
  }
}

class ForecastJETViewModel extends GetxController {
  final loading = false.obs;
  final rows = <JetMergedRow>[].obs;
  final dateFmt = DateFormat('dd/MM/yyyy');

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    try {
      loading.value = true;

      var res = await APICaller.getInstance().get(
        "QuanTriThongTin/DubaoGiaJetA1",
      );
      final data = json.decode(res);

      final List<dynamic> list =
          (data['BangDuDoanPlat'] ?? []) as List<dynamic>;
      rows.assignAll(
        list.map((e) => JetMergedRow.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      Utils.showSnackBar(
        title: 'Thống báo',
        message: 'Tải dữ liệu dự đoán JET thất bại',
      );
    } finally {
      loading.value = false;
    }
  }

  String formatDate(DateTime? d) => d == null ? '' : dateFmt.format(d);
}
