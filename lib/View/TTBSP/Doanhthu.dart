import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/TTBSP/TtbspDoanhthuViewModel.dart';

import 'package:skypec/components/TTBSP/Doanhthu/DoanhthuKhCard.dart';
import 'package:skypec/components/TTBSP/Doanhthu/DoanhthuCacthangCard.dart';
import 'package:skypec/components/TTBSP/Doanhthu/CocauDoanhthuCard.dart';
import 'package:skypec/components/TTBSP/Doanhthu/ChitietDoanhthuCard.dart';
class Doanhthu extends GetView<TtbspDoanhthuViewModel> {
  const Doanhthu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Doanh thu'),
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
              if (controller.loading.value) return const Center(child: CircularProgressIndicator());
              if (controller.error.isNotEmpty) return Center(child: Text(controller.error.value));
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _SearchAndFilterBar(vm: controller),
                  const SizedBox(height: 12),
                  // Cơ cấu doanh thu
                  CocauDoanhthuCard(
                    dataList: controller.cocauDataList,
                    title: 'Cơ cấu doanh thu',
                  ),
                  const SizedBox(height: 16),
                  // Doanh thu theo KH
                  DoanhthuKhCard(
                    dataList: controller.doanhthuKhDataList,
                    title: 'Doanh thu theo Khách hàng',
                  ),
                  const SizedBox(height: 16),
                  // Doanh thu các tháng
                  DoanhthuCacthangCard(
                  data: controller.monthlyRevenueData,
                  donViTien: controller.selectedDonViTien.value,
                ),

                //chi tiết doanh thu
                  const SizedBox(height: 16),
                  //const Text('Chi tiết doanh thu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF001E40))),
                  const Text('Chi tiết doanh thu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF))),
                  const SizedBox(height: 8),
ChitietDoanhthuGrid(
  items: controller.chiTietItems.toList(),
  donViTien: controller.selectedDonViTien.value,
),

                  const SizedBox(height: 160),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ==================== SEARCH & FILTER BAR ====================
class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.vm});
  final TtbspDoanhthuViewModel vm;

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
  final TtbspDoanhthuViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Option>(
      optionsBuilder: (TextEditingValue tv) {
        if (tv.text.isEmpty) return const Iterable<Option>.empty();
        final lower = tv.text.toLowerCase();
        return vm.allFilterOptions.where((opt) => opt.label.toLowerCase().contains(lower));
      },
      onSelected: (opt) => vm.onSearchSelected(opt),
      fieldViewBuilder: (_, ctrl, focusNode, __) => SizedBox(
        height: 40,
        child: TextField(
          controller: ctrl,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: ctrl.text.isNotEmpty ? IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () { ctrl.clear(); vm.searchCtrl.clear(); },
            ) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5EAF2))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5EAF2))),
          ),
        ),
      ),
      optionsViewBuilder: (_, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300, maxWidth: MediaQuery.of(context).size.width - 32),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: options.length,
              itemBuilder: (_, i) {
                final opt = options.elementAt(i);
                return ListTile(dense: true, title: Text(opt.label), onTap: () => onSelected(opt));
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
  final TtbspDoanhthuViewModel vm;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _FilterSheet.open(context, vm),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40, width: 40,
        decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5EAF2))),
        child: const Icon(Icons.tune, size: 20, color: Color(0xFF1F2A37)),
      ),
    );
  }
}

