import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Components/ComboField.dart';
import 'package:skypec/Controller/CNMN/Kythuat/CNMNPhantichchiphiViewModel.dart';
import 'package:skypec/Components/KT/Phantichchiphi/ChiphitranapCard.dart';
import 'package:skypec/Components/KT/Phantichchiphi/ChiphixevantaiCard.dart';
import 'package:skypec/Components/KT/Phantichchiphi/BangchiphitranapCard.dart';
import 'package:skypec/Components/KT/Phantichchiphi/BangchiphixevantaiCard.dart';
import 'package:skypec/Components/KT/Phantichchiphi/BangchiphikhacCard.dart';

class CNMNPhantichchiphi extends GetView<CNMNPhantichchiphiViewModel> {
  const CNMNPhantichchiphi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Phân tích chi phí - CNMN'),
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
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    _SearchAndFilterBar(vm: controller),
                    const SizedBox(height: 16),

                    // Date Range
                    _DateRangeCard(vm: controller),
                    const SizedBox(height: 16),

                    // Main KPI Card
                    _MainKpiCard(vm: controller),
                    const SizedBox(height: 16),

                    // Secondary Metrics
                    _SecondaryMetricGrid(vm: controller),
                    const SizedBox(height: 16),


                    // Chi phí tra nạp chart
                    Obx(() {
                      final dataList = controller.getChiphiTraNapData();
                      if (dataList.isEmpty) return const SizedBox.shrink();
                      return ChiphitranapCard(
                        dataList: dataList,
                        title: 'CHI PHÍ TRA NẠP THEO CHI NHÁNH',
                      );
                    }),
                    const SizedBox(height: 16),

                    // Chi phí xe vận tải chart
                    Obx(() {
                      final dataList = controller.getChiphiXeVanTaiData();
                      if (dataList.isEmpty) return const SizedBox.shrink();
                      return ChiphixevantaiCard(
                        dataList: dataList,
                        title: 'CHI PHÍ XE VẬN TẢI THEO CHI NHÁNH',
                      );
                    }),
                    const SizedBox(height: 16),

                    // Bảng chi phí tra nạp
                    Obx(() {
                      if (controller.bangChiPhiTraNapData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return BangchiphitranapCard(
                        data: controller.bangChiPhiTraNapData.toList(),
                        title: 'BẢNG CHI PHÍ TRA NẠP',
                      );
                    }),
                    const SizedBox(height: 16),

                    // Bảng chi phí xe vận tải
                    Obx(() {
                      if (controller.bangChiPhiXeVanTaiData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return BangchiphixevantaiCard(
                        data: controller.bangChiPhiXeVanTaiData.toList(),
                        title: 'BẢNG CHI PHÍ XE VẬN TẢI',
                      );
                    }),
                    const SizedBox(height: 16),

                    // Bảng chi phí kho bể
                    Obx(() {
                      if (controller.bangChiPhiKhoBeData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return BangchiphikhacCard(
                        data: controller.bangChiPhiKhoBeData.toList(),
                        title: 'BẢNG CHI PHÍ KHO BỂ',
                        type: 'kho_be',
                      );
                    }),
                    const SizedBox(height: 16),

                    // Bảng chi phí hàng hiểm
                    Obx(() {
                      if (controller.bangChiPhiHangHiemData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return BangchiphikhacCard(
                        data: controller.bangChiPhiHangHiemData.toList(),
                        title: 'BẢNG CHI PHÍ HÀNG HIỂM',
                        type: 'hang_hiem',
                      );
                    }),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ====== DATE RANGE CARD ======
class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({required this.vm});
  final CNMNPhantichchiphiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x30FFEBD5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFDBCA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_month, size: 16, color: Color(0xFF584237)),
          const SizedBox(width: 8),
          Obx(() => Text(
            'update : ${vm.dateRange}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF584237)),
          )),
        ],
      ),
    );
  }
}

// ====== MAIN KPI CARD ======
class _MainKpiCard extends StatelessWidget {
  const _MainKpiCard({required this.vm});
  final CNMNPhantichchiphiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFDBCA)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFDBCA)),
            ),
            child: const Icon(Icons.car_repair, size: 32, color: Color(0xFF9D4300)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Obx(() => Text(
                      vm.formatNumber(vm.tongCPKT.value),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF97316),
                        letterSpacing: -0.02,
                      ),
                    )),
                    const SizedBox(width: 4),
                    const Text('VND', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF97316))),
                  ],
                ),
                const Text('Tổng số chi phí kỹ thuật xe', style: TextStyle(fontSize: 14, color: Color(0xFF584237))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====== SECONDARY METRIC GRID ======
class _SecondaryMetricGrid extends StatelessWidget {
  const _SecondaryMetricGrid({required this.vm});
  final CNMNPhantichchiphiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.assignment_turned_in,
            iconColor: const Color(0xFF006C49),
            value: vm.formatNumber(vm.tongCPGHD.value),
            unit: 'VND',
            label: 'Tổng chi phí /\ngiờ hoạt động',
            color: const Color(0xFF006C49),
            backgroundColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFDCFCE7),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MetricCard(
            icon: Icons.speed,
            iconColor: const Color(0xFF006C49),
            value: vm.formatNumber(vm.tongCPGHDVC.value),
            unit: 'VND',
            label: 'Tổng chi phí /\nkm hoạt động',
            color: const Color(0xFF006C49),
            backgroundColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFDCFCE7),
          ),
        ),
      ],
    );
  }
}

// ====== METRIC CARD ======
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final String label;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(unit, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF584237), height: 1.3)),
        ],
      ),
    );
  }
}

// ====== SEARCH & FILTER BAR ======
class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.vm});
  final CNMNPhantichchiphiViewModel vm;

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
  final CNMNPhantichchiphiViewModel vm;

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
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.vm});
  final CNMNPhantichchiphiViewModel vm;

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
  static Future<void> open(BuildContext context, CNMNPhantichchiphiViewModel vm) async {
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
  final CNMNPhantichchiphiViewModel vm;

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
                    label: 'Từ tháng',
                    value: vm.filterFromMonth.value.toString().padLeft(2, '0'),
                    onTap: () => _pickMonth(context, initial: vm.filterFromMonth.value, onSelected: vm.setFromMonth),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ComboField(
                    label: 'Đến tháng',
                    value: vm.filterToMonth.value.toString().padLeft(2, '0'),
                    onTap: () => _pickMonth(context, initial: vm.filterToMonth.value, onSelected: vm.setToMonth),
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