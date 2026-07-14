import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Components/ComboField.dart';
import 'package:skypec/Controller/KT/BaoCao/QT70/Phuongtien/HSSS_Tuan_XVTViewModel.dart';

class HSSS_Tuan_XVT extends GetView<HSSS_Tuan_XVTViewModel> {
  const HSSS_Tuan_XVT({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('THEO DÕI HSSS XE VẬN TẢI'),
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
                  _SearchAndFilterBar(vm: controller),
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
                          _TableHeader(),
                          const Divider(height: 1),
                          Expanded(
                            child: Obx(() {
                              if (controller.filteredData.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'Không có dữ liệu',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              final totals = controller.calculateTotals();

                              return Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: controller.filteredData.length,
                                      itemBuilder: (_, index) {
                                        final item = controller.filteredData[index];
                                        return Container(
                                          color: index % 2 == 0 ? Colors.white : const Color(0xFFF8F9FA),
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          child: Row(
                                            children: [
                                              _BodyCell('${index + 1}', flex: 0.5),
                                              _BodyCell(item['Chinhanh']?.toString() ?? '', flex: 1.0),
                                              _BodyCell(item['Sanbay']?.toString() ?? '', flex: 1.0),
                                              _BodyCell(controller.formatNumber(item['Soluongxe']), flex: 1.0),
                                              _BodyCell(controller.formatNumber(item['Giotuan']), flex: 1.0),
                                              _BodyCell(controller.formatNumber(item['Gionamxuong']), flex: 1.0),
                                              _BodyCell(controller.formatNumber(item['Gioxetot']), flex: 1.0),
                                              _BodyCell(controller.formatHSSS(item['HSSS']), flex: 0.8),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Dòng tổng
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    color: const Color(0xFFE8EEF5),
                                    child: Row(
                                      children: [
                                        _BodyCell(
                                          'Tổng',
                                          flex: 0.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        _BodyCell('', flex: 1.0),
                                        _BodyCell('', flex: 1.0),
                                        _BodyCell(
                                          controller.formatNumber(totals['Soluongxe']),
                                          flex: 1.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        _BodyCell(
                                          controller.formatNumber(totals['Giotuan']),
                                          flex: 1.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        _BodyCell(
                                          controller.formatNumber(totals['Gionamxuong']),
                                          flex: 1.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        _BodyCell(
                                          controller.formatNumber(totals['Gioxetot']),
                                          flex: 1.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        _BodyCell(
                                          controller.formatHSSS(totals['HSSS']),
                                          flex: 0.8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
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

// ====== SEARCH & FILTER BAR ======
class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.vm});
  final HSSS_Tuan_XVTViewModel vm;

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
  final HSSS_Tuan_XVTViewModel vm;

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

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.vm});
  final HSSS_Tuan_XVTViewModel vm;

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
  static Future<void> open(BuildContext context, HSSS_Tuan_XVTViewModel vm) async {
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
  final HSSS_Tuan_XVTViewModel vm;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late int tempYear;
  late int tempWeek;

  @override
  void initState() {
    super.initState();
    final vm = widget.vm;
    tempYear = vm.filterYear.value;
    tempWeek = vm.filterWeek.value;
  }

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
                    label: 'Năm',
                    value: tempYear.toString(),
                    onTap: () => _pickYear(context, initial: tempYear, onSelected: (val) => setState(() => tempYear = val)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ComboField(
                    label: 'Tuần',
                    value: 'Tuần $tempWeek',
                    onTap: () => _pickWeek(context, initial: tempWeek, onSelected: (val) => setState(() => tempWeek = val)),
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
                      vm.setFilterYear(tempYear);
                      vm.setFilterWeek(tempWeek);
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

  Future<void> _pickYear(
    BuildContext context, {
    required int initial,
    required ValueChanged<int> onSelected,
  }) async {
    final years = List.generate(6, (i) => 2023 + i);
    final sel = await _showListPicker<int>(
      context,
      title: 'Chọn năm',
      items: years,
      display: (y) => y.toString(),
      initial: years.indexOf(initial.clamp(2023, 2028)),
    );
    if (sel != null) onSelected(sel);
  }

  Future<void> _pickWeek(
    BuildContext context, {
    required int initial,
    required ValueChanged<int> onSelected,
  }) async {
    final weeks = List.generate(53, (i) => i + 1);
    final sel = await _showListPicker<int>(
      context,
      title: 'Chọn tuần',
      items: weeks,
      display: (w) => 'Tuần $w',
      initial: weeks.indexOf(initial.clamp(1, 53)),
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

// ====== TABLE HEADER ======
class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF4D73B2),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          _HeaderCell('STT', flex: 0.5),
          _HeaderCell('CHI NHÁNH', flex: 1.0),
          _HeaderCell('SÂN BAY', flex: 1.0),
          _HeaderCell('SỐ LƯỢNG XE', flex: 1.0),
          _HeaderCell('GIỜ TRONG TUẦN', flex: 1.0),
          _HeaderCell('GIỜ NẰM XƯỞNG', flex: 1.0),
          _HeaderCell('GIỜ XE TỐT', flex: 1.0),
          _HeaderCell('HSSS', flex: 0.8),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final double flex;

  const _HeaderCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex.toInt(),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  final double flex;
  final FontWeight? fontWeight;
  final AlignmentGeometry? alignment;

  const _BodyCell(
    this.text, {
    required this.flex,
    this.fontWeight,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex.toInt(),
      child: Container(
        alignment: alignment ?? Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: fontWeight ?? FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}