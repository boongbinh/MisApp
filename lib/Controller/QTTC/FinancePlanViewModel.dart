import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class FinancePlanViewModel extends GetxController {
  // ---------- loading / error ----------
  final loading = false.obs;
  final error = ''.obs;

  // ---------- tháng / năm / sân bay ----------
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;
  String get monthLabel => 'Tháng ${selectedMonth.value}/${selectedYear.value}';

  final selectedAirport = 'Tất cả sân bay'.obs;
  var airportOptions = <String>[];

  void setMonthYear(int m, int y) {
    selectedMonth.value = m;
    selectedYear.value = y;
    update(); // chỉ để đảm bảo rebuild các widget không-bọc-Obx
    loadData();
  }

  void setAirport(String v) {
    selectedAirport.value = v;
    loadData();
  }

  // ---------- thống kê tài chính ----------
  final statsExpanded = true.obs;
  void toggleStats() => statsExpanded.toggle();

  final stats = <FinanceStat>[].obs;

  // ---------- bảng danh sách ----------
  final rows = <FinanceRow>[].obs;

  // cài đặt cột
  final showNgay = true.obs;
  final showLuyKe = true.obs;
  final showThang = true.obs;
  final showLuyKeDenThang = true.obs;
  final showUocTH = true.obs;

  // ---------- public helpers ----------
  String fmt(num? v) {
    if (v == null) return '--';
    final f = NumberFormat('#,##0.##', 'vi_VN');
    return f.format(v);
  }

  String fmtTy(num? v, {int digits = 2, bool showUnit = true}) {
    if (v == null) return '—';
    final n = v / 1e9; // đổi sang Tỷ
    final pattern = digits <= 0 ? '#,##0' : '#,##0.${'0' * digits}';
    final s = NumberFormat(pattern, 'vi_VN').format(n);
    return showUnit ? '$s Tỷ' : s;
  }

  String fmtFinanceCell(int rowIndex, num? v) {
    if (rowIndex == 0) return fmt(v);
    return fmtTy(v, digits: 2, showUnit: true);
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getAirportFilter();
    loadData();
  }

  void loadData() {
    getPriceValue();
    getStatisticValue();
    getTableValue();
  }

  // Các mục cho phép mở trang chi tiết
  final Set<String> drillableNames = {
    'sản lượng',
    'doanh thu',
    'chi phí cố định',
    'chi phí biến đổi',
    'lợi nhuận nhiên liệu',
    'lợi nhuận cutn',
  };

  bool canOpenDetail(FinanceRow r) =>
      drillableNames.contains(r.loai.toLowerCase());

  Future<void> getPriceValue() async {
    
    loading.value = true;
    try {
      var response = await APICaller.getInstance().get(
        "QuanTriTaiChinh/Dongiahangton?thang=$selectedMonth&nam=$selectedYear",
        
      );

      if (response != null) {
        applyPriceResponse(response);
      }
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }

  Future<void> getStatisticValue() async {
    try {
      String airport =
          selectedAirport.value == 'Tất cả sân bay'
              ? 'All'
              : selectedAirport.value;
      var response = await APICaller.getInstance().get(
        "QuanTriTaiChinh/KPI1?thang=$selectedMonth&nam=$selectedYear&sanbay=$airport",
      );
      if (response != null) {
        applyStatsResponse(response);
      }
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }

  Future<void> getTableValue() async {
    try {
      String airport =
          selectedAirport.value == 'Tất cả sân bay'
              ? 'All'
              : selectedAirport.value;

      var response = await APICaller.getInstance().get(
        "QuanTriTaiChinh/Baocaotaichinh?thang=$selectedMonth&nam=$selectedYear&sanbay=$airport",
      );
      if (response != null) {
        final map = jsonDecode(response) as Map<String, dynamic>;
        if (map['ThiPhanSanLuong'] != null) {
          applyTable(map['ThiPhanSanLuong'] as List);
        }
      }
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }

  void applyStatsResponse(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final cs = (map['chiSo'] ?? {}) as Map<String, dynamic>;

      double? d(String k) => (cs[k] as num?)?.toDouble();

      final list = <FinanceStat>[
        FinanceStat('Chi phí biến đổi (đồng/tấn)', d('CPBDTan')),
        FinanceStat('Chi phí cố định (đồng/tấn)', d('CPCDTan')),
        FinanceStat('Lãi trên biến phí (đồng/tấn)', d('LTBPTan')),
        FinanceStat('Sản lượng hoàn vốn (tấn)', d('SLHV')),
        // nếu muốn hiển thị cột _TT thì thêm ở đây
      ];

      stats.addAll(list);
    } catch (e) {
      error.value = 'Lỗi đọc dữ liệu thống kê';
    }
  }

  void applyPriceResponse(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final cs = (map['Dongiahangton'][0] ?? {}) as Map<String, dynamic>;

      double? d(String k) => (cs[k] as num?)?.toDouble();

      final list = <FinanceStat>[
        FinanceStat('Đơn giá hàng tồn (USD/BBL)', d('Platt_TB')),
        FinanceStat('Đơn giá bán (USD/BBL)', d('GiaBan')),
      ];
      stats.clear();
      stats.addAll(list);
    } catch (e) {
      error.value = 'Lỗi đọc dữ liệu thống kê giá';
    }
  }

  void applyTable(List<dynamic> list) {
    // Parse & sort theo STT
    final items =
        list.whereType<Map<String, dynamic>>().toList()..sort(
          (a, b) => ((a['STT'] ?? 0) as num).compareTo((b['STT'] ?? 0) as num),
        );

    // Group theo "Nhom"
    final Map<String, List<Map<String, dynamic>>> byGroup = {};
    for (final m in items) {
      final key = (m['Nhom'] ?? '').toString();
      byGroup.putIfAbsent(key, () => []).add(m);
    }

    // Thứ tự nhóm mong muốn: NHOM1 (Sản lượng), NHOM2 (Doanh thu), NHOM3 (Chi phí), NHOM4 (Lợi nhuận)
    final order = ['NHOM1', 'NHOM2', 'NHOM3', 'NHOM4'];

    final result = <FinanceRow>[];
    for (final g in order) {
      final groupItems = byGroup[g];
      if (groupItems == null || groupItems.isEmpty) continue;

      // Dòng đầu tiên của nhóm làm "tổng" (isParent = true)
      final first = groupItems.first;
      final parent = FinanceRow(
        loai: first['LOAI']?.toString() ?? _groupTitleFallback(g),
        isParent: true,
        expanded: false, // mặc định thu gọn
        ngay: first['Ngay'] as num?,
        luyKe: first['LuyKe'] as num?,
        uocTh: first['UocTH'] as num?,
        thang: first['GiaTri'] as num?,
        luyKeDenThang: first['CaNam'] as num?,
      );

      // Các item còn lại là con
      final children = <FinanceRow>[];
      for (final m in groupItems.skip(1)) {
        children.add(FinanceRow.fromMap(m));
      }
      parent.children.addAll(children);
      result.add(parent);
    }

    rows.assignAll(result);
    loading.value = false;
  }

  String _groupTitleFallback(String key) {
    switch (key) {
      case 'NHOM1':
        return 'Sản lượng';
      case 'NHOM2':
        return 'Doanh thu';
      case 'NHOM3':
        return 'Chi phí';
      case 'NHOM4':
        return 'Lợi nhuận';
      default:
        return 'Nhóm';
    }
  }

  FinanceRow _rowFromMap(Map<String, dynamic> m) {
    double? d(String k) => (m[k] as num?)?.toDouble();

    return FinanceRow(
      loai: m['LOAI']?.toString() ?? '',
      ngay: d('Ngay'),
      luyKe: d('LuyKe'),
      thang: d('CaNam'), // tuỳ nghiệp vụ, hiện map tạm
      luyKeDenThang: d('GiaTri'),
      uocTh: d('UocTH'),
    );
  }

  Future<void> getAirportFilter() async {
    try {
      try {
        var response = await APICaller.getInstance().get("Helper/FilterSanbay");
        if (response != null) {
          airportOptions.clear();
          List<dynamic> decoded = jsonDecode(response);
          airportOptions = decoded.cast<String>();
          airportOptions.insert(0, 'Tất cả sân bay');
        }
      } catch (e) {
        Utils.showSnackBar(title: 'Thông báo', message: '$e');
      }
    } finally {
      //isSubmitting.value = false;
    }
  }

  void openCellDetail(FinanceRow cellValue) {
    if (cellValue.loai.toLowerCase() == 'doanh thu') {
      Get.toNamed(
        Routes.revenuedetail,
        arguments: '$selectedYear-$selectedMonth',
      );
    } else if (cellValue.loai.toLowerCase() == 'chi phí cố định') {
      Get.toNamed(Routes.fixcost, arguments: '$selectedYear-$selectedMonth');
    } else if (cellValue.loai.toLowerCase() == 'chi phí biến đổi') {
      Get.toNamed(Routes.changecost, arguments: '$selectedYear-$selectedMonth');
    } else if (cellValue.loai.toLowerCase() == 'lợi nhuận cutn') {
      Get.toNamed(Routes.cutn, arguments: '$selectedYear-$selectedMonth');
    } else if (cellValue.loai.toLowerCase() == 'lợi nhuận nhiên liệu') {
      Get.toNamed(Routes.fuelprofit, arguments: '$selectedYear-$selectedMonth');
    } else if (cellValue.loai.toLowerCase() == 'sản lượng') {
      Get.toNamed(
        Routes.currentoutput,
        arguments: '$selectedYear-$selectedMonth',
      );
    }
  }

  // ---------- popup cột ----------
  void openColumnSettings() {
    final ctx = Get.context;
    if (ctx == null) return;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ColumnSettingsSheet(vm: this),
    );
  }
}

