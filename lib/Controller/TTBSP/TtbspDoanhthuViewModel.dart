import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

import 'package:skypec/components/TTBSP/Doanhthu/DoanhthuKhCard.dart';
import 'package:skypec/components/TTBSP/Doanhthu/DoanhthuCacthangCard.dart';
import 'package:skypec/components/TTBSP/Doanhthu/CocauDoanhthuCard.dart';

class Option {
  final String value, label;
  const Option(this.value, this.label);
}

class KhachhangOption {
  final String value;   // ObjectID_1 (label hiển thị)
  final String label;   // ObjectID_1 (giống value)
  final String group;   // ObjectID (HKNN hoặc HKTN)
  KhachhangOption(this.value, this.label, this.group);
}

class TtbspDoanhthuViewModel extends GetxController {
  // ====== trạng thái loading / error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu cho Donut "Cơ cấu doanh thu" ======
  final cocauLabels = <String>[].obs;
  final cocauValues = <double>[].obs;
  final cocauColors = <Color>[].obs;
  final cocauTotal = 0.0.obs;

  // ====== Dữ liệu cho Donut "Doanh thu theo KH" ======
  final doanhthuKhLabels = <String>[].obs;
  final doanhthuKhValues = <double>[].obs;
  final doanhthuKhColors = <Color>[].obs;
  final doanhthuKhTotal = 0.0.obs;

  // ====== Dữ liệu cho Bar chart "Doanh thu qua các tháng" ======
  final monthlyNN = <double>[].obs;
  final monthlyTN = <double>[].obs;
  final months = <String>[].obs;

  // ====== Dữ liệu cho các card chi tiết ======
  final chiTietItems = <Map<String, dynamic>>[].obs;

  // ====== FILTER STATE ======
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxString selectedSanbay = 'All'.obs;
  final RxList<String> selectedKH = <String>[].obs;
  final RxString selectedNhomKH = 'All'.obs;
  final RxString selectedDonViTien = 'VND'.obs;

  final RxInt filterYear = DateTime.now().year.obs;
  final RxInt filterMonth = DateTime.now().month.obs;
  final RxString filterSanbay = 'All'.obs;
  final RxList<String> filterKH = <String>[].obs;
  final RxString filterNhomKH = 'All'.obs;
  final RxString filterDonViTien = 'VND'.obs;

  // Options
  final sanbayOptions = <Option>[].obs;
  final khOptions = <Option>[].obs;
  final nhomkhOptions = <Option>[].obs;
  final donvitienOptions = <Option>[].obs;

  final khRawOptions = <KhachhangOption>[].obs; // lưu gốc
final filteredKhOptions = <KhachhangOption>[].obs; // đã lọc theo nhóm

  // Search
  final searchCtrl = TextEditingController();
  final allFilterOptions = <Option>[].obs;

  final _monthlyRawData = <Map<String, dynamic>>[].obs; // lưu raw data từ API


  // ====== Getter hiển thị label ======
  String get periodLabel => 'Tháng ${selectedMonth.value}/${selectedYear.value}';
  String get sanbayLabel => filterSanbay.value;
  String get khLabel => filterKH.isEmpty ? 'KH' : '${filterKH.length} mục';
  String get nhomkhLabel => filterNhomKH.value == 'All' ? 'Nhóm KH' : filterNhomKH.value;
  String get donvitienLabel => filterDonViTien.value;

  @override
  void onReady() {
    super.onReady();
    loadFilterOptions();
    loadData();
  }

