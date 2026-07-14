import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class BechuaDetailViewModel extends GetxController {
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
  final showChiNhanh = true.obs;
  final showTenBe = true.obs;
  final showChucNang = true.obs;
  final showDungTich = true.obs;
  final showNamSuDung = true.obs;
  final showNgayVeSinh = true.obs;
  final showNgayKiemDinh = true.obs;

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
        final beChuaData = data['Bechua'] as List? ?? [];
        allData.assignAll(beChuaData.cast<Map<String, dynamic>>());
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

  String formatDate(dynamic dateValue) {
    if (dateValue == null) return '--';
    return dateValue.toString();
  }

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
        'DonVi': ['CNMB', 'CNMT', 'CNMN', 'CQCT'][i % 4],
        'Ma_be': '021.HAN.01.${(1000 + i).toString().padLeft(4, '0')}',
        'Chuc_nang': 'Nhập/xuất Jet A-1',
        'Dung_tich': 1000 + (i * 20),
        'Ngay_sudung': '198${i % 5}',
        'ngay_vesinh': '${(i % 12 + 1).toString().padLeft(2, '0')}/202${i % 6}',
        'ngay_kiemdinh': '${(i % 12 + 1).toString().padLeft(2, '0')}/203${i % 5}',
        'CNKV': ['CNMB', 'CNMT', 'CNMN'][i % 3],
        'Sanbay': ['HAN', 'SGN', 'DAD'][i % 3],
      });
    }
    allData.assignAll(mockData);
    _applySearchAndPagination();
  }
}

// ====== COLUMN SETTINGS SHEET ======
class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({required this.vm});
  final BechuaDetailViewModel vm;

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
                        _switch('Chi nhánh', vm.showChiNhanh),
                        _switch('Tên bể', vm.showTenBe),
                        _switch('Chức năng', vm.showChucNang),
                        _switch('Dung tích', vm.showDungTich),
                        _switch('Năm sử dụng', vm.showNamSuDung),
                        _switch('Ngày vệ sinh bể kế tiếp', vm.showNgayVeSinh),
                        _switch('Ngày kiểm định barem', vm.showNgayKiemDinh),
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
                          vm.showChiNhanh.value = true;
                          vm.showTenBe.value = true;
                          vm.showChucNang.value = true;
                          vm.showDungTich.value = true;
                          vm.showNamSuDung.value = true;
                          vm.showNgayVeSinh.value = true;
                          vm.showNgayKiemDinh.value = true;
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

  Widget _switch(String title, RxBool bind) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Obx(() => Switch(
            value: bind.value,
            onChanged: (v) => bind.value = v,
          )),
        ],
      ),
    );
  }
}