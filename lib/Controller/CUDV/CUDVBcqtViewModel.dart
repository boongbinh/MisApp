// controllers/cudv_bcqt_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class CUDVBcqtViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu từ API ======
  final bangBienDongLoiNhuan = <Map<String, dynamic>>[].obs;
  final bangCanDoiHangHoa = <Map<String, dynamic>>[].obs;
  final bangPhanTichLoiNhuan = <Map<String, dynamic>>[].obs;

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
      final response = await APICaller.getInstance().get(
        "CUDV/BaocaoCUDV/Baocaoquantri",
      );

      print('response: $response');

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
    // Bảng biến động lợi nhuận
    final b1 = data['BangbiendongloinhuanBcqt'] as List? ?? [];
    bangBienDongLoiNhuan.assignAll(b1.cast<Map<String, dynamic>>());

    // Bảng cân đối hàng hóa
    final b2 = data['BangcandoihanghoaBcqt'] as List? ?? [];
    bangCanDoiHangHoa.assignAll(b2.cast<Map<String, dynamic>>());

    // Bảng phân tích lợi nhuận
    final b3 = data['BangphantichloinhuanBcqt'] as List? ?? [];
    bangPhanTichLoiNhuan.assignAll(b3.cast<Map<String, dynamic>>());
  }

  // ====== Refresh ======
  void refreshData() {
    loadData();
  }

  // ====== Helper Methods ======
  bool get hasData =>
      bangBienDongLoiNhuan.isNotEmpty ||
      bangCanDoiHangHoa.isNotEmpty ||
      bangPhanTichLoiNhuan.isNotEmpty;
}