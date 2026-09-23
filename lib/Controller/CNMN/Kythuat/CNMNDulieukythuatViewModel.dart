import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';
import 'package:skypec/Route/AppRoutes.dart';


class CNMNDulieukythuatViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu Card ======
  // Card 1: Xe tra nạp
  final xeTNTong = ''.obs;
  final xeTNChiTiet = <String>[].obs;

  // Card 2: Xe vận chuyển
  final xeVCTong = ''.obs;
  final xeVCChiTiet = <String>[].obs;

  // Card 3: Bể chứa
  final beChuaTong = ''.obs;
  final beChuaChiTiet = <String>[].obs;

  // Card 4: Bầu lọc
  final bauLocTong = ''.obs;
  final bauLocChiTiet = <String>[].obs;

  // Card 5: Máy bơm
  final mayBomTong = ''.obs;
  final mayBomChiTiet = <String>[].obs;

  // Card 6: Đồng hồ
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
    // 1. Xe tra nạp
    final xeTN = (data['XeTNTong'] as List?)?.first;
    if (xeTN != null) {
      xeTNTong.value = xeTN['Tieude']?.toString() ?? '0 Xe tra nạp';
    }
    final xeTNChiTietList = data['XeTN'] as List? ?? [];
    xeTNChiTiet.assignAll(
      xeTNChiTietList
          .map((e) => (e as Map)['ma_xe']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

    // 2. Xe vận chuyển
    final xeVC = (data['XeVCTong'] as List?)?.first;
    if (xeVC != null) {
      xeVCTong.value = xeVC['Tieude']?.toString() ?? '0 Xe vận chuyển';
    }
    final xeVCChiTietList = data['XeVC'] as List? ?? [];
    xeVCChiTiet.assignAll(
      xeVCChiTietList
          .map((e) => (e as Map)['ma_xe']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

    // 3. Bể chứa
    final beChua = (data['BechuaTong'] as List?)?.first;
    if (beChua != null) {
      beChuaTong.value = beChua['Tieude']?.toString() ?? '0 Bể / 0 ㎥';
    }
    final beChuaChiTietList = data['Bechua'] as List? ?? [];
    beChuaChiTiet.assignAll(
      beChuaChiTietList
          .map((e) => (e as Map)['Ma_be']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

    // 4. Bầu lọc
    final bauLoc = (data['BaulocTong'] as List?)?.first;
    if (bauLoc != null) {
      bauLocTong.value = bauLoc['Tieude']?.toString() ?? '0 Bầu lọc';
    }
    final bauLocChiTietList = data['Bauloc'] as List? ?? [];
    bauLocChiTiet.assignAll(
      bauLocChiTietList
          .map((e) => (e as Map)['Model_loc']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

    // 5. Máy bơm
    final mayBom = (data['MaybomTong'] as List?)?.first;
    if (mayBom != null) {
      mayBomTong.value = mayBom['Tieude']?.toString() ?? '0 Máy bơm';
    }
    final mayBomChiTietList = data['Maybom'] as List? ?? [];
    mayBomChiTiet.assignAll(
      mayBomChiTietList
          .map((e) => (e as Map)['Ma_bom']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

    // 6. Đồng hồ
    final dongHo = (data['DonghoTong'] as List?)?.first;
    if (dongHo != null) {
      dongHoTong.value = dongHo['Tieude']?.toString() ?? '0 Đồng hồ';
    }
    final dongHoChiTietList = data['Dongho'] as List? ?? [];
    dongHoChiTiet.assignAll(
      dongHoChiTietList
          .map((e) => (e as Map)['Tenthietbi']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList()
    );

  }

  void onCardTap(String type) {
    switch (type) {
      case 'xe_tranap':
        Get.toNamed(Routes.xeTranapDetailCNKV);
        break;
      case 'xe_vanchuyen':
        Get.toNamed(Routes.xeVanChuyenDetailCNKV);
        break;
      case 'be_dungtich':
        Get.toNamed(Routes.beChuaDetailCNKV);
        break;
      case 'bau_loc':
        Get.toNamed(Routes.bauLocDetailCNKV);
        break;
      case 'may_bom':
        Get.toNamed(Routes.mayBomDetailCNKV);
        break;
      case 'dong_ho':
        Get.toNamed(Routes.dongHoDetailCNKV);
        break;
      default:
        print('Unknown type: $type');
        break;
    }
  }
}