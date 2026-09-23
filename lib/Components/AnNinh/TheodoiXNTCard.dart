// widgets/TheodoiXNT_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ============================================================
// MODEL
// ============================================================

class TheodoiXNTRow {
  final int Id_xnt;
  final String MaKho;
  final String Chinhanh;
  final String Ngay;
  final double TonDau;
  final double? Nhap;
  final double Xuat;
  final double? TonCuoi;
  final String KHXuat;
  final String NguoiChot;
  final DateTime NgayChot;
  final String? NguoiTao;

  TheodoiXNTRow({
    required this.Id_xnt,
    required this.MaKho,
    required this.Chinhanh,
    required this.Ngay,
    required this.TonDau,
    required this.Nhap,
    required this.Xuat,
    required this.TonCuoi,
    required this.KHXuat,
    required this.NguoiChot,
    required this.NgayChot,
    required this.NguoiTao,
  });

  factory TheodoiXNTRow.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll(',', '');
        return double.tryParse(cleaned) ?? 0;
      }
      return 0;
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      final str = value.toString().trim();
      return str.isEmpty ? null : str;
    }

    return TheodoiXNTRow(
      Id_xnt: map['Id_xnt'],
      MaKho: map['MaKho']?.toString() ?? '',
      Chinhanh: map['Chinhanh']?.toString() ?? '',
      Ngay: map['Ngay']?.toString() ?? '',
      TonDau: parseDouble(map['TonDau']),
      Nhap: parseDouble(map['Nhap']),
      Xuat: parseDouble(map['Xuat']),
      TonCuoi: parseDouble(map['TonCuoi']),
      KHXuat: map['KHXuat']?.toString() ?? '',
      NguoiChot: map['NguoiChot']?.toString() ?? '',
      NgayChot: DateTime.parse(map['NgayChot'].toString()),
      NguoiTao: parseString(map['NguoiTao']),
    );
  }
}

// ============================================================
// CONTROLLER
// ============================================================

class TheodoiXNTController extends GetxController {
  final rows = <TheodoiXNTRow>[].obs;
  final loading = false.obs;

  // Column visibility
  final showIdXnt = true.obs;
  final showMaKho = true.obs;
  final showChinhanh = true.obs;
  final showNgay = true.obs;
  final showTonDau = true.obs;
  final showNhap = true.obs;
  final showXuat = true.obs;
  final showTonCuoi = true.obs;
  final showKHXuat = true.obs;
  final showNguoiChot = true.obs;
  final showNgayChot = true.obs;
  final showNguoiTao = true.obs;

  void loadData(List<Map<String, dynamic>> data) {
    rows.assignAll(data.map((e) => TheodoiXNTRow.fromMap(e)).toList());
  }

  String fmt(num? v, {int decimals = 0}) {
    if (v == null || v == 0) return '--';
    if (decimals == 0) {
      return NumberFormat('#,##0', 'vi_VN').format(v);
    }
    return NumberFormat('#,##0.${'0' * decimals}', 'vi_VN').format(v);
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get currentMonth {
    if (rows.isEmpty) return '';
    try {
      final firstDate = rows.first.Ngay;
      if (firstDate.contains('/')) {
        final parts = firstDate.split('/');
        if (parts.length >= 2) {
          return '${parts[1]}/20${parts[2]}';
        }
      }
    } catch (e) {
      // ignore
    }
    return '';
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

// ============================================================
// COLUMN DEFINITION
// ============================================================

class _ColDef {
  final String key;
  final String title;
  final double flex;
  final Color? color;

  const _ColDef(this.key, this.title, this.flex, {this.color});
}

// ============================================================
// CARD CHÍNH
// ============================================================

class TheodoiXNTCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const TheodoiXNTCard({
    super.key,
    required this.data,
    this.title = 'THEO DÕI XNT KHO CẢNG',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TheodoiXNTController())..loadData(data);

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 600),
            child: _TableBody(controller: controller),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// XÂY DỰNG CÁC CỘT
// ============================================================

List<_ColDef> _buildDefs(TheodoiXNTController c) {
  final configs = [
    // Thông tin chung
    ('showMaKho', 'MaKho', 'MÃ KHO', 0.5, null),

    // Tồn đầu
    ('showTonDau', 'TonDau', 'TỒN ĐẦU', 0.8, Color(0xFFDCEBFA)),

    // Nhập
    ('showNhap', 'Nhap', 'NHẬP', 0.8, Color(0xFFDCEBFA)),

    // Xuất
    ('showXuat', 'Xuat', 'XUẤT', 0.8, Color(0xFFFFE8CC)),

    // Tồn cuối
    ('showTonCuoi', 'TonCuoi', 'TỒN CUỐI', 0.8, Color(0xFFE2F0D9)),

    // Khách hàng xuất
    ('showKHXuat', 'KHXuat', 'KẾ HOẠCH NHẬP TÀU', 1.2, Color(0xFFF4D9E8)),
  ];
  final showMap = {
    'showMaKho': c.showMaKho.value,
    'showTonDau': c.showTonDau.value,
    'showNhap': c.showNhap.value,
    'showXuat': c.showXuat.value,
    'showTonCuoi': c.showTonCuoi.value,

    'showKHXuat': c.showKHXuat.value,
  };

  return configs
      .where((x) => showMap[x.$1] == true)
      .map((x) => _ColDef(x.$2, x.$3, x.$4, color: x.$5))
      .toList();
}
// ============================================================
// TỔNG FLEX
// ============================================================

double _getTotalFlex(TheodoiXNTController c) {
  double total = 0;

  if (c.showMaKho.value) total += 0.8;

  if (c.showTonDau.value) total += 0.8;
  if (c.showNhap.value) total += 0.8;
  if (c.showXuat.value) total += 0.8;
  if (c.showTonCuoi.value) total += 0.8;
  if (c.showKHXuat.value) total += 0.85;

  return total;
}

// ============================================================
// HEADER
// ============================================================

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.controller});

