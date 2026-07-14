import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class ChartTonkhoData {
  final String donvi;
  final double hangCTY;
  final double hangCN;
  final double dmn;
  final double tonkho;

  ChartTonkhoData({
    required this.donvi,
    required this.hangCTY,
    required this.hangCN,
    required this.dmn,
    required this.tonkho,
  });

  double get total => hangCTY + hangCN + dmn + tonkho;
}

class ChartTonkhoCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final double height;

  const ChartTonkhoCard({
    super.key,
    required this.data,
    this.title = 'CHART TỒN KHO',
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
                title,
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

    // Chuyển đổi dữ liệu
    final chartData = data.map((item) {
      return ChartTonkhoData(
        donvi: item['Donvi']?.toString() ?? 'Khác',
        hangCTY: (item['HANG_CTY'] as num?)?.toDouble() ?? 0,
        hangCN: (item['HANG_CN'] as num?)?.toDouble() ?? 0,
        dmn: (item['DMN'] as num?)?.toDouble() ?? 0,
        tonkho: (item['Tonkho'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    // Sắp xếp theo tổng giảm dần
    final sortedData = List<ChartTonkhoData>.from(chartData)
      ..sort((a, b) => b.total.compareTo(a.total));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (Tổng: ${_formatTotal(sortedData)})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                primaryXAxis: CategoryAxis(
                  labelPlacement: LabelPlacement.onTicks,
                  labelIntersectAction: AxisLabelIntersectAction.rotate45,
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                  rangePadding: ChartRangePadding.additional,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                    text: 'Giá trị',
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 2,
                  maximum: _getMaxY(sortedData),
                  numberFormat: NumberFormat.decimalPattern(),
                  majorGridLines: MajorGridLines(
                    width: 0.5,
                    color: Colors.grey.shade200,
                    dashArray: const [4, 4],
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: '',
                  format: 'point.x\npoint.seriesName: point.y',
                  color: Colors.white,
                  borderColor: Colors.grey.shade300,
                  borderWidth: 1,
                  textStyle: const TextStyle(color: Color(0xFF1F2A37)),
                ),
                series: <StackedColumnSeries<ChartTonkhoData, String>>[
                  // ⭐ HANG_CTY (nằm dưới cùng)
                  StackedColumnSeries<ChartTonkhoData, String>(
                    dataSource: sortedData,
                    xValueMapper: (ChartTonkhoData d, _) => d.donvi,
                    yValueMapper: (ChartTonkhoData d, _) => d.hangCTY,
                    name: 'HÀNG CTY',
                    color: Colors.blue.shade700,
                    width: 0.5,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    enableTooltip: true,
                  ),
                  // ⭐ HANG_CN (nằm giữa)
                  StackedColumnSeries<ChartTonkhoData, String>(
                    dataSource: sortedData,
                    xValueMapper: (ChartTonkhoData d, _) => d.donvi,
                    yValueMapper: (ChartTonkhoData d, _) => d.hangCN,
                    name: 'HÀNG CN',
                    color: Colors.green.shade600,
                    width: 0.5,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    enableTooltip: true,
                  ),
                  // ⭐ DMN (nằm trên cùng)
                  StackedColumnSeries<ChartTonkhoData, String>(
                    dataSource: sortedData,
                    xValueMapper: (ChartTonkhoData d, _) => d.donvi,
                    yValueMapper: (ChartTonkhoData d, _) => d.dmn,
                    name: 'DMN',
                    color: Colors.orange.shade600,
                    width: 0.5,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    enableTooltip: true,
                  ),
                ],
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: const TextStyle(
                    fontSize: 12,
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

  String _formatTotal(List<ChartTonkhoData> data) {
    final total = data.fold(0.0, (sum, item) => sum + item.total);
    return NumberFormat('#,###.##', 'vi_VN').format(total);
  }

  double _getMaxY(List<ChartTonkhoData> data) {
    double max = 0;
    for (var item in data) {
      if (item.total > max) max = item.total;
    }
    return ((max / 2).ceil() * 2).toDouble() + 2;
  }
}