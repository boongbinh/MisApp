import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Components/TCNL/CongTacDang/TrinhdodaotaoCard.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';
import 'package:skypec/components/TCNL/CongTacDang/GioiTinhCard.dart';
import 'package:skypec/components/TCNL/CongTacDang/DotuoidangCard.dart';
import 'package:skypec/components/TCNL/CongTacDang/SoluongdangvienCard.dart';
import 'package:skypec/components/TCNL/CongTacDang/CapuydangCard.dart';

class Option {
  final String value, label;
  const Option(this.value, this.label);
}

class CongTacDangViewModel extends GetxController {
  // ====== trạng thái loading / error ======
  final loading = false.obs;
  final error = ''.obs;

  // Dữ liệu từ API ======
  //Dữ liệu đã xử lý cho Card ======
  final gioiTinhDataList = <GioiTinhData>[].obs;
  final dangVienToChucDataList = <GioiTinhData>[].obs;
  final trinhDoDaoTaoDataList = <TrinhdodaotaoData>[].obs;
  final dotuoiDangDataList = <DotuoidangData>[].obs;
  final soLuongDangVienDataList = <SoluongdangvienData>[].obs;
  final capUyDangDataList = <CapuydangData>[].obs;

  // ====== Thống kê tổng quan ======
  final tyLeDangVien = 0.0.obs;
  final tyLeDangVienText = '0/0'.obs;
  final tuoiBinhQuan = '0 năm 0 tháng'.obs;
  final tyLeChuyenDang = '0/0'.obs;
  final tyLeChuyenDang100 = 0.0.obs;

  final tyLeKetNap = 0.0.obs;
  final tyLeKetNapText = '0/0'.obs;
  final tyLe_DvTT_to_LDTT = 0.0.obs;
  final tyLe_DvTT_to_LDTTText = '0/0'.obs;
  final tyLe_DvGT_to_LDGT = 0.0.obs;
  final tyLe_DvGT_to_LDGTText = '0/0'.obs;

  // ====== FILTER ======
  final RxString filterDonVi = 'Tất cả'.obs;
  final RxString selectedDonVi = 'Tất cả'.obs;
  final donViValue = Rxn<String>();
  // Options
  final donViOptions = <Option>[].obs;
  
  // Search
  final searchCtrl = TextEditingController();
  final allFilterOptions = <Option>[].obs;

  // ====== Getter hiển thị label ======
  String get donViLabel => filterDonVi.value;

  // ====== Khởi tạo ======
  @override
  void onReady() {
    super.onReady();
    _initDonViOptions();
    loadData();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  // ====== Khởi tạo danh sách đơn vị ======
  void _initDonViOptions() {
    final options = ['Tất cả','CQCT','CNMB','CNMT','CNMN','CNVT',];
    donViOptions.assignAll(options.map((e) => Option(e, e)));
    allFilterOptions.assignAll(donViOptions);
  }

  // ====== Gọi API chính ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      Map<String, dynamic> payload = {
        "donvi": donViValue?.value, // null khi là "Tất cả"
      };

      // ⭐ DEBUG: In payload để kiểm tra
      print('===== LOAD DATA =====');
      print('donViValue: ${donViValue?.value}');
      print('Payload: $payload');
      print('=====================');

