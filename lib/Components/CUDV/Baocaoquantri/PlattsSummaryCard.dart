// components/CUDV/PlattsSummaryCard.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlattsSummaryCard extends StatelessWidget {
  final double? plattsThangTruoc;
  final double? plattsHienTai;
  final double? diff;
  final double? diffPercent;

  const PlattsSummaryCard({
    super.key,
    this.plattsThangTruoc,
    this.plattsHienTai,
    this.diff,
    this.diffPercent,
  });

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildItem(
              'Platts tháng trước',
              plattsThangTruoc,
              const Color(0xFF6B7280),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE6ECF5),
          ),
          Expanded(
            child: _buildItem(
              'Platts hiện tại',
              plattsHienTai,
              const Color(0xFF1F7BD8),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE6ECF5),
          ),
          Expanded(
            child: _buildDiffItem(diff, diffPercent),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String label, double? value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value != null
              ? '\$${NumberFormat('#,##0.00', 'vi_VN').format(value)}'
              : '--',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDiffItem(double? diff, double? diffPercent) {
    final isUp = (diff ?? 0) >= 0;
    final color = isUp ? Colors.green : Colors.red;
    final icon = isUp ? Icons.trending_up : Icons.trending_down;

    return Column(
      children: [
        const Text(
          'Chênh lệch',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 2),
            Text(
              diff != null
                  ? '\$${NumberFormat('#,##0.00', 'vi_VN').format(diff.abs())}'
                  : '--',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        if (diffPercent != null)
          Text(
            '(${diffPercent >= 0 ? '+' : ''}${diffPercent.toStringAsFixed(2)}%)',
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
      ],
    );
  }
}