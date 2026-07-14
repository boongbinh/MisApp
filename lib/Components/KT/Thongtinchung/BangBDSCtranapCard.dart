import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ====== MODEL ======
class BangBDSCtranapRow {
  final String donvi;
  final int? soBDTT;
  final int? soSCTT;
  final int? gioBDSC_TT;
  final int? gioHdTotTT;
  final int? gioHDTT;
  final int? soBDTK;
  final int? soSCTK;
  final int? gioBDSC;
  final int? gioHdTot;
  final int? gioHDTK;

  BangBDSCtranapRow({
    required this.donvi,
    this.soBDTT,
    this.soSCTT,
    this.gioBDSC_TT,
    this.gioHdTotTT,
    this.gioHDTT,
    this.soBDTK,
    this.soSCTK,
    this.gioBDSC,
    this.gioHdTot,
    this.gioHDTK,
  });

  factory BangBDSCtranapRow.fromMap(Map<String, dynamic> map) {
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final cleaned = value.replaceAll(',', '');
        return int.tryParse(cleaned);
      }
      return null;
    }

    return BangBDSCtranapRow(
      donvi: map['Donvi']?.toString() ?? '',
      soBDTT: _parseInt(map['SoBD_TT']),
      soSCTT: _parseInt(map['SoSC_TT']),
      gioBDSC_TT: _parseInt(map['Gio_BDSC_TT']),
      gioHdTotTT: _parseInt(map['Gio_hd_tot_TT']),
      gioHDTT: _parseInt(map['GioHD_TT']),
      soBDTK: _parseInt(map['SoBD_TK']),
      soSCTK: _parseInt(map['SoSC_TK']),
      gioBDSC: _parseInt(map['Gio_BDSC']),
      gioHdTot: _parseInt(map['Gio_hd_tot']),
      gioHDTK: _parseInt(map['GioHD_TK']),
    );
  }
}

// ====== CONTROLLER ======
class BangBDSCtranapController extends GetxController {
  final rows = <BangBDSCtranapRow>[].obs;
  final loading = false.obs;

  // Cài đặt cột - Thực tế (TT)
  final showSoBDTT = true.obs;
  final showSoSCTT = true.obs;
  final showGioBDSC_TT = true.obs;
  final showGioHdTotTT = true.obs;
  final showGioHDTT = true.obs;

  // Cài đặt cột - Thống kê (TK)
  final showSoBDTK = true.obs;
  final showSoSCTK = true.obs;
  final showGioBDSC = true.obs;
  final showGioHdTot = true.obs;
  final showGioHDTK = true.obs;

  void loadData(List<Map<String, dynamic>> data) {
    rows.assignAll(data.map((e) => BangBDSCtranapRow.fromMap(e)).toList());
  }

  String fmtInt(int? v) {
    if (v == null) return '--';
    return NumberFormat('#,###', 'vi_VN').format(v);
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
  final bool isTT; // true: thực tế, false: thống kê

  const _ColDef({
    required this.key,
    required this.title,
    this.flex = 1,
    this.isTT = true,
  });
}

// ====== WIDGET CHÍNH ======
// ====== WIDGET CHÍNH ======
class BangBDSCtranapCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final String monthYear;

  const BangBDSCtranapCard({
    super.key,
    required this.data,
    this.title = 'BẢNG BĐSC TRẦN',
    this.monthYear = '',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BangBDSCtranapController())..loadData(data);

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
            title: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (monthYear.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    monthYear,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: controller.openColumnSettings,
            ),
          ),
          // ⭐ Truyền monthYear vào _TableHeader
          _TableHeader(controller: controller, monthYear: monthYear),
          const Divider(height: 1),
          _TableBody(controller: controller),
        ],
      ),
    );
  }
}

