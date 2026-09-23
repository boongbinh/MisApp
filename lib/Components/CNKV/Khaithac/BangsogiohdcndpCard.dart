import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ============================================================
// MODEL
// ============================================================

class BangsogiohdcndpRow {
  final String sanbay;
  final String dongxe;
  final String bienso;
  final double homkia;
  final double homqua;
  final double tongGioHD;
  final double tbGioHD;
  final String chinhanh;
  final int loai;

  BangsogiohdcndpRow({
    required this.sanbay,
    required this.dongxe,
    required this.bienso,
    required this.homkia,
    required this.homqua,
    required this.tongGioHD,
    required this.tbGioHD,
    required this.chinhanh,
    required this.loai,
  });

  factory BangsogiohdcndpRow.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        final cleaned = value.replaceAll(',', '');
        return double.tryParse(cleaned) ?? 0;
      }

      return 0;
    }

    return BangsogiohdcndpRow(
      sanbay: map['Sanbay']?.toString() ?? '',
      dongxe: map['Dongxe']?.toString() ?? '',
      bienso: map['Bienso']?.toString() ?? '',
      homkia: parseDouble(map['Homkia']),
      homqua: parseDouble(map['Homqua']),
      tongGioHD: parseDouble(map['Tong_gioHD']),
      tbGioHD: parseDouble(map['TB_gioHD']),
      chinhanh: map['Chinhanh']?.toString() ?? '',
      loai: (map['Loai'] as num?)?.toInt() ?? 1,
    );
  }
}


// ============================================================
// CONTROLLER
// ============================================================

class BangsogiohdcndpController extends GetxController {
  final rows = <BangsogiohdcndpRow>[].obs;
  final loading = false.obs;

  DateTime? selectedDate;

  final showSanbay = true.obs;
  final showDongxe = true.obs;
  final showBienso = true.obs;
  final showHomkia = true.obs;
  final showHomqua = true.obs;
  final showTongGioHD = true.obs;
  final showTbGioHD = true.obs;

  void loadData(
    List<Map<String, dynamic>> data,
    DateTime date,
  ) {
    selectedDate = date;

    rows.assignAll(
      data
          .map((e) => BangsogiohdcndpRow.fromMap(e))
          .toList(),
    );
  }

  String fmt(
    num? v, {
    int decimals = 1,
  }) {
    if (v == null || v == 0) return '--';

    if (decimals == 0) {
      return NumberFormat(
        '#,##0',
        'vi_VN',
      ).format(v);
    }

    return NumberFormat(
      '#,##0.${'0' * decimals}',
      'vi_VN',
    ).format(v);
  }

  String get previousDay {
    if (selectedDate == null) {
      return 'Hôm kia';
    }

    final prev = selectedDate!.subtract(
      const Duration(days: 1),
    );

    return DateFormat('dd/MM').format(prev);
  }

  String get currentDay {
    if (selectedDate == null) {
      return 'Hôm qua';
    }

    return DateFormat('dd/MM').format(
      selectedDate!,
    );
  }

  String get currentMonth {
    if (selectedDate == null) {
      return '';
    }

    return DateFormat('MM/yyyy').format(
      selectedDate!,
    );
  }

  void openColumnSettings() {
    final ctx = Get.context;

    if (ctx == null) return;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ColumnSettingsSheet(
        controller: this,
      ),
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

  const _ColDef(
    this.key,
    this.title,
    this.flex,
  );
}


// ============================================================
// CARD CHÍNH
// ============================================================

class BangsogiohdcndpCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final DateTime selectedDate;

  const BangsogiohdcndpCard({
    super.key,
    required this.data,
    required this.selectedDate,
    this.title = 'BẢNG SỐ GIỜ HOẠT ĐỘNG CƠ ĐỘNG NỘI ĐỊA PHỤ',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      BangsogiohdcndpController(),
    )..loadData(
        data,
        selectedDate,
      );

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
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
              ),
              onPressed: controller.openColumnSettings,
            ),
          ),

          _TableHeader(
            controller: controller,
          ),

          const Divider(height: 1),

          //mơ rộng height để hiển thị hết dữ liệu không bị warning nữa
           Expanded(
              child: _TableBody(
                controller: controller,
              ),
            ),

          const _FooterNote(),
        ],
      ),
    );
  }
}


// ============================================================
// XÂY DỰNG CÁC CỘT
// ============================================================

List<_ColDef> _buildDefs(
  BangsogiohdcndpController c,
) {
  final defs = <_ColDef>[];

  if (c.showSanbay.value) {
    defs.add(
      const _ColDef(
        'sanbay',
        'SÂN BAY',
        0.5,
      ),
    );
  }

  if (c.showDongxe.value) {
    defs.add(
      const _ColDef(
        'dongxe',
        'DÒNG XE',
        1.2,
      ),
    );
  }

  if (c.showBienso.value) {
    defs.add(
      const _ColDef(
        'bienso',
        'SỐ ĐĂNG KÝ',
        1.0,
      ),
    );
  }

  if (c.showHomkia.value) {
    defs.add(
      _ColDef(
        'homkia',
        'GIỜ XE HOẠT ĐỘNG\n${c.previousDay}',
        0.9,
      ),
    );
  }

  if (c.showHomqua.value) {
    defs.add(
      _ColDef(
        'homqua',
        'GIỜ XE HOẠT ĐỘNG\n${c.currentDay}',
        0.9,
      ),
    );
  }

  if (c.showTongGioHD.value) {
    defs.add(
      _ColDef(
        'tongGioHD',
        'TỔNG THÁNG\n${c.currentMonth}',
        0.8,
      ),
    );
  }

  if (c.showTbGioHD.value) {
    defs.add(
      _ColDef(
        'tbGioHD',
        'TRUNG BÌNH THÁNG\n${c.currentMonth}',
        0.8,
      ),
    );
  }

  return defs;
}


