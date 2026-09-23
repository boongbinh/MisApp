// views/ansanluongchuyenbay_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Controller/AnNinh/ANSanluongchuyenbayViewModel.dart';
import 'package:skypec/Components/AnNinh/BangSanluongchuyenbayCard.dart';

class ANSanluongchuyenbay extends GetView<ANSanluongchuyenbayViewModel> {
  const ANSanluongchuyenbay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('SẢN LƯỢNG CHUYẾN BAY'),
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
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  // Filter bar chỉ có nút filter
                  _FilterBar(vm: controller),
                  const SizedBox(height: 12),

                  // Bảng sản lượng chuyến bay
                  Obx(() {
                    if (controller.sanLuongChuyenBay.isEmpty) {
                      return Container(
                        height: 200,
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
                    return BangSanluongchuyenbayCard(
                      data: controller.sanLuongChuyenBay.toList(),
                      title: 'BẢNG SẢN LƯỢNG CHUYẾN BAY',
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

// ==================== FILTER BAR ====================
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.vm});
  final ANSanluongchuyenbayViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Hiển thị khoảng ngày hiện tại
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
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${DateFormat('dd/MM').format(vm.tuNgay.value)} - ${DateFormat('dd/MM').format(vm.denNgay.value)}',
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
        // Nút filter
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
            child: const Icon(Icons.tune, size: 20, color: Color(0xFF1F2A37)),
          ),
        ),
      ],
    );
  }
}

// ==================== FILTER SHEET ====================
class _FilterSheet extends StatefulWidget {
  static Future<void> open(BuildContext context, ANSanluongchuyenbayViewModel vm) async {
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
  final ANSanluongchuyenbayViewModel vm;

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

            // Từ ngày - Đến ngày
            Row(
              children: [
                Expanded(
                  child: _dateField(
                    label: 'Từ ngày',
                    date: vm.filterTuNgay.value,
                    onTap: () => _pickDate(context, vm.filterTuNgay.value, vm.setFilterTuNgay),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateField(
                    label: 'Đến ngày',
                    date: vm.filterDenNgay.value,
                    onTap: () => _pickDate(context, vm.filterDenNgay.value, vm.setFilterDenNgay),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Chi nhánh
            Obx(() => _singleSelect(
              'Chi nhánh',
              vm.chiNhanhOptions,
              vm.filterChiNhanh,
              vm.setFilterChiNhanh,
            )),
            const SizedBox(height: 12),

            // Sân bay
            Obx(() => _singleSelect(
              'Sân bay',
              vm.sanBayOptions,
              vm.filterSanBay,
              vm.setFilterSanBay,
            )),
            const SizedBox(height: 16),

            // Buttons
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
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _singleSelect(
    String label,
    RxList<Option> options,
    RxString selected,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showSingleSelectSheet(context, label, options, selected.value, onChanged),
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
                Text(
                  selected.value == '%'
                      ? 'Tất cả'
                      : (options.firstWhere((o) => o.value == selected.value,
                          orElse: () => const Option('%', 'Tất cả')).label),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
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

  void _showSingleSelectSheet(
    BuildContext context,
    String title,
    RxList<Option> options,
    String currentValue,
    Function(String) onChanged,
  ) async {
    final sel = await showModalBottomSheet<String>(
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
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final opt = options[i];
                  final isSel = opt.value == currentValue;
                  return ListTile(
                    onTap: () => Navigator.pop(context, opt.value),
                    leading: isSel
                        ? const Icon(Icons.radio_button_checked, color: Color(0xFF2563EB))
                        : const Icon(Icons.radio_button_off, color: Color(0xFF9CA3AF)),
                    title: Text(opt.label),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (sel != null) onChanged(sel);
  }
}