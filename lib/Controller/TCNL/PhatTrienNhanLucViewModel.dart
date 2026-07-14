import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class Option {
  final String value, label;
  final String? companyCode; // thêm companyCode
  const Option(this.value, this.label, {this.companyCode});
}

class PhatTrienNhanLucViewModel extends GetxController {
  // ====== trạng thái loading / error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== thống kê tổng quan (giữ nguyên như trong OutputReport) ======
  final tongLaoDong = 0.obs;
  final laoDongNam = 0.obs;
  final laoDongNu = 0.obs;

  final laoDongBQ = 0.obs;
  final tyLeSoVoiKeHoach = 0.0.obs;

  final tuyenDungBQ = 0.obs;
  final tyLeTuyenDung = 0.0.obs;

  final chamDutBQ = 0.obs;
  final tyLeChamDut = 0.0.obs;

  final thamNienBQ = 0.obs;
  final tuoiBQ = 0.obs;

  // Cấu trúc nhân sự
  final quanLy = 0.obs;
  final nvnv = 0.obs;
  final thoKyThuat = 0.obs;
  final phucVu = 0.obs;

  // ====== dữ liệu cho biểu đồ ======
  final tuyenDungList = <Map<String, dynamic>>[].obs; // [{Thang, GT_Nam, GT_Nu}]
  final chamDutList = <Map<String, dynamic>>[].obs;   //  [{Thang, NghiViec, VeHuu}]
  final phanLoaiCQDVList = <Map<String, dynamic>>[].obs; // [{CompanyCode, SoNguoi}]
  final trinhDoList = <Map<String, dynamic>>[].obs;      // [{TrinhDo, Nam, Nu, SoNguoi}]
  final doTuoiList = <Map<String, dynamic>>[].obs;       // [{TenNhom, SoNguoi}]
  final thamNienList = <Map<String, dynamic>>[].obs;     // [{TenNhom, SoNguoi}]
  //final phanLoaiDonViList = <Map<String, dynamic>>[].obs; // [{FilterPhongDoiTT, SoNguoi}]

  // ====== FILTER STATE ======
  final RxInt fromMonth = DateTime.now().month.obs;
  final RxInt fromYear = DateTime.now().year.obs;
  final RxInt toMonth = DateTime.now().month.obs;
  final RxInt toYear = DateTime.now().year.obs;

  // Các filter chính (được chọn trong filter sheet)
  final selectedCQDV = <String>[].obs;       // lưu value ("CQCT", "CNMB"...)
  final selectedPhongDTT = <String>[].obs;
  final selectedNhomCD = <String>[].obs;
  final selectedChucDanh = <String>[].obs;
  final selectedLoaiLaoDong = <String>[].obs;

  // Options cho dropdown (sẽ lấy từ API)
  final cqdvOptions = <Option>[].obs;        // value: "CQCT", label: "Công ty"
  final phongDttOptions = <Option>[].obs;
  final nhomCdOptions = <Option>[].obs;
  final chucDanhOptions = <Option>[].obs;
  final loaiLaoDongOptions = <Option>[].obs;

  // ====== Các biến tạm cho filter sheet (giống OutputReport) ======
  final RxInt filterYear = DateTime.now().year.obs;
  final RxInt filterFromMonth = DateTime.now().month.obs;
  final RxInt filterToMonth = DateTime.now().month.obs;

  final filterCQDV = <String>[].obs;
  final filterPhongDTT = <String>[].obs;
  final filterNhomCD = <String>[].obs;
  final filterChucDanh = <String>[].obs;
  final filterLoaiLaoDong = <String>[].obs;
// ====== search ======
  final searchCtrl = TextEditingController();
  final allFilterOptions = <Option>[].obs; // Tổng hợp tất cả options để search

