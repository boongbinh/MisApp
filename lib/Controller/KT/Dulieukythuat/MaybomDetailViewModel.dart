import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class MaybomDetailViewModel extends GetxController {
  // ====== Loading / Error ======
  final loading = false.obs;
  final error = ''.obs;

  // ====== Dữ liệu ======
  final allData = <Map<String, dynamic>>[].obs;
  final filteredData = <Map<String, dynamic>>[].obs;

  // ====== Pagination ======
  final currentPage = 1.obs;
  final pageSize = 20.obs;
  final totalItems = 0.obs;

  // ====== Search ======
  final searchCtrl = TextEditingController();
  final searchKeyword = ''.obs;

  // ====== Cài đặt cột ======
  final showDonVi = true.obs;
  final showKyHieu = true.obs;
  final showChucNang = true.obs;
  final showNamSX = true.obs;
  final showNamSD = true.obs;
  final showNuocSX = true.obs;
  final showHangSXBom = true.obs;
  final showModelBom = true.obs;
  final showKieuBom = true.obs;
  final showLuuLuong = true.obs;
  final showChieuCaoDay = true.obs;
  final showHangSXDongCo = true.obs;
  final showModelDongCo = true.obs;
  final showKieuDongCo = true.obs;
  final showCongSuatDongCo = true.obs;
  final showDienAp = true.obs;

  int get totalPages => totalItems.value > 0 ? (totalItems.value / pageSize.value).ceil() : 1;

  @override
  void onInit() {
    super.onInit();
    searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  @override
  void onClose() {
    searchCtrl.removeListener(_onSearchChanged);
    searchCtrl.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchKeyword.value = searchCtrl.text.trim().toLowerCase();
    _applySearchAndPagination();
  }

  // ====== Load Data từ API ======
  Future<void> loadData() async {
    loading.value = true;
    error.value = '';
    try {
      final response = await APICaller.getInstance().get(
        "KT/Dulieukythuat",
      );

      if (response != null) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        final mayBomData = data['Maybom'] as List? ?? [];
        allData.assignAll(mayBomData.cast<Map<String, dynamic>>());
        _applySearchAndPagination();
      } else {
        _loadMockData();
      }
    } catch (e) {
      error.value = e.toString();
      _loadMockData();
    } finally {
      loading.value = false;
    }
  }

  void _applySearchAndPagination() {
    final keyword = searchKeyword.value;
    List<Map<String, dynamic>> filtered;

    if (keyword.isEmpty) {
      filtered = allData.toList();
    } else {
      filtered = allData.where((item) {
        final searchText = item.values
            .where((v) => v != null)
            .map((v) => v.toString().toLowerCase())
            .join(' ');
        return searchText.contains(keyword);
      }).toList();
    }

    totalItems.value = filtered.length;
    filteredData.assignAll(filtered);
    if (keyword.isNotEmpty) {
      currentPage.value = 1;
    }
  }

  List<Map<String, dynamic>> getCurrentPageData() {
    if (filteredData.isEmpty) return [];
    final start = (currentPage.value - 1) * pageSize.value;
    final end = (start + pageSize.value).clamp(0, filteredData.length);
    return filteredData.sublist(start, end);
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    currentPage.value = page;
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  // ⭐ Hàm toggle cột
  void toggleDonVi() { showDonVi.toggle(); update(); }
  void toggleKyHieu() { showKyHieu.toggle(); update(); }
  void toggleChucNang() { showChucNang.toggle(); update(); }
  void toggleNamSX() { showNamSX.toggle(); update(); }
  void toggleNamSD() { showNamSD.toggle(); update(); }
  void toggleNuocSX() { showNuocSX.toggle(); update(); }
  void toggleHangSXBom() { showHangSXBom.toggle(); update(); }
  void toggleModelBom() { showModelBom.toggle(); update(); }
  void toggleKieuBom() { showKieuBom.toggle(); update(); }
  void toggleLuuLuong() { showLuuLuong.toggle(); update(); }
  void toggleChieuCaoDay() { showChieuCaoDay.toggle(); update(); }
  void toggleHangSXDongCo() { showHangSXDongCo.toggle(); update(); }
  void toggleModelDongCo() { showModelDongCo.toggle(); update(); }
  void toggleKieuDongCo() { showKieuDongCo.toggle(); update(); }
  void toggleCongSuatDongCo() { showCongSuatDongCo.toggle(); update(); }
  void toggleDienAp() { showDienAp.toggle(); update(); }

  // ====== Column Settings ======
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

  // ====== Dữ liệu mẫu ======
  void _loadMockData() {
    final List<Map<String, dynamic>> mockData = [];
    for (int i = 1; i <= 15; i++) {
      mockData.add({
        'Don_vi': ['HAN', 'SGN', 'DAD', 'NHA'][i % 4],
        'Ma_bom': '021.${['HAN', 'SGN', 'DAD'][i % 3]}.03.${(1000 + i).toString().padLeft(4, '0')}',
        'Chuc_nang': 'Tiếp nhận Jet A-1',
        'Nam_sx': i % 2 == 0 ? '' : '20${(10 + i % 10).toString()}',
        'Nam_sd': '20${(10 + i % 10).toString()}',
        'Nuoc_sx': ['VN', 'JP', 'KR', 'US'][i % 4],
        'Hang_sx_bom': ['Tiệp', 'Nhật', 'Hàn', 'Mỹ'][i % 4],
        'Model_bom': i % 2 == 0 ? '' : 'MB${100 + i}',
        'Kieu_bom': ['Bơm đa tầng cánh', 'Bơm ly tâm', 'Bơm piston'][i % 3],
        'Luuluong': '${60 + (i * 5)}.0000',
        'Chieucao_day': 0,
        'Hang_sanxuat': ['Việt Hung', 'Đông Á', 'Nam Phương'][i % 3],
        'Model_dongco': i % 2 == 0 ? '' : 'DC${100 + i}',
        'Kieu_dongco': ['Điện', 'Diesel', 'Khí nén'][i % 3],
        'Cong_suat_dongco': '${20 + i}',
        'Dienap': '380',
      });
    }
    allData.assignAll(mockData);
    _applySearchAndPagination();
  }
}

// ====== COLUMN SETTINGS SHEET ======
class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({required this.vm});
  final MaybomDetailViewModel vm;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Cài đặt hiển thị',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _switch('Đơn vị', vm.showDonVi, vm.toggleDonVi),
                        _switch('Ký hiệu', vm.showKyHieu, vm.toggleKyHieu),
                        _switch('Chức năng', vm.showChucNang, vm.toggleChucNang),
                        _switch('Năm sản xuất', vm.showNamSX, vm.toggleNamSX),
                        _switch('Năm sử dụng', vm.showNamSD, vm.toggleNamSD),
                        _switch('Nước SX', vm.showNuocSX, vm.toggleNuocSX),
                        _switch('Hãng SX bơm', vm.showHangSXBom, vm.toggleHangSXBom),
                        _switch('Model bơm', vm.showModelBom, vm.toggleModelBom),
                        _switch('Kiểu bơm', vm.showKieuBom, vm.toggleKieuBom),
                        _switch('Lưu lượng', vm.showLuuLuong, vm.toggleLuuLuong),
                        _switch('Chiều cao đẩy', vm.showChieuCaoDay, vm.toggleChieuCaoDay),
                        _switch('Hãng SX động cơ', vm.showHangSXDongCo, vm.toggleHangSXDongCo),
                        _switch('Model động cơ', vm.showModelDongCo, vm.toggleModelDongCo),
                        _switch('Kiểu động cơ', vm.showKieuDongCo, vm.toggleKieuDongCo),
                        _switch('Công suất động cơ', vm.showCongSuatDongCo, vm.toggleCongSuatDongCo),
                        _switch('Điện áp', vm.showDienAp, vm.toggleDienAp),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          vm.showDonVi.value = true;
                          vm.showKyHieu.value = true;
                          vm.showChucNang.value = true;
                          vm.showNamSX.value = true;
                          vm.showNamSD.value = true;
                          vm.showNuocSX.value = true;
                          vm.showHangSXBom.value = true;
                          vm.showModelBom.value = true;
                          vm.showKieuBom.value = true;
                          vm.showLuuLuong.value = true;
                          vm.showChieuCaoDay.value = true;
                          vm.showHangSXDongCo.value = true;
                          vm.showModelDongCo.value = true;
                          vm.showKieuDongCo.value = true;
                          vm.showCongSuatDongCo.value = true;
                          vm.showDienAp.value = true;
                          vm.update();
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
    );
  }

  Widget _switch(String title, RxBool bind, VoidCallback onToggle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
          Switch(
            value: bind.value,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}