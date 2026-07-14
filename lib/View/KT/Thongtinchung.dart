import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Components/ComboField.dart';
import 'package:skypec/Controller/KT/ThongtinchungViewModel.dart';
import 'package:skypec/Components/KT/Thongtinchung/ChartGiohoatdongxetranapCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/ChartGiohoatdongxevantaiCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/ChartTonkhoCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/HSSSXeCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/BangchiphiCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/BangBDSCtranapCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/BangBDSCvantaiCard.dart';


class Thongtinchung extends GetView<ThongtinchungViewModel> {
  const Thongtinchung({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Thông tin chung'),
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
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  // Search và Filter Bar
                  _SearchAndFilterBar(vm: controller),
                  //bảng chi phí
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.bangChiphiData.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return BangchiphiCard(
                      data: controller.bangChiphiData.toList(),
                      title: 'CHI PHÍ',
                    );
                  }),
                //hsss 4 cái-4 tab
                  const SizedBox(height: 16),

                  // Cụm tab 1: HSSS 
                  Obx(() {
                    if (controller.hsssXeTNData.isEmpty &&
                        controller.hsssXeVTData.isEmpty &&
                        controller.hsssKhobeData.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return DefaultTabController(
                      length: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TabBar(
                              labelColor: Color(0xFF1F7BD8),
                              unselectedLabelColor: Color(0xFF6B7280),
                              indicatorColor: Color(0xFF1F7BD8),
                              indicatorWeight: 3,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              tabs: [
                                Tab(text: 'HSSS Xe tra nạp'),
                                Tab(text: 'HSSS Xe vận chuyển'),
                                Tab(text: 'HSSS Kho bể'),
                                Tab(text: 'HSSS CNTT'),
                              ],
                            ),
                            const Divider(height: 1, thickness: 1),
                            SizedBox(
                              height: 360,
                              child: TabBarView(
                                children: [
                                  HSSSXeCard(
                                    data: controller.hsssXeTNData.toList(),
                                    loaiXe: 'XeTN',
                                    title: 'HSSS Xe tra nạp',
                                    height: 330,
                                  ),
                                  HSSSXeCard(
                                    data: controller.hsssXeVTData.toList(),
                                    loaiXe: 'XeVT',
                                    title: 'HSSS Xe vận chuyển',
                                    height: 330,
                                  ),
                                  HSSSXeCard(
                                    data: controller.hsssKhobeData.toList(),
                                    loaiXe: 'Khobe',
                                    title: 'HSSS Kho bể',
                                    height: 330,
                                  ),
                                  HSSSXeCard(
                                    data: controller.hsssCNTTData.toList(),
                                    loaiXe: 'CNTT',
                                    title: 'HSSS CNTT',
                                    height: 330,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  //bảng Bảo dưỡng sửa chữa xe tra nạp
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.bangBDSCtranapData.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return BangBDSCtranapCard(
                      data: controller.bangBDSCtranapData.toList(),
                      title: 'Bảo dưỡng sửa chữa xe tra nạp',
                      monthYear: '${controller.selectedMonth.value}/${controller.selectedYear.value}',
                    );
                  }),
                  //bảng Bảo dưỡng sửa chữa xe vận tải
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.bangBDSCvantaiData.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return BangBDSCvantaiCard(
                      data: controller.bangBDSCvantaiData.toList(),
                      title: 'Bảo dưỡng sửa chữa xe vận tải',
                      monthYear: '${controller.selectedMonth.value}/${controller.selectedYear.value}',
                    );
                  }),

                  
                  //Biểu đồ giờ hoạt động 2 cái-2 tab
                  const SizedBox(height: 16),

                  // ⭐ Cụm tab 2: Giờ hoạt động (độc lập)
                  DefaultTabController(
                    length: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TabBar(
                            labelColor: Color(0xFF1F7BD8),
                            unselectedLabelColor: Color(0xFF6B7280),
                            indicatorColor: Color(0xFF1F7BD8),
                            indicatorWeight: 3,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                            tabs: [
                              Tab(text: 'Biểu đồ giờ hoạt động xe tra nạp'),
                              Tab(text: 'Biểu đồ Km hoạt động của xe vận chuyển'),
                            ],
                          ),
                          const Divider(height: 1, thickness: 1),
                          SizedBox(
                            height: 420,
                            child: TabBarView(
                              children: [
                                // Tab 1: Xé trần
                                Obx(() {
                                  if (controller.chartGioHoatDongData.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Không có dữ liệu',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    );
                                  }
                                  return ChartGiohoatdongxetranapCard(
                                    data: controller.chartGioHoatDongData.toList(),
                                    title: 'Biểu đồ giờ hoạt động xe tra nạp',
                                    height: 350,
                                  );
                                }),
                                // Tab 2: Xe vận tải
                                Obx(() {
                                  if (controller.chartGioHoatDongXeVTData.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Không có dữ liệu',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    );
                                  }
                                  return ChartGiohoatdongxevantaiCard(
                                    data: controller.chartGioHoatDongXeVTData.toList(),
                                    title: 'Biểu đồ Km hoạt động của xe vận chuyển',
                                    height: 350,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Biểu đồ tồn kho 
                  const SizedBox(height: 16),
                  // Card 1: Tồn kho
                  Obx(() {
                    if (controller.chartTonkhoData.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return ChartTonkhoCard(
                      data: controller.chartTonkhoData.toList(),
                      title: 'Biểu đồ tồn kho ',
                    );
                  }),
                  
                  const SizedBox(height: 80),
                  
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ====== SEARCH & FILTER BAR ======
class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.vm});
  final ThongtinchungViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SearchBar(vm: vm)),
        const SizedBox(width: 8),
        _FilterButton(vm: vm),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.vm});
  final ThongtinchungViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.vm});
  final ThongtinchungViewModel vm;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _FilterSheet.open(context, vm),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5EAF2)),
        ),
        child: const Icon(Icons.tune, size: 20, color: Color(0xFF1F2A37)),
      ),
    );
  }
}

