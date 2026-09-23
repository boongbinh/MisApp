// views/anninh_theodoi_xnt_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Controller/AnNinh/ANNINHTheodoiXNTViewModel.dart';
import 'package:skypec/Components/AnNinh/TheodoiXNTCard.dart';

class ANNINHTheodoiXNT extends GetView<ANNINHTheodoiXNTViewModel> {
  const ANNINHTheodoiXNT({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Theo dõi XNT kho cảng'),
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
                  // ⭐ Filter bar
                  _FilterBar(vm: controller),
                  const SizedBox(height: 12),

                  // Bảng dữ liệu
                  Obx(() {
                    if (controller.theodoiXNTkhoCang.isEmpty) {
                      return Container(
                        height: 200,
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
                        child: const Center(
                          child: Text(
                            'Không có dữ liệu',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return TheodoiXNTCard(
                      data: controller.theodoiXNTkhoCang.toList(),
                      title:
                          'THEO DÕI XNT KHO CẢNG - ${controller.displayDate}',
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
  final ANNINHTheodoiXNTViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Hiển thị ngày đã chọn
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
            child:
                const Icon(Icons.tune, size: 20, color: Color(0xFF1F2A37)),
          ),
        ),
      ],
    );
  }
}

// ==================== FILTER SHEET ====================
class _FilterSheet extends StatefulWidget {
  static Future<void> open(
      BuildContext context, ANNINHTheodoiXNTViewModel vm) async {
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
  final ANNINHTheodoiXNTViewModel vm;

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

            // Ngày
            _dateField(
              label: 'Ngày',
              date: vm.filterNgay.value,
              onTap: () =>
                  _pickDate(context, vm.filterNgay.value, vm.setFilterNgay),
            ),
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