// views/atcl_baocaotunguyen_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Controller/Atcl/AtclBaocaotunguyenViewModel.dart';
import 'package:skypec/Components/Atcl/Baocaotunguyen/BaocaotunguyenChart.dart';
import 'package:skypec/Components/Atcl/Baocaongay/DanhgiabaocaongayCard.dart';

class AtclBaocaotunguyen extends GetView<AtclBaocaotunguyenViewModel> {
  const AtclBaocaotunguyen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('BÁO CÁO TỰ NGUYỆN TỔNG HỢP'),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refreshData,
          ),
        ],
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
              if (controller.error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.error.value,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.refreshData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // ⭐ Filter Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _FilterBar(vm: controller),
                  ),
                  const SizedBox(height: 12),

                  // Nội dung scroll
                  Expanded(
                    child: Obx(() {
                      if (controller.allowedKhuVucs.isEmpty) {
                        return const Center(
                          child: Text(
                            'Không có dữ liệu',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ═══════════════════════════════
                            // SECTION 1: BÁO CÁO NGÀY (BaocaotunguyenChart)
                            // ═══════════════════════════════
                            const _SectionHeader(
                              title: 'BÁO CÁO TỰ NGUYỆN TỔNG HỢP NGÀY',
                              icon: Icons.today,
                            ),
                            const SizedBox(height: 8),
                            const _KhuVucChartSection(isThang: false),
                            const SizedBox(height: 32),

                            // ═══════════════════════════════
                            // SECTION 2: BÁO CÁO THÁNG (BaocaotunguyenChart)
                            // ═══════════════════════════════
                            const _SectionHeader(
                              title: 'BÁO CÁO TỰ NGUYỆN TỔNG HỢP THÁNG',
                              icon: Icons.calendar_month,
                            ),
                            const SizedBox(height: 8),
                            const _KhuVucChartSection(isThang: true),
                            const SizedBox(height: 32),

                            // ═══════════════════════════════
                            // SECTION 3: CHUYỂN THÀNH HIRA THEO NGÀY
                            // ═══════════════════════════════
                            const _SectionHeader(
                              title: 'CHUYỂN THÀNH HIRA THEO NGÀY',
                              icon: Icons.check_circle_outline,
                            ),
                            const SizedBox(height: 8),
                            const _KetQuaXuLySection(isThang: false),
                            const SizedBox(height: 32),

                            // ═══════════════════════════════
                            // SECTION 4: CHUYỂN THÀNH HIRA THEO THÁNG
                            // ═══════════════════════════════
                            const _SectionHeader(
                              title: 'CHUYỂN THÀNH HIRA THEO THÁNG',
                              icon: Icons.assignment_turned_in_outlined,
                            ),
                            const SizedBox(height: 8),
                            const _KetQuaXuLySection(isThang: true),

                            const SizedBox(height: 80),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FILTER BAR
// ═══════════════════════════════════════════════════════════
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.vm});
  final AtclBaocaotunguyenViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.displayDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2A37),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
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
            child:
                const Icon(Icons.tune, size: 20, color: Color(0xFF1F2A37)),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FILTER SHEET
// ═══════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  static Future<void> open(
      BuildContext context, AtclBaocaotunguyenViewModel vm) async {
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
  final AtclBaocaotunguyenViewModel vm;

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
            const Text('Bộ lọc',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _dateField(
              label: 'Ngày',
              date: vm.filterNgay.value,
              onTap: () => _pickDate(
                  context, vm.filterNgay.value, vm.setFilterNgay),
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

  Widget _dateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          border: Border.all(color: const Color(0xFFE5EAF2)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            const Spacer(),
            Text(
              DateFormat('dd/MM/yyyy').format(date),
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    DateTime initialDate,
    ValueChanged<DateTime> onSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) onSelected(picked);
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F7BD8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION CHART CŨ (BaocaotunguyenChart)
// ═══════════════════════════════════════════════════════════
class _KhuVucChartSection extends GetView<AtclBaocaotunguyenViewModel> {
  final bool isThang;
  const _KhuVucChartSection({required this.isThang});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final khuVucs = controller.allowedKhuVucs;
      if (khuVucs.isEmpty) return const SizedBox.shrink();

      final selected = isThang
          ? controller.selectedKhuVucThang.value
          : controller.selectedKhuVucNgay.value;
      if (selected == null) return const SizedBox.shrink();

      final data = isThang
          ? controller.getCurrentDataThang(selected)
          : controller.getCurrentDataNgay(selected);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (khuVucs.length > 1) ...[
            _KhuVucTabBar(
              khuVucs: khuVucs,
              selected: selected,
              onSelect: isThang
                  ? controller.selectKhuVucThang
                  : controller.selectKhuVucNgay,
            ),
            const SizedBox(height: 12),
          ],
          if (data.isEmpty)
            const _EmptyChart()
          else
            BaocaotunguyenChart(
              dataList: data,
              title: isThang
                  ? 'BÁO CÁO TỔNG HỢP THÁNG - ${selected.label}'
                  : 'BÁO CÁO TỔNG HỢP NGÀY - ${selected.label}',
            ),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION KẾT QUẢ XỬ LÝ (DanhgiabaocaongayCard)
// ═══════════════════════════════════════════════════════════
class _KetQuaXuLySection extends GetView<AtclBaocaotunguyenViewModel> {
  final bool isThang;
  const _KetQuaXuLySection({required this.isThang});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final khuVucs = controller.allowedKhuVucs;
      if (khuVucs.isEmpty) return const SizedBox.shrink();

      final selected = isThang
          ? controller.selectedKhuVucXuLyThang.value
          : controller.selectedKhuVucXuLyNgay.value;
      if (selected == null) return const SizedBox.shrink();

      final data = isThang
          ? controller.getDanhGiaThang(selected)
          : controller.getDanhGiaNgay(selected);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (khuVucs.length > 1) ...[
            _KhuVucTabBar(
              khuVucs: khuVucs,
              selected: selected,
              onSelect: isThang
                  ? controller.selectKhuVucXuLyThang
                  : controller.selectKhuVucXuLyNgay,
            ),
            const SizedBox(height: 12),
          ],
          if (data.isEmpty || !data.any((e) => e.value > 0))
            const _EmptyChart()
          else
            DanhgiabaocaongayCard(
              dataList: data,
              title: isThang
                  ? 'CHUYỂN THÀNH HIRA THÁNG - ${selected.label}'
                  : 'CHUYỂN THÀNH HIRA NGÀY - ${selected.label}',
            ),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════
// TAB BAR
// ═══════════════════════════════════════════════════════════
class _KhuVucTabBar extends StatelessWidget {
  final List<KhuVuc> khuVucs;
  final KhuVuc selected;
  final ValueChanged<KhuVuc> onSelect;

  const _KhuVucTabBar({
    required this.khuVucs,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(4),
      child: Row(
        children: khuVucs.map((kv) {
          final isActive = selected == kv;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(kv),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF1F7BD8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kv.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// EMPTY
// ═══════════════════════════════════════════════════════════
class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}