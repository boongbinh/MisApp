import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class Option {
  final String value, label;
  const Option(this.value, this.label);
}

class OutputReportViewModel extends GetxController {
  // ====== header: thống kê ======các biến trạng thái thống kê
  final tongSanLuong = 0.0.obs;
  final sanLuongKeHoach = 0.0.obs;
  final sanLuongUocTh = 0.0.obs;

  final pctSoVoiKeHoach = 0.0.obs;
  final pctThangTruoc = 0.0.obs;
  final sanLuongThangTruoc = 0.0.obs;
  final pctCungKy = 0.0.obs;
  final sanLuongCungKy = 0.0.obs;

  final statsExpanded = true.obs;

  // ====== tabbar ======các biến trạng thái  tùy chọn hiển thị
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

  final RxDouble _maxY = 0.0.obs;
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

  // ====== FILTER STATE (ADD) ======
  final searchCtrl = TextEditingController();

  final RxInt fromMonth = DateTime.now().month.obs;
  final RxInt fromYear = DateTime.now().year.obs;
  final RxInt toMonth = DateTime.now().month.obs;
  final RxInt toYear = DateTime.now().year.obs;

  final RxString khachHangFilter = '0'.obs; // "Tất cả"
  final RxString changBayFilter = 'all'.obs; // "all"
  final RxString version = ''.obs; // ""

  // OPTIONS (ADD)

  final RxList<Option> khachHangOptions = <Option>[].obs;
  final RxList<Option> changBayOptions =
      <Option>[const Option('all', 'Tất cả')].obs;
  final RxList<Option> versionOptions =
      <Option>[const Option('', 'Tất cả')].obs;

  // ====== DỮ LIỆU CƠ CẤU BÁN (ADD) ======
  final RxList<String> khuVucLabel = <String>[].obs;
  final RxList<double> khuVucData = <double>[].obs;
  final RxDouble khuVucSumRx = 0.0.obs;

  final RxList<String> changBayLabel = <String>[].obs;
  final RxList<double> changBayData = <double>[].obs;
  final RxDouble changBaySumRx = 0.0.obs;

  final RxList<String> nhomKhLabel = <String>[].obs;
  final RxList<double> nhomKhData = <double>[].obs;
  final RxDouble nhomKhSumRx = 0.0.obs;

  final RxList<String> sanBayLabel = <String>[].obs;
  final RxList<double> sanBayData = <double>[].obs;
  double sanBaySum = 0;
  double sanBayMax = 0;

  double get khuVucSum =>
      khuVucData.fold<double>(0, (p, e) => p + (e.isNaN ? 0 : e));
  double get changBaySum =>
      changBayData.fold<double>(0, (p, e) => p + (e.isNaN ? 0 : e));

  String timeSelected = '';

  final airports = <String>[].obs; // danh sách sân bay lấy từ API
  final selectedAirports = <String>[].obs; // các mã đã chọn

  String get airportsLabel =>
      selectedAirports.isEmpty ? 'Tất cả' : selectedAirports.join(', ');

  final RxInt filterYear = DateTime.now().year.obs;
  final RxInt filterFromMonth = DateTime.now().month.obs;
  final RxInt filterToMonth = DateTime.now().month.obs;

  void setFilterYear(int y) {
    filterYear.value = y;
    // giữ nguyên tháng; nếu cần bạn có thể clamp theo dữ liệu server
  }

  void setFromMonth(int m) {
    filterFromMonth.value = m;
    if (filterToMonth.value < m) filterToMonth.value = m; // auto clamp
  }

  void setToMonth(int m) {
    filterToMonth.value = m;
    if (filterFromMonth.value > m) filterFromMonth.value = m; // auto clamp
  }

  // đóng gói request khi Apply
  Map<String, dynamic> buildStructurePayload() {
    return {
      "chonnam": filterYear.value.toString(),
      "Chonthang1": filterFromMonth.value.toString(),
      "Chonthang": filterToMonth.value.toString(),
      "sanbayfilter": selectedAirports.toList(), // ví dụ
      "sanbayNNfilter": [],
      "Khachhangfilter": khachHangFilter.value,
      "Changbayfilter": changBayFilter.value,
      "Version": version.value,
    };
  }