      final response = await APICaller.getInstance().post(
        "TCNL/ThongTinQuanTriTCNL/Congtacdang",
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
    //GioiTinh api
    final gioiTinhRaw = data['GioiTinh'] as List? ?? [];
    final colorMapGioiTinh = {'Nam': Colors.blue.shade700, 'Nữ': Colors.pink.shade400, 'Khác': Colors.grey};
    final List<GioiTinhData> result = [];
    for (var item in gioiTinhRaw) {
      if (item is Map) {
        final gender = item['Gender']?.toString() ?? 'Khác';
        final soNguoi = (item['SoNguoi'] as num?)?.toDouble() ?? 0;
        if (soNguoi > 0) {
          result.add(GioiTinhData(
            label: gender,
            value: soNguoi,
            color: colorMapGioiTinh[gender] ?? Colors.grey,
          ));
        }
      }
    }
  
    if (result.isEmpty) {
      gioiTinhDataList.assignAll([
        GioiTinhData(label: 'Nam', value: 0, color: Colors.blue.shade700),
        GioiTinhData(label: 'Nữ', value: 0, color: Colors.pink.shade400),
      ]);
    } else {
      gioiTinhDataList.assignAll(result);
    }

    //Dangviencactochuc api
    final dangVienRaw = data['Dangviencactochuc'] as List? ?? [];
    final colorPalette = [
  // Xanh dương
  Colors.blue.shade700,Colors.blue.shade500, Colors.blue.shade300,
  // Xanh lá 
  Colors.green.shade700,Colors.green.shade500,Colors.green.shade300,
  // Cam
  Colors.orange.shade700,Colors.orange.shade500, Colors.orange.shade300, 
  // Tím
  Colors.purple.shade700,Colors.purple.shade500,Colors.purple.shade300,
  // Đỏ
  Colors.red.shade700, Colors.red.shade500,Colors.red.shade300,
  // Hồng
  Colors.pink.shade700,Colors.pink.shade500, Colors.pink.shade300,
  // Xanh ngọc
  Colors.teal.shade700,Colors.teal.shade500,Colors.teal.shade300,
  // Vàng
  Colors.amber.shade700,Colors.amber.shade500, Colors.amber.shade300,
];
    
    final List<GioiTinhData> dangVienResult = [];
    for (int i = 0; i < dangVienRaw.length; i++) {
      final item = dangVienRaw[i];
      if (item is Map) {
        final label = item['CompanyCode']?.toString() ?? 'Khác';
        final value = (item['SoNguoi'] as num?)?.toDouble() ?? 0;
        if (value > 0) {
          dangVienResult.add(GioiTinhData(
            label: label,
            value: value,
            color: colorPalette[i % colorPalette.length],
          ));
        }
      }
    }
    
    dangVienToChucDataList.assignAll(dangVienResult.isEmpty ? [
      GioiTinhData(label: 'Không có dữ liệu', value: 0, color: Colors.grey),
    ] : dangVienResult);

    //TDDT api
    final tdtdRaw = data['TDDT'] as List? ?? [];
    final List<TrinhdodaotaoData> tdtdResult = [];
    for (var item in tdtdRaw) {
      if (item is Map) {
        final label = item['EducationName']?.toString() ?? 'Khác';
        final nam = (item['Nam'] as num?)?.toInt() ?? 0;
        final nu = (item['Nu'] as num?)?.toInt() ?? 0;
        if (nam > 0 || nu > 0) {
          tdtdResult.add(TrinhdodaotaoData(
            label: label,
            nam: nam,
            nu: nu,
          ));
        }
      }
    }
    trinhDoDaoTaoDataList.assignAll(tdtdResult);

    //Dotuoidang api
    final dotuoiRaw = data['Dotuoidang'] as List? ?? [];
    final List<DotuoidangData> dotuoiResult = [];
    for (var item in dotuoiRaw) {
      if (item is Map) {
        final nhomTuoi = item['NhomTuoi']?.toString() ?? 'Khác';
        final nam = (item['NAM'] as num?)?.toInt() ?? 0;
        final nu = (item['NU'] as num?)?.toInt() ?? 0;
        if (nam > 0 || nu > 0) {
          dotuoiResult.add(DotuoidangData(
            nhomTuoi: nhomTuoi,
            nam: nam,
            nu: nu,
          ));
        }
      }
    }
    dotuoiDangDataList.assignAll(dotuoiResult);

    //SoLuongDangVien api
    final soLuongRaw = data['Soluongdangvien'] as List? ?? [];
    final List<SoluongdangvienData> soLuongResult = [];
    for (var item in soLuongRaw) {
      if (item is Map) {
        final thang = item['ThoiGian']?.toString() ?? '0';
        final duBi = (item['DuBi'] as num?)?.toInt() ?? 0;
        final chinhThuc = (item['ChinhThuc'] as num?)?.toInt() ?? 0;
        soLuongResult.add(SoluongdangvienData(
          thang: thang,
          duBi: duBi,
          chinhThuc: chinhThuc,
        ));
      }
    }
    soLuongDangVienDataList.assignAll(soLuongResult);

    //CapUyDang api
    final capUyRaw = data['CapUyDang'] as List? ?? [];
    print('===== CAP UY RAW =====');
    print(capUyRaw);
    print('=======================');

    final List<CapuydangData> capUyResult = [];
    for (var item in capUyRaw) {
      if (item is Map) {
        final tenCapUy = item['tenCapUy']?.toString() ?? 'Khác';
        final soLuong = (item['SoLuong'] as num?)?.toInt() ?? 0;
        if (soLuong > 0) {
          capUyResult.add(CapuydangData(
            tenCapUy: tenCapUy,
            soLuong: soLuong,
          ));
        }
      }
    }
    
    print('===== CAP UY RESULT =====');
    print('Số lượng: ${capUyResult.length}');
    for (var item in capUyResult) {
      print('${item.tenCapUy}: ${item.soLuong}');
    }
    print('==========================');
    
    capUyDangDataList.assignAll(capUyResult);

    // ====== THỐNG KÊ ======
    tyLeDangVien.value = (data['Tyledangvien'] as num?)?.toDouble() ?? 0.0;
    tyLeDangVienText.value = data['TyledangvienText']?.toString() ?? '0/0';
    tuoiBinhQuan.value = data['Tuoibinhquan']?.toString() ?? '0 năm 0 tháng';
    tyLeChuyenDang.value = data['Tilechuyendang']?.toString() ?? '0/0';
    tyLeChuyenDang100.value = (data['Tilechuyendang100'] as num?)?.toDouble() ?? 0.0;

    tyLeKetNap.value = (data['TyLeKetNap'] as num?)?.toDouble() ?? 0.0;
    tyLeKetNapText.value = data['TyledangvienText']?.toString() ?? '0/0';
    tyLe_DvTT_to_LDTT.value = (data['TyLe_DvTT_to_LDTT'] as num?)?.toDouble() ?? 0.0;
    tyLe_DvTT_to_LDTTText.value = data['TyLe_DvTT_to_LDTTText']?.toString() ?? '0/0';
    tyLe_DvGT_to_LDGT.value = (data['TyLe_DvGT_to_LDGT'] as num?)?.toDouble() ?? 0.0;
    tyLe_DvGT_to_LDGTText.value = data['TyLe_DvGT_to_LDGTText']?.toString() ?? '0/0';
  }

  // ====== Hàm thay đổi filter ======
  void setDonVi(String value) {
    print('===== SET DON VI =====');
    print('Giá trị mới: $value');
    print('Giá trị cũ: ${filterDonVi.value}');
    print('=======================');
    
    filterDonVi.value = value;
    selectedDonVi.value = value;
    if (value == 'Tất cả') {
      donViValue?.value = null;
    } else {
      donViValue?.value = value;
    }
    
    print('donViValue sau khi set: ${donViValue?.value}');
    loadData();
  }

  // ====== Search ======
  void onSearchSelected(Option selected) {
    if (donViOptions.contains(selected)) {
      setDonVi(selected.value);
    }
  }

 

  // ====== Helper format số ======
  String fmt(num v) {
    if (v == null) return '0';
    return NumberFormat('#,###', 'vi_VN').format(v);
  }

  String pct(double v) => '${(v * 100).toStringAsFixed(1)}%';
}