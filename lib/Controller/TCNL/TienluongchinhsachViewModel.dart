import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';
import 'package:skypec/components/TCNL/TienLuongChinhSach/TylequyluongCard.dart';


class Option {
  final String value, label;
  final String? companyCode;
  const Option(this.value, this.label, {this.companyCode});
}

class TienluongchinhsachViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Filter State ======
  final RxInt fromMonth = 1.obs;
  final RxInt fromYear = DateTime.now().year.obs;
  final RxInt toMonth = DateTime.now().month.obs;
  final RxInt toYear = DateTime.now().year.obs;

  final RxList<String> selectedChinhanh = <String>[].obs;
  final RxList<String> selectedChucDanh = <String>[].obs;
  final RxList<String> selectedBoPhan = <String>[].obs;

  // Filter tạm cho sheet
  final RxInt filterFromMonth = 1.obs;
  final RxInt filterToMonth = DateTime.now().month.obs;
  final RxInt filterYear = DateTime.now().year.obs;
  final RxList<String> filterChinhanh = <String>[].obs;
  final RxList<String> filterChucDanh = <String>[].obs;
  final RxList<String> filterBoPhan = <String>[].obs;

  // ====== Options ======
  final chinhanhOptions = <Option>[].obs;
  final chucDanhOptions = <Option>[].obs;
  final boPhanOptions = <Option>[].obs;

  // ====== Filtered Options (theo chi nhánh đã chọn) ======
  final filteredChucDanhOptions = <Option>[].obs;
  final filteredBoPhanOptions = <Option>[].obs;

  // ====== Search ======
  final searchCtrl = TextEditingController();
  final allFilterOptions = <Option>[].obs;

  // ====== Dữ liệu từ API ======
  final luongBQNamNay = 0.0.obs;
  final luongBQKH = 0.0.obs;
  final soSanhLuongBQKH = 0.0.obs;
  final luongBQNamTruoc = 0.0.obs;
  final soSanhLuongBQNamTrc = 0.0.obs;
  final daChiNamNay = 0.0.obs;
  final quyLuongKH = 0.0.obs;
  final soSanhQuyLuongKH = 0.0.obs;
  final daChiNamTruoc = 0.0.obs;
  final soSanhQuyLuongNamTruoc = 0.0.obs;


  // ====== Getter ======
  String get periodLabel => 'Tháng ${fromMonth.value}/${fromYear.value}';
  String get chinhanhLabel => filterChinhanh.isEmpty ? 'Chi nhánh' : '${filterChinhanh.length} mục';
  String get chucDanhLabel => filterChucDanh.isEmpty ? 'Chức danh' : '${filterChucDanh.length} mục';
  String get boPhanLabel => filterBoPhan.isEmpty ? 'Bộ phận' : '${filterBoPhan.length} mục';

  final tylequyluongiDataList = <TylequyluongData>[].obs;


  // ====== Khởi tạo ======
  @override
  void onReady() {
    super.onReady();
    loadFilterOptions();
    loadData();
  }

  @override
  void onInit() {
    super.onInit();
    // ⭐ Lắng nghe khi filterChinhanh thay đổi
    ever(filterChinhanh, (_) {
      updateFilteredOptions();
    });
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  // ====== Cập nhật options đã filter ======
  void updateFilteredOptions() {

    if (filterChinhanh.isEmpty) {
      filteredChucDanhOptions.assignAll(chucDanhOptions);
      filteredBoPhanOptions.assignAll(boPhanOptions);
    } else {
      final codes = filterChinhanh.toSet();
      
      // Filter chức danh
      final filteredChucDanh = chucDanhOptions.where((opt) {
        final match = opt.companyCode == null || codes.contains(opt.companyCode);
        return match;
      }).toList();
      
      // Filter bộ phận
      final filteredBoPhan = boPhanOptions.where((opt) {
        final match = opt.companyCode == null || codes.contains(opt.companyCode);
        return match;
      }).toList();

      filteredChucDanhOptions.assignAll(filteredChucDanh);
      filteredBoPhanOptions.assignAll(filteredBoPhan);
    }

  }

  // ====== Lọc options ======
  Future<void> loadFilterOptions() async {
    try {
      
      // 1. Chi nhánh (hardcode)
      chinhanhOptions.assignAll([
        const Option('CQCT', 'Cơ Quan Công Ty', companyCode: 'CQCT'),
        const Option('CNMB', 'CN Miền Bắc', companyCode: 'CNMB'),
        const Option('CNMT', 'CN Miền Trung', companyCode: 'CNMT'),
        const Option('CNMN', 'CN Miền Nam', companyCode: 'CNMN'),
        const Option('CNVT', 'CN Vận Tải', companyCode: 'CNVT'),
      ]);

      // 2. Chức danh
      var resp = await APICaller.getInstance().get("Helper/FilterChucdanhtlcs");
      if (resp != null) {
        List<dynamic> list = jsonDecode(resp);
        chucDanhOptions.assignAll(list.map((e) => Option(
          e['EmployeeType']?.toString() ?? '',
          e['EmployeeType']?.toString() ?? '',
          companyCode: e['CompanyCode']?.toString(),
        )));
        chucDanhOptions.insert(0, const Option('', 'Tất cả', companyCode: null));
      }

      // 3. Bộ phận
      resp = await APICaller.getInstance().get("Helper/FilterPhongbandoi");
      if (resp != null) {
        List<dynamic> list = jsonDecode(resp);
        boPhanOptions.assignAll(list.map((e) => Option(
          e['BP']?.toString() ?? '',
          e['BP']?.toString() ?? '',
          companyCode: e['DV']?.toString(),
        )));
        boPhanOptions.insert(0, const Option('', 'Tất cả', companyCode: null));
      }

      // Khởi tạo filtered options
      updateFilteredOptions();

      // Gộp tất cả options cho search
      _updateAllFilterOptions();
      
    } catch (e) {
      Utils.showSnackBar(title: 'Lỗi', message: 'Không thể tải danh sách filter');
    }
  }

  void _updateAllFilterOptions() {
    allFilterOptions.assignAll([
      ...chinhanhOptions,
      ...chucDanhOptions,
      ...boPhanOptions,
    ]);
  }

  // ====== Gọi API ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "nam": toYear.value.toString(),
        "tuthang": fromMonth.value.toString(),
        "denthang": toMonth.value.toString(),
        "chinhanh": selectedChinhanh.toList(),
        "chucdanh": selectedChucDanh.toList(),
        "bophan": selectedBoPhan.toList(),
      };


      final response = await APICaller.getInstance().post(
        "TCNL/ThongTinQuanTriTCNL/Tienluongchinhsach",
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

  // ====== Parse dữ liệu ======
  void applyData(Map<String, dynamic> data) {


    final kpi = data['TLCS_Tao_KPILuong'] as Map<String, dynamic>?;

    if (kpi != null) {
    // ⭐ Parse trực tiếp từ Object
    luongBQNamNay.value = _parseDouble(kpi['LuongBQNamNay']);
    luongBQKH.value = _parseDouble(kpi['LuongBQKH']);
    soSanhLuongBQKH.value = _parseDouble(kpi['SoSanhLuongBQKH']);
    luongBQNamTruoc.value = _parseDouble(kpi['LuongBQNamTruoc']);
    soSanhLuongBQNamTrc.value = _parseDouble(kpi['SoSanhLuongBQNamTrc']);
    daChiNamNay.value = _parseDouble(kpi['DaChiNamNay']);
    quyLuongKH.value = _parseDouble(kpi['QuyLuongKH']);
    soSanhQuyLuongKH.value = _parseDouble(kpi['SoSanhQuyLuongKH']);
    daChiNamTruoc.value = _parseDouble(kpi['DaChiNamTruoc']);
    soSanhQuyLuongNamTruoc.value = _parseDouble(kpi['SoSanhQuyLuongNamTruoc']);
      
    }

    // 5. TỶ LỆ QUỸ LƯƠNG
  final tylequyluongList = data['TLCS_TaoChartQuyTienLuong'] as List? ?? [];
  
  print(tylequyluongList);
  final List<TylequyluongData> tylequyluongResult = [];
  final List<Color> colorPalette = [
    Colors.blue.shade700,  Colors.green.shade700,Colors.orange.shade700,Colors.purple.shade700,Colors.red.shade700,     // Đỏ
    Colors.pink.shade700,    // Hồng
    Colors.teal.shade700,    // Xanh ngọc
    Colors.amber.shade700,   // Vàng
    Colors.indigo.shade700,  // Chàm
    Colors.cyan.shade700,    // Xanh lơ
    Colors.lime.shade700,    // Xanh chanh
    Colors.brown.shade700,   // Nâu
    Colors.deepPurple.shade700,  // Tím đậm
    Colors.lightBlue.shade700,   // Xanh dương nhạt
    Colors.deepOrange.shade700,  // Cam đậm
  ];

Color getColorByIndex(int index) {
  return colorPalette[index % colorPalette.length];
}

// ⭐ Dùng forEach với index
tylequyluongList.asMap().forEach((index, item) {
  if (item is Map) {
    final label = item['CODE_DV']?.toString() ?? 'Khác';
    final value = _parseDouble(item['Quy_TienLuong']);
    if (value > 0) {
      tylequyluongResult.add(TylequyluongData(
        label: label,
        value: value,
        color: getColorByIndex(index), // ⭐ Dùng index từ asMap()
      ));
    }
  }
});

tylequyluongiDataList.assignAll(tylequyluongResult);
    
    
  }

  //hàm parse double từ dynamic, xử lý cả trường hợp null, int, double, String
  double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final cleaned = value.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }
  return 0.0;
}

  // ====== Search ======
  void onSearchSelected(Option selected) {
    
    if (chinhanhOptions.contains(selected)) {
      filterChinhanh.assignAll([selected.value]);
    } else if (chucDanhOptions.contains(selected)) {
      filterChucDanh.assignAll([selected.value]);
    } else if (boPhanOptions.contains(selected)) {
      filterBoPhan.assignAll([selected.value]);
    }
    applyFilters();
  }

  // ====== Filter functions ======
  void setFilterYear(int y) {
    filterYear.value = y;
  }
  
  void setFromMonth(int m) {
    filterFromMonth.value = m;
    if (filterToMonth.value < m) filterToMonth.value = m;
  }
  
  void setToMonth(int m) {
    filterToMonth.value = m;
    if (filterFromMonth.value > m) filterFromMonth.value = m;
  }

  Future<void> applyFilters() async {
    
    fromMonth.value = filterFromMonth.value;
    toMonth.value = filterToMonth.value;
    toYear.value = filterYear.value;
    selectedChinhanh.assignAll(filterChinhanh);
    selectedChucDanh.assignAll(filterChucDanh);
    selectedBoPhan.assignAll(filterBoPhan);
    
    // ⭐ Cập nhật filtered options sau khi áp dụng filter
    updateFilteredOptions();
    
    await loadData();
  }

  void resetFilters() {
    final now = DateTime.now();
    filterFromMonth.value = 1;
    filterToMonth.value = now.month;
    filterYear.value = now.year;
    filterChinhanh.clear();
    filterChucDanh.clear();
    filterBoPhan.clear();
    
    // ⭐ Cập nhật filtered options sau khi reset
    updateFilteredOptions();
  }

  // ====== Helper ======
  String fmt(num v) {
    if (v == null) return '0';
    if (v >= 1e9) {
      return NumberFormat('#,###.##', 'vi_VN').format(v / 1e9) + ' Tỷ';
    } else if (v >= 1e6) {
      return NumberFormat('#,###', 'vi_VN').format(v / 1e6) + ' Triệu';
    }
    return NumberFormat('#,###', 'vi_VN').format(v)+ ' Tỷ';
  }

  String fmtNumber(num v) {
    if (v == null) return '0';
    return NumberFormat('#,###', 'vi_VN').format(v);
  }

  String pct(num v) => '${(v * 100).toStringAsFixed(1)}%';
}