  // ====== parse helpers ======
  double _toD(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getAirportFilter();
    getData1();
    getData2();
    getData3();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    ever(unitIndex, (_) => _recomputeMaxY());
  }

//	Lấy KPI thống kê-Tự động trong onReady()
  Future<void> getData1() async {
    try {
      var param = {
        "chonnam": toYear.value.toString(),
        "Chonthang1": fromMonth.value.toString(),
        "Chonthang": toMonth.value.toString(),
        "sanbayfilter": selectedAirports.toList(),
        "sanbayNNfilter": <String>[],
        "Khachhangfilter": khachHangFilter.value,
        "Changbayfilter": changBayFilter.value,
        "Version": version.value,
      };
      final resp = await APICaller.getInstance().post(
        "BaoCaoSanLuong/KPI",
        param,
      );
      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      applyStats(map);
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    } finally {}
  }

//Lấy SL bán theo ngày-Tự động trong onReady()
  Future<void> getData2() async {
    try {
      var param = {
        "chonnam": toYear.value.toString(),
        "Chonthang1": fromMonth.value.toString(),
        "Chonthang": toMonth.value.toString(),
        "sanbayfilter": selectedAirports.toList(),
        "sanbayNNfilter": <String>[],
        "Khachhangfilter": khachHangFilter.value,
        "Changbayfilter": changBayFilter.value,
        "Version": version.value,
      };
      final resp = await APICaller.getInstance().post(
        "BaoCaoSanLuong/SanLuongBanTheoNgay",
        param,
      );

      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      applySales(map);
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }

//Lấy cơ cấu bán-Tự động trong onReady()
  Future<void> getData3() async {
    try {
      var param = {
        "chonnam": toYear.value.toString(),
        "Chonthang1": fromMonth.value.toString(),
        "Chonthang": toMonth.value.toString(),
        "sanbayfilter": selectedAirports.toList(),
        "sanbayNNfilter": <String>[],
        "Khachhangfilter": khachHangFilter.value,
        "Changbayfilter": changBayFilter.value,
        "Version": version.value,
      };
      final resp = await APICaller.getInstance().post(
        "BaoCaoSanLuong/CoCauBan",
        param,
      );
      if (resp == null) return;

      final map = jsonDecode(resp) as Map<String, dynamic>;
      applyStructure(map);
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }

  // ====== public API to apply JSON ======
    // Cập nhật dữ liệu từ API vào các biến trạng thái.
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
    final List raw = (js['data'] as List?) ?? const [];

    final tTan = <double>[];
    final kTan = <double>[];
    final tM3 = <double>[];
    final kM3 = <double>[];
    final labs = <String>[];

    for (final e in raw) {
      final d = DateTime.tryParse((e['VoucherDate'] ?? '').toString());
      labs.add(
        d == null
            ? ''
            : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}',
      );

      tTan.add(_toD(e['Ton']));
      kTan.add(_toD(e['SL_KH']));
      tM3.add(_toD(e['m3']));
      kM3.add(_toD(e['KH_m3']));
    }

    thucTeTan.assignAll(tTan);
    keHoachTan.assignAll(kTan);
    thucTeM3.assignAll(tM3);
    keHoachM3.assignAll(kM3);
    labelDays.assignAll(labs);

    _recomputeMaxY();
  }

  void applyStructure(Map<String, dynamic> json) {
    List<double> _toD(List a) =>
        a.map((e) => (e as num?)?.toDouble() ?? 0.0).toList();
    List<String> _toS(List a) => a.map((e) => e?.toString() ?? '').toList();

    nhomKhData.assignAll(_toD(json["DataNhomKh"] ?? []));
    nhomKhLabel.assignAll(_toS(json["LabelNhomKh"] ?? []));
    nhomKhSumRx.value = nhomKhData.fold(0.0, (p, e) => p + e);

    changBayData.assignAll(_toD(json["DataChangBay"] ?? []));
    changBayLabel.assignAll(_toS(json["LabelChangBay"] ?? []));
    changBaySumRx.value = changBayData.fold(0.0, (p, e) => p + e);

    khuVucData.assignAll(_toD(json["DataKhuVuc"] ?? []));
    khuVucLabel.assignAll(_toS(json["LabelKhuVuc"] ?? []));
    khuVucSumRx.value = khuVucData.fold(0.0, (p, e) => p + e);

    sanBayLabel.value = List<String>.from(json['LabelSanBay'] ?? const []);
    sanBayData.value =
        (json['DataSanBay'] as List? ?? [])
            .map((e) => (e as num).toDouble())
            .toList();
    sanBaySum = sanBayData.fold(0.0, (p, e) => p + e);
    sanBayMax = sanBayData.fold<double>(0.0, (p, e) => e > p ? e : p);
  }

