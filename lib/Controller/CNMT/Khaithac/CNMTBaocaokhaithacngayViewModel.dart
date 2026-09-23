import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class CNMTBaocaokhaithacngayViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu ======
  final selectedDate = DateTime.now().obs;

  // Dữ liệu từ API
  final sanLuongTuanSanBay = <Map<String, dynamic>>[].obs;
  final sanLuongTuanCNDP = <Map<String, dynamic>>[].obs;
  final keHoachTraNapTrongNgay = Rx<Map<String, dynamic>>({}); // ⭐ Sửa thành Rx
  final tyLeTonKhoSanBay = <Map<String, dynamic>>[].obs;
  final soGioHoatDongXeSanBay = <Map<String, dynamic>>[].obs;
  final soGioHoatDongXeCndp = <Map<String, dynamic>>[].obs;

  final soGioHoatDongXeSanBayChart =<Map<String, dynamic>>[].obs;
  final soGioHoatDongXeCndpChart =<Map<String, dynamic>>[].obs;

  final thongTinDieuHanhKhaiThac = ''.obs;

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
        "Ngay_BC_th": DateFormat('yyyy-MM-dd').format(selectedDate.value),
      };


      final response = await APICaller.getInstance().post(
        "CNKV/Khaithac/Baocao/Khaithacbaocao/TongHopBaoCaoCNMT",
        payload,
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
    // Lấy dữ liệu sản lượng tuần sân bay
    final sanLuong = data['Sanluontuansanbay'] as List? ?? [];
    sanLuongTuanSanBay.assignAll(sanLuong.cast<Map<String, dynamic>>());

    // Lấy dữ liệu sản lượng tuần CNDP
    final sanLuongCNDP = data['Sanluontuancndp'] as List? ?? [];
    sanLuongTuanCNDP.assignAll(sanLuongCNDP.cast<Map<String, dynamic>>());

    // Lấy thông tin điều hành khai thác
    thongTinDieuHanhKhaiThac.value = data['ThongtinDieuHanhKhaiThac']?.toString() ?? '';

    // Lấy dữ liệu kế hoạch tra nạp trong ngày
    final keHoach = data['Kehoachtranaptrongngay'] as Map<String, dynamic>? ?? {};
    keHoachTraNapTrongNgay.value = keHoach;

    // Lấy dữ liệu tỷ lệ tồn kho sân bay
    final tyLeTonKho = data['Tyletonkhosanbay'] as List? ?? [];
    tyLeTonKhoSanBay.assignAll(tyLeTonKho.cast<Map<String, dynamic>>());

    // Lấy dữ liệu số giờ hoạt động xe sân bay
    final soGioHoatDong = data['Sogiohoatdongxesanbay'] as List? ?? [];
    soGioHoatDongXeSanBay.assignAll(soGioHoatDong.cast<Map<String, dynamic>>());

    // Lấy dữ liệu số giờ hoạt động xe CNDP
    final soGioHoatDongCNDP = data['Sogiohoatdongxecndp'] as List? ?? [];
    soGioHoatDongXeCndp.assignAll(soGioHoatDongCNDP.cast<Map<String, dynamic>>());

    final soGioHD =data['SogiohoatdongxesanbayChart'] as List? ?? [];
    soGioHoatDongXeSanBayChart.assignAll(soGioHD.cast<Map<String, dynamic>>());

    final soGioHDCNDP = data['SogiohoatdongxecndpChart'] as List? ?? [];
    soGioHoatDongXeCndpChart.assignAll(soGioHDCNDP.cast<Map<String, dynamic>>());

  }

  void changeDate(DateTime date) {
    selectedDate.value = date;
    loadData();
  }

  void goToPreviousDay() {
    changeDate(selectedDate.value.subtract(const Duration(days: 1)));
  }

  void goToNextDay() {
    changeDate(selectedDate.value.add(const Duration(days: 1)));
  }

  void goToToday() {
    changeDate(DateTime.now());
  }
}