  // ====== Getter cho hiển thị label trên nút filter ======
  String get monthLabel => 'Tháng ${fromMonth.value}/${fromYear.value}';
  String get cqdvLabel => filterCQDV.isEmpty ? 'CQDV' : '${filterCQDV.length} mục';
  String get phongDttLabel => filterPhongDTT.isEmpty ? 'Phòng/Đội' : '${filterPhongDTT.length} mục';
  String get nhomCdLabel => filterNhomCD.isEmpty ? 'Nhóm CD' : '${filterNhomCD.length} mục';
  String get chucDanhLabel => filterChucDanh.isEmpty ? 'Chức danh' : '${filterChucDanh.length} mục';
  String get loaiLaoDongLabel => filterLoaiLaoDong.isEmpty ? 'Loại LĐ' : '${filterLoaiLaoDong.length} mục';

  // ====== Khởi tạo ======
  @override
  void onReady() {
    super.onReady();
    loadFilterOptions();
    loadData();
  }

  // ====== Lấy danh sách các option từ API (có thêm "Tất cả" = '') ======
  Future<void> loadFilterOptions() async {
  try {
    // 1. CQDV (hardcode) – companyCode chính là value
    cqdvOptions.assignAll([
      const Option('CQCT', 'Công ty', companyCode: 'CQCT'),
      const Option('CNMB', 'CN Miền Bắc', companyCode: 'CNMB'),
      const Option('CNMT', 'CN Miền Trung', companyCode: 'CNMT'),
      const Option('CNMN', 'CN Miền Nam', companyCode: 'CNMN'),
      const Option('CNVT', 'CN Vận Tải', companyCode: 'CNVT'),
    ]);

    // 2. PhongDTT
    var resp = await APICaller.getInstance().get("Helper/FilterPhongdoi");
    if (resp != null) {
      List<dynamic> list = jsonDecode(resp);
      final opts = list.map((e) => Option(
        e['FilterPhongDoiTT'].toString(),
        e['FilterPhongDoiTT'].toString(),
        companyCode: e['CompanyCode']?.toString(),
      )).toList();
      phongDttOptions.assignAll(opts);
      phongDttOptions.insert(0, const Option('', 'Tất cả', companyCode: null));
    }

    // 3. NhomCD
    resp = await APICaller.getInstance().get("Helper/FilterNhomChucDanh");
    if (resp != null) {
      List<dynamic> list = jsonDecode(resp);
      final opts = list.map((e) => Option(
        e['EmployeeType'].toString(),
        e['EmployeeType'].toString(),
        companyCode: e['CompanyCode']?.toString(),
      )).toList();
      nhomCdOptions.assignAll(opts);
      nhomCdOptions.insert(0, const Option('', 'Tất cả', companyCode: null));
    }

    // 4. ChucDanh
    resp = await APICaller.getInstance().get("Helper/FilterChucDanh");
    if (resp != null) {
      List<dynamic> list = jsonDecode(resp);
      final opts = list.map((e) => Option(
        e['JobTitleName'].toString(),
        e['JobTitleName'].toString(),
        companyCode: e['CompanyCode']?.toString(),
      )).toList();
      chucDanhOptions.assignAll(opts);
      chucDanhOptions.insert(0, const Option('', 'Tất cả', companyCode: null));
    }

    // 5. LoaiLaoDong
    resp = await APICaller.getInstance().get("Helper/FilterLoailaodong");
    if (resp != null) {
      List<dynamic> list = jsonDecode(resp);
      final opts = list.map((e) => Option(
        e['LaborType'].toString(),
        e['LaborType'].toString(),
        companyCode: e['CompanyCode']?.toString(),
      )).toList();
      loaiLaoDongOptions.assignAll(opts);
      loaiLaoDongOptions.insert(0, const Option('', 'Tất cả', companyCode: null));
    }

    initCombinedOptions();
  } catch (e) {
    Utils.showSnackBar(title: 'Lỗi', message: 'Không thể tải danh sách filter');
  }
}