// ============================================================
// TỔNG FLEX
// ============================================================

double _getTotalFlex(
  BangsogiohdcndpController c,
) {
  double total = 0;

  if (c.showSanbay.value) {
    total += 0.5;
  }

  if (c.showDongxe.value) {
    total += 1.2;
  }

  if (c.showBienso.value) {
    total += 1.0;
  }

  if (c.showHomkia.value) {
    total += 0.9;
  }

  if (c.showHomqua.value) {
    total += 0.9;
  }

  if (c.showTongGioHD.value) {
    total += 0.8;
  }

  if (c.showTbGioHD.value) {
    total += 0.8;
  }

  return total;
}


// ============================================================
// HEADER
// ============================================================

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.controller,
  });

  final BangsogiohdcndpController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final defs = _buildDefs(controller);
      final totalFlex = _getTotalFlex(controller);

      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth =
              constraints.maxWidth - 16;

          final columnWidth =
              availableWidth / totalFlex;

          return Container(
            color: const Color(0xFF4D73B2),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  for (int i = 0;
                      i < defs.length;
                      i++)
                    SizedBox(
                      width:
                          columnWidth * defs[i].flex,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Text(
                          defs[i].title,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w600,
                            fontSize: 9,
                          ),
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
  const _TableBody({
    required this.controller,
  });

  final BangsogiohdcndpController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.rows;

      if (rows.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        );
      }

      final defs = _buildDefs(controller);
      final totalFlex = _getTotalFlex(
        controller,
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth =
              constraints.maxWidth - 16;

          final columnWidth =
              availableWidth / totalFlex;

          return ListView.separated(
            physics:
                const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: rows.length,
            separatorBuilder: (_, __) =>
                const Divider(
              height: 1,
              color: Color(0xFFE6ECF5),
            ),
            itemBuilder: (_, index) =>
                _RowWidget(
              controller: controller,
              row: rows[index],
              index: index,
              defs: defs,
              columnWidth: columnWidth,
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
  final BangsogiohdcndpRow row;
  final List<_ColDef> defs;
  final double columnWidth;
  final BangsogiohdcndpController controller;

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
      color: index % 2 == 0
          ? Colors.white
          : const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            for (int i = 0;
                i < defs.length;
                i++)
              SizedBox(
                width:
                    columnWidth * defs[i].flex,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: _cell(
                    defs[i].key,
                    row,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    String key,
    BangsogiohdcndpRow row,
  ) {
    final text = switch (key) {
      'sanbay' => row.sanbay,

      'dongxe' => row.dongxe,

      'bienso' => row.bienso,

      'homkia' => controller.fmt(
          row.homkia,
          decimals: 1,
        ),

      'homqua' => controller.fmt(
          row.homqua,
          decimals: 1,
        ),

      'tongGioHD' => controller.fmt(
          row.tongGioHD,
          decimals: 1,
        ),

      'tbGioHD' => controller.fmt(
          row.tbGioHD,
          decimals: 2,
        ),

      _ => '--',
    };

    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: text == '--'
            ? Colors.grey.shade400
            : Colors.black87,
        fontWeight: text == '--'
            ? FontWeight.w400
            : FontWeight.w500,
        height: 1.2,
      ),
    );
  }
}


// ============================================================
// COLUMN SETTINGS
// ============================================================

class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({
    required this.controller,
  });

  final BangsogiohdcndpController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),

                const Text(
                  'Cài đặt hiển thị',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        _switch(
                          'Sân bay',
                          controller.showSanbay,
                        ),

                        _switch(
                          'Dòng xe',
                          controller.showDongxe,
                        ),

                        _switch(
                          'Số đăng ký',
                          controller.showBienso,
                        ),

                        _switch(
                          'Giờ xe hoạt động hôm kia',
                          controller.showHomkia,
                        ),

                        _switch(
                          'Giờ xe hoạt động hôm qua',
                          controller.showHomqua,
                        ),

                        _switch(
                          'Tổng tháng',
                          controller.showTongGioHD,
                        ),

                        _switch(
                          'Trung bình tháng',
                          controller.showTbGioHD,
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
                          controller
                              .showSanbay
                              .value = true;

                          controller
                              .showDongxe
                              .value = true;

                          controller
                              .showBienso
                              .value = true;

                          controller
                              .showHomkia
                              .value = true;

                          controller
                              .showHomqua
                              .value = true;

                          controller
                              .showTongGioHD
                              .value = true;

                          controller
                              .showTbGioHD
                              .value = true;

                          controller.update();
                        },
                        style:
                            OutlinedButton.styleFrom(
                          shape:
                              const StadiumBorder(),
                        ),
                        child:
                            const Text('Mặc định'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        style:
                            FilledButton.styleFrom(
                          shape:
                              const StadiumBorder(),
                        ),
                        child:
                            const Text('Áp dụng'),
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

  Widget _switch(
    String title,
    RxBool bind,
  ) {
    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 16),

          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(fontSize: 13),
            ),
          ),

          Obx(
            () => Switch(
              value: bind.value,
              onChanged: (v) => bind.value = v,
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// FOOTER NOTE
// ============================================================

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE6ECF5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Ghi chú:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2A37),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Nguồn: Từ phiếu kiểm tra đầu ca trên hệ thống số hóa xe tra nạp',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}