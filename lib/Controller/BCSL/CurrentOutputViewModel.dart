import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class CurrentOutputViewModel extends GetxController {
  // ====== header: thống kê ======
  final tongSanLuong = 0.0.obs;
  final sanLuongKeHoach = 0.0.obs;
  final sanLuongUocTh = 0.0.obs;

  final pctSoVoiKeHoach = 0.0.obs;
  final pctThangTruoc = 0.0.obs;
  final sanLuongThangTruoc = 0.0.obs;
  final pctCungKy = 0.0.obs;
  final sanLuongCungKy = 0.0.obs;

  final statsExpanded = true.obs;

  // ====== tabbar ======
  final tabIndex = 0.obs; // 0: SL bán, 1: Cơ cấu bán

  // ====== tab 1: Sản lượng bán ======
  final unitIndex = 0.obs; // 0: Tấn, 1: M3
  final showThucTe = true.obs;
  final showKeHoach = true.obs;

  final labelDays = <String>[].obs;

  // data Tấn
  final thucTeTan = <double>[].obs;
  final keHoachTan = <double>[].obs;
  double nguongTan = 0;

  // data M3
  final thucTeM3 = <double>[].obs;
  final keHoachM3 = <double>[].obs;
  double nguongM3 = 0;

  double get maxYBar {
    final a = unitIndex.value == 0 ? thucTeTan : thucTeM3;
    final b = unitIndex.value == 0 ? keHoachTan : keHoachM3;
    final m = ([
      ...a,
      ...b,
      unitIndex.value == 0 ? nguongTan : nguongM3,
    ].where((e) => e != null)).fold<double>(0, (p, e) => e > p ? e : p);
    // dư 12% cho đẹp
    return (m * 1.12);
  }

  // ====== tab 2: Cơ cấu bán ======
  // chip con để chọn chart
  final ccIndex = 0.obs; // 0: khu vực, 1: chặng bay

  final khuVucLabel = <String>[].obs;
  final khuVucData = <double>[].obs;

  final changBayLabel = <String>[].obs;
  final changBayData = <double>[].obs;

  double get khuVucSum =>
      khuVucData.fold<double>(0, (p, e) => p + (e.isNaN ? 0 : e));
  double get changBaySum =>
      changBayData.fold<double>(0, (p, e) => p + (e.isNaN ? 0 : e));

  String timeSelected = '';

  // ====== parse helpers ======
  List<double> _toD(List src) => src
      .map<double>((e) {
        if (e == null) return 0.0;
        if (e is num) return e.toDouble();
        final s = e.toString();
        return double.tryParse(s) ?? 0.0;
      })
      .toList(growable: false);

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    timeSelected = Get.arguments;
    getData1();
    getData2();
    getData3();
  }

  Future<void> getData1() async {
    try {
      final resp = await APICaller.getInstance().get(
        "QuanTriTaiChinh/ThongtinchitietSanluong/KPI2?time=$timeSelected&sanbay=ALL",
      );
      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      applyStats(map);
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    } finally {}
  }

  Future<void> getData2() async {
    try {
      final resp = await APICaller.getInstance().get(
        "QuanTriTaiChinh/ThongtinchitietSanluong/SanLuongBanTheoNgay?time=$timeSelected&sanbay=ALL",
      );
      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      applySales(map);
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }

  Future<void> getData3() async {
    try {
      final resp = await APICaller.getInstance().get(
        "QuanTriTaiChinh/ThongtinchitietSanluong/SanLuongTheoKhuVucChangBay?time=$timeSelected&sanbay=ALL",
      );
      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      applyStructure(map);
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }

  // ====== public API to apply JSON ======

  void applyStats(Map<String, dynamic> js) {
    tongSanLuong.value = (js['TongSanLuong'] ?? 0).toDouble();
    sanLuongKeHoach.value = (js['SanluonhKeHoach'] ?? 0).toDouble();
    sanLuongUocTh.value = (js['SanLuongUocThucHien'] ?? 0).toDouble();

    pctSoVoiKeHoach.value = (js['Phan100SoVoiKeHoach'] ?? 0).toDouble();

    pctThangTruoc.value = (js['Phan100SanLuongThangTruoc'] ?? 0).toDouble();
    sanLuongThangTruoc.value = (js['SanLuongThangTruoc'] ?? 0).toDouble();

    pctCungKy.value = (js['Phan100SanLuongCungKy'] ?? 0).toDouble();
    sanLuongCungKy.value = (js['SanLuongCungKy'] ?? 0).toDouble();
  }

  void applySales(Map<String, dynamic> js) {
    thucTeTan.assignAll(_toD(js['ThucTeTan'] ?? []));
    keHoachTan.assignAll(_toD(js['KeHoachTan'] ?? []));
    nguongTan = (js['NguongTan'] ?? 0).toDouble();

    thucTeM3.assignAll(_toD(js['ThucTeM3'] ?? []));
    keHoachM3.assignAll(_toD(js['KeHoachM3'] ?? []));
    nguongM3 = (js['NguongM3'] ?? 0).toDouble();

    labelDays.assignAll((js['Lable'] as List? ?? []).map((e) => '$e'));
  }

  void applyStructure(Map<String, dynamic> js) {
    khuVucLabel.assignAll((js['KhuVucLabel'] as List? ?? []).map((e) => '$e'));
    khuVucData.assignAll(_toD(js['KhuVucData'] ?? []));

    changBayLabel.assignAll(
      (js['ChangBayLabel'] as List? ?? []).map((e) => '$e'),
    );
    changBayData.assignAll(_toD(js['ChangBayData'] ?? []));
  }

  // convenience
  String fmt(num v) {
    final n = v is double ? v : v.toDouble();
    return n
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => '.',
        ); // 12.345
  }

  String pct(num v) => '${v.toStringAsFixed(1)}%';
}
