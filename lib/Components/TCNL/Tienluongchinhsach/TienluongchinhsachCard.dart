import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ====== DATA MODEL ======
class TienLuongSummaryData {
  final String title;
  final double value;
  final double planValue;
  final double previousYearValue;
  final double percentVsPlan;
  final double percentVsPreviousYear;
  final String? unit;
  final Color? valueColor;

  TienLuongSummaryData({
    required this.title,
    required this.value,
    required this.planValue,
    required this.previousYearValue,
    required this.percentVsPlan,
    required this.percentVsPreviousYear,
    this.unit,
    this.valueColor,
  });
}

// ====== CARD TIỀN LƯƠNG BÌNH QUÂN / QUỸ TIỀN LƯƠNG ======
class TienLuongBinQuanCard extends StatelessWidget {
  final String title;
  final double value;
  final double planValue;
  final double previousYearValue;
  final double percentVsPlan;
  final double percentVsPreviousYear;
  final Color color;
  final IconData icon;

  const TienLuongBinQuanCard({
    super.key,
    required this.title,
    required this.value,
    required this.planValue,
    required this.previousYearValue,
    required this.percentVsPlan,
    required this.percentVsPreviousYear,
    required this.color,
    required this.icon,
  });

  String _formatValue(double val) {
  if (val >= 1e6) {
    // Nếu >= 1,000,000 -> chia cho 1,000,000, hiển thị Triệu
    return NumberFormat('#,###.###', 'vi_VN').format(val / 1e6) + ' Triệu VND';
  } else if (val >= 1e3) {
    // Nếu >= 1,000 -> chia cho 1,000, hiển thị Triệu
    return NumberFormat('#,###.###', 'vi_VN').format(val / 1e3) + ' Triệu VND';
  } else {
    // Nếu < 1,000 -> giữ nguyên, hiển thị Triệu
    return NumberFormat('#,###.###', 'vi_VN').format(val) + ' Triệu VND';
  }
}

  String _formatPercent(double val) => val.toStringAsFixed(2) + '%';
  

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color, // ⭐ Nền là màu chính
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title + Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28), // ⭐ Icon màu của color
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white, // ⭐ Chữ trắng
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatValue(value),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white, // ⭐ Chữ trắng
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid: Kế hoạch + Năm trước
          Row(
            children: [
              _infoCard(
                label: 'Kế hoạch',
                value: _formatValue(planValue),
                color: Colors.white.withOpacity(0.2),
                textColor: Colors.white,
                fontSize: 22,

              ),
              const SizedBox(width: 12),
              _infoCard(
                label: 'Năm trước',
                value: _formatValue(previousYearValue),
                color: Colors.white.withOpacity(0.2),
                textColor: Colors.white,
                fontSize: 22,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // % so với kế hoạch
          _percentRow(
            label: '% so với kế hoạch',
            value: _formatPercent(percentVsPlan),
            progress: percentVsPlan / 100,
            color: Colors.white,
            bgColor: Colors.white.withOpacity(0.2),
            
          ),
          const SizedBox(height: 8),

          // % so với năm trước
          _percentRow(
            label: '% so với năm trước',
            value: _formatPercent(percentVsPreviousYear),
            progress: percentVsPreviousYear / 100,
            color: Colors.white,
            bgColor: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 12),

          // Growth badges - màu trắng
          
        ],
      ),
    );
  }

  Widget _infoCard({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    required double fontSize,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _percentRow({
    required String label,
    required String value,
    required double progress,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: color.withOpacity(0.2),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthBadge({
    required IconData icon,
    required String text,
    required String subtitle,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}