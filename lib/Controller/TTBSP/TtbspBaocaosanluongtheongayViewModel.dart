// controllers/ttbsp_baocaosanluongtheongay_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class TtbspBaocaosanluongtheongayViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Filter ======
  final tuNgay = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final denNgay = DateTime.now().obs;

  // ====== Dữ liệu ======
  final sanLuongTheoNgay = <Map<String, dynamic>>[].obs;
  final sanLuongTheoSanBay  = <Map<String, dynamic>>[].obs;

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
      Map<String, dynamic> payload = {
        "tungay": DateFormat('yyyy-MM-dd').format(tuNgay.value),
        "denngay": DateFormat('yyyy-MM-dd').format(denNgay.value),
      };


      final response = await APICaller.getInstance().post(
        "TTBSP/BaoCaoSanLuong/baocaosanluong_hangngay",
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

  void applyData(Map<String, dynamic> data) {
    final sanLuong = data['sanluongtheongay'] as List? ?? [];
    sanLuongTheoNgay.assignAll(sanLuong.cast<Map<String, dynamic>>());

    final sanLuongSanBay = data['sanluongtheosanbay'] as List? ?? [];
    sanLuongTheoSanBay.assignAll(sanLuongSanBay.cast<Map<String, dynamic>>());
  }

  // ====== Change Date ======
  void changeTuNgay(DateTime date) {
    tuNgay.value = date;
  }

  void changeDenNgay(DateTime date) {
    denNgay.value = date;
  }

  void applyFilters() {
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

  bool get hasData => sanLuongTheoNgay.isNotEmpty || sanLuongTheoSanBay.isNotEmpty;

  // Tổng hợp
  double get tongThucHien {
    return sanLuongTheoNgay.fold(0.0, (sum, item) {
      final hktnNgoai = (item['HKTN_BayNuocNgoai_Ton'] as num?)?.toDouble() ?? 0;
      final hktnTrong = (item['HKTN_BayTrongNuoc_Ton'] as num?)?.toDouble() ?? 0;
      final hknn = (item['HKNN_Ton'] as num?)?.toDouble() ?? 0;
      final khac = (item['BayKhac_Ton'] as num?)?.toDouble() ?? 0;
      return sum + hktnNgoai + hktnTrong + hknn + khac;
    });
  }

  double get tongKeHoach {
    return sanLuongTheoNgay.fold(0.0,
        (sum, item) => sum + ((item['Tong_SL_KH'] as num?)?.toDouble() ?? 0));
  }
}