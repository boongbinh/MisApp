import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Components/ComboField.dart';
import 'package:skypec/Controller/CNMB/Kythuat/CNMBThongtinchungViewModel.dart';
import 'package:skypec/Components/KT/Thongtinchung/ChartGiohoatdongxetranapCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/ChartGiohoatdongxevantaiCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/ChartTonkhoCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/HSSSXeCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/BangBDSCtranapCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/BangBDSCvantaiCard.dart';
import 'package:skypec/Components/KT/Thongtinchung/BangchiphiCard.dart';

class CNMBThongtinchung extends GetView<CNMBThongtinchungViewModel> {
  const CNMBThongtinchung({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Thông tin chung - CNMB'),
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
                    _SearchAndFilterBar(vm: controller),
                    const SizedBox(height: 16),

                    // Card tồn kho
                    Obx(() {
                      if (controller.chartTonkhoData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return ChartTonkhoCard(
                        data: controller.chartTonkhoData.toList(),
                        title: 'CHART TỒN KHO',
                      );
                    }),
                    const SizedBox(height: 16),

                    // HSSS Xe với 3 tab
                    Obx(() {
                      if (controller.hsssXeTNData.isEmpty &&
                          controller.hsssXeVTData.isEmpty &&
                          controller.hsssKhobeData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Container(
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
                                Tab(text: 'HSSS XeTN'),
                                Tab(text: 'HSSS XeVT'),
                                Tab(text: 'HSSS Khobe'),
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
                                    title: 'HSSS XE',
                                    height: 330,
                                  ),
                                  HSSSXeCard(
                                    data: controller.hsssXeVTData.toList(),
                                    loaiXe: 'XeVT',
                                    title: 'HSSS XE',
                                    height: 330,
                                  ),
                                  HSSSXeCard(
                                    data: controller.hsssKhobeData.toList(),
                                    loaiXe: 'Khobe',
                                    title: 'HSSS XE',
                                    height: 330,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Giờ hoạt động với 2 tab
                    Container(
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
                              Tab(text: 'Xé trần'),
                              Tab(text: 'Xe vận tải'),
                            ],
                          ),
                          const Divider(height: 1, thickness: 1),
                          SizedBox(
                            height: 400,
                            child: TabBarView(
                              children: [
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
                                    title: 'GIỜ HOẠT ĐỘNG XÉ TRẦN',
                                    height: 350,
                                  );
                                }),
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
                                    title: 'GIỜ HOẠT ĐỘNG XE VẬN TẢI',
                                    height: 350,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bảng BĐSC trần
                    Obx(() {
                      if (controller.bangBDSCtranapData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return BangBDSCtranapCard(
                        data: controller.bangBDSCtranapData.toList(),
                        title: 'BẢNG BĐSC TRẦN',
                        monthYear: '${controller.selectedMonth.value}/${controller.selectedYear.value}',
                      );
                    }),
                    const SizedBox(height: 16),

                    // Bảng BĐSC vận tải
                    Obx(() {
                      if (controller.bangBDSCvantaiData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return BangBDSCvantaiCard(
                        data: controller.bangBDSCvantaiData.toList(),
                        title: 'BẢNG BĐSC VẬN TẢI',
                        monthYear: '${controller.selectedMonth.value}/${controller.selectedYear.value}',
                      );
                    }),
                    const SizedBox(height: 16),

                    // Bảng chi phí
                    Obx(() {
                      if (controller.bangChiphiData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return BangchiphiCard(
                        data: controller.bangChiphiData.toList(),
                        title: 'BẢNG CHI PHÍ',
                      );
                    }),
                    const SizedBox(height: 80),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ====== SEARCH & FILTER BAR ======
class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.vm});
  final CNMBThongtinchungViewModel vm;

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
  final CNMBThongtinchungViewModel vm;

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
              controller: vm.searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm...',
                border: InputBorder.none,
              ),
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.vm});
  final CNMBThongtinchungViewModel vm;

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
  static Future<void> open(BuildContext context, CNMBThongtinchungViewModel vm) async {
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
  final CNMBThongtinchungViewModel vm;

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