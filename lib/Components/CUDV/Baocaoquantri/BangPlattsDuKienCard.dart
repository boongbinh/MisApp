// components/CUDV/BangPlattsDuKienCard.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BangPlattsDuKienCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const BangPlattsDuKienCard({
    super.key,
    required this.data,
    this.title = 'BẢNG PLATTS DỰ KIẾN',
  });

  static const List<_Col> _cols = [
    _Col('stt', 'STT', 1.0),
    _Col('test', 'PLATTS DỰ KIẾN', 3.0),
    _Col('bq', 'PLATTS BQ', 3.0),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmpty();

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF1F2A37),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final totalFlex =
                  _cols.fold(0.0, (sum, c) => sum + c.flex);
              final availWidth = constraints.maxWidth;

              return Column(
                children: [
                  // Header
                  Container(
                    color: const Color(0xFF4D73B2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: _cols.map((c) {
                        return SizedBox(
                          width: availWidth * (c.flex / totalFlex),
                          child: Text(
                            c.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Rows
                  ...data.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final isEven = idx % 2 == 0;

                    final test =
                        (item['Platt_TEST'] as num?)?.toDouble() ?? 0;
                    final bq = (item['Platt_BQ'] as num?)?.toDouble() ?? 0;

                    return Container(
                      color: isEven
                          ? Colors.white
                          : const Color(0xFFF8F9FA),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          _cell(availWidth, _cols[0], '${idx + 1}'),
                          _cell(availWidth, _cols[1], _fmt(test)),
                          _cell(availWidth, _cols[2], _fmt(bq), bold: true),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _cell(
    double availWidth,
    _Col col,
    String text, {
    bool bold = false,
  }) {
    final totalFlex = _cols.fold(0.0, (sum, c) => sum + c.flex);
    return SizedBox(
      width: availWidth * (col.flex / totalFlex),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF1F2A37),
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _fmt(num v) {
    if (v == 0) return '--';
    return NumberFormat('#,##0.00', 'vi_VN').format(v);
  }

  Widget _buildEmpty() {
    return Container(
      height: 160,
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
      child: const Center(
        child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

class _Col {
  final String key;
  final String title;
  final double flex;
  const _Col(this.key, this.title, this.flex);
}