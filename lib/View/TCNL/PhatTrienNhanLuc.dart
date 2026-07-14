import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/TCNL/PhatTrienNhanLucViewModel.dart';
import 'package:skypec/components/TCNL/phatTrienNhanLuc/TuyenDungCard.dart';
import 'package:skypec/components/TCNL/phatTrienNhanLuc/ChamdutHdCard.dart';
import 'package:skypec/components/TCNL/phatTrienNhanLuc/TrinhdoDaotaoCard.dart';
import 'package:skypec/components/TCNL/phatTrienNhanLuc/DotuoiCard.dart';
import 'package:skypec/components/TCNL/phatTrienNhanLuc/ThamnienCard.dart';
import 'package:skypec/components/TCNL/phatTrienNhanLuc/PhanLoaiTochucCard.dart';
import 'package:skypec/components/TCNL/phatTrienNhanLuc/PhanLoaiCqCard.dart';

class PhatTrienNhanLuc extends GetView<PhatTrienNhanLucViewModel> {
  const PhatTrienNhanLuc({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Phát triển nguồn nhân lực'),
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
                  const SizedBox(height: 12),
                  _TotalStaffCard(vm: controller),
                  //NhansuchamdutBQ + TuyendunglaodongBQ api
                  // const SizedBox(height: 16),
                  // _HiringTurnoverRow(vm: controller),
                  //TuyenDung api
                  // const SizedBox(height: 16),
                  // _TuyenDungCard(vm: controller),
                  //ChamdutHDLD api
                  // const SizedBox(height: 16),
                  // _ChamDutCard (vm: controller),
                  const SizedBox(height: 16),
                  _StaffStructureCard(vm: controller),
                  // Phanloaidonvi api
                  // const SizedBox(height: 16),
                  // _PhanLoaiDonViTreemap(vm: controller),
                  //TDDT api
                  // const SizedBox(height: 16),
                  // _TrinhdoDaotaoCard(vm: controller),
                  const SizedBox(height: 16),
                  _PhanLoaiCQDVDonut(vm: controller),
                  // TuoiBQ api
                  const SizedBox(height: 16),
                  _DotuoiCard(vm: controller),
                  //ThamnienBQ api
                  const SizedBox(height: 16),
                  _ThamnienCard(vm: controller),
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

// ===================== SEARCH & FILTER BAR =====================
class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.vm});
  final PhatTrienNhanLucViewModel vm;

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
  final PhatTrienNhanLucViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Option>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Option>.empty();
        }
        final lower = textEditingValue.text.toLowerCase();
        return vm.allFilterOptions.where((opt) => opt.label.toLowerCase().contains(lower));
      },
      onSelected: (Option option) => vm.onSearchSelected(option),
      fieldViewBuilder: (context, textCtrl, focusNode, onFieldSubmitted) {
        // Đồng bộ với controller nếu cần
        if (vm.searchCtrl.text.isNotEmpty && textCtrl.text.isEmpty) {
          textCtrl.text = vm.searchCtrl.text;
          textCtrl.selection = TextSelection.collapsed(offset: textCtrl.text.length);
        }
        return SizedBox(
          height: 40,
          child: TextField(
            controller: textCtrl,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: textCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        textCtrl.clear();
                        vm.searchCtrl.clear();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
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
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.vm});
  final PhatTrienNhanLucViewModel vm;

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

// --------------------- BỘ LỌC (Sheet) ---------------------
class _FilterSheet extends StatefulWidget {
  static Future<void> open(BuildContext context, PhatTrienNhanLucViewModel vm) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _FilterSheet(vm: vm),
    );
  }
  const _FilterSheet({required this.vm});
  final PhatTrienNhanLucViewModel vm;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, width: 42, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(99))),
            const Text('Bộ lọc', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            // Dòng tháng/năm (giống OutputReport)
            Row(
              children: [
                //Expanded(child: _monthField('Từ tháng', vm.filterFromMonth.value, vm.filterYear.value, onTap: () => _pickMonth(context, vm, isFrom: true))),
                Expanded(child: _monthField(vm.filterToMonth.value, onTap: () => _pickMonth(context, vm, isFrom: false))),


                const SizedBox(width: 12),
                Expanded(child: _yearField(vm.filterYear.value, onTap: () => _pickYear(context, vm))),
              ],
            ),
            const SizedBox(height: 12),
            // Multi‑select filters
            // Trong _FilterSheetState, thay thế toàn bộ phần Column chứa các chip bằng:

Obx(() {
  // --- Lọc các giá trị đã chọn không hợp lệ (chạy sau khi build) ---
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final validPhong = vm.getFilteredPhongDttOptionsTemp().map((e) => e.value).toList();
    vm.filterPhongDTT.removeWhere((v) => !validPhong.contains(v));
    
    final validNhom = vm.getFilteredNhomCdOptionsTemp().map((e) => e.value).toList();
    vm.filterNhomCD.removeWhere((v) => !validNhom.contains(v));
    
    final validChuc = vm.getFilteredChucDanhOptionsTemp().map((e) => e.value).toList();
    vm.filterChucDanh.removeWhere((v) => !validChuc.contains(v));
    
    final validLoai = vm.getFilteredLoaiLaoDongOptionsTemp().map((e) => e.value).toList();
    vm.filterLoaiLaoDong.removeWhere((v) => !validLoai.contains(v));
  });
  
  return Column(
    children: [
      _MultiSelectChip(
        title: 'CQDV',
        options: vm.cqdvOptions,
        selected: vm.filterCQDV,
        onChanged: (val) => vm.filterCQDV.assignAll(val),
      ),
      const SizedBox(height: 12),
      _MultiSelectChip(
        title: 'Phòng/Đội',
        options: vm.getFilteredPhongDttOptionsTemp(),
        selected: vm.filterPhongDTT,
        onChanged: (val) => vm.filterPhongDTT.assignAll(val),
      ),
      const SizedBox(height: 12),
      _MultiSelectChip(
        title: 'Nhóm CD',
        options: vm.getFilteredNhomCdOptionsTemp(),
        selected: vm.filterNhomCD,
        onChanged: (val) => vm.filterNhomCD.assignAll(val),
      ),
      const SizedBox(height: 12),
      _MultiSelectChip(
        title: 'Chức danh',
        options: vm.getFilteredChucDanhOptionsTemp(),
        selected: vm.filterChucDanh,
        onChanged: (val) => vm.filterChucDanh.assignAll(val),
      ),
      const SizedBox(height: 12),
      _MultiSelectChip(
        title: 'Loại LĐ',
        options: vm.getFilteredLoaiLaoDongOptionsTemp(),
        selected: vm.filterLoaiLaoDong,
        onChanged: (val) => vm.filterLoaiLaoDong.assignAll(val),
      ),
    ],
  );
}),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => vm.resetFilters(), child: const Text('Đặt lại'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () { vm.applyFilters(); Navigator.pop(context); }, child: const Text('Áp dụng'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

 

    Widget _monthField(int year, {required VoidCallback onTap}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF7F8FA), border: Border.all(color: const Color(0xFFE5EAF2)), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [const Text('Tháng'), const Spacer(), Text('$year', style: const TextStyle(fontWeight: FontWeight.w700)), const Icon(Icons.keyboard_arrow_down, size: 18)]),
    ),
  );

  Widget _yearField(int year, {required VoidCallback onTap}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF7F8FA), border: Border.all(color: const Color(0xFFE5EAF2)), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [const Text('Năm'), const Spacer(), Text('$year', style: const TextStyle(fontWeight: FontWeight.w700)), const Icon(Icons.keyboard_arrow_down, size: 18)]),
    ),
  );

  
  void _pickMonth(BuildContext context, PhatTrienNhanLucViewModel vm, {required bool isFrom}) async {
    final sel = await _showListPicker(context, title: 'Chọn tháng', items: List.generate(12, (i) => i+1), display: (m) => m.toString().padLeft(2, '0'), initial: (isFrom ? vm.filterFromMonth.value : vm.filterToMonth.value)-1);
    if (sel != null) {
      if (isFrom) vm.setFromMonth(sel);
      else vm.setToMonth(sel);
    }
  }
  void _pickYear(BuildContext context, PhatTrienNhanLucViewModel vm) async {
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

  
}