  final TheodoiXNTController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final defs = _buildDefs(controller);
      final totalFlex = _getTotalFlex(controller);

      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - 16;
          final columnWidth = availableWidth / totalFlex;

          return Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (final def in defs)
                    Container(
                      width: columnWidth * def.flex,
                      height: 42,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F7FD),
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                          right: BorderSide(
                            color: Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                          bottom: BorderSide(
                            color: Color(0xFF94A3B8),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        def.title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
// ============================================================
// BODY
// ============================================================

class _TableBody extends StatelessWidget {
  const _TableBody({required this.controller});

  final TheodoiXNTController controller;

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

      final defs = _buildDefs(controller);
      final totalFlex = _getTotalFlex(controller);

      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - 16;
          final columnWidth = availableWidth / totalFlex;

          return Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFDEE2E6), width: 1),
                right: BorderSide(color: Color(0xFFDEE2E6), width: 1),
              ),
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: rows.length,

              separatorBuilder: (_, __) {
                return const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE6ECF5),
                );
              },

              itemBuilder: (_, index) {
                return Stack(
                  children: [
                    // ==============================
                    // DÒNG DỮ LIỆU
                    // ==============================
                    _RowWidget(
                      controller: controller,
                      row: rows[index],
                      index: index,
                      defs: defs,
                      columnWidth: columnWidth,
                    ),

                    // ==============================
                    // ĐƯỜNG KẺ DỌC CÁC CỘT
                    // ==============================
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Row(
                          children: [
                            for (final def in defs)
                              SizedBox(
                                width: columnWidth * def.flex,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Color(0xFFE1E6EC),
                                        width: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    });
  }
}

// ============================================================
// ROW
// ============================================================

class _RowWidget extends StatelessWidget {
  final int index;
  final TheodoiXNTRow row;
  final List<_ColDef> defs;
  final double columnWidth;
  final TheodoiXNTController controller;

  const _RowWidget({
    required this.controller,
    required this.row,
    required this.index,
    required this.defs,
    required this.columnWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: index % 2 == 0 ? Colors.white : const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < defs.length; i++)
              SizedBox(
                width: columnWidth * defs[i].flex,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: _cell(defs[i].key, row),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String key, TheodoiXNTRow row) {
    final text = switch (key) {
      'MaKho' => row.MaKho,

      'TonDau' => controller.fmt(row.TonDau),
      'Nhap' => row.Nhap != null ? controller.fmt(row.Nhap!) : '--',
      'Xuat' => controller.fmt(row.Xuat),
      'TonCuoi' => row.TonCuoi != null ? controller.fmt(row.TonCuoi!) : '--',
      'KHXuat' => row.KHXuat,

      _ => '--',
    };

    final isEmpty = text == '--';

    return Text(
      text,
      textAlign: TextAlign.left,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: isEmpty ? Colors.grey.shade400 : Colors.black87,
        fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500,
        height: 1.2,
      ),
    );
  }
}

// ============================================================
// COLUMN SETTINGS
// ============================================================

class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({required this.controller});

  final TheodoiXNTController controller;

  @override
  Widget build(BuildContext context) {
    const columnColor = Color(0xFFDCEBFA);

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

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _switchWithColor(
                          'Mã kho',
                          controller.showMaKho,
                          columnColor,
                        ),
                        _switchWithColor(
                          'Tồn Đầu',
                          controller.showTonDau,
                          columnColor,
                        ),

                        _switchWithColor(
                          'Nhập',
                          controller.showNhap,
                          columnColor,
                        ),

                        _switchWithColor(
                          'Xuất',
                          controller.showXuat,
                          columnColor,
                        ),

                        _switchWithColor(
                          'Tồn Cuối',
                          controller.showTonCuoi,
                          columnColor,
                        ),

                        _switchWithColor(
                          'Kế hoạch nhập tàu',
                          controller.showKHXuat,
                          columnColor,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Reset tất cả về true
                          controller.showMaKho.value = true;
                          controller.showTonDau.value = true;
                          controller.showNhap.value = true;
                          controller.showXuat.value = true;
                          controller.showTonCuoi.value = true;
                          controller.showKHXuat.value = true;

                          controller.update();
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
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
          Obx(
            () => Switch(value: bind.value, onChanged: (v) => bind.value = v),
          ),
        ],
      ),
    );
  }

  Widget _switchWithColor(String title, RxBool bind, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
          Obx(
            () => Switch(value: bind.value, onChanged: (v) => bind.value = v),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FOOTER NOTE
// ============================================================
