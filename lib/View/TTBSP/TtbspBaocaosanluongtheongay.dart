// views/ttbsp_baocaosanluongtheongay_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Controller/TTBSP/TtbspBaocaosanluongtheongayViewModel.dart';
import 'package:skypec/Components/TTBSP/Baocaosanluong/SanluongbanCard.dart';
import 'package:skypec/Components/TTBSP/Baocaosanluong/SanluongbantheosanbayCard.dart';

class TtbspBaocaosanluongtheongay
    extends GetView<TtbspBaocaosanluongtheongayViewModel> {
  const TtbspBaocaosanluongtheongay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('BÁO CÁO SẢN LƯỢNG THEO NGÀY'),
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
                  // Filter cố định ở trên
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _FilterSection(vm: controller),
                  ),
                  const SizedBox(height: 16),
                  // Nội dung scroll
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        children: [
                          // Card biểu đồ
                          Obx(() {
                            if (controller.sanLuongTheoNgay.isEmpty) {
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
                            return SanluongbanCard(
                              data: controller.sanLuongTheoNgay.toList(),
                              title: 'SẢN LƯỢNG BÁN',
                              height: 400,
                            );
                          }),

                          const SizedBox(height: 16),
                          // Card theo sân bay
                          Obx(() {
                            if (controller.sanLuongTheoSanBay.isEmpty) {
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
                            return SanluongbantheosanbayCard(
                              data: controller.sanLuongTheoSanBay.toList(),
                              title: 'SẢN LƯỢNG BÁN THEO SÂN BAY',
                              height: 400,
                            );
                          }),
                          
                          
                          
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
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

// ====== FILTER SECTION ======
class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.vm});
  final TtbspBaocaosanluongtheongayViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Từ ngày',
                  date: vm.tuNgay.value,
                  onTap: () =>
                      _selectDate(context, vm.tuNgay.value, vm.changeTuNgay),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'Đến ngày',
                  date: vm.denNgay.value,
                  onTap: () =>
                      _selectDate(context, vm.denNgay.value, vm.changeDenNgay),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: vm.applyFilters,
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Xem dữ liệu'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5EAF2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              DateFormat('dd/MM/yyyy').format(date),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
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
    if (picked != null) {
      onSelected(picked);
    }
  }
}