// widgets/sogiohoatdongxe_chart.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SogiohoatdongxeChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double height;
  final String title;

  const SogiohoatdongxeChart({
    super.key,
    required this.data,
    this.height = 300,
    this.title = 'GIỜ HOẠT ĐỘNG XE SÂN BAY',
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

    // Nhóm dữ liệu theo mã xe (ma_xe)
    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in data) {
      final maXe = item['ma_xe']?.toString() ?? 'Khác';
      if (!groupedData.containsKey(maXe)) {
        groupedData[maXe] = [];
      }
      groupedData[maXe]!.add(item);
    }

    // Lấy danh sách các ngày (sắp xếp tăng dần)
    final allDates = data.map((e) {
      final date = DateTime.tryParse(e['Ngay']?.toString() ?? '');
      return date;
    }).whereType<DateTime>().toSet().toList()..sort();

    // Tạo dữ liệu cho biểu đồ
    final List<ChartData> chartData = [];
    for (var date in allDates) {
      final dateStr = DateFormat('dd/MM').format(date);
      for (var entry in groupedData.entries) {
        final maXe = entry.key;
        final items = entry.value;
        final item = items.firstWhere(
          (e) {
            final eDate = DateTime.tryParse(e['Ngay']?.toString() ?? '');
            return eDate != null && eDate.isAtSameMomentAs(date);
          },
          orElse: () => {},
        );
        final gioHD = (item['gioHD'] as num?)?.toDouble() ?? 0;
        chartData.add(ChartData(
          date: dateStr,
          maXe: maXe,
          gioHD: gioHD,
        ));
      }
    }

    // Bảng màu cho các xe
    final colorPalette = [
      Colors.blue.shade700,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.pink.shade600,
      Colors.amber.shade600,
      Colors.cyan.shade600,
      Colors.indigo.shade600,
    ];

    final maXeList = groupedData.keys.toList()..sort();

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
                  text: 'Giờ',
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
                format: 'point.x\nGiờ hoạt động: point.y giờ',
                color: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 1,
                textStyle: const TextStyle(color: Color(0xFF1F2A37)),
              ),
              series: _buildSeries(chartData, maXeList, colorPalette),
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
    List<String> maXeList,
    List<Color> colorPalette,
  ) {

    // Tự điều chỉnh độ rộng cột theo số lượng legend
  final double columnWidth =maXeList.length <= 10 ? 0.95 : 0.9;

    return maXeList.asMap().entries.map((entry) {
      final index = entry.key;
      final maXe = entry.value;
      return ColumnSeries<ChartData, String>(
        dataSource: data.where((d) => d.maXe == maXe).toList(),
        xValueMapper: (ChartData d, _) => d.date,
        yValueMapper: (ChartData d, _) => d.gioHD,
        name: maXe,
        color: colorPalette[index % colorPalette.length],
        width: 0.9,
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

  double _getMaxY(List<ChartData> data) {
    double max = 0;
    for (var item in data) {
      if (item.gioHD > max) max = item.gioHD;
    }
    // Làm tròn lên bội số của 2
    if (max <= 10) {
      return ((max / 2).ceil() * 2).toDouble() + 1;
    } else if (max <= 20) {
      return ((max / 5).ceil() * 5).toDouble() + 2;
    } else {
      return ((max / 10).ceil() * 10).toDouble() + 5;
    }
  }

  double _getInterval(double max) {
    if (max <= 5) return 1;
    if (max <= 10) return 2;
    if (max <= 20) return 5;
    if (max <= 50) return 10;
    if (max <= 100) return 20;
    return 50;
  }
}

class ChartData {
  final String date;
  final String maXe;
  final double gioHD;

  ChartData({
    required this.date,
    required this.maXe,
    required this.gioHD,
  });
}