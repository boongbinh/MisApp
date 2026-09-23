// widgets/bangkehoachnhap_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ============================================================
// MODEL
// ============================================================

class BangkehoachnhapRow {
  final String ngayNhap;
  final double hli;
  final double dvu;
  final double tly;
  final String? ghichuMB;
  final double lch;
  final String? ghichuDN;
  final double hmo;
  final String? ghichuCR;
  final double cla;
  final double tle;
  final double qch;
  final String? ghichuMN;

  BangkehoachnhapRow({
    required this.ngayNhap,
    required this.hli,
    required this.dvu,
    required this.tly,
    this.ghichuMB,
    required this.lch,
    this.ghichuDN,
    required this.hmo,
    this.ghichuCR,
    required this.cla,
    required this.tle,
    required this.qch,
    this.ghichuMN,
  });

  factory BangkehoachnhapRow.fromMap(Map<String, dynamic> map) {
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

    return BangkehoachnhapRow(
      ngayNhap: map['NgayNhap']?.toString() ?? '',
      hli: parseDouble(map['HLI']),
      dvu: parseDouble(map['DVU']),
      tly: parseDouble(map['TLY']),
      ghichuMB: parseString(map['Ghichu_MB']),
      lch: parseDouble(map['LCH']),
      ghichuDN: parseString(map['Ghichu_DN']),
      hmo: parseDouble(map['HMO']),
      ghichuCR: parseString(map['Ghichu_CR']),
      cla: parseDouble(map['CLA']),
      tle: parseDouble(map['TLE']),
      qch: parseDouble(map['QCH']),
      ghichuMN: parseString(map['Ghichu_MN']),
    );
  }
}

// ============================================================
// CONTROLLER
// ============================================================

class BangkehoachnhapController extends GetxController {
  final rows = <BangkehoachnhapRow>[].obs;
  final loading = false.obs;

  // Column visibility
  final showNgayNhap = true.obs;
  final showHLI = true.obs;
  final showDVU = true.obs;
  final showTLY = true.obs;
  final showGhichuMB = true.obs;
  final showLCH = true.obs;
  final showGhichuDN = true.obs;
  final showHMO = true.obs;
  final showGhichuCR = true.obs;
  final showCLA = true.obs;
  final showTLE = true.obs;
  final showQCH = true.obs;
  final showGhichuMN = true.obs;

  void loadData(List<Map<String, dynamic>> data) {
    rows.assignAll(data.map((e) => BangkehoachnhapRow.fromMap(e)).toList());
  }

  String fmt(num? v, {int decimals = 0}) {
    if (v == null || v == 0) return '--';
    if (decimals == 0) {
      return NumberFormat('#,##0', 'vi_VN').format(v);
    }
    return NumberFormat('#,##0.${'0' * decimals}', 'vi_VN').format(v);
  }

