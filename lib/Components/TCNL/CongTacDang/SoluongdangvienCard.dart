import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SoluongdangvienData {
  final String thang;
  final int duBi;
  final int chinhThuc;
  SoluongdangvienData({required this.thang, required this.duBi, required this.chinhThuc});
}

class SoluongdangvienCard extends StatelessWidget {
  final List<SoluongdangvienData> dataList;
  final double height;
  final String title;

  const SoluongdangvienCard({
    super.key,
    required this.dataList,
    this.height = 350,
    this.title = 'SỐ LƯỢNG ĐẢNG VIÊN',
  });


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

    final sortedData = List<SoluongdangvienData>.from(dataList)
      ..sort((a, b) => int.parse(a.thang).compareTo(int.parse(b.thang)));

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
            SizedBox(
              height: height,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Tháng'),
                  labelPlacement: LabelPlacement.onTicks,
                  labelRotation: 0,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  rangePadding: ChartRangePadding.additional,
                  //spacing: 0.4,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Số lượng'),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 50,
                  maximum: _getMaxY(sortedData),
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
                  format: 'Tháng point.x\nDự bị: point.y\nChính thức: point.y',
                ),
                series: <StackedColumnSeries<SoluongdangvienData, String>>[
                  // Chính thức (nằm dưới)
                  StackedColumnSeries<SoluongdangvienData, String>(
                    dataSource: sortedData,
                    xValueMapper: (SoluongdangvienData data, _) => 'Tháng ${data.thang}',
                    yValueMapper: (SoluongdangvienData data, _) => data.chinhThuc,
                    name: 'Chính thức',
                    color: Colors.blue.shade700,
                    width: 0.4,
                    // ⭐ HIỂN THỊ SỐ CHO CHÍNH THỨC
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  // Dự bị (nằm trên - chồng lên Chính thức)
                  StackedColumnSeries<SoluongdangvienData, String>(
                    dataSource: sortedData,
                    xValueMapper: (SoluongdangvienData data, _) => 'Tháng ${data.thang}',
                    yValueMapper: (SoluongdangvienData data, _) => data.duBi,
                    name: 'Dự bị',
                    color: Colors.amber.shade300,
                    width: 0.4,
                    // ⭐ HIỂN THỊ SỐ CHO DỰ BỊ
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
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

  double _getMaxY(List<SoluongdangvienData> data) {
    int max = 0;
    for (var item in data) {
      final total = item.duBi + item.chinhThuc;
      if (total > max) max = total;
    }
    return ((max / 50).ceil() * 50).toDouble() + 20;
  }
}