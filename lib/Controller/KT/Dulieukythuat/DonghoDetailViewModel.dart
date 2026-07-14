import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class DonghoDetailViewModel extends GetxController {
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
  final showTenThietBi = true.obs;
  final showViTri = true.obs;
  final showNamSX = true.obs;
  final showNamSD = true.obs;
  final showHangSXBuongDong = true.obs;
  final showModelBuongDong = true.obs;
  final showHangSXBoDem = true.obs;
  final showModelBoDem = true.obs;
  final showPhuKienDiKem = true.obs;
  final showGiaiLL = true.obs;

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
        final dongHoData = data['Dongho'] as List? ?? [];
        allData.assignAll(dongHoData.cast<Map<String, dynamic>>());
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

  // ====== Toggle columns ======
  void toggleDonVi() { showDonVi.toggle(); update(['header']); }
  void toggleTenThietBi() { showTenThietBi.toggle(); update(['header']); }
  void toggleViTri() { showViTri.toggle(); update(['header']); }
  void toggleNamSX() { showNamSX.toggle(); update(['header']); }
  void toggleNamSD() { showNamSD.toggle(); update(['header']); }
  void toggleHangSXBuongDong() { showHangSXBuongDong.toggle(); update(['header']); }
  void toggleModelBuongDong() { showModelBuongDong.toggle(); update(['header']); }
  void toggleHangSXBoDem() { showHangSXBoDem.toggle(); update(['header']); }
  void toggleModelBoDem() { showModelBoDem.toggle(); update(['header']); }
  void togglePhuKienDiKem() { showPhuKienDiKem.toggle(); update(['header']); }
  void toggleGiaiLL() { showGiaiLL.toggle(); update(['header']); }

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
        'ChiNhanh': ['CNMB', 'CNMT', 'CNMN', 'CQCT'][i % 4],
        'Donvi': ['HAN', 'SGN', 'DAD', 'NHA'][i % 4],
        'Tenthietbi': 'Đồng hồ lưu lượng',
        'Vitri': 'HX${i % 3 + 1} - Kho N${i % 2 + 1}',
        'Nam_sx': '20${(15 + i % 10).toString()}',
        'Nam_sd': '20${(15 + i % 10).toString()}',
        'Hang_sx_buongdong': i % 2 == 0 ? '' : 'Hãng ${i % 3 + 1}',
        'Model_buongdong': 'TCS-${700 + i * 10}-${60 + i}',
        'Hang_sx_bodem': ['TCS', 'OMRON', 'KEYENCE'][i % 3],
        'Model_bodem': i % 2 == 0 ? '' : 'MD${100 + i}',
        'Phukien_dikem': i % 3 == 0 ? 'Cáp kết nối' : '',
        'Giai_ll': '${300 + i * 20} - ${3000 + i * 100} (L/min)',
      });
    }
    allData.assignAll(mockData);
    _applySearchAndPagination();
  }
}

// ====== COLUMN SETTINGS SHEET ======
class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({required this.vm});
  final DonghoDetailViewModel vm;

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
                        _switch('Tên thiết bị', vm.showTenThietBi, vm.toggleTenThietBi),
                        _switch('Vị trí', vm.showViTri, vm.toggleViTri),
                        _switch('Năm sản xuất', vm.showNamSX, vm.toggleNamSX),
                        _switch('Năm sử dụng', vm.showNamSD, vm.toggleNamSD),
                        _switch('Hãng SX buồng đong', vm.showHangSXBuongDong, vm.toggleHangSXBuongDong),
                        _switch('Model buồng đong', vm.showModelBuongDong, vm.toggleModelBuongDong),
                        _switch('Hãng SX bộ đếm', vm.showHangSXBoDem, vm.toggleHangSXBoDem),
                        _switch('Model bộ đếm', vm.showModelBoDem, vm.toggleModelBoDem),
                        _switch('Phụ kiện đi kèm', vm.showPhuKienDiKem, vm.togglePhuKienDiKem),
                        _switch('Dải lưu lượng', vm.showGiaiLL, vm.toggleGiaiLL),
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
                          vm.showTenThietBi.value = true;
                          vm.showViTri.value = true;
                          vm.showNamSX.value = true;
                          vm.showNamSD.value = true;
                          vm.showHangSXBuongDong.value = true;
                          vm.showModelBuongDong.value = true;
                          vm.showHangSXBoDem.value = true;
                          vm.showModelBoDem.value = true;
                          vm.showPhuKienDiKem.value = true;
                          vm.showGiaiLL.value = true;
                          vm.update(['header']);
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