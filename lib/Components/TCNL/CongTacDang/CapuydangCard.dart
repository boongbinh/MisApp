import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class CapuydangData {
  final String tenCapUy;
  final int soLuong;
  CapuydangData({required this.tenCapUy, required this.soLuong});
}

class CapuydangCard extends StatelessWidget {
  final List<CapuydangData> dataList;
  final double height;
  final String title;

  const CapuydangCard({
    super.key,
    required this.dataList,
    this.height = 320,
    this.title = 'CẤP ỦY ĐẢNG',
  });

  int get total => dataList.fold(0, (sum, item) => sum + item.soLuong);

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

    // Sắp xếp theo số lượng giảm dần
    final sortedData = List<CapuydangData>.from(dataList)
      ..sort((a, b) => b.soLuong.compareTo(a.soLuong));

    final List<Color> colorPalette = [
      Colors.blue.shade700,
      Colors.blue.shade600,
      Colors.blue.shade500,
      Colors.blue.shade400,
      Colors.blue.shade300,
    ];

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
                plotAreaBorderWidth: 0,
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                
                primaryXAxis: CategoryAxis(
                  labelPlacement: LabelPlacement.onTicks,
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  rangePadding: ChartRangePadding.additional,
                  //spacing: 0.6,
                ),
                primaryYAxis: NumericAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 10,
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
                  format: 'point.x: point.y',
                ),
                series: <ColumnSeries<CapuydangData, String>>[
                  ColumnSeries<CapuydangData, String>(
                    dataSource: sortedData,
                    xValueMapper: (CapuydangData data, _) => _getShortLabel(data.tenCapUy),
                    yValueMapper: (CapuydangData data, _) => data.soLuong,
                    name: 'Số lượng',
                    width: 0.4, // ⭐ Width 0.4
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    pointColorMapper: (CapuydangData data, _) {
                      final index = sortedData.indexOf(data);
                      return colorPalette[index % colorPalette.length];
                    },
                  ),
                ],
                legend: const Legend(isVisible: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<CapuydangData> data) {
    int max = 0;
    for (var item in data) {
      if (item.soLuong > max) max = item.soLuong;
    }
    return ((max / 10).ceil() * 10).toDouble() + 10;
  }

  // Rút gọn tên cho gọn
  String _getShortLabel(String text) {
    // Ánh xạ tên ngắn cho từng loại cấp ủy
    final Map<String, String> shortNameMap = {
      'Ban TVDU': 'Ban TVDU',
      'Ủy viên BCH DU Công ty': 'UV BCH DU CT',
      'Cấp ủy Chi bộ Công ty': 'Cấp ủy CB CT',
      'Ủy viên BCH DU Chi nhánh': 'UV BCH DU CN',
      'Cấp ủy Chi bộ chi nhánh': 'Cấp ủy CB CN',
    };
    
    return shortNameMap[text] ?? text;
  }
}