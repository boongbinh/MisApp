import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class TyletonkhosanbayChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double height;
  final String title;

  const TyletonkhosanbayChart({
    super.key,
    required this.data,
    this.height = 300,
    this.title = 'TỶ LỆ TỒN KHO SÂN BAY',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text(
            'Không có dữ liệu',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Chuyển đổi dữ liệu
    final chartData = data.map((item) {
      return ChartData(
        name: item['name']?.toString() ?? 'Khác',
        value: (item['value'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    // Sắp xếp theo giá trị giảm dần
    final sortedData = List<ChartData>.from(chartData)
      ..sort((a, b) => b.value.compareTo(a.value));

    // Tìm max value để set trục Y
    final maxValue = sortedData.isNotEmpty ? sortedData.first.value : 0;
    final maxY = ((maxValue / 10).ceil() * 10).toDouble() + 10;

    // Màu sắc dựa trên giá trị
    Color getColor(double value) {
      if (value >= 80) return Colors.red.shade700; // Cao - nguy hiểm
      if (value >= 60) return Colors.orange.shade700; // Trung bình
      if (value >= 40) return Colors.amber.shade600; // Thấp
      return Colors.green.shade600; // Rất thấp - an toàn
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                interval: _getInterval(maxY),
                maximum: maxY,
                minimum: 0,
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
                format: 'point.x: point.y%',
                color: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 1,
                textStyle: const TextStyle(color: Color(0xFF1F2A37)),
              ),
              series: <ColumnSeries<ChartData, String>>[
                ColumnSeries<ChartData, String>(
                  dataSource: sortedData,
                  xValueMapper: (ChartData d, _) => d.name,
                  yValueMapper: (ChartData d, _) => d.value,
                  name: 'Tỷ lệ tồn kho',
                  width: 0.5,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  // ⭐ Màu sắc theo giá trị
                  pointColorMapper: (ChartData d, _) => getColor(d.value),
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
                ),
              ],
              legend: const Legend(
                isVisible: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getInterval(double max) {
    if (max <= 20) return 5;
    if (max <= 50) return 10;
    if (max <= 100) return 20;
    if (max <= 200) return 50;
    return 100;
  }
}

class ChartData {
  final String name;
  final double value;

  ChartData({
    required this.name,
    required this.value,
  });
}