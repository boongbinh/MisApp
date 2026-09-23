// components/AnNinh/BangSanluongchuyenbayCard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ============================================================
// MODEL
// ============================================================

class BangSanluongchuyenbayRow {
  final String sanBay;
  final String tenSanBay;
  final String chiNhanh;
  final double khCb;
  final double khSl;
  final double tileKH;
  final double thCb;
  final double thSl;
  final double tileTH;

  BangSanluongchuyenbayRow({
    required this.sanBay,
    required this.tenSanBay,
    required this.chiNhanh,
    required this.khCb,
    required this.khSl,
    required this.tileKH,
    required this.thCb,
    required this.thSl,
    required this.tileTH,
  });

  factory BangSanluongchuyenbayRow.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return BangSanluongchuyenbayRow(
      sanBay: map['SanBay']?.toString() ?? '',
      tenSanBay: map['TenSanbay']?.toString() ?? '',
      chiNhanh: map['Chinhanh']?.toString() ?? '',
      khCb: parseDouble(map['KH_CB']),
      khSl: parseDouble(map['KH_SL']),
      tileKH: parseDouble(map['TileKH']),
      thCb: parseDouble(map['TH_CB']),
      thSl: parseDouble(map['TH_SL']),
      tileTH: parseDouble(map['TileTH']),
    );
  }
}

// ============================================================
// CONTROLLER
// ============================================================

class BangSanluongchuyenbayController extends GetxController {
  final rows = <BangSanluongchuyenbayRow>[].obs;

  void loadData(List<Map<String, dynamic>> data) {
    rows.assignAll(data.map((e) => BangSanluongchuyenbayRow.fromMap(e)).toList());
  }

  String fmt(num? v, {int decimals = 0}) {
    if (v == null || v == 0) return '0';
    if (decimals == 0) return NumberFormat('#,##0', 'vi_VN').format(v);
    return NumberFormat('#,##0.${'0' * decimals}', 'vi_VN').format(v);
  }

  String fmtPercent(num? v) {
    if (v == null || v == 0) return '0%';
    return '${NumberFormat('#,##0.0#', 'vi_VN').format(v)}%';
  }
}

// ============================================================
// COLUMN DEFINITION
// ============================================================

class _ColDef {
  final String key;
  final String title;
  final double width;
  const _ColDef(this.key, this.title, this.width);
}

// ============================================================
// CARD CHÍNH
// ============================================================

class BangSanluongchuyenbayCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const BangSanluongchuyenbayCard({
    super.key,
    required this.data,
    this.title = 'BẢNG SẢN LƯỢNG CHUYẾN BAY',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BangSanluongchuyenbayController())..loadData(data);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF1F2A37),
              ),
            ),
          ),
          _TableContent(controller: controller),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ============================================================
// TABLE CONTENT
// ============================================================

class _TableContent extends StatelessWidget {
  const _TableContent({required this.controller});

  final BangSanluongchuyenbayController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.rows;

      if (rows.isEmpty) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      final defs = [
        const _ColDef('tenSanBay', 'ĐƠN VỊ', 150),
        const _ColDef('khCb', 'KH', 100),
        const _ColDef('thCb', 'TH', 100),
        const _ColDef('tileKH', 'TH/KH', 100),
        const _ColDef('khSl', 'KH', 120),
        const _ColDef('thSl', 'TH', 120),
        const _ColDef('tileTH', 'TH/KH', 100),
      ];

      // Width colspan
      double chuyenBayWidth = defs[1].width + defs[2].width + defs[3].width;
      double sanLuongWidth = defs[4].width + defs[5].width + defs[6].width;

      // Header dòng 1
      List<Widget> headerRow1 = [
        Container(
          width: defs[0].width,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF4D73B2),
            border: Border(
              right: BorderSide(color: Colors.white, width: 0.5),
              bottom: BorderSide(color: Colors.white, width: 0.5),
            ),
          ),
        ),
        Container(
          width: chuyenBayWidth,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF4D73B2),
            border: Border(
              right: BorderSide(color: Colors.white, width: 0.5),
              bottom: BorderSide(color: Colors.white, width: 0.5),
            ),
          ),
          child: const Text(
            'CHUYẾN BAY',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        Container(
          width: sanLuongWidth,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF4D73B2),
            border: Border(
              right: BorderSide(color: Colors.white, width: 0.5),
              bottom: BorderSide(color: Colors.white, width: 0.5),
            ),
          ),
          child: const Text(
            'SẢN LƯỢNG',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
      ];

      // Header dòng 2
      List<Widget> headerRow2 = [];
      for (int i = 0; i < defs.length; i++) {
        headerRow2.add(
          Container(
            width: defs[i].width,
            height: 36,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF4D73B2),
              border: Border(
                right: BorderSide(color: Colors.white, width: 0.5),
                bottom: BorderSide(color: Color(0xFF94A3B8), width: 1),
              ),
            ),
            child: Text(
              defs[i].title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        );
      }

      // Data rows
      List<Widget> dataRows = [];
      for (int index = 0; index < rows.length; index++) {
        final row = rows[index];

        dataRows.add(
          Container(
            color: index % 2 == 0 ? Colors.white : const Color(0xFFF8F9FA),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _cell(defs[0].width, row.tenSanBay, isText: true),
                _cell(defs[1].width, controller.fmt(row.khCb)),
                _cell(defs[2].width, controller.fmt(row.thCb)),
                _cell(defs[3].width, controller.fmtPercent(row.tileKH)), // bỏ màu
                _cell(defs[4].width, controller.fmt(row.khSl)),
                _cell(defs[5].width, controller.fmt(row.thSl)),
                _cell(defs[6].width, controller.fmtPercent(row.tileTH)), // bỏ màu
              ],
            ),
          ),
        );

        if (index < rows.length - 1) {
          dataRows.add(const Divider(height: 1, thickness: 1, color: Color(0xFFE6ECF5)));
        }
      }

      final totalWidth = defs.fold(0.0, (sum, def) => sum + def.width);

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: totalWidth + 18,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xFFDEE2E6), width: 1),
              right: BorderSide(color: Color(0xFFDEE2E6), width: 1),
            ),
          ),
          child: Column(
            children: [
              Row(children: headerRow1),
              Row(children: headerRow2),
              ...dataRows,
            ],
          ),
        ),
      );
    });
  }

  Widget _cell(double width, String text, {bool isText = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isText ? FontWeight.w500 : FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: isText ? TextAlign.left : TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}