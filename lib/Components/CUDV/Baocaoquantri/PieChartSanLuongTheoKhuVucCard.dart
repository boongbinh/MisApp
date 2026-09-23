// components/CUDV/PieChartSanLuongTheoKhuVucCard.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SanLuongTheoKVData {
  final String kv;
  final double giaTri;

  SanLuongTheoKVData({required this.kv, required this.giaTri});
}

class PieChartSanLuongTheoKhuVucCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final double height;

  const PieChartSanLuongTheoKhuVucCard({
    super.key,
    required this.data,
    this.title = 'SẢN LƯỢNG THEO KHU VỰC',
    this.height = 350,
  });

  // ⭐ Bảng màu cho các khu vực
  static const List<Color> _colorPalette = [
    Color(0xFF1F77B4), // MB - Xanh dương
    Color(0xFFFF7F0E), // MT - Cam
    Color(0xFF2CA02C), // CR - Xanh lá
    Color(0xFFD62728), // MN - Đỏ
    Color(0xFF9467BD), // Khác - Tím
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmpty();

    // Map dữ liệu
    final chartData = data.map((item) {
      return SanLuongTheoKVData(
        kv: item['KV']?.toString() ?? 'Khác',
        giaTri: (item['KeHoach_KG'] as num?)?.toDouble() ?? 0,
      );
    }).where((e) => e.giaTri > 0).toList();

    if (chartData.isEmpty) return _buildEmpty();

    // Tính tổng
    final total = chartData.fold(0.0, (sum, item) => sum + item.giaTri);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Total
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1F2A37),
                  ),
                ),
              ),
              Text(
                'Tổng: ${NumberFormat('#,##0', 'vi_VN').format(total)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F7BD8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chart
          SizedBox(
            height: height,
            child: SfCircularChart(
              margin: const EdgeInsets.all(0),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.right,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                format: 'point.x\npoint.y',
                color: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 1,
                textStyle: const TextStyle(color: Color(0xFF1F2A37)),
              ),
              series: <CircularSeries<SanLuongTheoKVData, String>>[
                DoughnutSeries<SanLuongTheoKVData, String>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.kv,
                  yValueMapper: (d, _) => d.giaTri,
                  pointColorMapper: (d, index) =>
                      _colorPalette[index % _colorPalette.length],
                  radius: '70%',
                  innerRadius: '50%',
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2A37),
                    ),
                    labelIntersectAction: LabelIntersectAction.hide,
                    builder: (data, point, series, pointIndex, seriesIndex) {
                      final d = data as SanLuongTheoKVData;
                      final percent = total > 0
                          ? (d.giaTri / total) * 100
                          : 0.0;
                      return Text(
                        '${d.kv}: ${percent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  enableTooltip: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Legend chi tiết (list)
          ...chartData.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final percent =
                total > 0 ? (item.giaTri / total) * 100 : 0.0;
            final color = _colorPalette[idx % _colorPalette.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.kv,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2A37),
                      ),
                    ),
                  ),
                  Text(
                    NumberFormat('#,##0', 'vi_VN').format(item.giaTri),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2A37),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 200,
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