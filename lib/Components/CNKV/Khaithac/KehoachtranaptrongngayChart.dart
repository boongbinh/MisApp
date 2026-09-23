import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class KehoachtranaptrongngayChart extends StatelessWidget {
  final Map<String, dynamic> data;
  final double height;
  final String title;

  const KehoachtranaptrongngayChart({
    super.key,
    required this.data,
    this.height = 300,
    this.title = 'KẾ HOẠCH TRA NẠP TRONG NGÀY',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || !data.containsKey('categories') || !data.containsKey('series')) {
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

    final categories = (data['categories'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final seriesList = data['series'] as List? ?? [];

    if (categories.isEmpty || seriesList.isEmpty) {
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

    // Tạo dữ liệu cho biểu đồ
    final List<ChartData> chartData = [];
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      for (var series in seriesList) {
        final name = series['name']?.toString() ?? 'Khác';
        final dataList = series['data'] as List? ?? [];
        // ⭐ Sửa: ép kiểu an toàn sang double
        final value = i < dataList.length 
            ? _toDouble(dataList[i]) 
            : 0.0;
        chartData.add(ChartData(
          category: category,
          seriesName: name,
          value: value,
        ));
      }
    }

    // Lấy danh sách các series name
    final seriesNames = seriesList.map((e) => e['name']?.toString() ?? 'Khác').toList();

    // Bảng màu cho các series
    final colorPalette = [
      Colors.blue.shade700,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.pink.shade600,
      Colors.amber.shade600,
      Colors.indigo.shade600,
      Colors.cyan.shade700,
    ];

    // Tính max Y
    double maxY = 0;
    for (var item in chartData) {
      if (item.value > maxY) maxY = item.value;
    }
    maxY = ((maxY / 50).ceil() * 50).toDouble() + 20;

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
                  text: 'Chuyến',
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                interval: _getInterval(maxY),
                maximum: maxY,
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
                format: 'point.x\npoint.seriesName: point.y chuyến',
                color: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 1,
                textStyle: const TextStyle(color: Color(0xFF1F2A37)),
              ),
              series: _buildSeries(chartData, seriesNames, colorPalette),
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
    );
  }

  List<ColumnSeries<ChartData, String>> _buildSeries(
    List<ChartData> data,
    List<String> seriesNames,
    List<Color> colorPalette,
  ) {
    return seriesNames.asMap().entries.map((entry) {
      final index = entry.key;
      final seriesName = entry.value;
      return ColumnSeries<ChartData, String>(
        dataSource: data.where((d) => d.seriesName == seriesName).toList(),
        xValueMapper: (ChartData d, _) => d.category,
        yValueMapper: (ChartData d, _) => d.value,
        name: seriesName,
        color: colorPalette[index % colorPalette.length],
        width: 0.8,
        spacing: 0.1,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          textStyle: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2A37),
          ),
        ),
        enableTooltip: true,
      );
    }).toList();
  }

  // ⭐ Hàm ép kiểu an toàn sang double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  double _getInterval(double max) {
    if (max <= 50) return 10;
    if (max <= 100) return 20;
    if (max <= 200) return 50;
    if (max <= 500) return 100;
    return 200;
  }
}

class ChartData {
  final String category;
  final String seriesName;
  final double value;

  ChartData({
    required this.category,
    required this.seriesName,
    required this.value,
  });
}