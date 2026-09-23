import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class XeTranapDetailCNKVViewModel extends GetxController {
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
  final showBienKiemSoat = true.obs;
  final showLoaiXe = true.obs;
  final showDungTich = true.obs;
  final showNamSX = true.obs;
  final showNamSD = true.obs;
  final showLLTNHong = true.obs;
  final showLLTNGN = true.obs;
  final showNgayKD = true.obs;
  final showNgayKDTiep = true.obs;

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
        "CNKV/KT/Baocao/Dulieukythuat",
      );

      if (response != null) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        final xeTNData = data['XeTN'] as List? ?? [];
        allData.assignAll(xeTNData.cast<Map<String, dynamic>>());
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
    try {
      if (dateValue is DateTime) {
        return DateFormat('dd/MM/yyyy').format(dateValue);
      }
      if (dateValue is String) {
        final parsed = DateTime.tryParse(dateValue);
        if (parsed != null) {
          return DateFormat('dd/MM/yyyy').format(parsed);
        }
        return dateValue;
      }
      return dateValue.toString();
    } catch (e) {
      return dateValue.toString();
    }
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
    for (int i = 1; i <= 10; i++) {
      mockData.add({
        'ID_xe': i,
        'ma_sb': ['HAN', 'SGN', 'DAD'][i % 3],
        'ma_xe': 'HAN${1000 + i}',
        'ma_kx': 'GARSITE101995',
        'nam_sx': '${1990 + i}',
        'DT_GL': 8000.0 + (i * 100),
        'Nam_sd': 1995 + i,
        'ChiNhanh': ['CNMB', 'CNMT', 'CNMN'][i % 3],
        'LLTN_hong': 300 + i,
        'LLTN_Giannang': 700 + i,
        'Ngay_KD_GN': '2026-01-${i.toString().padLeft(2, '0')}T00:00:00',
        'Ngay_KD_Tiep': '2026-07-${i.toString().padLeft(2, '0')}T00:00:00',
      });
    }
    allData.assignAll(mockData);
    _applySearchAndPagination();
  }
}

// ====== COLUMN SETTINGS SHEET ======
class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({required this.vm});
  final XeTranapDetailCNKVViewModel vm;

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
                _switch('Chi nhánh', vm.showChiNhanh),
                _switch('Biển kiểm soát', vm.showBienKiemSoat),
                _switch('Loại xe', vm.showLoaiXe),
                _switch('Dung tích (GL)', vm.showDungTich),
                _switch('Năm SX', vm.showNamSX),
                _switch('Năm SD', vm.showNamSD),
                _switch('LLTN hông', vm.showLLTNHong),
                _switch('LLTN giàn nâng', vm.showLLTNGN),
                _switch('Ngày đăng kiểm', vm.showNgayKD),
                _switch('Ngày đăng kiểm kế tiếp', vm.showNgayKDTiep),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          vm.showChiNhanh.value = true;
                          vm.showBienKiemSoat.value = true;
                          vm.showLoaiXe.value = true;
                          vm.showDungTich.value = true;
                          vm.showNamSX.value = true;
                          vm.showNamSD.value = true;
                          vm.showLLTNHong.value = true;
                          vm.showLLTNGN.value = true;
                          vm.showNgayKD.value = true;
                          vm.showNgayKDTiep.value = true;
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