  //lọc phongDttOptions dựa trên selectedCQDV
  List<Option> getFilteredPhongDttOptions() {
  if (selectedCQDV.isEmpty) return phongDttOptions;
  final codes = selectedCQDV.toSet();
  return phongDttOptions.where((opt) => opt.companyCode == null || codes.contains(opt.companyCode)).toList();
}
  //lọc nhomCdOptions dựa trên selectedCQDV
List<Option> getFilteredNhomCdOptions() {
  if (selectedCQDV.isEmpty) return nhomCdOptions;
  final codes = selectedCQDV.toSet();
  return nhomCdOptions.where((opt) => opt.companyCode == null || codes.contains(opt.companyCode)).toList();
}

  //lọc chucDanhOptions dựa trên selectedCQDV
List<Option> getFilteredChucDanhOptions() {
  if (selectedCQDV.isEmpty) return chucDanhOptions;
  final codes = selectedCQDV.toSet();
  return chucDanhOptions.where((opt) => opt.companyCode == null || codes.contains(opt.companyCode)).toList();
}

  //lọc loaiLaoDongOptions dựa trên selectedCQDV
List<Option> getFilteredLoaiLaoDongOptions() {
  if (selectedCQDV.isEmpty) return loaiLaoDongOptions;
  final codes = selectedCQDV.toSet();
  return loaiLaoDongOptions.where((opt) => opt.companyCode == null || codes.contains(opt.companyCode)).toList();
}

// Dùng trong filter sheet (dựa trên filterCQDV tạm)
List<Option> getFilteredPhongDttOptionsTemp() {
  if (filterCQDV.isEmpty) return phongDttOptions;
  final codes = filterCQDV.toSet();
  return phongDttOptions.where((opt) => opt.companyCode == null || codes.contains(opt.companyCode)).toList();
}

List<Option> getFilteredNhomCdOptionsTemp() {
  if (filterCQDV.isEmpty) return nhomCdOptions;
  final codes = filterCQDV.toSet();
  return nhomCdOptions.where((opt) => opt.companyCode == null || codes.contains(opt.companyCode)).toList();
}

List<Option> getFilteredChucDanhOptionsTemp() {
  if (filterCQDV.isEmpty) return chucDanhOptions;
  final codes = filterCQDV.toSet();
  return chucDanhOptions.where((opt) => opt.companyCode == null || codes.contains(opt.companyCode)).toList();
}

List<Option> getFilteredLoaiLaoDongOptionsTemp() {
  if (filterCQDV.isEmpty) return loaiLaoDongOptions;
  final codes = filterCQDV.toSet();
  return loaiLaoDongOptions.where((opt) => opt.companyCode == null || codes.contains(opt.companyCode)).toList();
}

  // Xử lý khi chọn kết quả tìm kiếm
  void onSearchSelected(Option selected) {
    // Xác định loại filter và cập nhật filter tạm
    if (cqdvOptions.contains(selected)) {
      filterCQDV.assignAll([selected.value]);
    } else if (phongDttOptions.contains(selected)) {
      filterPhongDTT.assignAll([selected.value]);
    } else if (nhomCdOptions.contains(selected)) {
      filterNhomCD.assignAll([selected.value]);
    } else if (chucDanhOptions.contains(selected)) {
      filterChucDanh.assignAll([selected.value]);
    } else if (loaiLaoDongOptions.contains(selected)) {
      filterLoaiLaoDong.assignAll([selected.value]);
    }
    applyFilters();
  }


  // Phương thức khởi tạo combined options cho search
void initCombinedOptions() {
  allFilterOptions.assignAll([
    ...cqdvOptions,
    ...phongDttOptions,
    ...nhomCdOptions,
    ...chucDanhOptions,
    ...loaiLaoDongOptions,
  ]);
}