// ====== HEADER BẢNG ======
class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.controller,
    required this.monthYear,
  });
  final BangBDSCtranapController controller;
  final String monthYear;

  // ⭐ Hàm lấy tháng và năm từ monthYear
  (int month, int year) _parseMonthYear(String value) {
    if (value.isEmpty) return (0, 0);
    final parts = value.split('/');
    if (parts.length == 2) {
      final month = int.tryParse(parts[0]) ?? 0;
      final year = int.tryParse(parts[1]) ?? 0;
      return (month, year);
    }
    return (0, 0);
  }

  // ⭐ Hàm format tháng trước
  String _getPreviousMonthYear(String value) {
    final (month, year) = _parseMonthYear(value);
    if (month == 0 || year == 0) return '';
    int prevMonth = month - 1;
    int prevYear = year;
    if (prevMonth == 0) {
      prevMonth = 12;
      prevYear = year - 1;
    }
    return '$prevMonth/$prevYear';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final defs = _buildColDefs(controller);
      final hasTT = defs.any((d) => d.isTT == true);
      final hasTK = defs.any((d) => d.isTT == false);

      // Tính số cột TT và TK
      final ttCount = defs.where((d) => d.isTT == true).length;
      final tkCount = defs.where((d) => d.isTT == false).length;

      final previousMonthYear = _getPreviousMonthYear(monthYear);

      return Column(
        children: [
          // Hàng 1: Đơn vị + THỰC TẾ + THỐNG KÊ
          Container(
            height: 40,
            color: const Color(0xFF4D73B2),
            child: Row(
              children: [
                // Cột Đơn vị
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: const Text(
                    'Đơn vị',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                // ⭐ Nhóm THỰC TẾ - hiển thị tháng trước
                if (hasTT)
                  Expanded(
                    flex: ttCount,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: hasTK ? const Color(0xFFE6ECF5) : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Text(
                        'SỐ LIỆU THÁNG ${previousMonthYear.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                // ⭐ Nhóm THỐNG KÊ - hiển thị tháng hiện tại
                if (hasTK)
                  Expanded(
                    flex: tkCount,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'SỐ LIỆU THÁNG ${monthYear.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Hàng 2: Tên các cột con
          Container(
            height: 36,
            color: const Color(0xFF5B82C4),
            child: Row(
              children: [
                // Cột Đơn vị (giữ trống)
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: const SizedBox.shrink(),
                ),
                // Các cột con
                for (int i = 0; i < defs.length; i++)
                  Expanded(
                    flex: defs[i].flex,
                    child: Container(
                      alignment: Alignment.center,
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
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }

  List<_ColDef> _buildColDefs(BangBDSCtranapController c) {
    final defs = <_ColDef>[];

    if (c.showSoBDTT.value) {
      defs.add(const _ColDef(key: 'soBDTT', title: 'Lượt BD', isTT: true));
    }
    if (c.showSoSCTT.value) {
      defs.add(const _ColDef(key: 'soSCTT', title: 'Lượt SC', isTT: true));
    }
    if (c.showGioBDSC_TT.value) {
      defs.add(const _ColDef(key: 'gioBDSC_TT', title: 'Giờ BĐSC', isTT: true));
    }
    if (c.showGioHdTotTT.value) {
      defs.add(const _ColDef(key: 'gioHdTotTT', title: 'Giờ xe tốt', isTT: true));
    }
    if (c.showGioHDTT.value) {
      defs.add(const _ColDef(key: 'gioHDTT', title: 'Giờ hoạt động', isTT: true));
    }
    if (c.showSoBDTK.value) {
      defs.add(const _ColDef(key: 'soBDTK', title: 'Lượt BD', isTT: false));
    }
    if (c.showSoSCTK.value) {
      defs.add(const _ColDef(key: 'soSCTK', title: 'Lượt SC', isTT: false));
    }
    if (c.showGioBDSC.value) {
      defs.add(const _ColDef(key: 'gioBDSC', title: 'Giờ BĐSC', isTT: false));
    }
    if (c.showGioHdTot.value) {
      defs.add(const _ColDef(key: 'gioHdTot', title: 'Giờ xe tốt', isTT: false));
    }
    if (c.showGioHDTK.value) {
      defs.add(const _ColDef(key: 'gioHDTK', title: 'Giờ hoạt động', isTT: false));
    }

    return defs;
  }
}

// ====== BODY BẢNG ======
class _TableBody extends StatelessWidget {
  const _TableBody({required this.controller});
  final BangBDSCtranapController controller;

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

  List<_ColDef> _buildColDefs(BangBDSCtranapController c) {
    final defs = <_ColDef>[];

    if (c.showSoBDTT.value) {
      defs.add(const _ColDef(key: 'soBDTT', title: 'Lượt BD', isTT: true));
    }
    if (c.showSoSCTT.value) {
      defs.add(const _ColDef(key: 'soSCTT', title: 'Lượt SC', isTT: true));
    }
    if (c.showGioBDSC_TT.value) {
      defs.add(const _ColDef(key: 'gioBDSC_TT', title: 'Giờ BĐSC', isTT: true));
    }
    if (c.showGioHdTotTT.value) {
      defs.add(const _ColDef(key: 'gioHdTotTT', title: 'Giờ xe tốt', isTT: true));
    }
    if (c.showGioHDTT.value) {
      defs.add(const _ColDef(key: 'gioHDTT', title: 'Giờ hoạt động', isTT: true));
    }
    if (c.showSoBDTK.value) {
      defs.add(const _ColDef(key: 'soBDTK', title: 'Lượt BD', isTT: false));
    }
    if (c.showSoSCTK.value) {
      defs.add(const _ColDef(key: 'soSCTK', title: 'Lượt SC', isTT: false));
    }
    if (c.showGioBDSC.value) {
      defs.add(const _ColDef(key: 'gioBDSC', title: 'Giờ BĐSC', isTT: false));
    }
    if (c.showGioHdTot.value) {
      defs.add(const _ColDef(key: 'gioHdTot', title: 'Giờ xe tốt', isTT: false));
    }
    if (c.showGioHDTK.value) {
      defs.add(const _ColDef(key: 'gioHDTK', title: 'Giờ hoạt động', isTT: false));
    }

    return defs;
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
  final BangBDSCtranapController controller;
  final BangBDSCtranapRow row;
  final int index;
  final List<_ColDef> defs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: index % 2 == 0 ? Colors.white : const Color(0xFFF8F9FA),
      child: Row(
        children: [
          // Cột Đơn vị - cố định width 60
          Container(
            width: 60,
            alignment: Alignment.center,
            child: Text(
              row.donvi,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2A37),
              ),
            ),
          ),
          // Các cột dữ liệu
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
                child: _cell(defs[i].key, row),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(String key, BangBDSCtranapRow row) {
    final text = switch (key) {
      'soBDTT' => controller.fmtInt(row.soBDTT),
      'soSCTT' => controller.fmtInt(row.soSCTT),
      'gioBDSC_TT' => controller.fmtInt(row.gioBDSC_TT),
      'gioHdTotTT' => controller.fmtInt(row.gioHdTotTT),
      'gioHDTT' => controller.fmtInt(row.gioHDTT),
      'soBDTK' => controller.fmtInt(row.soBDTK),
      'soSCTK' => controller.fmtInt(row.soSCTK),
      'gioBDSC' => controller.fmtInt(row.gioBDSC),
      'gioHdTot' => controller.fmtInt(row.gioHdTot),
      'gioHDTK' => controller.fmtInt(row.gioHDTK),
      _ => '',
    };
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: text == '--' ? Colors.grey.shade400 : Colors.black87,
        fontWeight: text == '--' ? FontWeight.w400 : FontWeight.w500,
      ),
    );
  }
}

// ====== COLUMN SETTINGS SHEET ======
class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({required this.controller});
  final BangBDSCtranapController controller;

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
                // Nhóm Thực tế
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'THỰC TẾ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF4D73B2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _switch('Lượt BD', controller.showSoBDTT),
                _switch('Lượt SC', controller.showSoSCTT),
                _switch('Giờ BĐSC', controller.showGioBDSC_TT),
                _switch('Giờ xe tốt', controller.showGioHdTotTT),
                _switch('Giờ hoạt động', controller.showGioHDTT),
                // Nhóm Thống kê
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'THỐNG KÊ LŨY KẾ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF4D73B2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _switch('Lượt BD', controller.showSoBDTK),
                _switch('Lượt SC', controller.showSoSCTK),
                _switch('Giờ BĐSC', controller.showGioBDSC),
                _switch('Giờ xe tốt', controller.showGioHdTot),
                _switch('Giờ hoạt động', controller.showGioHDTK),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Reset tất cả về true
                          controller.showSoBDTT.value = true;
                          controller.showSoSCTT.value = true;
                          controller.showGioBDSC_TT.value = true;
                          controller.showGioHdTotTT.value = true;
                          controller.showGioHDTT.value = true;
                          controller.showSoBDTK.value = true;
                          controller.showSoSCTK.value = true;
                          controller.showGioBDSC.value = true;
                          controller.showGioHdTot.value = true;
                          controller.showGioHDTK.value = true;
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