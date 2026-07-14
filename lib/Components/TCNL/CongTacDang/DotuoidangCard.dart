import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class DotuoidangData {
  final String nhomTuoi;
  final int nam;
  final int nu;
  DotuoidangData({required this.nhomTuoi, required this.nam, required this.nu});
}

class DotuoidangCard extends StatelessWidget {
  final List<DotuoidangData> dataList;
  final double height;
  final String title;

  const DotuoidangCard({
    super.key,
    required this.dataList,
    this.height = 450,
    this.title = 'ĐỘ TUỔI ĐẢNG',
  });

  int get total => dataList.fold(0, (sum, item) => sum + item.nam + item.nu);

  @override
  Widget build(BuildContext context) {
    if (dataList.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title (Tổng: 0)',
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

    final sortedData = List<DotuoidangData>.from(dataList)
      ..sort((a, b) => _getSortOrder(a.nhomTuoi).compareTo(_getSortOrder(b.nhomTuoi)));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (Tổng: $total)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: SfCartesianChart(
                // ⭐ Cách viền chart
                plotAreaBorderWidth: 0,
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Nhóm tuổi đảng'),
                  labelPlacement: LabelPlacement.onTicks,
                  labelRotation: -30,
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  // ⭐ Khoảng cách 2 đầu trục X
                  rangePadding: ChartRangePadding.additional,
                  // ⭐ Khoảng cách giữa các nhóm
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Số lượng'),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 1,
                  numberFormat: NumberFormat.decimalPattern(),
                  majorGridLines: MajorGridLines(
                    width: 0.5,
                    color: Colors.grey.shade200,
                    dashArray: const [4, 4],
                  ),
                  axisLine: const AxisLine(width: 0),
                  rangePadding: ChartRangePadding.additional,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: '',
                  format: 'point.x\nNam: point.y\nNữ: point.y',
                ),
                series: <StackedColumnSeries<DotuoidangData, String>>[
                  StackedColumnSeries<DotuoidangData, String>(
                    dataSource: sortedData,
                    xValueMapper: (DotuoidangData data, _) => _getShortLabel(data.nhomTuoi),
                    yValueMapper: (DotuoidangData data, _) => data.nam,
                    name: 'Nam',
                    color: Colors.blue.shade600,
                    width: 0.4,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  StackedColumnSeries<DotuoidangData, String>(
                    dataSource: sortedData,
                    xValueMapper: (DotuoidangData data, _) => _getShortLabel(data.nhomTuoi),
                    yValueMapper: (DotuoidangData data, _) => data.nu,
                    name: 'Nữ',
                    color: Colors.amber.shade600,
                    width: 0.4,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getShortLabel(String nhomTuoi) {
    final parts = nhomTuoi.split('.');
    if (parts.length == 2) {
      return parts[1].trim();
    }
    return nhomTuoi;
  }

  int _getSortOrder(String nhomTuoi) {
    if (nhomTuoi.contains('0 đến 5')) return 1;
    if (nhomTuoi.contains('5 đến 10')) return 2;
    if (nhomTuoi.contains('10 đến 15')) return 3;
    if (nhomTuoi.contains('15 đến 20')) return 4;
    if (nhomTuoi.contains('20 đến 25')) return 5;
    if (nhomTuoi.contains('25 đến 30')) return 6;
    if (nhomTuoi.contains('30')) return 7;
    return 99;
  }
}