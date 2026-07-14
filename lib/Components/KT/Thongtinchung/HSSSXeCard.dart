import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class HSSSXeData {
  final String chinhanh;
  final double avgHS;
  final int thang;
  final int nam;
  final String loai;

  HSSSXeData({
    required this.chinhanh,
    required this.avgHS,
    required this.thang,
    required this.nam,
    required this.loai,
  });
}

class HSSSXeCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final double height;
  final String loaiXe;

  const HSSSXeCard({
    super.key,
    required this.data,
    required this.loaiXe,
    this.title = 'HSSS XE',
    this.height = 350,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Không có dữ liệu',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredData = data.where((item) => item['loai'] == loaiXe).toList();
    if (filteredData.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title $loaiXe',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Không có dữ liệu cho loại xe này',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final chartData = filteredData.map((item) {
      return HSSSXeData(
        chinhanh: item['Chinhanh']?.toString() ?? 'Khác',
        avgHS: (item['AVGHS'] as num?)?.toDouble() ?? 0,
        thang: (item['thang'] as num?)?.toInt() ?? 0,
        nam: (item['nam'] as num?)?.toInt() ?? 0,
        loai: item['loai']?.toString() ?? '',
      );
    }).toList();

    final months = chartData.map((d) => d.thang).toSet().toList()..sort();
    final chinhanhList = chartData.map((d) => d.chinhanh).toSet().toList()..sort();

    final colorPalette = [
      Colors.blue.shade700,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.pink.shade600,
      Colors.amber.shade600,
    ];

    // 1. Lấy tất cả giá trị AVGHS
    final allValues = chartData.map((d) => d.avgHS).toList();
    // 2. Tìm min và max
    final minValue = allValues.isNotEmpty ? allValues.reduce((a, b) => a < b ? a : b) : 0;
    final maxValue = allValues.isNotEmpty ? allValues.reduce((a, b) => a > b ? a : b) : 0;

    // Thêm padding 5% cho min và max để biểu đồ không bị sát mép
    final padding = (maxValue - minValue) * 0.1; // 10% padding
    final yMin = (minValue - padding).floorToDouble();
    final yMax = (maxValue + padding).ceilToDouble();

    // 4. Tính interval tự động dựa trên range
    final range = yMax - yMin;
    double interval = 2;
    if (range <= 10) {
      interval = 1;
    } else if (range <= 20) {
      interval = 2;
    } else if (range <= 50) {
      interval = 5;
    } else {
      interval = 10;
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Giảm padding
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$title $loaiXe',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2A37),
                  ),
                ),
              ],
            ),
            // ⭐ Giảm SizedBox
            const SizedBox(height: 8),
            // ⭐ Sử dụng Expanded để chiếm hết không gian còn lại
            Expanded(
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                // ⭐ Giảm margin
                margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                primaryXAxis: CategoryAxis(
                  labelPlacement: LabelPlacement.onTicks,
                  labelIntersectAction: AxisLabelIntersectAction.rotate45,
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                  rangePadding: ChartRangePadding.additional,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                    text: '%',
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  minimum: yMin,
                  maximum: yMax,
                  interval: interval,
                  numberFormat: NumberFormat.decimalPattern(),
                  majorGridLines: MajorGridLines(
                    width: 0.5,
                    color: Colors.grey.shade200,
                    dashArray: const [4, 4],
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: '',
                  format: 'point.x : point.y%',
                  color: Colors.white,
                  borderColor: Colors.grey.shade300,
                  borderWidth: 1,
                  textStyle: const TextStyle(color: Color(0xFF1F2A37)),
                ),
                series: _buildSeries(chartData, chinhanhList, colorPalette),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SplineSeries<HSSSXeData, String>> _buildSeries(
    List<HSSSXeData> data,
    List<String> chinhanhList,
    List<Color> colorPalette,
  ) {
    return chinhanhList.asMap().entries.map((entry) {
      final index = entry.key;
      final cn = entry.value;

      final seriesData = data
          .where((d) => d.chinhanh == cn)
          .toList()
        ..sort((a, b) => a.thang.compareTo(b.thang));

      return SplineSeries<HSSSXeData, String>(
        dataSource: seriesData,
        xValueMapper: (HSSSXeData d, _) => 'Tháng ${d.thang}',
        yValueMapper: (HSSSXeData d, _) => d.avgHS,
        name: 'CN $cn',
        color: colorPalette[index % colorPalette.length],
        splineType: SplineType.cardinal,
        cardinalSplineTension: 0.5,
        width: 2.5,
        markerSettings: const MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle,
          borderWidth: 2,
          borderColor: Colors.white,
        ),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2A37),
          ),
        ),
        enableTooltip: true,
      );
    }).toList();
  }
}