import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ====== MODEL ======
class BangChiphiRow {
  final String maDV;
  final double? khCPNam;
  final double? tongCPTHThang;
  final double? tongCPTHLuyKe;
  final double? chiphi;
  final double? sanluong;

  BangChiphiRow({
    required this.maDV,
    this.khCPNam,
    this.tongCPTHThang,
    this.tongCPTHLuyKe,
    this.chiphi,
    this.sanluong,
  });

  factory BangChiphiRow.fromMap(Map<String, dynamic> map) {
    double? _parse(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll(',', '');
        return double.tryParse(cleaned);
      }
      return null;
    }

    return BangChiphiRow(
      maDV: map['ma_dv']?.toString() ?? '',
      khCPNam: _parse(map['KH_CP_NAM']),
      tongCPTHThang: _parse(map['TONG_CP_TH_thang']),
      tongCPTHLuyKe: _parse(map['TONG_CP_TH_Luyke']),
      chiphi: _parse(map['Chiphi']),
      sanluong: _parse(map['Sanluong']),
    );
  }
}

// ====== CONTROLLER ======
class BangchiphiController extends GetxController {
  final rows = <BangChiphiRow>[].obs;
  final loading = false.obs;

  // Cài đặt cột
  final showKhCPNam = true.obs;
  final showTongCPTHThang = true.obs;
  final showTongCPTHLuyKe = true.obs;
  final showChiphi = true.obs;
  final showSanluong = true.obs;

  void loadData(List<Map<String, dynamic>> data) {
    rows.assignAll(data.map((e) => BangChiphiRow.fromMap(e)).toList());
  }

  String fmt(num? v) {
    if (v == null) return '--';
    final n = v / 1e9;
    return NumberFormat('#,##0.00', 'vi_VN').format(n) + ' Tỷ';
  }

  String fmtTrieu(num? v) {
    if (v == null) return '--';
    final n = v / 1e6;
    return NumberFormat('#,##0.##', 'vi_VN').format(n) + ' Triệu';
  }

  String fmtPercent(num? v) {
    if (v == null) return '--';
    return NumberFormat('#,##0.00', 'vi_VN').format(v) + '%';
  }

  

  void openColumnSettings() {
    final ctx = Get.context;
    if (ctx == null) return;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ColumnSettingsSheet(controller: this),
    );
  }
}

// ====== COLUMN DEFINITION ======
class _ColDef {
  final String key;
  final String title;
  final int flex;

  const _ColDef(this.key, this.title, this.flex);
}

// ====== WIDGET CHÍNH ======
class BangchiphiCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const BangchiphiCard({
    super.key,
    required this.data,
    this.title = 'CHI PHÍ',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BangchiphiController())..loadData(data);

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
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: controller.openColumnSettings,
            ),
          ),
          _TableHeader(controller: controller),
          const Divider(height: 1),
          _TableBody(controller: controller),
        ],
      ),
    );
  }
}

