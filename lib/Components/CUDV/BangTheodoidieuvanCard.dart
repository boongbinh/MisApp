// components/CUDV/BangTheodoidieuvanCard.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ============================================================
// MODEL
// ============================================================

class BangTheodoidieuvanRow {
  final String khuVuc;
  final String kho;
  final double dungTich;
  final double heSoCanhBao;
  final double heSoCanhBao2;
  final List<Map<String, dynamic>> ngayData;

  BangTheodoidieuvanRow({
    required this.khuVuc,
    required this.kho,
    required this.dungTich,
    required this.heSoCanhBao,
    required this.heSoCanhBao2,
    required this.ngayData,
  });

  factory BangTheodoidieuvanRow.fromMap(
  Map<String, dynamic> map,
  List<DateTime> dateRange,
) {
  return BangTheodoidieuvanRow(
    khuVuc: map['KHU_VUC']?.toString() ?? '',

    kho: map['KHO']?.toString() ?? '',

    dungTich:
        (map['DUNG_TICH_M3'] as num?)
                ?.toDouble() ??
            0,

    heSoCanhBao:
        (map['HE_SO_CANH_BAO'] as num?)
                ?.toDouble() ??
            0,

    heSoCanhBao2:
        (map['HE_SO_CANH_BAO2'] as num?)
                ?.toDouble() ??
            0,

    ngayData: dateRange.map((date) {
      final dateStr = DateFormat(
        'yyyy-MM-dd',
      ).format(date);

      final dailyData = map[dateStr] is Map
          ? Map<String, dynamic>.from(map[dateStr] as Map)
          : null;

      return {
        'date': dateStr,

        'Ton':
            (dailyData?['Ton'] as num?)
                    ?.toDouble() ??
                0,

        'Sanluong':
            (dailyData?['Sanluong'] as num?)
                    ?.toDouble() ??
                0,
        'Heso':
            (dailyData?['Heso'] as num?)?.toDouble() ?? 0,

        'HesoString':
            dailyData?['HesoString']?.toString() ?? '',
      };
    }).toList(),
  );
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

class BangTheodoidieuvanCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final List<DateTime> dateRange;

  const BangTheodoidieuvanCard({
    super.key,
    required this.data,
    required this.dateRange,
    this.title = 'BẢNG THEO DÕI TỒN KHO',
  });

  @override
  Widget build(BuildContext context) {
    // ViewModel đã xử lý dữ liệu API thành dạng:
    // {
    //   KHU_VUC: 'CNKVMB',
    //   KHO: 'HAN',
    //   DUNG_TICH_M3: 7200,
    //   HE_SO_CANH_BAO: 5,
    //   HE_SO_CANH_BAO2: 3,
    //   '2026-08-24': {
    //      'Ton': 5983.72,
    //      'Sanluong': 1000.756,
    //   }
    // }
    //
    // Card chỉ chuyển dữ liệu sang Row để hiển thị, không group lại nữa.
    final rows = data
        .map(
          (item) => BangTheodoidieuvanRow.fromMap(
            item,
            dateRange,
          ),
        )
        .toList();

    return Container(
      height: 500,
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
          Expanded(
            child: _TableContent(rows: rows, dateRange: dateRange),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// XÂY DỰNG CÁC CỘT
// ============================================================

List<_ColDef> _buildDefs(List<DateTime> dateRange) {
  final defs = <_ColDef>[];

  defs.add(const _ColDef('khuVuc', 'KHU VỰC', 120));
  defs.add(const _ColDef('kho', 'KHO', 80));
  defs.add(const _ColDef('dungTich', 'DUNG TÍCH', 90));
  defs.add(const _ColDef('heSoCanhBao', 'HỆ SỐ\nCB 1', 90));
  defs.add(const _ColDef('heSoCanhBao2', 'HỆ SỐ\nCB 2', 90));

  for (int i = 0; i < dateRange.length; i++) {
    defs.add(_ColDef('ton_$i', 'TỒN', 110));
    defs.add(_ColDef('sanluong_$i', 'SẢN LƯỢNG', 110));
    defs.add(_ColDef('heso_$i', 'HỆ SỐ\nDỰ TRỮ', 110));

  }

  return defs;
}

double _getTotalWidth(List<DateTime> dateRange) {
  double total = 120 + 80 + 90 + 90 + 90;
  total += dateRange.length * (110 + 110 + 110);
  return total;
}

// ============================================================
// TABLE CONTENT - GỘP HEADER VÀ BODY TRONG 1 SCROLL
// ============================================================

class _TableContent extends StatelessWidget {
  const _TableContent({
    required this.rows,
    required this.dateRange,
  });

  final List<BangTheodoidieuvanRow> rows;
  final List<DateTime> dateRange;

  @override
  Widget build(BuildContext context) {
    final defs = _buildDefs(dateRange);
    final dayCount = dateRange.length;
    final totalWidth = _getTotalWidth(dateRange);

    if (rows.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

      // Xây dựng header dòng 1
      List<Widget> headerRow1Children = [];

      // 5 cột đầu trống
      headerRow1Children.add(Container(width: 120, height: 28, color: const Color(0xFFF1F3F5)));
      headerRow1Children.add(Container(width: 80, height: 28, color: const Color(0xFFF1F3F5)));
      headerRow1Children.add(Container(width: 90, height: 28, color: const Color(0xFFF1F3F5)));
      headerRow1Children.add(Container(width: 90, height: 28, color: const Color(0xFFF1F3F5)));
      headerRow1Children.add(Container(width: 90, height: 28, color: const Color(0xFFF1F3F5)));

      // Colspan cho từng ngày
      for (int i = 0; i < dayCount; i++) {
        final colIndex = 5 + i * 3;

        if (colIndex + 2 < defs.length) {
          final colspanWidth =
              defs[colIndex].width +
              defs[colIndex + 1].width +
              defs[colIndex + 2].width;

          headerRow1Children.add(
            Container(
              width: colspanWidth,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                border: Border.all(
                  color: const Color(0xFFADB5BD),
                  width: 0.5,
                ),
              ),
              child: Text(
                _formatDate(dateRange[i]),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          );
        }
      }

      // Xây dựng header dòng 2
      List<Widget> headerRow2Children = [];
      for (int i = 0; i < defs.length; i++) {
        final isTon = defs[i].key.startsWith('ton_');
        final isSanLuong = defs[i].key.startsWith('sanluong_');
        final isHeso = defs[i].key.startsWith('heso_');

        final isFixed = !isTon && !isSanLuong && !isHeso;

        headerRow2Children.add(
          Container(
            width: defs[i].width,
            height: 42,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: isFixed
                  ? const Color(0xFFF5F6F7)
                  : (isTon ? const Color(0xFFF0F7FD) : const Color(0xFFF2F8EE)),
              border: const Border(
                left: BorderSide(color: Color(0xFFCBD5E1), width: 0.8),
                right: BorderSide(color: Color(0xFFCBD5E1), width: 0.8),
                bottom: BorderSide(color: Color(0xFF94A3B8), width: 1),
              ),
            ),
            child: Text(
              defs[i].title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        );
      }

      // Xây dựng các dòng dữ liệu
      List<Widget> dataRows = [];
      for (int index = 0; index < rows.length; index++) {
        final row = rows[index];
        List<Widget> rowCells = [];
        for (int i = 0; i < defs.length; i++) {
          rowCells.add(
            SizedBox(
              width: defs[i].width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: _cell(defs[i].key, row),
              ),
            ),
          );
        }
        
        dataRows.add(
          Container(
            color: index % 2 == 0 ? Colors.white : const Color(0xFFF8F9FA),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: rowCells,
            ),
          ),
        );
        
        if (index < rows.length - 1) {
          dataRows.add(
            const Divider(height: 1, thickness: 1, color: Color(0xFFE6ECF5)),
          );
        }
      }

      // GỘP TẤT CẢ VÀO 1 CỘT VÀ SCROLL CHUNG
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
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                // Header dòng 1
                Row(children: headerRow1Children),
                // Header dòng 2
                Row(children: headerRow2Children),
                // Divider ngăn cách header và body
                const Divider(height: 1, thickness: 1, color: Color(0xFF94A3B8)),
                // Các dòng dữ liệu
                ...dataRows,
              ],
            ),
          ),
        ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _fmt(num? value, {int decimals = 1}) {
    if (value == null || value == 0) return '--';

    if (decimals == 0) {
      return NumberFormat('#,##0', 'vi_VN').format(value);
    }

    return NumberFormat(
      '#,##0.${'0' * decimals}',
      'vi_VN',
    ).format(value);
  }

  Widget _cell(String key, BangTheodoidieuvanRow row) {
    if (key == 'khuVuc') {
      return Text(
        row.khuVuc,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      );
    }
    if (key == 'kho') {
      return Text(
        row.kho,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      );
    }
    if (key == 'dungTich') {
      return Text(
        _fmt(row.dungTich, decimals: 0),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      );
    }
    if (key == 'heSoCanhBao') {
      return Text(
        _fmt(row.heSoCanhBao, decimals: 2),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color:  Colors.black87,
        ),
      );
    }
    if (key == 'heSoCanhBao2') {
      return Text(
        _fmt(row.heSoCanhBao2, decimals: 2),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color:  Colors.black87,
        ),
      );
    }

    if (key.startsWith('ton_')) {
      final idx = int.parse(key.split('_')[1]);
      if (idx < row.ngayData.length) {
        final value = row.ngayData[idx]['Ton'] ?? 0;
        return Text(
          _fmt(value, decimals: 1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: value > 0 ? Colors.black87 : Colors.grey.shade400,
          ),
        );
      }
      return const Text('--');
    }

    if (key.startsWith('sanluong_')) {
      final idx = int.parse(key.split('_')[1]);
      if (idx < row.ngayData.length) {
        final value = row.ngayData[idx]['Sanluong'] ?? 0;
        return Text(
          _fmt(value, decimals: 1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: value > 0 ? Colors.black87 : Colors.grey.shade400,
          ),
        );
      }
      return const Text('--');
    }

    if (key.startsWith('heso_')) {
      final idx = int.tryParse(key.split('_')[1]) ?? -1;

      if (idx >= 0 && idx < row.ngayData.length) {
        final dailyData = row.ngayData[idx];

        final heso =
            (dailyData['Heso'] as num?)?.toDouble() ?? 0;

        final hesoString =
            dailyData['HesoString']?.toString() ?? '';

        Color? backgroundColor;

        if (hesoString == 'Note') {
          backgroundColor = const Color(0xFFFFEB3B);
        } else if (hesoString == 'Risk') {
          backgroundColor = const Color(0xFFFF9800);
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 3,
          ),
          decoration: backgroundColor != null
              ? BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(3),
                )
              : null,
          child: Text(
            _fmt(heso, decimals: 2),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    }

    return const Text('--');
  }
}