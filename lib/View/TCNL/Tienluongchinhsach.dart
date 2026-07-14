import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Components/ComboField.dart';
import 'package:skypec/Controller/TCNL/TienluongchinhsachViewModel.dart';
import 'package:skypec/components/TCNL/TienLuongChinhSach/TienluongchinhsachCard.dart';
import 'package:skypec/components/TCNL/TienLuongChinhSach/TylequyluongCard.dart';


class Tienluongchinhsach extends GetView<TienluongchinhsachViewModel> {
  const Tienluongchinhsach({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Tiền lương - Chính sách'),
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

                  // Card tiền lương bình quân (dùng dữ liệu từ KPILuong)
                  _buildLuongBQCard(controller),
                  const SizedBox(height: 16),

                  // Card quỹ tiền lương
                  _buildQuyLuongCard(controller),
                  const SizedBox(height: 16),

                  // Cơ cấu chi phí nhân công
                  TylequyluongCard(
                    dataList: controller.tylequyluongiDataList.toList(),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLuongBQCard(TienluongchinhsachViewModel vm) {
    return TienLuongBinQuanCard(
      title: 'Tiền lương bình quân',
      value: vm.luongBQNamNay.value,
      planValue: vm.luongBQKH.value,
      previousYearValue: vm.luongBQNamTruoc.value,
      percentVsPlan: vm.soSanhLuongBQKH.value * 100,
      percentVsPreviousYear: vm.soSanhLuongBQNamTrc.value * 100,
      color: const Color(0xFFFDC003),
      icon: Icons.account_balance_wallet,
    );
  }

  Widget _buildQuyLuongCard(TienluongchinhsachViewModel vm) {
    return TienLuongBinQuanCard(
      title: 'Quỹ tiền lương',
      value: vm.daChiNamNay.value * 1e6, // Đã chi (triệu -> nguyên)
      planValue: vm.quyLuongKH.value * 1e6,
      previousYearValue: vm.daChiNamTruoc.value * 1e6,
      percentVsPlan: vm.soSanhQuyLuongKH.value * 100,
      percentVsPreviousYear: vm.soSanhQuyLuongNamTruoc.value * 100,
      color: const Color(0xFF003366),
      icon: Icons.account_balance,
    );
  }

  
}

// ====== SEARCH & FILTER BAR ======
class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.vm});
  final TienluongchinhsachViewModel vm;

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
  final TienluongchinhsachViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Option>(
      optionsBuilder: (TextEditingValue tv) {
        if (tv.text.isEmpty) return const Iterable<Option>.empty();
        final lower = tv.text.toLowerCase();
        return vm.allFilterOptions.where((opt) => opt.label.toLowerCase().contains(lower));
      },
      onSelected: (opt) => vm.onSearchSelected(opt),
      fieldViewBuilder: (_, ctrl, focusNode, __) => Container(
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
                controller: ctrl,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm...',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (ctrl.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 18, color: Color(0xFF6B7280)),
                onPressed: () {
                  ctrl.clear();
                  vm.searchCtrl.clear();
                },
              ),
          ],
        ),
      ),
      optionsViewBuilder: (_, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 300,
              maxWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: options.length,
              itemBuilder: (_, i) {
                final opt = options.elementAt(i);
                return ListTile(
                  dense: true,
                  title: Text(opt.label),
                  onTap: () => onSelected(opt),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.vm});
  final TienluongchinhsachViewModel vm;

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
  static Future<void> open(BuildContext context, TienluongchinhsachViewModel vm) async {
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
  final TienluongchinhsachViewModel vm;

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

            // Tháng - Năm
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
            const SizedBox(height: 12),

            // Chi nhánh (multi-select)
            _multiSelect(
              label: 'Chi nhánh',
              options: vm.chinhanhOptions,
              selected: vm.filterChinhanh,
            ),
            const SizedBox(height: 12),

            // Chức danh (multi-select)
            _multiSelect(
              label: 'Chức danh',
              options: vm.filteredChucDanhOptions,
              selected: vm.filterChucDanh,
            ),
            const SizedBox(height: 12),

            // Bộ phận (multi-select)
            _multiSelect(
              label: 'Bộ phận',
              options: vm.filteredBoPhanOptions,
              selected: vm.filterBoPhan,
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

  Widget _multiSelect({
  required String label,
  required List<Option> options,  // ⭐ Đổi từ RxList<Option> thành List<Option>
  required RxList<String> selected,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      const SizedBox(height: 6),
      InkWell(
        onTap: () => _showMultiSelectSheet(context, label, options, selected),
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
                selected.isEmpty ? 'Tất cả' : '${selected.length} mục',
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

Future<void> _showMultiSelectSheet(
  BuildContext context,
  String title,
  List<Option> options,  // ⭐ Đổi từ RxList<Option> thành List<Option>
  RxList<String> selected,
) async {
  final temp = selected.toList();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        return SafeArea(
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
                    final checked = temp.contains(opt.value);
                    return CheckboxListTile(
                      value: checked,
                      onChanged: (b) {
                        setSheetState(() {
                          if (b == true) temp.add(opt.value);
                          else temp.remove(opt.value);
                        });
                      },
                      title: Text(opt.label),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setSheetState(() => temp.clear()),
                        child: const Text('Bỏ chọn'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          selected.assignAll(temp);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Xong'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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