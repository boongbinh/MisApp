import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class ChamdutHdData {
  final int month;
  final int nghihuu;
  final int nghiviec;
  ChamdutHdData({required this.month, required this.nghihuu, required this.nghiviec});
}

class ChamdutHdCard extends StatelessWidget {
  final List<ChamdutHdData> dataList;
  final double height;

  const ChamdutHdCard({
    super.key,
    required this.dataList,
    this.height = 280,
  });

  factory ChamdutHdCard.withDefaultData() {
    return ChamdutHdCard(
      dataList: [
        ChamdutHdData(month: 1, nghihuu: 3, nghiviec: 2),
        ChamdutHdData(month: 2, nghihuu: 4, nghiviec: 1),
        ChamdutHdData(month: 3, nghihuu: 2, nghiviec: 3),
        ChamdutHdData(month: 4, nghihuu: 5, nghiviec: 2),
      ],
    );
  }

  int get total => dataList.fold(0, (sum, item) => sum + item.nghihuu + item.nghiviec);

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
              'CHẤM DỨT HĐLĐ (Tổng: $total)',
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
                  interval: 1,
                  numberFormat: NumberFormat.decimalPattern(),
                ),
                tooltipBehavior: TooltipBehavior(enable: true, header: ''),
                series: <StackedBarSeries<ChamdutHdData, String>>[
                  StackedBarSeries<ChamdutHdData, String>(
                    dataSource: dataList,
                    xValueMapper: (ChamdutHdData data, _) => 'Tháng ${data.month}',
                    yValueMapper: (ChamdutHdData data, _) => data.nghihuu,
                    name: 'Nghỉ hưu',
                    color: Colors.blue,
                    width: 0.6, // ✅ Độ rộng cột cố định
                  ),
                  StackedBarSeries<ChamdutHdData, String>(
                    dataSource: dataList,
                    xValueMapper: (ChamdutHdData data, _) => 'Tháng ${data.month}',
                    yValueMapper: (ChamdutHdData data, _) => data.nghiviec,
                    name: 'Nghỉ việc',
                    color: Colors.amber,
                    width: 0.6, // ✅ Cùng width
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