// --------------------- Các card hiển thị dữ liệu ---------------------
//tổng số lao động+sử dụng bình quân
class _TotalStaffCard extends StatelessWidget {
  const _TotalStaffCard({required this.vm});
  final PhatTrienNhanLucViewModel vm;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('TỔNG SỐ LAO ĐỘNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Icon(Icons.groups, color: Color(0xFF00458F))]),
        const SizedBox(height: 12),
        Text(vm.fmt(vm.tongLaoDong.value), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('NAM', style: TextStyle(fontSize: 10)), Text(vm.fmt(vm.laoDongNam.value), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00458F)))])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('NỮ', style: TextStyle(fontSize: 10)), Text(vm.fmt(vm.laoDongNu.value), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF862300)))])),
        ]),
        const SizedBox(height: 16), const Divider(), const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('SỬ DỤNG BÌNH QUÂN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Icon(Icons.analytics, color: Color(0xFF006A60))]),
        const SizedBox(height: 8),
        Text(vm.fmt(vm.laoDongBQ.value), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: LinearProgressIndicator(value: vm.tyLeSoVoiKeHoach.value, backgroundColor: const Color(0xFFE1E3E4), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006A60)), minHeight: 8, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 8),
          Text(vm.pct(vm.tyLeSoVoiKeHoach.value), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      ]),
    ),
  );
}
//chấm dứt lao động và tuyển dụng tỉ lệ
//NhansuchamdutBQ + TuyendunglaodongBQ api
// class _HiringTurnoverRow extends StatelessWidget {
//   const _HiringTurnoverRow({required this.vm});
//   final PhatTrienNhanLucViewModel vm;
//   @override
//   Widget build(BuildContext context) => Row(children: [
    
