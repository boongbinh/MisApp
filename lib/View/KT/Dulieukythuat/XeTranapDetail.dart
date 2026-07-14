import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Controller/KT/Dulieukythuat/XeTranapDetailViewModel.dart';

// ⭐ Hàm xây dựng danh sách cột (dùng chung cho cả header và body)
List<_ColDef> _buildColDefs(XeTranapDetailViewModel vm) {
  return [
    const _ColDef('stt', 'STT', 1),
    if (vm.showChiNhanh.value) const _ColDef('chiNhanh', 'Chi nhánh', 1),
    if (vm.showBienKiemSoat.value) const _ColDef('bienKiemSoat', 'Biển kiểm soát', 2),
    if (vm.showLoaiXe.value) const _ColDef('loaiXe', 'Loại xe', 2),
    if (vm.showDungTich.value) const _ColDef('dungTich', 'Dung tích', 1),
    if (vm.showNamSX.value) const _ColDef('namSX', 'Năm SX', 1),
    if (vm.showNamSD.value) const _ColDef('namSD', 'Năm SD', 1),
    if (vm.showLLTNHong.value) const _ColDef('lltnHong', 'LLTN hông', 1),
    if (vm.showLLTNGN.value) const _ColDef('lltnGN', 'LLTN GN', 1),
    if (vm.showNgayKD.value) const _ColDef('ngayKD', 'Ngày đăng kiểm', 2),
    if (vm.showNgayKDTiep.value) const _ColDef('ngayKDTiep', 'Ngày ĐK kế tiếp', 2),
  ];
}

class XeTranapDetail extends GetView<XeTranapDetailViewModel> {
  const XeTranapDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Tổng hợp xe tra nạp'),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/images/background_inside.png',
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error.isNotEmpty) {
                return Center(child: Text(controller.error.value));
              }
              return Column(
                children: [
                  _SearchBar(vm: controller),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _TableHeader(vm: controller),
                          const Divider(height: 1),
                          Expanded(
                            child: Obx(() {
                              final currentData = controller.getCurrentPageData();
                              if (currentData.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'Không có dữ liệu',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              // ⭐ Gọi hàm _buildColDefs bên ngoài
                              final defs = _buildColDefs(controller);
                              return ListView.builder(
                                itemCount: currentData.length,
                                itemBuilder: (_, index) {
                                  final item = currentData[index];
                                  return _TableRow(
                                    index: (controller.currentPage.value - 1) * controller.pageSize.value + index + 1,
                                    item: item,
                                    defs: defs,
                                  );
                                },
                              );
                            }),
                          ),
                          _Pagination(vm: controller),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ====== SEARCH BAR ======
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.vm});
  final XeTranapDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: vm.searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm...',
                border: InputBorder.none,
              ),
            ),
          ),
          if (vm.searchCtrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18, color: Color(0xFF6B7280)),
              onPressed: () {
                vm.searchCtrl.clear();
              },
            ),
        ],
      ),
    );
  }
}

// ====== TABLE HEADER ======
class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.vm});
  final XeTranapDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ⭐ Gọi hàm _buildColDefs bên ngoài
      final defs = _buildColDefs(vm);
      return Container(
        height: 50,
        color: const Color(0xFF4D73B2),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            for (int i = 0; i < defs.length; i++)
              Expanded(
                flex: defs[i].flex,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: i == defs.length - 1
                            ? Colors.transparent
                            : const Color(0xFFE6ECF5),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        defs[i].title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      if (i == defs.length - 1)
                        IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: vm.openColumnSettings,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ====== TABLE ROW ======
class _TableRow extends StatelessWidget {
  final int index;
  final Map<String, dynamic> item;
  final List<_ColDef> defs;

  const _TableRow({
    required this.index,
    required this.item,
    required this.defs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: index % 2 == 0 ? Colors.white : const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (int i = 0; i < defs.length; i++)
            Expanded(
              flex: defs[i].flex,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: i == defs.length - 1
                          ? Colors.transparent
                          : const Color(0xFFE6ECF5),
                    ),
                  ),
                ),
                child: _cell(defs[i].key, item),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(String key, Map<String, dynamic> item) {
    final text = switch (key) {
      'stt' => index.toString(),
      'chiNhanh' => item['ChiNhanh']?.toString() ?? item['ma_sb']?.toString() ?? '--',
      'bienKiemSoat' => item['ma_xe']?.toString() ?? '--',
      'loaiXe' => item['ma_kx']?.toString() ?? '--',
      'dungTich' => item['DT_GL']?.toString() ?? '--',
      'namSX' => item['nam_sx']?.toString() ?? '--',
      'namSD' => item['Nam_sd']?.toString() ?? '--',
      'lltnHong' => item['LLTN_hong']?.toString() ?? '--',
      'lltnGN' => item['LLTN_Giannang']?.toString() ?? '--',
      'ngayKD' => _formatDate(item['Ngay_KD_GN']),
      'ngayKDTiep' => _formatDate(item['Ngay_KD_Tiep']),
      _ => '--',
    };

    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: text == '--' ? Colors.grey.shade400 : Colors.black87,
        fontWeight: text == '--' ? FontWeight.w400 : FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatDate(dynamic dateValue) {
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
}

// ====== PAGINATION ======
class _Pagination extends StatelessWidget {
  const _Pagination({required this.vm});
  final XeTranapDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = vm.totalPages;
      if (total <= 1 && vm.filteredData.length <= vm.pageSize.value) {
        return const SizedBox(height: 44);
      }

      return Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(vm.currentPage.value - 1) * vm.pageSize.value + 1} - ${(vm.currentPage.value * vm.pageSize.value).clamp(0, vm.totalItems.value)} / ${vm.totalItems.value}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: vm.currentPage.value > 1 ? vm.prevPage : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                ...List.generate(
                  total > 5 ? 5 : total,
                  (i) {
                    int pageNum;
                    if (total <= 5) {
                      pageNum = i + 1;
                    } else {
                      final current = vm.currentPage.value;
                      if (current <= 3) {
                        pageNum = i + 1;
                      } else if (current >= total - 2) {
                        pageNum = total - 4 + i;
                      } else {
                        pageNum = current - 2 + i;
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () => vm.goToPage(pageNum),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: vm.currentPage.value == pageNum
                                ? const Color(0xFF4D73B2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pageNum.toString(),
                            style: TextStyle(
                              color: vm.currentPage.value == pageNum
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: vm.currentPage.value == pageNum
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: vm.currentPage.value < total ? vm.nextPage : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ====== COLUMN DEFINITION ======
class _ColDef {
  final String key;
  final String title;
  final int flex;

  const _ColDef(this.key, this.title, this.flex);
}