import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class BaulocDetailCNKVViewModel extends GetxController {
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
  final showTenBauLoc = true.obs;
  final showChucNang = true.obs;
  final showLuuLuong = true.obs;
  final showNamSX = true.obs;
  final showSoSN = true.obs;
  final showModelLoc = true.obs;

  int get totalPages => totalItems.value > 0 ? (totalItems.value / pageSize.value).ceil() : 1;

  @override
  void onInit() {
    super.onInit();
    searchCtrl.addListener(_onSearchChanged);
    
    // ⭐ Theo dõi thay đổi của các cột để gọi update()
    ever(showChiNhanh, (_) => update());
    ever(showTenBauLoc, (_) => update());
    ever(showChucNang, (_) => update());
    ever(showLuuLuong, (_) => update());
    ever(showNamSX, (_) => update());
    ever(showSoSN, (_) => update());
    ever(showModelLoc, (_) => update());
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
        final bauLocData = data['Bauloc'] as List? ?? [];
        allData.assignAll(bauLocData.cast<Map<String, dynamic>>());
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
        'Don_vi': ['HAN', 'SGN', 'DAD', 'NHA'][i % 4],
        'Model_loc': 'Lọc ${['cấp phát', 'tiếp nhận', 'lọc thô'][i % 3]} BL${i % 3 + 1}-N${i % 2 + 1}',
        'Chucnang': ['Cấp phát', 'Tiếp nhận', 'Lọc thô'][i % 3],
        'Luuluong': '${300 + (i * 30)} GPM',
        'Nam_sx': '${1995 + (i % 20)}',
        'SoSN': 'F${10000 + i * 3}-${i + 5}',
        'Hang_loc': ['Facet', 'Parker', 'Donaldson'][i % 3],
      });
    }
    allData.assignAll(mockData);
    _applySearchAndPagination();
  }
}

// ====== COLUMN SETTINGS SHEET ======
class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({required this.vm});
  final BaulocDetailCNKVViewModel vm;

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
                        _switch('Tên bầu lọc', vm.showTenBauLoc),
                        _switch('Chức năng', vm.showChucNang),
                        _switch('Lưu lượng định danh', vm.showLuuLuong),
                        _switch('Năm sản xuất', vm.showNamSX),
                        _switch('Số nhận dạng', vm.showSoSN),
                        _switch('Model lọc', vm.showModelLoc),
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
                          vm.showTenBauLoc.value = true;
                          vm.showChucNang.value = true;
                          vm.showLuuLuong.value = true;
                          vm.showNamSX.value = true;
                          vm.showSoSN.value = true;
                          vm.showModelLoc.value = true;
                          // ⭐ Gọi update sau khi reset
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

  Widget _switch(String title, RxBool bind) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Obx(() => Switch(
            value: bind.value,
            onChanged: (v) {
              bind.value = v;
              // ⭐ Gọi update khi switch thay đổi
              // Sử dụng Get.find để gọi update
              Get.find<BaulocDetailCNKVViewModel>().update();
            },
          )),
        ],
      ),
    );
  }
}