  Future<void> loadFilterOptions() async {
    try {
      var resp = await APICaller.getInstance().get("Helper/FilterSanbayDn");
      if (resp != null) {
        List<dynamic> list = jsonDecode(resp);
        sanbayOptions.assignAll(list.map((e) => Option(e.toString(), e.toString())));
        sanbayOptions.insert(0, const Option('All', 'Tất cả'));
      } else {
        sanbayOptions.assignAll([const Option('All', 'Tất cả')]);
      }

    resp = await APICaller.getInstance().get("Helper/FilterKhachhang");
    if (resp != null) {
      List<dynamic> list = jsonDecode(resp);
      khRawOptions.assignAll(list.map((e) => KhachhangOption(
        e['ObjectID_1'].toString(),
        e['ObjectID_1'].toString(),
        e['ObjectID'].toString()
      )));
      _filterKhOptionsByNhom(selectedNhomKH.value);
    }

      nhomkhOptions.assignAll([
        const Option('All', 'All'),
        const Option('HKNN', 'HKNN'),
        const Option('HKTN', 'HKTN'),
      ]);

      khOptions.assignAll(khRawOptions.map((e) => Option(e.value, e.label))); // chuyển sang Option cho search


      donvitienOptions.assignAll([
        const Option('VND', 'VND'),
        const Option('USD', 'USD'),
      ]);

      allFilterOptions.assignAll([
        ...sanbayOptions,
        ...khOptions,
        ...nhomkhOptions,
        ...donvitienOptions,
      ]);
    } catch (e) {
      Utils.showSnackBar(title: 'Lỗi', message: 'Không thể tải danh sách filter');
    }
  }

//hàm lọc Kh theo nhóm
void _filterKhOptionsByNhom(String nhom) {
  if (nhom == 'All') {
    filteredKhOptions.assignAll(khRawOptions);
  } else {
    filteredKhOptions.assignAll(khRawOptions.where((opt) => opt.group == nhom).toList());
  }
}

// Theo dõi selectedNhomKH thay đổi
@override
void onInit() {
  super.onInit();
  ever(filterNhomKH, (nhom) {
    _filterKhOptionsByNhom(nhom);
    filterKH.clear(); // reset khi nhóm thay đổi
  });
}


List<CocauDoanhthuData> get cocauDataList {
  return List.generate(cocauLabels.length, (i) => CocauDoanhthuData(
    label: cocauLabels[i],
    value: cocauValues[i],
    color: cocauColors[i],
  ));
}

List<DoanhthuKhData> get doanhthuKhDataList {
  return List.generate(doanhthuKhLabels.length, (i) => DoanhthuKhData(
    label: doanhthuKhLabels[i],
    value: doanhthuKhValues[i],
    color: doanhthuKhColors[i],
  ));
}

List<Map<String, dynamic>> get monthlyRevenueData {
  final suffix = selectedDonViTien.value == 'VND' ? '_VND' : '_USD';
  final sorted = _monthlyRawData.toList()..sort((a,b) => (a['TranMonth'] as int).compareTo(b['TranMonth'] as int));
  return sorted.map((item) {
    return {
      'month': item['TranMonth'],
      'nn': item['DOANHTHUTONG_NN$suffix'] ?? 0.0,
      'tn': item['DOANHTHUTONG_TN$suffix'] ?? 0.0,
    };
  }).toList();
}