// ==================== FILTER SHEET ====================
class _FilterSheet extends StatefulWidget {
  static Future<void> open(BuildContext context, TtbspDoanhthuViewModel vm) async {
    await showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (_) => _FilterSheet(vm: vm));
  }
  const _FilterSheet({required this.vm});
  final TtbspDoanhthuViewModel vm;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(height: 4, width: 42, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(99))),
          const Text('Bộ lọc', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _monthField('Tháng', vm.filterMonth.value, vm.filterYear.value, onTap: () => _pickMonth(context, vm))),
            const SizedBox(width: 12),
            Expanded(child: _yearField(vm.filterYear.value, onTap: () => _pickYear(context, vm))),
          ]),
          const SizedBox(height: 12),
          Obx(() => _singleSelect('Sân bay', vm.sanbayOptions, vm.filterSanbay, vm.setFilterSanbay)),
          const SizedBox(height: 12),
          Obx(() => _singleSelect('Nhóm KH', vm.nhomkhOptions, vm.filterNhomKH, vm.setFilterNhomKH)),
          const SizedBox(height: 12),
          Obx(() => _multiSelect('Khách hàng', vm.filteredKhOptions, vm.filterKH, (val) => vm.filterKH.assignAll(val))),          
          //Obx(() => _multiSelectKhachhang('Khách hàng', vm.filteredKhOptions, vm.filterKH, (val) => vm.filterKH.assignAll(val))),
          const SizedBox(height: 12),
          Obx(() => _singleSelect('Đơn vị tiền', vm.donvitienOptions, vm.filterDonViTien, vm.setFilterDonViTien)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: vm.resetFilters, child: const Text('Đặt lại'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(onPressed: () { vm.applyFilters(); Navigator.pop(context); }, child: const Text('Áp dụng'))),
          ]),
        ]),
      ),
    );
  }

  Widget _monthField(String label, int month, int year, {required VoidCallback onTap}) => InkWell(
    onTap: onTap,
    child: Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF7F8FA), border: Border.all(color: const Color(0xFFE5EAF2)), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [Text(label), const Spacer(), Text('${month.toString().padLeft(2, '0')}/$year', style: const TextStyle(fontWeight: FontWeight.w700)), const Icon(Icons.keyboard_arrow_down, size: 18)]),
    ),
  );
  Widget _yearField(int year, {required VoidCallback onTap}) => InkWell(
    onTap: onTap,
    child: Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF7F8FA), border: Border.all(color: const Color(0xFFE5EAF2)), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [const Text('Năm'), const Spacer(), Text('$year', style: const TextStyle(fontWeight: FontWeight.w700)), const Icon(Icons.keyboard_arrow_down, size: 18)]),
    ),
  );
  Widget _singleSelect(String label, RxList<Option> options, RxString selected, Function(String) onChanged) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      const SizedBox(height: 6),
      InkWell(
        onTap: () => _showSingleSelectSheet(context, label, options, selected.value, onChanged),
        child: Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF7F8FA), border: Border.all(color: const Color(0xFFE5EAF2)), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [Text(selected.value, style: const TextStyle(fontWeight: FontWeight.w700)), const Spacer(), const Icon(Icons.arrow_drop_down)]),
        ),
      ),
    ],
  );

