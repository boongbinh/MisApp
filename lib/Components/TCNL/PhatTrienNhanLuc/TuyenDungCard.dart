import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class TuyenDungData {
  final int month;
  final int male;
  final int female;
  TuyenDungData({required this.month, required this.male, required this.female});
}

class TuyenDungCard extends StatelessWidget {
  final List<TuyenDungData> dataList;
  final double height;

  const TuyenDungCard({
    super.key,
    required this.dataList,
    this.height = 280,
  });

  factory TuyenDungCard.withDefaultData() {
    return TuyenDungCard(
      dataList: [
        TuyenDungData(month: 1, male: 3, female: 2),
        TuyenDungData(month: 2, male: 4, female: 1),
        TuyenDungData(month: 3, male: 2, female: 3),
        TuyenDungData(month: 4, male: 5, female: 2),
      ],
    );
  }

  int get totalHiring => dataList.fold(0, (sum, item) => sum + item.male + item.female);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TUYỂN DỤNG (Tổng: $totalHiring)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Tháng'),
                  labelPlacement: LabelPlacement.onTicks,
                  labelIntersectAction: AxisLabelIntersectAction.rotate45,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Số lượng'),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 1,                     // ✅ Bước nhảy là 1
                  numberFormat: NumberFormat.decimalPattern(), // ✅ Không thập phân
                ),
                tooltipBehavior: TooltipBehavior(enable: true, header: ''),
                series: <StackedBarSeries<TuyenDungData, String>>[
                  StackedBarSeries<TuyenDungData, String>(
                    dataSource: dataList,
                    xValueMapper: (TuyenDungData data, _) => 'Tháng ${data.month}',
                    yValueMapper: (TuyenDungData data, _) => data.male,
                    name: 'Nam',
                    color: Colors.blue,
                    width: 0.6,              // ✅ Độ rộng cột cố định
                  ),
                  StackedBarSeries<TuyenDungData, String>(
                    dataSource: dataList,
                    xValueMapper: (TuyenDungData data, _) => 'Tháng ${data.month}',
                    yValueMapper: (TuyenDungData data, _) => data.female,
                    name: 'Nữ',
                    color: Colors.amber,
                    width: 0.6,              // ✅ Cùng trackWidth
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
}