//     Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const Text('CHẤM DỨT BQ/THÁNG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//       Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
//         Text(vm.fmt(vm.chamDutBQ.value), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//         const SizedBox(width: 8),
//         Text(vm.pct(vm.tyLeChamDut.value), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
//       ]),
//     ])))),
//     Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const Text('TUYỂN DỤNG BQ/THÁNG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//       Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
//         Text(vm.fmt(vm.tuyenDungBQ.value), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//         const SizedBox(width: 8),
//         Text('+${vm.pct(vm.tyLeTuyenDung.value)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
//       ]),
//     ])))),
//   ]);
// }

//tuyển dụng chart
//TuyenDung api
// class _TuyenDungCard extends StatelessWidget {
//   const _TuyenDungCard({required this.vm});
//   final PhatTrienNhanLucViewModel vm;

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final list = vm.tuyenDungList.map((e) => TuyenDungData(
//         month: e['Thang'] as int,
//         male: e['GT_Nam'] as int,
//         female: e['GT_Nu'] as int,
//       )).toList();
//       return TuyenDungCard(dataList: list);
//     });
//   }
// }

//chấm dứt chart
//ChamdutHDLD api
// class _ChamDutCard extends StatelessWidget {
//   const _ChamDutCard({required this.vm});
//   final PhatTrienNhanLucViewModel vm;

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final list = vm.chamDutList.map((e) => ChamdutHdData(
//         month: e['Thang'] as int,
//         nghihuu: e['NghiHuu'] as int? ?? 0,
//         nghiviec: e['NghiViec'] as int? ?? 0,
//       )).toList();
//       return ChamdutHdCard(dataList: list);
//     });
//   }
// }

//cấu trúc nhân sự
class _StaffStructureCard extends StatelessWidget {
  const _StaffStructureCard({required this.vm});
  final PhatTrienNhanLucViewModel vm;
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF00458F),
    child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Cấu trúc Nhân sự', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 10),
      GridView.count(shrinkWrap: true, crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 3, physics: const NeverScrollableScrollPhysics(), children: [
        _StaffItem(title: 'Quản lý', value: vm.fmt(vm.quanLy.value)),
        _StaffItem(title: 'NVNV', value: vm.fmt(vm.nvnv.value)),
        _StaffItem(title: 'Thợ kỹ thuật', value: vm.fmt(vm.thoKyThuat.value)),
        _StaffItem(title: 'Phục vụ', value: vm.fmt(vm.phucVu.value)),
      ]),
    ])),
  );
}
class _StaffItem extends StatelessWidget {
  final String title, value;
  const _StaffItem({required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFABC7FF))),
    const SizedBox(height: 3),
    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
  ]);
}


