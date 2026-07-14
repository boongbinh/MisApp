import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Components/TCNL/CongTacDang/TrinhdodaotaoCard.dart';
import 'package:skypec/Controller/TCNL/CongTacDangViewModel.dart';
import 'package:skypec/components/TCNL/CongTacDang/GioiTinhCard.dart'; 
import 'package:skypec/components/TCNL/CongTacDang/DotuoidangCard.dart'; 
import 'package:skypec/components/TCNL/CongTacDang/SoluongdangvienCard.dart'; 
import 'package:skypec/components/TCNL/CongTacDang/CapuydangCard.dart'; 

class CongTacDang extends GetView<CongTacDangViewModel> {
  const CongTacDang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Công tác Đảng'),
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
                  
// TỶ LỆ ĐẢNG VIÊN
                  Row(
                    children: [
                      Expanded(
                        child: _KpiBigCard(
                          title: "TỶ LỆ ĐẢNG VIÊN",
                          value: "${controller.tyLeDangVien.value.toStringAsFixed(1)}%",

                          subtitle: controller.tyLeDangVienText.value,
                          progress: controller.tyLeDangVien.value/100,
                          progressColor: const Color(0xFF002B5B),
                        ),
                      ),
// Tỷ lệ chuyển đảng chính thức
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiBigCard(
                          title: "Tỷ lệ chuyển đảng chính thức",
                          value: "${controller.tyLeChuyenDang100.value.toStringAsFixed(1)}%",
                          subtitle: "Đã chuyển ${controller.tyLeChuyenDang.value}",
                          progress: controller.tyLeChuyenDang100.value / 100,
                          progressColor: const Color(0xFFFDC003),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Hàng 2: Card "Tuổi đảng bình quân"
                  _KpiFullWidthCard(
                    title: "TUỔI ĐẢNG BÌNH QUÂN",
                    value: controller.tuoiBinhQuan.value,
                    subtitle: "Tính trên tổng số Đảng viên hiện tại",
                  ),
                  const SizedBox(height: 12),

//Tỷ lệ phát triển đảng viên 
                  Row(
                    children: [
                      Expanded(
                        child: _KpiSmallCard(
                          title: "Tỷ lệ phát triển đảng viên ",
                          value: "${controller.tyLeKetNap.value.toStringAsFixed(1)}%",
                          subtitle: "(${controller.tyLeKetNapText.value} đảng viên)",
                        ),
                      ),
                      const SizedBox(width: 12),
//Tỉ lệ số Đảng viên trên tổng số lao động trực tiếp
                      Expanded(
                        child: _KpiSmallCard(
                          title: "Tỉ lệ số Đảng viên trên tổng số lao động trực tiếp",
                          value: "${controller.tyLe_DvTT_to_LDTT.value.toStringAsFixed(1)}%",
                          subtitle: controller.tyLe_DvTT_to_LDTTText.value,
                          showProgress: true,
                          progress: controller.tyLe_DvTT_to_LDTT.value/100,
                          progressColor: const Color(0xFF002B5B),
                        ),
                      ),
                      const SizedBox(width: 12),
//Tỉ lệ số Đảng viên trên tổng số lao động gián tiếp
                      Expanded(
                        child: _KpiSmallCard(
                          title: "Tỉ lệ số Đảng viên trên tổng số lao động gián tiếp",
                          value: "${controller.tyLe_DvGT_to_LDGT.value.toStringAsFixed(1)}%",
                          subtitle: controller.tyLe_DvGT_to_LDGTText.value,
                          showProgress: true,
                          progress: controller.tyLe_DvGT_to_LDGT.value/100,
                          progressColor: const Color(0xFF002B5B),
                        ),
                      ),
                    ],
                  ),
                  

                  const SizedBox(height: 12),
                  // Giới tính
                  GioiTinhCard(
                    dataList: controller.gioiTinhDataList.toList(),
                  ),
                  const SizedBox(height: 16),
                  // DANH SÁCH ĐẢNG VIÊN CÁC TỔ CHỨC ĐẢNG mượn component GioiTinhCard để hiển thị
                  GioiTinhCard(
                    dataList: controller.dangVienToChucDataList.toList(),
                    title: 'DANH SÁCH ĐẢNG VIÊN CÁC TỔ CHỨC ĐẢNG',
                  ),
                  const SizedBox(height: 16),
                   TrinhdodaotaoCard(
                    dataList: controller.trinhDoDaoTaoDataList.toList(),
                    title: 'TRÌNH ĐỘ ĐÀO TẠO',
                  ),
                  const SizedBox(height: 16),
                   DotuoidangCard(
                    dataList: controller.dotuoiDangDataList.toList(),
                    title: 'ĐỘ TUỔI ĐẢNG',
                  ),
                  const SizedBox(height: 16),
                   SoluongdangvienCard(
                    dataList: controller.soLuongDangVienDataList.toList(),
                    title: 'SỐ LƯỢNG ĐẢNG VIÊN',
                  ),
                  
                  const SizedBox(height: 16),
                   CapuydangCard(
                    dataList: controller.capUyDangDataList.toList(),
                    title: 'CẤP ỦY ĐẢNG',
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  double _parseProgress(String value) {
    final parts = value.split('/');
    if (parts.length == 2) {
      final numerator = double.tryParse(parts[0]) ?? 0;
      final denominator = double.tryParse(parts[1]) ?? 1;
      return denominator > 0 ? numerator / denominator : 0;
    }
    return 0;
  }
}

// ==================== SEARCH & FILTER BAR ====================
class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.vm});
  final CongTacDangViewModel vm;

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
  final CongTacDangViewModel vm;

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
  final CongTacDangViewModel vm;

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

// ==================== FILTER SHEET (CHỈ CÒN ĐƠN VỊ) ====================
class _FilterSheet extends StatefulWidget {
  static Future<void> open(BuildContext context, CongTacDangViewModel vm) async {
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
  final CongTacDangViewModel vm;

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
            const SizedBox(height: 16),
            // CHỈ CÓ ĐƠN VỊ
            Obx(() => _singleSelect(
              'Đơn vị',
              vm.donViOptions,
              vm.filterDonVi,
              vm.setDonVi,
            )),
            const SizedBox(height: 16),
            
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
  ) => Column(
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
              Text(selected.value, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    ],
  );

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

// ====== Các widget KPI ======
class _KpiBigCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double progress;
  final Color progressColor;

  const _KpiBigCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7A5A00),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF002B5B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE9EDF3),
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiFullWidthCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _KpiFullWidthCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A5A00),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF002B5B),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiSmallCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool showProgress;
  final double? progress;
  final Color? progressColor;

  const _KpiSmallCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.showProgress = false,
    this.progress,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF7A5A00),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF002B5B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          if (showProgress && progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: const Color(0xFFE9EDF3),
                valueColor: AlwaysStoppedAnimation(progressColor ?? const Color(0xFF002B5B)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}