// ====== FILTER SHEET ======
class _FilterSheet extends StatefulWidget {
  static Future<void> open(BuildContext context, ThongtinchungViewModel vm) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FilterSheet(vm: vm),
    );
  }
  const _FilterSheet({required this.vm});
  final ThongtinchungViewModel vm;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 42,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const Text('Bộ lọc', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ComboField(
                    label: 'Tháng',
                    value: vm.filterMonth.value.toString().padLeft(2, '0'),
                    onTap: () => _pickMonth(context, initial: vm.filterMonth.value, onSelected: vm.setFilterMonth),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ComboField(
                    label: 'Năm',
                    value: vm.filterYear.value.toString(),
                    onTap: () => _pickYear(context, initial: vm.filterYear.value, onSelected: vm.setFilterYear),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: vm.resetFilters,
                    child: const Text('Đặt lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      vm.applyFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMonth(
    BuildContext context, {
    required int initial,
    required ValueChanged<int> onSelected,
  }) async {
    final items = List.generate(12, (i) => i + 1);
    final sel = await _showListPicker<int>(
      context,
      title: 'Chọn tháng',
      items: items,
      display: (m) => m.toString().padLeft(2, '0'),
      initial: items.indexOf(initial.clamp(1, 12)),
    );
    if (sel != null) onSelected(sel);
  }

  Future<void> _pickYear(
    BuildContext context, {
    required int initial,
    required ValueChanged<int> onSelected,
  }) async {
    final nowY = DateTime.now().year;
    final years = List.generate(20, (i) => nowY - 19 + i);
    if (!years.contains(initial)) years.add(initial);
    years.sort((a, b) => b.compareTo(a));
    final sel = await _showListPicker<int>(
      context,
      title: 'Chọn năm',
      items: years,
      display: (y) => y.toString(),
      initial: years.indexOf(initial),
    );
    if (sel != null) onSelected(sel);
  }

  Future<T?> _showListPicker<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) display,
    int? initial,
  }) async {
    int current = (initial ?? 0).clamp(0, items.length - 1);
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final isSel = i == current;
                  return ListTile(
                    onTap: () => Navigator.pop(ctx, items[i]),
                    leading: isSel
                        ? const Icon(Icons.radio_button_checked, color: Color(0xFF2563EB))
                        : const Icon(Icons.radio_button_off, color: Color(0xFF9CA3AF)),
                    title: Text(
                      display(items[i]),
                      style: TextStyle(fontWeight: isSel ? FontWeight.w700 : FontWeight.w400),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}