  // ====== Gọi API chính ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "nam": toYear.value.toString(),
        "thang": toMonth.value.toString(),
        "CQDV": selectedCQDV.toList(),
        "PhongDTT": selectedPhongDTT.toList(),
        "ChucDanh": selectedChucDanh.toList(),
        "LoaiLaoDong": selectedLoaiLaoDong.toList(),
        "NhomCD": selectedNhomCD.toList(),
      };

      final response = await APICaller.getInstance().post(
        "TCNL/ThongTinQuanTriTCNL/Phattriennhanluc",
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

  // ====== Parse dữ liệu từ API ======
  void applyData(Map<String, dynamic> data) {
    // Tuyển dụng
    //TuyenDung api
    //tuyenDungList.assignAll((data['TuyenDung'] as List?)?.cast<Map<String, dynamic>>() ?? []);

    // Chấm dứt (hiện API trả về mảng rỗng)
    //ChamdutHDLD api
    //chamDutList.assignAll((data['ChamdutHDLD'] as List?)?.cast<Map<String, dynamic>>() ?? []);
    
    // Phân loại cơ quan đơn vị
    phanLoaiCQDVList.assignAll((data['Phanloaicqdv'] as List?)?.cast<Map<String, dynamic>>() ?? []);

    // Trình độ đào tạo
    //TDDT api
    //trinhDoList.assignAll((data['TDDT'] as List?)?.cast<Map<String, dynamic>>() ?? []);

    // Độ tuổi
    //DoTuoiDoTuoi api
    doTuoiList.assignAll((data['DoTuoiDoTuoi'] as List?)?.cast<Map<String, dynamic>>() ?? []);
    // Thâm niên
    //ThamNien api
    thamNienList.assignAll((data['ThamNien'] as List?)?.cast<Map<String, dynamic>>() ?? []);
    // Phân loại đơn vị (phòng/đội) – dùng cho treemap
    //Phanloaidonvi api
    //phanLoaiDonViList.assignAll((data['Phanloaidonvi'] as List?)?.cast<Map<String, dynamic>>() ?? []);

    // Tổng lao động
    final totalLd = (data['LaodongTotallaodongTotal'] as List?)?.first;
    if (totalLd != null) {
      tongLaoDong.value = totalLd['TongLaoDong'] ?? 0;
      laoDongNam.value = totalLd['LaoDongNam'] ?? 0;
      laoDongNu.value = totalLd['LaoDongNu'] ?? 0;
    }

    // Sử dụng bình quân
    final sd = (data['LaodongSDBQ'] as List?)?.first;
    if (sd != null) {
      laoDongBQ.value = sd['LaoDongBQ'] ?? 0;
      tyLeSoVoiKeHoach.value = (sd['TyLeSoVoiKeHoach'] as num?)?.toDouble() ?? 0;
    }

    // Tuyển dụng bình quân tỉ lệ
    //TuyendunglaodongBQ api
    // final td = (data['TuyendunglaodongBQ'] as List?)?.first;
    // if (td != null) {
    //   tuyenDungBQ.value = td['NhanSuTuyenDungBinhQuanNamNay'] ?? 0;
    //   tyLeTuyenDung.value = (td['TyLeTuyenDungTongNguonLuc'] as num?)?.toDouble() ?? 0;
    // }

    // Chấm dứt bình quân tỉ lêk
    //NhansuchamdutBQ api
    // final cd = (data['NhansuchamdutBQ'] as List?)?.first;
    // if (cd != null && cd['NhanSuChanDutBinhQuanNamNay'] != null) {
    //   chamDutBQ.value = cd['NhanSuChanDutBinhQuanNamNay'] ?? 0;
    //   tyLeChamDut.value = (cd['TyLeChamDutTongNguonLuc'] as num?)?.toDouble() ?? 0;
    // }

    // Thâm niên bình quân
    //ThamnienBQ api
    final tn = (data['ThamnienBQ'] as List?)?.first;
    if (tn != null) thamNienBQ.value = tn['ThamNien'] ?? 0;

    // Tuổi bình quân
    //TuoiBQ api
    final tuoi = (data['TuoiBQ'] as List?)?.first;
    if (tuoi != null) tuoiBQ.value = tuoi['Tuoi'] ?? 0;

    // cấu trúc nhân sự
    final phanTich = (data['Phantichlaodong'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    for (var item in phanTich) {
      String loai = item['PhanLoai'] ?? '';
      int so = item['SoNguoi'] ?? 0;
      if (loai.contains('quản lý')) quanLy.value = so;
      else if (loai.contains('NVNV')) nvnv.value = so;
      else if (loai.contains('phục vụ')) phucVu.value = so;
      else if (loai.contains('Thợ kỹ thuật')) thoKyThuat.value = so;
    }
  }

  // ====== Các hàm thay đổi filter (giống OutputReport) ======
  void setFilterYear(int y) => filterYear.value = y;
  void setFromMonth(int m) {
    filterFromMonth.value = m;
    if (filterToMonth.value < m) filterToMonth.value = m;
  }
  void setToMonth(int m) {
    filterToMonth.value = m;
    if (filterFromMonth.value > m) filterFromMonth.value = m;
  }

  void onSearch(String keyword) {
  if (keyword.isEmpty) {
    // Nếu keyword rỗng, không làm gì hoặc reset?
    return;
  }
  final lowerKeyword = keyword.toLowerCase();
  // Tìm trong tất cả options
  final matched = allFilterOptions.where((opt) => opt.label.toLowerCase().contains(lowerKeyword)).toList();
  if (matched.isEmpty) return;
  // Lấy option đầu tiên (hoặc có thể hiển thị list để chọn, nhưng OutputReport chỉ chọn 1 sân bay)
  final firstMatch = matched.first;
  // Xác định loại filter dựa trên việc option nằm trong list nào
  if (cqdvOptions.contains(firstMatch)) {
    filterCQDV.assignAll([firstMatch.value]);
  } else if (phongDttOptions.contains(firstMatch)) {
    filterPhongDTT.assignAll([firstMatch.value]);
  } else if (nhomCdOptions.contains(firstMatch)) {
    filterNhomCD.assignAll([firstMatch.value]);
  } else if (chucDanhOptions.contains(firstMatch)) {
    filterChucDanh.assignAll([firstMatch.value]);
  } else if (loaiLaoDongOptions.contains(firstMatch)) {
    filterLoaiLaoDong.assignAll([firstMatch.value]);
  }
  // Sau khi set filter tạm, cần áp dụng? OutputReport gọi onSearchAirport rồi applyFilters()
  applyFilters();
}



  // Áp dụng filter từ sheet vào biến thật và load lại dữ liệu
  Future<void> applyFilters() async {
    fromMonth.value = filterFromMonth.value;
    toMonth.value = filterToMonth.value;
    toYear.value = filterYear.value;

    selectedCQDV.assignAll(filterCQDV);
    selectedPhongDTT.assignAll(filterPhongDTT);
    selectedNhomCD.assignAll(filterNhomCD);
    selectedChucDanh.assignAll(filterChucDanh);
    selectedLoaiLaoDong.assignAll(filterLoaiLaoDong);

    await loadData();
  }

  void resetFilters() {
    final now = DateTime.now();
    filterFromMonth.value = now.month;
    filterToMonth.value = now.month;
    filterYear.value = now.year;

    filterCQDV.clear();
    filterPhongDTT.clear();
    filterNhomCD.clear();
    filterChucDanh.clear();
    filterLoaiLaoDong.clear();
  }



  // Khi load xong options, gọi initCombinedOptions()
// Sửa loadFilterOptions, sau mỗi lần gán options, gọi initCombinedOptions()
// Hoặc gọi sau khi tất cả đã load xong.

// Thêm phương thức tìm kiếm và áp dụng filter cho từng loại

  // ====== Helper format số ======
  String fmt(num v) {
    if (v == null) return '0';
    return NumberFormat('#,###', 'vi_VN').format(v);
  }
  String pct(double v) => '${(v * 100).toStringAsFixed(1)}%';
}