  void onSearchSelected(Option selected) {
    if (sanbayOptions.contains(selected)) filterSanbay.value = selected.value;
    else if (khOptions.contains(selected)) filterKH.assignAll([selected.value]);
    else if (nhomkhOptions.contains(selected)) filterNhomKH.value = selected.value;
    else if (donvitienOptions.contains(selected)) filterDonViTien.value = selected.value;
    applyFilters();
  }

  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "nam": selectedYear.value.toString(),
        "thang": selectedMonth.value.toString(),
        "sanbay": selectedSanbay.value,
        "kh": selectedKH.toList(),
        "nhomkh": selectedNhomKH.value,
        "donvitien": selectedDonViTien.value,
      };
      final response = await APICaller.getInstance().post("TTBSP/Doanhthu/Doanhthu", payload);
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
    final donVi = selectedDonViTien.value;
    final suffix = donVi == 'VND' ? '_VND' : '_USD';

    // 1. Cơ cấu doanh thu
    final cocauList = data['dataDoanhThuCoCauAll'] as List? ?? [];
    cocauLabels.clear();
    cocauValues.clear();
    double total = 0;
    for (var item in cocauList) {
      String label = item['CoCau'] ?? '';
      double value = (item['DoanhThu'] as num?)?.toDouble() ?? 0;
      cocauLabels.add(label);
      cocauValues.add(value);
      total += value;
    }
    cocauTotal.value = total;
    final colorMap = {
      'Dịch vụ': const Color(0xFF003366),
      'Nhiên liệu': const Color(0xFFFDC003),
      'Tra nạp ngầm': const Color(0xFF001E40),
      'Thuế nhập khẩu': const Color(0xFF34A853),
      'Thuế môi trường': const Color(0xFFEA4335),
      'Thuế VAT': const Color(0xFFFBBC05),
    };
    cocauColors.assignAll(cocauLabels.map((l) => colorMap[l] ?? Colors.grey).toList());

    // 2. Doanh thu theo KH
    final khList = data['DoanhthutheoKh'] as List? ?? [];
    doanhthuKhLabels.clear();
    doanhthuKhValues.clear();
    double khTotal = 0;
    for (var item in khList) {
      if (item is List && item.length == 2) {
        String label = item[0] ?? '';
        Map<String, dynamic> values = item[1] ?? {};
        double value = ((values['DOANHTHUTONG$suffix'] as num?)?.toDouble() ?? 0) / 1e9;        
        doanhthuKhLabels.add(label);
        doanhthuKhValues.add(value);
        khTotal += value;
      }
    }
    doanhthuKhTotal.value = khTotal;
    doanhthuKhColors.assignAll([const Color(0xFF003366), const Color(0xFFFDC003)]);

    // 3. Doanh thu các tháng
    final thangList = data['DoanhthutheoThang'] as List? ?? [];
    _monthlyRawData.assignAll(thangList.cast<Map<String, dynamic>>());

    monthlyNN.clear();
    monthlyTN.clear();
    months.clear();
    for (var item in thangList) {
      int thang = item['TranMonth'] ?? 0;
      double nn = (item['DOANHTHUTONG_NN$suffix'] as num?)?.toDouble() ?? 0.0;
      double tn = (item['DOANHTHUTONG_TN$suffix'] as num?)?.toDouble() ?? 0.0;
      monthlyNN.add(nn);
      monthlyTN.add(tn);
      months.add(DateFormat('MMM').format(DateTime(2020, thang, 1)).toUpperCase());
    }

    // 4. Chi tiết doanh thu
    final chiTiet = data['ChitietDoanhThuTongHop'] as Map<String, dynamic>? ?? {};
    final categories = [
      {'key': 'DichVu', 'title': 'Dịch vụ', 'icon': Icons.payments, 'bgColor': const Color(0xFF003366), 'textColor': Colors.white},
      {'key': 'NhienLieu', 'title': 'Nhiên liệu', 'icon': Icons.local_gas_station, 'bgColor': const Color(0xFFFDC003), 'textColor': const Color(0xFF001E40)},
      {'key': 'Tranapngam', 'title': 'Tra nạp ngầm', 'icon': Icons.engineering, 'bgColor': const Color(0xFF003366), 'textColor': Colors.white},
      {'key': 'ThueNK', 'title': 'Thuế nhập khẩu', 'icon': Icons.import_export, 'bgColor': const Color(0xFFFDC003), 'textColor': const Color(0xFF001E40)},
      {'key': 'ThueMT', 'title': 'Thuế môi trường', 'icon': Icons.eco, 'bgColor': const Color(0xFF003366), 'textColor': Colors.white},
      {'key': 'VAT', 'title': 'Thuế VAT', 'icon': Icons.receipt, 'bgColor': const Color(0xFFFDC003), 'textColor': const Color(0xFF001E40)},
    ];
    chiTietItems.clear();
    for (var cat in categories) {
      final key = cat['key'] as String;
      double hknn = (chiTiet['${key}_VND_HKNN'] as num?)?.toDouble() ?? 0;
      double hktn = (chiTiet['${key}_VND_HKTN'] as num?)?.toDouble() ?? 0;
      if (donVi == 'USD') {
        hknn = (chiTiet['${key}_USD_HKNN'] as num?)?.toDouble() ?? 0;
        hktn = (chiTiet['${key}_USD_HKTN'] as num?)?.toDouble() ?? 0;
      }
      chiTietItems.add({
        'title': cat['title'],
        'icon': cat['icon'],
        'bgColor': cat['bgColor'],
        'textColor': cat['textColor'],
        'hknn': hknn,
        'hktn': hktn,
        'total': hknn + hktn,
      });
    }
  }



  void setFilterYear(int y) => filterYear.value = y;
  void setFilterMonth(int m) => filterMonth.value = m;
  void setFilterSanbay(String v) => filterSanbay.value = v;
  void setFilterKH(List<String> v) => filterKH.assignAll(v);
  void setFilterNhomKH(String v) => filterNhomKH.value = v;
  void setFilterDonViTien(String v) => filterDonViTien.value = v;

  Future<void> applyFilters() async {
    selectedYear.value = filterYear.value;
    selectedMonth.value = filterMonth.value;
    selectedSanbay.value = filterSanbay.value;
    selectedKH.assignAll(filterKH);
        print(filterKH);

    selectedNhomKH.value = filterNhomKH.value;
    selectedDonViTien.value = filterDonViTien.value;
    await loadData();
  }

  void resetFilters() {
    final now = DateTime.now();
    filterYear.value = now.year;
    filterMonth.value = now.month;
    filterSanbay.value = 'All';
    filterKH.clear();
    filterNhomKH.value = 'All';
    filterDonViTien.value = 'VND';
  }

  String fmt(num v) {
    if (v == null) return '0';
    if (v >= 1e9) return NumberFormat('#,###.##', 'vi_VN').format(v / 1e9) + ' tỷ';
    return NumberFormat('#,###', 'vi_VN').format(v);
  }
}