/* ==================== Models ==================== */

class FinanceStat {
  final String label;
  final double? value;
  FinanceStat(this.label, this.value);
}

class FinanceRow {
  final String loai; // tên hiển thị
  final bool isParent; // dòng tổng (group header)
  final RxBool expanded; // trạng thái expand
  final List<FinanceRow> children; // các dòng con
  final num? ngay; // cột "Ngày"
  final num? luyKe; // cột "Lũy kế"
  final num? uocTh; // cột "Ước thực hiện"
  final num? thang; // cột "Tháng"
  final num? luyKeDenThang; // cột "Lũy kế đến tháng" (map từ CaNam)

  FinanceRow({
    required this.loai,
    this.isParent = false,
    bool expanded = false,
    List<FinanceRow>? children,
    this.ngay,
    this.luyKe,
    this.uocTh,
    this.thang,
    this.luyKeDenThang,
  }) : expanded = RxBool(expanded),
       children = children ?? [];

  /// Tiện ích: tạo FinanceRow từ map thô (dòng con)
  factory FinanceRow.fromMap(Map<String, dynamic> m) {
    num? _n(v) => (v == null) ? null : (v as num);
    return FinanceRow(
      loai: (m['LOAI'] ?? '').toString(),
      ngay: _n(m['Ngay']),
      luyKe: _n(m['LuyKe']),
      uocTh: _n(m['UocTH']),
      thang: _n(m['GiaTri']),
      luyKeDenThang: _n(m['CaNam']), // tạm map sang cột này
    );
  }
}

/* ==================== BottomSheet cột ==================== */

class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({required this.vm});
  final FinancePlanViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Cài đặt hiển thị',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _switch('Ngày', vm.showNgay),
                  _switch('Lũy kế', vm.showLuyKe),
                  _switch('Ước thực hiện', vm.showUocTH),
                  _switch('Tháng', vm.showThang),
                  _switch('Lũy kế đến tháng', vm.showLuyKeDenThang),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            vm.showNgay.value = true;
                            vm.showLuyKe.value = true;
                            vm.showUocTH.value = true;
                            vm.showThang.value = true;
                            vm.showLuyKeDenThang.value = true;
                          },
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Mặc định'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _switch(String title, RxBool bind) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Switch(value: bind.value, onChanged: (v) => bind.value = v),
        ],
      ),
    );
  }
}
