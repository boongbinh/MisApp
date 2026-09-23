import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SanluongtuansanbayChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double height;
  final String title;

  const SanluongtuansanbayChart({
    super.key,
    required this.data,
    this.height = 300,
    this.title = 'SẢN LƯỢNG TUẦN SÂN BAY',
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
        child: Center(
          child: Text(
            'Không có dữ liệu',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    // Nhóm dữ liệu theo sân bay
    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in data) {
      final warehouseID = item['warehouseID']?.toString() ?? 'Khác';
      if (!groupedData.containsKey(warehouseID)) {
        groupedData[warehouseID] = [];
      }
      groupedData[warehouseID]!.add(item);
    }

    // Lấy danh sách các ngày (sắp xếp tăng dần)
    final allDates = data.map((e) {
      final date = DateTime.tryParse(e['VoucherDate']?.toString() ?? '');
      return date;
    }).whereType<DateTime>().toSet().toList()..sort();

    // Tạo dữ liệu cho biểu đồ
    final List<ChartData> chartData = [];
    for (var date in allDates) {
      final dateStr = DateFormat('dd/MM').format(date);
      for (var entry in groupedData.entries) {
        final warehouseID = entry.key;
        final items = entry.value;
        final item = items.firstWhere(
          (e) {
            final eDate = DateTime.tryParse(e['VoucherDate']?.toString() ?? '');
            return eDate != null && eDate.isAtSameMomentAs(date);
          },
          orElse: () => {},
        );
        final m3 = (item['m3'] as num?)?.toDouble() ?? 0;
        chartData.add(ChartData(
          date: dateStr,
          warehouseID: warehouseID,
          m3: m3,
        ));
      }
    }

    // Bảng màu cho các sân bay
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

    final warehouses = groupedData.keys.toList()..sort();

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
                  text: 'm³',
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                interval: _getInterval(_getMaxY(chartData)),
                maximum: _getMaxY(chartData),
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
                format: 'point.x\nSản lượng: point.y m³',
                color: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 1,
                textStyle: const TextStyle(color: Color(0xFF1F2A37)),
              ),
              series: _buildSeries(chartData, warehouses, colorPalette),
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
    List<String> warehouses,
    List<Color> colorPalette,
  ) {
    return warehouses.asMap().entries.map((entry) {
      final index = entry.key;
      final warehouse = entry.value;
      return ColumnSeries<ChartData, String>(
        dataSource: data.where((d) => d.warehouseID == warehouse).toList(),
        xValueMapper: (ChartData d, _) => d.date,
        yValueMapper: (ChartData d, _) => d.m3,
        name: '$warehouse (m³)',
        color: colorPalette[index % colorPalette.length],
        width: 0.6,
        spacing: 0.2,
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

  double _getMaxY(List<ChartData> data) {
    double max = 0;
    for (var item in data) {
      if (item.m3 > max) max = item.m3;
    }
    return ((max / 200).ceil() * 200).toDouble() + 100;
  }

  double _getInterval(double max) {
    if (max <= 500) return 100;
    if (max <= 1000) return 200;
    if (max <= 2000) return 400;
    if (max <= 5000) return 1000;
    return 2000;
  }
}

class ChartData {
  final String date;
  final String warehouseID;
  final double m3;

  ChartData({
    required this.date,
    required this.warehouseID,
    required this.m3,
  });
}