Widget _multiSelect(String label, RxList<KhachhangOption> options, RxList<String> selected, Function(List<String>) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      const SizedBox(height: 6),
      InkWell(
        onTap: () => _showMultiSelectSheet(context, label, options, selected, onChanged),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF7F8FA), border: Border.all(color: const Color(0xFFE5EAF2)), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Text(selected.isEmpty ? 'Tất cả' : selected.join(', '), style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ]),
        ),
      ),
    ],
  );
}

  //multiple select cho lhasch hàng
    Widget _multiSelectKhachhang(String label, RxList<KhachhangOption> options, RxList<String> selected, Function(List<String>) onChanged) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _showMultiSelectSheetKhachhang(context, label, options, selected, onChanged),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFFF7F8FA), border: Border.all(color: const Color(0xFFE5EAF2)), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Text(selected.isEmpty ? 'Tất cả' : selected.join(', '), style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ]),
            ),
          ),
        ],
      );
    }

    Future<void> _showMultiSelectSheetKhachhang(
      BuildContext context,
      String title,
      RxList<KhachhangOption> options,
      RxList<String> selected,
      Function(List<String>) onChanged,
    ) async {
      final temp = selected.toList();
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => StatefulBuilder(builder: (ctx, setSheetState) {
          return SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              Flexible(child: ListView.builder(shrinkWrap: true, itemCount: options.length, itemBuilder: (_, i) {
                final opt = options[i];
                final checked = temp.contains(opt.value);
                return CheckboxListTile(
                  value: checked,
                  onChanged: (b) { setSheetState(() { if (b == true) temp.add(opt.value); else temp.remove(opt.value); }); },
                  title: Text(opt.label),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              })),
              Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => setSheetState(() => temp.clear()), child: const Text('Bỏ chọn'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () { onChanged(temp); Navigator.pop(ctx); }, child: const Text('Xong'))),
              ])),
            ]),
          );
        }),
      );
    }


  void _pickMonth(BuildContext context, TtbspDoanhthuViewModel vm) async {
    final sel = await _showListPicker(context, title: 'Chọn tháng', items: List.generate(12, (i) => i+1), display: (m) => m.toString().padLeft(2, '0'), initial: vm.filterMonth.value-1);
    if (sel != null) vm.setFilterMonth(sel);
  }
  void _pickYear(BuildContext context, TtbspDoanhthuViewModel vm) async {
    final nowY = DateTime.now().year;
    final years = List.generate(20, (i) => nowY - 19 + i);
    final sel = await _showListPicker(context, title: 'Chọn năm', items: years, display: (y) => y.toString(), initial: years.indexOf(vm.filterYear.value));
    if (sel != null) vm.setFilterYear(sel);
  }
  Future<T?> _showListPicker<T>(BuildContext context, {required String title, required List<T> items, required String Function(T) display, int? initial}) async {
    int current = (initial ?? 0).clamp(0, items.length-1);
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Flexible(child: ListView.builder(shrinkWrap: true, itemCount: items.length, itemBuilder: (ctx, i) {
            final isSel = i == current;
            return ListTile(
              onTap: () => Navigator.pop(ctx, items[i]),
              leading: isSel ? const Icon(Icons.radio_button_checked, color: Color(0xFF2563EB)) : const Icon(Icons.radio_button_off, color: Color(0xFF9CA3AF)),
              title: Text(display(items[i]), style: TextStyle(fontWeight: isSel ? FontWeight.w700 : FontWeight.w400)),
            );
          })),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
  void _showSingleSelectSheet(BuildContext context, String title, RxList<Option> options, String currentValue, Function(String) onChanged) async {
    final sel = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Flexible(child: ListView.builder(shrinkWrap: true, itemCount: options.length, itemBuilder: (_, i) {
            final opt = options[i];
            final isSel = opt.value == currentValue;
            return ListTile(
              onTap: () => Navigator.pop(context, opt.value),
              leading: isSel ? const Icon(Icons.radio_button_checked, color: Color(0xFF2563EB)) : const Icon(Icons.radio_button_off, color: Color(0xFF9CA3AF)),
              title: Text(opt.label),
            );
          })),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (sel != null) onChanged(sel);
  }


  Future<void> _showMultiSelectSheet(BuildContext context, String title, RxList<KhachhangOption> options, RxList<String> selected, Function(List<String>) onChanged) async {
  final temp = selected.toList();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => StatefulBuilder(builder: (ctx, setSheetState) {
      return SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Flexible(child: ListView.builder(shrinkWrap: true, itemCount: options.length, itemBuilder: (_, i) {
            final opt = options[i];
            final checked = temp.contains(opt.value);
            return CheckboxListTile(
              value: checked,
              onChanged: (b) { setSheetState(() { if (b == true) temp.add(opt.value); else temp.remove(opt.value); }); },
              title: Text(opt.label),
              controlAffinity: ListTileControlAffinity.leading,
            );
          })),
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => setSheetState(() => temp.clear()), child: const Text('Bỏ chọn'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(onPressed: () { onChanged(temp); Navigator.pop(ctx); }, child: const Text('Xong'))),
          ])),
        ]),
      );
    }),
  );
}
}

