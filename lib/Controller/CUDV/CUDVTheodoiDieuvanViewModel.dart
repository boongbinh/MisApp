// controllers/theodoidieuvan_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class TheodoidieuvanViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu ======
  //final tuNgay = DateTime.now().subtract(const Duration(days: 1)).obs;
  final tuNgay = DateTime.now().obs;
  final denNgay = DateTime.now().add(const Duration(days: 14)).obs;

  // Dữ liệu từ API
  final theoDoiTonKho = <Map<String, dynamic>>[].obs;
  final dateRange = <DateTime>[].obs;

  // ====== Khởi tạo ======
  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  // ====== Load Data ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      // Tạo danh sách các ngày trong khoảng
      final dates = _getDateRange(tuNgay.value, denNgay.value);
      dateRange.assignAll(dates);

      Map<String, dynamic> payload = {
        "tungay": DateFormat('yyyy-MM-dd').format(tuNgay.value),
        "denngay": DateFormat('yyyy-MM-dd').format(denNgay.value),
      };


      final response = await APICaller.getInstance().post(
        "CUDV/BaocaoCUDV/theodoidieuvan",
        payload,
      );


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

// controllers/theodoidieuvan_viewmodel.dart
// Thêm logic tính hệ số cảnh báo

void applyData(Map<String, dynamic> data) {
  final tonKho = data['theodoitonkho'] as List? ?? [];

  // ============================================================
  // GROUP THEO KHU VỰC + KHO
  // ============================================================

  final Map<String, Map<String, dynamic>> grouped = {};

  for (final rawItem in tonKho) {
    final item = Map<String, dynamic>.from(rawItem);

    final khuVuc = item['KHU_VUC']?.toString() ?? '';
    final kho = item['KHO']?.toString() ?? '';

    if (kho.isEmpty) continue;

    final key = '${khuVuc}_$kho';

    // ----------------------------------------------------------
    // Tạo thông tin cố định của kho
    // ----------------------------------------------------------

    if (!grouped.containsKey(key)) {
      grouped[key] = {
        'KHU_VUC': khuVuc,
        'KHO': kho,

        'DUNG_TICH_M3':
            (item['DUNG_TICH_M3'] as num?)
                    ?.toDouble() ??
                0,

        'HE_SO_CANH_BAO':
            (item['HE_SO_CANH_BAO'] as num?)
                    ?.toDouble() ??
                0,

        'HE_SO_CANH_BAO2':
            (item['HE_SO_CANH_BAO2'] as num?)
                    ?.toDouble() ??
                0,
      };
    }

    // ----------------------------------------------------------
    // Ngày của dữ liệu
    // ----------------------------------------------------------

    final voucherDate =
        DateTime.tryParse(
      item['VoucherDate']?.toString() ?? '',
    );

    if (voucherDate == null) continue;

    final dateKey = DateFormat(
      'yyyy-MM-dd',
    ).format(voucherDate);

    // ----------------------------------------------------------
    // Dữ liệu tồn + sản lượng theo ngày
    // ----------------------------------------------------------

    grouped[key]![dateKey] = {
      'Ton': (item['Ton'] as num?)?.toDouble() ?? 0,
      'Sanluong': (item['Sanluong'] as num?)?.toDouble() ?? 0,
      'Heso': (item['Heso'] as num?)?.toDouble() ?? 0,
      'HesoString': item['HesoString']?.toString() ?? '',
    };
  }

  // ============================================================
  // ĐỔ DỮ LIỆU ĐÃ GROUP VÀO RxList
  // ============================================================

  theoDoiTonKho.assignAll(
    grouped.values.toList(),
  );

  print(theoDoiTonKho);
}



  // ====== Lấy danh sách ngày trong khoảng ======
  List<DateTime> _getDateRange(DateTime from, DateTime to) {
    final dates = <DateTime>[];
    var current = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }


  // ====== Change Date ======
  void changeTuNgay(DateTime date) {
    tuNgay.value = date;
  }

  void changeDenNgay(DateTime date) {
    denNgay.value = date;
  }

  void applyDateRange() {
    loadData();
  }

  // ====== Refresh ======
  void refreshData() {
    loadData();
  }

  // ====== Helper Methods ======
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String get displayDateRange {
    return '${formatDate(tuNgay.value)} - ${formatDate(denNgay.value)}';
  }

  bool get hasData => theoDoiTonKho.isNotEmpty;

  int get dayCount => dateRange.length;
}