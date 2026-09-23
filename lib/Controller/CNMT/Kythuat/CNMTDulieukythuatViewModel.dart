import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class CNMTDulieukythuatViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu từ API ======
  final xeTNTong = ''.obs;
  final xeTNChiTiet = <String>[].obs;
  final xeVCTong = ''.obs;
  final xeVCChiTiet = <String>[].obs;
  final beChuaTong = ''.obs;
  final beChuaChiTiet = <String>[].obs;
  final bauLocTong = ''.obs;
  final bauLocChiTiet = <String>[].obs;
  final mayBomTong = ''.obs;
  final mayBomChiTiet = <String>[].obs;
  final dongHoTong = ''.obs;
  final dongHoChiTiet = <String>[].obs;

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
        "CNKV/KT/Baocao/Dulieukythuat",
      );

      if (response != null) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        applyData(data);
      }
    } catch (e) {
      error.value = e.toString();
      Utils.showSnackBar(title: 'Lỗi', message: e.toString());
    } finally {
      loading.value = false;
    }
  }

  void applyData(Map<String, dynamic> data) {
    // Xe tra nạp
    final xeTN = (data['XeTNTong'] as List?)?.first;
    xeTNTong.value = xeTN?['Tieude']?.toString() ?? '0 Xe tra nạp';
    final xeTNChiTietList = data['xeTNChitiet'] as List? ?? [];
    xeTNChiTiet.assignAll(
      xeTNChiTietList
          .map((e) => (e as Map)['Noidung']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

    // Xe vận chuyển
    final xeVC = (data['XeVCTong'] as List?)?.first;
    xeVCTong.value = xeVC?['Tieude']?.toString() ?? '0 Xe vận chuyển';
    final xeVCChiTietList = data['xeVCChitiet'] as List? ?? [];
    xeVCChiTiet.assignAll(
      xeVCChiTietList
          .map((e) => (e as Map)['Noidung']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

    // Bể chứa
    final beChua = (data['BechuaTong'] as List?)?.first;
    beChuaTong.value = beChua?['Tieude']?.toString() ?? '0 Bể / 0 ㎥';
    final beChuaChiTietList = data['BechuaChitiet'] as List? ?? [];
    beChuaChiTiet.assignAll(
      beChuaChiTietList
          .map((e) => (e as Map)['Noidung']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

    // Bầu lọc
    final bauLoc = (data['BaulocTong'] as List?)?.first;
    bauLocTong.value = bauLoc?['Tieude']?.toString() ?? '0 Bầu lọc';
    final bauLocChiTietList = data['BaulocChitiet'] as List? ?? [];
    bauLocChiTiet.assignAll(
      bauLocChiTietList
          .map((e) => (e as Map)['Noidung']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

    // Máy bơm
    final mayBom = (data['MaybomTong'] as List?)?.first;
    mayBomTong.value = mayBom?['Tieude']?.toString() ?? '0 Máy bơm';
    final mayBomChiTietList = data['MaybomChitiet'] as List? ?? [];
    mayBomChiTiet.assignAll(
      mayBomChiTietList
          .map((e) => (e as Map)['Noidung']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

    // Đồng hồ
    final dongHo = (data['DonghoTong'] as List?)?.first;
    dongHoTong.value = dongHo?['Tieude']?.toString() ?? '0 Đồng hồ';
    final dongHoChiTietList = data['DonghoChitiet'] as List? ?? [];
    dongHoChiTiet.assignAll(
      dongHoChiTietList
          .map((e) => (e as Map)['Noidung']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );
  }

  void onCardTap(String type) {
    print('Card tapped: $type');
  }
}