  void onSearchAirport(String code) {
    code.toUpperCase();
    if (code.isNotEmpty && airports.contains(code)) {
      selectedAirports.clear();
      selectedAirports.add(code);
    }
    applyFilters();
  }

  Future<void> applyFilters() async {
    // final demo = {
    //   "chonnam": toYear.value.toString(),
    //   "Chonthang1": fromMonth.value.toString(),
    //   "Chonthang": toMonth.value.toString(),
    //   "sanbayfilter": selectedAirports.toList(),
    //   "sanbayNNfilter": <String>[],
    //   "Khachhangfilter": khachHangFilter.value,
    //   "Changbayfilter": changBayFilter.value,
    //   "Version": version.value,
    // };
    getData1();
    getData2();
    getData3();
  }

  void resetFilters() {
    fromMonth.value = DateTime.now().month;
    fromYear.value = DateTime.now().year;
    toMonth.value = DateTime.now().month;
    toYear.value = DateTime.now().year;

    khachHangFilter.value = '0';
    changBayFilter.value = 'all';
    version.value = '';
    selectedAirports.clear();
  }

  Future<void> getAirportFilter() async {
    try {
      try {
        var response = await APICaller.getInstance().get("Helper/FilterSanbay");
        if (response != null) {
          airports.clear();
          List<dynamic> decoded = jsonDecode(response);
          airports.value = decoded.cast<String>();
        }
      } catch (e) {
        Utils.showSnackBar(title: 'Thông báo', message: '$e');
      }
    } finally {
      //isSubmitting.value = false;
    }
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

  Future<void> ensureFilterOptionsLoaded() async {
    if (khachHangOptions.isNotEmpty) return;
    // -- Nhóm KH (sample từ response bạn đưa)
    khachHangOptions.assignAll([
      const Option('0', 'Tất cả'),
      const Option('1', 'Hàng không nước ngoài'),
      const Option('2', 'VNA Group'),
      const Option('4', 'Bán tại nước ngoài'),
      const Option('3', 'Khác'),
    ]);

    // -- Chặng bay (demo 2 mục)
    changBayOptions.assignAll(const [
      Option('all', 'Tất cả'),
      Option('ND', 'Nội địa'),
      Option('QT', 'Quốc tế'),
    ]);

    // -- Phiên bản (map từ response)
    versionOptions.assignAll([
      const Option('', 'Tất cả'),
      // ... có thể map từ API thực tế
      const Option('KHDH3.5', 'KHDH3.5 (10/2025-16/10/2025)'),
      const Option('KHDH3.4', 'KHDH3.4 (09/2025-25/09/2025)'),
    ]);
  }

  Future<(int, int)?> pickYearMonth(
    BuildContext ctx,
    int year,
    int month,
  ) async {
    // đơn giản: showDatePicker rồi lấy year/month
    final d = await showDatePicker(
      context: ctx,
      initialDate: DateTime(year, month, 1),
      firstDate: DateTime(DateTime.now().year - 3, 1, 1),
      lastDate: DateTime(DateTime.now().year + 3, 12, 31),
      helpText: 'Chọn tháng',
    );
    if (d == null) return null;
    return (d.year, d.month);
  }

  void _recomputeMaxY() {
    final a = unitIndex.value == 0 ? thucTeTan : thucTeM3;
    final b = unitIndex.value == 0 ? keHoachTan : keHoachM3;

    double m = 0;
    for (final v in a) if (v > m) m = v;
    for (final v in b) if (v > m) m = v;

    // thêm headroom 15%
    _maxY.value = m <= 0 ? 1.0 : (m * 1.15);
  }

  String pct(num v) => '${v.toStringAsFixed(1)}%';
}