// ===================== TREEMAP DÙNG COMPONENT CÓ SẴN =====================
// Phanloaidonvi api
// class _PhanLoaiDonViTreemap extends StatelessWidget {
//   const _PhanLoaiDonViTreemap({required this.vm});
//   final PhatTrienNhanLucViewModel vm;

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final list = vm.phanLoaiDonViList;
//       if (list.isEmpty) return const SizedBox.shrink();
//       final data = list.map((e) => PhanLoaiTochucData(
//         name: e['FilterPhongDoiTT'] as String? ?? '',
//         count: (e['SoNguoi'] as num?)?.toDouble() ?? 0,
//       )).toList();
//       return PhanLoaiTochucCard(
//         dataList: data,
//         title: 'PHÂN LOẠI TỔ CHỨC TRỰC THUỘC CQ - ĐV',   // ✅ có thể tùy chỉnh title
//         height: 600,                    // ✅ có thể tùy chỉnh height
//       );
//           });
//   }
// }

// ===================== DONUT DÙNG COMPONENT CÓ SẴN =====================
class _PhanLoaiCQDVDonut extends StatelessWidget {
  const _PhanLoaiCQDVDonut({required this.vm});
  final PhatTrienNhanLucViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = vm.phanLoaiCQDVList;
      if (list.isEmpty) return const SizedBox.shrink();

      // Lọc theo selectedCQDV (các CQDV đã được áp dụng)
      List<Map<String, dynamic>> filteredList;
      if (vm.selectedCQDV.isNotEmpty) {
        filteredList = list.where((e) => vm.selectedCQDV.contains(e['CompanyCode'])).toList();
      } else {
        filteredList = list;
      }

      if (filteredList.isEmpty) return const SizedBox.shrink();

      // Màu sắc theo company code
      final colorMap = {
        'CNMN': const Color(0xFF2D8CFF),
        'CNMT': const Color(0xFF35C189),
        'CNMB': const Color(0xFFF59E0B),
        'CQCT': const Color(0xFFEF4444),
        'CNVT': const Color(0xFF8B5CF6),
      };
      final data = filteredList.map((e) {
        final code = e['CompanyCode'] as String;
        return PhanLoaiData(
          label: code,
          value: (e['SoNguoi'] as num).toDouble(),
          color: colorMap[code] ?? Colors.grey,
        );
      }).toList();
      return PhanLoaiCqCard(
        dataList: data,
        title: 'PHÂN LOẠI CƠ QUAN ĐƠN VỊ',
        strokeWidth: 70,
        showPercents: true,
      );
    });
  }
}

//TDDT api
// class _TrinhdoDaotaoCard extends StatelessWidget {
//   const _TrinhdoDaotaoCard({required this.vm});
//   final PhatTrienNhanLucViewModel vm;
//   @override
//   Widget build(BuildContext context) => Obx(() {
//     final data = vm.trinhDoList.map((e) => {'TrinhDo': e['TrinhDo'], 'Nam': e['Nam'], 'Nu': e['Nu']}).toList();
//     return TrinhdoDaotaoCard(data: data);
//   });
// }

// độ tuổi
// TuoiBQ api
class _DotuoiCard extends StatelessWidget {
  const _DotuoiCard({required this.vm});
  final PhatTrienNhanLucViewModel vm;

  @override
  Widget build(BuildContext context) => Obx(() {
    final data = vm.doTuoiList.map((e) => {'TenNhom': e['TenNhom'], 'SoNguoi': e['SoNguoi']}).toList();
    return DotuoiCard(data: data, tuoiTrungBinh: vm.tuoiBQ.value);
  });
}

// thâm niên

class _ThamnienCard extends StatelessWidget {
  const _ThamnienCard({required this.vm});
  final PhatTrienNhanLucViewModel vm;
  @override
  Widget build(BuildContext context) => Obx(() {
    final data = vm.thamNienList.map((e) => {'TenNhom': e['TenNhom'], 'SoNguoi': e['SoNguoi']}).toList();
    return ThamnienCard(data: data, thamNienTrungBinh: vm.thamNienBQ.value);
  });
}


class _MultiSelectChip extends StatelessWidget {
  final String title;
  final List<Option> options;
  final RxList<String> selected;
  final Function(List<String>) onChanged;

  const _MultiSelectChip({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _openMultiSelectSheet(context, title, options, selected, onChanged),
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
                Text(selected.isEmpty ? 'Tất cả' : '${selected.length} mục', style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMultiSelectSheet(
    BuildContext context,
    String title,
    List<Option> opts,
    RxList<String> selected,
    Function(List<String>) onChanged,
  ) async {
    final temp = selected.toList();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: opts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final opt = opts[i];
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
                            onChanged(temp);
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
}