  String get currentMonth {
    if (rows.isEmpty) return '';
    try {
      final firstDate = rows.first.ngayNhap;
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

class BangkehoachnhapCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const BangkehoachnhapCard({
    super.key,
    required this.data,
    this.title = 'BẢNG KẾ HOẠCH NHẬP HÀNG',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BangkehoachnhapController())..loadData(data);

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

List<_ColDef> _buildDefs(BangkehoachnhapController c) {
  final configs = [
    // Ngày - giữ nguyên
    ('showNgayNhap', 'ngayNhap', 'NGÀY', 0.9, null),
    
    // Miền Bắc - giảm flex các cột số, tăng ghi chú
    ('showHLI', 'hli', 'HLI', 0.6, Color(0xFFDCEBFA)),
    ('showDVU', 'dvu', 'DVU', 0.6, Color(0xFFDCEBFA)),
    ('showTLY', 'tly', 'TLY', 0.6, Color(0xFFDCEBFA)),
    ('showGhichuMB', 'ghichuMB', 'GHI CHÚ', 1.5, Color(0xFFDCEBFA)),
    
    // Miền Trung - giảm flex cột số, tăng ghi chú
    ('showLCH', 'lch', 'LCH', 0.7, Color(0xFFFFE8CC)),
    ('showGhichuDN', 'ghichuDN', 'GHI CHÚ', 1.5, Color(0xFFFFE8CC)),
    
    // Cam Ranh - giảm flex cột số, tăng ghi chú
    ('showHMO', 'hmo', 'HMO', 0.7, Color(0xFFE2F0D9)),
    ('showGhichuCR', 'ghichuCR', 'GHI CHÚ', 1.5, Color(0xFFE2F0D9)),
    
    // Miền Nam - giảm flex các cột số, tăng ghi chú
    ('showCLA', 'cla', 'CLA', 0.6, Color(0xFFF4D9E8)),
    ('showTLE', 'tle', 'TLE', 0.6, Color(0xFFF4D9E8)),
    ('showQCH', 'qch', 'QCH', 0.6, Color(0xFFF4D9E8)),
    ('showGhichuMN', 'ghichuMN', 'GHI CHÚ', 1.5, Color(0xFFF4D9E8)),
  ];

  final showMap = {
    'showNgayNhap': c.showNgayNhap.value,
    'showHLI': c.showHLI.value,
    'showDVU': c.showDVU.value,
    'showTLY': c.showTLY.value,
    'showGhichuMB': c.showGhichuMB.value,
    'showLCH': c.showLCH.value,
    'showGhichuDN': c.showGhichuDN.value,
    'showHMO': c.showHMO.value,
    'showGhichuCR': c.showGhichuCR.value,
    'showCLA': c.showCLA.value,
    'showTLE': c.showTLE.value,
    'showQCH': c.showQCH.value,
    'showGhichuMN': c.showGhichuMN.value,
  };

  return configs
      .where((x) => showMap[x.$1] == true)
      .map((x) => _ColDef(x.$2, x.$3, x.$4, color: x.$5))
      .toList();
}
// ============================================================
// TỔNG FLEX
// ============================================================

double _getTotalFlex(BangkehoachnhapController c) {
  double total = 0;

  if (c.showNgayNhap.value) total += 0.9;
  if (c.showHLI.value) total += 0.6;
  if (c.showDVU.value) total += 0.6;
  if (c.showTLY.value) total += 0.6;
  if (c.showGhichuMB.value) total += 1.5;
  if (c.showLCH.value) total += 0.7;
  if (c.showGhichuDN.value) total += 1.5;
  if (c.showHMO.value) total += 0.7;
  if (c.showGhichuCR.value) total += 1.5;
  if (c.showCLA.value) total += 0.6;
  if (c.showTLE.value) total += 0.6;
  if (c.showQCH.value) total += 0.6;
  if (c.showGhichuMN.value) total += 1.5;

  return total;
}

// ============================================================
// HEADER
// ============================================================

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.controller});

  final BangkehoachnhapController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final defs = _buildDefs(controller);
      final totalFlex = _getTotalFlex(controller);

      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - 16;
          final columnWidth = availableWidth / totalFlex;

          double widthOf(List<String> keys) {
            return defs
                .where((e) => keys.contains(e.key))
                .fold(0.0, (sum, e) => sum + columnWidth * e.flex);
          }

          bool has(String key) {
            return defs.any((e) => e.key == key);
          }

          // ==========================================================
          // HEADER KHU VỰC
          // ==========================================================
          Widget groupHeader(
            String title,
            List<String> keys, {
            required Color color,
          }) {
            final width = widthOf(keys);

            if (width <= 0) {
              return const SizedBox.shrink();
            }

            return Container(
              width: width,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                border: const Border(
                  left: BorderSide(color: Color(0xFFADB5BD), width: 1),
                  right: BorderSide(color: Color(0xFFADB5BD), width: 1),
                  bottom: BorderSide(color: Color(0xFFADB5BD), width: 1),
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF343A40),
                ),
              ),
            );
          }

          // ==========================================================
          // Ô TRỐNG
          // ==========================================================
          Widget emptyGroup(
            double width, {
            Color color = const Color(0xFFF1F3F5),
          }) {
            return Container(
              width: width,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFADB5BD), width: 1),
                ),
              ),
            );
          }

          // ==========================================================
          // MÀU TỪNG KHU VỰC
          // ==========================================================
          const northColor = Color(0xFFDCEBFA);
          const centralColor = Color(0xFFFFE8CC);
          const eastColor = Color(0xFFE2F0D9);
          const southColor = Color(0xFFF4D9E8);

          return Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // ==================================================
                  // HÀNG 1 - KHU VỰC
                  // ==================================================
                  Row(
                    children: [
                      // NGÀY
                      if (has('ngayNhap')) emptyGroup(widthOf(['ngayNhap'])),

                      // ==================================================
                      // MIỀN BẮC + GHI CHÚ MB
                      // ==================================================
                      groupHeader('MIỀN BẮC', [
                        'hli',
                        'dvu',
                        'tly',
                        if (has('ghichuMB')) 'ghichuMB',
                      ], color: northColor),

                      // ==================================================
                      // MIỀN TRUNG + GHI CHÚ DN
                      // ==================================================
                      groupHeader('MIỀN TRUNG', [
                        'lch',
                        if (has('ghichuDN')) 'ghichuDN',
                      ], color: centralColor),

                      // ==================================================
                      // Cam Ranh + GHI CHÚ CR
                      // ==================================================
                      groupHeader('CAM RANH', [
                        'hmo',
                        if (has('ghichuCR')) 'ghichuCR',
                      ], color: eastColor),

                      // ==================================================
                      // MIỀN NAM + GHI CHÚ MN
                      // ==================================================
                      groupHeader('MIỀN NAM', [
                        'cla',
                        'tle',
                        'qch',
                        if (has('ghichuMN')) 'ghichuMN',
                      ], color: southColor),
                    ],
                  ),

                  // ==================================================
                  // HÀNG 2 - TÊN CỘT
                  // ==================================================
                  Row(
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
                          decoration: BoxDecoration(
                            color:
                                [
                                      'hli',
                                      'dvu',
                                      'tly',
                                      'ghichuMB',
                                    ].contains(def.key)
                                    ? const Color(0xFFF0F7FD) // Miền Bắc
                                    : ['lch', 'ghichuDN'].contains(def.key)
                                    ? const Color(0xFFFFF7ED) // Miền Trung
                                    : ['hmo', 'ghichuCR'].contains(def.key)
                                    ? const Color(0xFFF2F8EE) // Cam Ranh
                                    : [
                                      'cla',
                                      'tle',
                                      'qch',
                                      'ghichuMN',
                                    ].contains(def.key)
                                    ? const Color(0xFFFCF1F7) // Miền Nam
                                    : const Color(0xFFF5F6F7), // Ngày / khác

                            border: const Border(
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

  final BangkehoachnhapController controller;

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
  final BangkehoachnhapRow row;
  final List<_ColDef> defs;
  final double columnWidth;
  final BangkehoachnhapController controller;

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _cell(String key, BangkehoachnhapRow row) {
    final text = switch (key) {
      'ngayNhap' => row.ngayNhap,
      'hli' => controller.fmt(row.hli),
      'dvu' => controller.fmt(row.dvu),
      'tly' => controller.fmt(row.tly),
      'ghichuMB' => row.ghichuMB ?? '--',
      'lch' => controller.fmt(row.lch),
      'ghichuDN' => row.ghichuDN ?? '--',
      'hmo' => controller.fmt(row.hmo),
      'ghichuCR' => row.ghichuCR ?? '--',
      'cla' => controller.fmt(row.cla),
      'tle' => controller.fmt(row.tle),
      'qch' => controller.fmt(row.qch),
      'ghichuMN' => row.ghichuMN ?? '--',
      _ => '--',
    };

    final isNumeric = switch (key) {
      'ngayNhap' => false,
      'ghichuMB' => false,
      'ghichuDN' => false,
      'ghichuCR' => false,
      'ghichuMN' => false,
      _ => true,
    };

    return Text(
      text,
      textAlign: TextAlign.left,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color:
            text == '--'
                ? Colors.grey.shade400
                : (isNumeric ? Colors.black87 : Colors.black87),
        fontWeight:
            text == '--'
                ? FontWeight.w400
                : (isNumeric ? FontWeight.w600 : FontWeight.w500),
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
  final BangkehoachnhapController controller;

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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nhóm 1: Ngày
                        _switch('Ngày', controller.showNgayNhap),
                        const Divider(height: 1, color: Color(0xFFE6ECF5)),
                        // Nhóm 2: Đỏ
                        _switchWithColor(
                          'Hải Linh',
                          controller.showHLI,
                          Color(0xFFDCEBFA),
                        ),
                        _switchWithColor(
                          'Đinh Vũ',
                          controller.showDVU,
                          Color(0xFFDCEBFA),
                        ),
                        _switchWithColor(
                          'Thượng Lý',
                          controller.showTLY,
                          Color(0xFFDCEBFA),
                        ),
                        _switchWithColor(
                          'Ghi chú',
                          controller.showGhichuMB,
                          Color(0xFFDCEBFA),
                        ),
                        const Divider(height: 1, color: Color(0xFFE6ECF5)),
                        // Nhóm 3: Vàng
                        _switchWithColor(
                          'Kho Liên Chiểu',
                          controller.showLCH,
                          Color(0xFFFFE8CC),
                        ),
                        _switchWithColor(
                          'Ghi chú DN',
                          controller.showGhichuDN,
                          Color(0xFFFFE8CC),
                        ),
                        const Divider(height: 1, color: Color(0xFFE6ECF5)),
                        // Nhóm 4: Xanh lá
                        _switchWithColor(
                          'Kho Hồng Mộc',
                          controller.showHMO,
                          Color(0xFFE2F0D9),
                        ),
                        _switchWithColor(
                          'Ghi chú CR',
                          controller.showGhichuCR,
                          Color(0xFFE2F0D9),
                        ),
                        const Divider(height: 1, color: Color(0xFFE6ECF5)),
                        // Nhóm 5: Xanh dương
                        _switchWithColor(
                          'Cát Lái',
                          controller.showCLA,
                          Color(0xFFF4D9E8),
                        ),
                        _switchWithColor(
                          'Thanh Lễ',
                          controller.showTLE,
                          Color(0xFFF4D9E8),
                        ),
                        _switchWithColor(
                          'Kho Quốc Chánh',
                          controller.showQCH,
                          Color(0xFFF4D9E8),
                        ),
                        _switchWithColor(
                          'Ghi chú',
                          controller.showGhichuMN,
                          Color(0xFFF4D9E8),
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
                          // Reset all to true
                          controller.showNgayNhap.value = true;
                          controller.showHLI.value = true;
                          controller.showDVU.value = true;
                          controller.showTLY.value = true;
                          controller.showGhichuMB.value = true;
                          controller.showLCH.value = true;
                          controller.showGhichuDN.value = true;
                          controller.showHMO.value = true;
                          controller.showGhichuCR.value = true;
                          controller.showCLA.value = true;
                          controller.showTLE.value = true;
                          controller.showQCH.value = true;
                          controller.showGhichuMN.value = true;
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