// ====== HEADER BẢNG ======
class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.controller});
  final BangchiphiController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final defs = _buildColDefs(controller);
      return Container(
        height: 44,
        color: const Color(0xFF4D73B2),
        child: Row(
          children: [
            for (int i = 0; i < defs.length; i++)
              Expanded(
                flex: defs[i].flex,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: i == defs.length - 1
                            ? Colors.transparent
                            : const Color(0xFFE6ECF5),
                      ),
                    ),
                  ),
                  child: Text(
                    defs[i].title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  List<_ColDef> _buildColDefs(BangchiphiController c) {
    return [
      const _ColDef('maDV', 'Đơn vị', 1),
      if (c.showKhCPNam.value) const _ColDef('khCPNam', 'Kế hoạch năm', 1),
      if (c.showTongCPTHThang.value) const _ColDef('tongCPTHThang', 'Thực hiện trong tháng', 1),
      if (c.showTongCPTHLuyKe.value) const _ColDef('tongCPTHLuyKe', 'Lũy kế từ đầu năm', 1),
      if (c.showChiphi.value) const _ColDef('chiphi', 'Chi phí (%)', 1),
      if (c.showSanluong.value) const _ColDef('sanluong', 'Sản lượng (%)', 1),
    ];
  }
}

// ====== BODY BẢNG ======
class _TableBody extends StatelessWidget {
  const _TableBody({required this.controller});
  final BangchiphiController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.rows;
      if (rows.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }
      final defs = _buildColDefs(controller);
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: rows.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE6ECF5)),
        itemBuilder: (_, index) => _RowWidget(
          controller: controller,
          row: rows[index],
          index: index,
          defs: defs,
        ),
      );
    });
  }

  List<_ColDef> _buildColDefs(BangchiphiController c) {
    return [
      const _ColDef('maDV', 'Đơn vị', 1),
      if (c.showKhCPNam.value) const _ColDef('khCPNam', 'Kế hoạch năm', 1),
      if (c.showTongCPTHThang.value) const _ColDef('tongCPTHThang', 'Thực hiện trong tháng', 1),
      if (c.showTongCPTHLuyKe.value) const _ColDef('tongCPTHLuyKe', 'Lũy kế từ đầu năm', 1),
      if (c.showChiphi.value) const _ColDef('chiphi', 'Chi phí (%)', 1),
      if (c.showSanluong.value) const _ColDef('sanluong', 'Sản lượng (%)', 1),
    ];
  }
}

// ====== ROW WIDGET ======
class _RowWidget extends StatelessWidget {
  const _RowWidget({
    required this.controller,
    required this.row,
    required this.index,
    required this.defs,
  });
  final BangchiphiController controller;
  final BangChiphiRow row;
  final int index;
  final List<_ColDef> defs;

  @override
  Widget build(BuildContext context) {
    // Kiểm tra nếu là dòng Tổng thì đổi màu nền
    final isTotal = row.maDV.toLowerCase() == 'tổng';

    return Container(
      height: 40,
      color: isTotal
          ? const Color(0xFFE8EEF5)
          : (index % 2 == 0 ? Colors.white : const Color(0xFFF8F9FA)),
      child: Row(
        children: [
          for (int i = 0; i < defs.length; i++)
            Expanded(
              flex: defs[i].flex,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: i == defs.length - 1
                          ? Colors.transparent
                          : const Color(0xFFE6ECF5),
                    ),
                  ),
                ),
                child: _cell(defs[i].key, row, isTotal),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(String key, BangChiphiRow row, bool isTotal) {
    final text = switch (key) {
      'maDV' => row.maDV,
      'khCPNam' => controller.fmt(row.khCPNam),
      'tongCPTHThang' => controller.fmt(row.tongCPTHThang),
      'tongCPTHLuyKe' => controller.fmt(row.tongCPTHLuyKe),
      'chiphi' => controller.fmtPercent(row.chiphi),
      'sanluong' => controller.fmtPercent(row.sanluong),
      _ => '',
    };

    final isBold = isTotal || key == 'maDV';

    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isTotal ? 13 : 12,
        fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
        color: text == '--'
            ? Colors.grey.shade400
            : (isTotal ? const Color(0xFF1F2A37) : Colors.black87),
      ),
    );
  }
}

// ====== COLUMN SETTINGS SHEET ======
class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({required this.controller});
  final BangchiphiController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Cài đặt hiển thị',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _switch('Kế hoạch năm', controller.showKhCPNam),
                _switch('Thực hiện trong tháng', controller.showTongCPTHThang),
                _switch('Lũy kế từ đầu năm', controller.showTongCPTHLuyKe),
                _switch('Chi phí (%)', controller.showChiphi),
                _switch('Sản lượng (%)', controller.showSanluong),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.showKhCPNam.value = true;
                          controller.showTongCPTHThang.value = true;
                          controller.showTongCPTHLuyKe.value = true;
                          controller.showChiphi.value = true;
                          controller.showSanluong.value = true;
                        },
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Mặc định'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Áp dụng'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switch(String title, RxBool bind) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Obx(() => Switch(
            value: bind.value,
            onChanged: (v) => bind.value = v,
          )),
        ],
      ),
    );
  }
}