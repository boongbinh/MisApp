import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChitietDoanhthuGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String donViTien; // 'VND' hoặc 'USD'

  const ChitietDoanhthuGrid({super.key, required this.items, required this.donViTien});

  String _formatNumber(double v) {
  if (v >= 1e9) {
    final valueInBillions = v / 1e9;
    final formatter = NumberFormat('#,##0.00', 'vi_VN');
    return '${formatter.format(valueInBillions)} tỷ';
  } else if (v >= 1e6) {
    final valueInMillions = v / 1e6;
    final formatter = NumberFormat('#,##0.00', 'vi_VN');
    return '${formatter.format(valueInMillions)} triệu';
  } else {
    final formatter = NumberFormat('#,##0.00', 'vi_VN');
    return formatter.format(v);
  }
}

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 200,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isBlue = (index == 0 || index == 1 || index == 4 || index == 5);
        final bgColor = isBlue ? const Color(0xFF003366) : const Color(0xFFFDC003);
        final textColor = isBlue ? Colors.white : const Color(0xFF001E40);
        final iconColor = isBlue ? const Color(0xFFFDC003) : const Color(0xFF001E40);
        
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item['icon'], color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['title'],
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                      // overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _infoRow('HKNN', item['hknn'], textColor),
              const SizedBox(height: 2),
              _infoRow('HKTN', item['hktn'], textColor),
              const SizedBox(height: 2),
              Divider(color: textColor.withOpacity(0.3), thickness: 0.5),
              const SizedBox(height: 2),
              _totalRow(item['total'], textColor),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, double value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8))),
        Text(_formatNumber(value), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
      ],
    );
  }

  Widget _totalRow(double value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Tổng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        Text(_formatNumber(value), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }
}