// components/CUDV/LineChartBieuDoGiaPlattCard.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class BieuDoGiaPlattData {
  final String ngay;
  final DateTime date;
  final double? value;  // ⭐ Nullable

  BieuDoGiaPlattData({
    required this.ngay,
    required this.date,
    required this.value,
  });
}

class LineChartBieuDoGiaPlattCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final double height;

  const LineChartBieuDoGiaPlattCard({
    super.key,
    required this.data,
    this.title = 'BIỂU ĐỒ GIÁ PLATTS',
    this.height = 320,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmpty();

    // ⭐ Giữ nguyên null — KHÔNG convert thành 0
    final chartData = data
        .map((item) {
          final dateStr = item['AssessDate']?.toString() ?? '';
          DateTime date;
          try {
            date = DateTime.parse(dateStr);
          } catch (e) {
            return null;
          }

          // ⭐ Nếu null hoặc không parse được → giữ null
          final rawValue = item['Value'];
          final value =
              rawValue == null ? null : (rawValue as num?)?.toDouble();

          return BieuDoGiaPlattData(
            ngay: DateFormat('dd/MM').format(date),
            date: date,
            value: value,  // ⭐ Có thể null
          );
        })
        .whereType<BieuDoGiaPlattData>()
        .toList();

    if (chartData.isEmpty) return _buildEmpty();

    chartData.sort((a, b) => a.date.compareTo(b.date));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 12),
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
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
                rangePadding: ChartRangePadding.additional,
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Giá (USD)',
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                numberFormat: NumberFormat('#,##0.00'),
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
                //format: 'Ngày point.x\nGiá: \$$point.y',
                format: 'Ngày point.x\nGiá: \$point.y',
                color: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 1,
                textStyle: const TextStyle(color: Color(0xFF1F2A37)),
              ),
              series: <CartesianSeries<BieuDoGiaPlattData, String>>[
                // ⭐ Area fill
                AreaSeries<BieuDoGiaPlattData, String>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.ngay,
                  yValueMapper: (d, _) => d.value,  // ⭐ Nullable
                  name: 'Giá Platts',
                  color: const Color(0xFF1F77B4).withOpacity(0.15),
                  borderColor: const Color(0xFF1F77B4),
                  borderWidth: 2,
                  enableTooltip: true,
                  // ⭐ Ngắt đoạn khi null
                  emptyPointSettings: EmptyPointSettings(
                    mode: EmptyPointMode.gap,  // ⭐ Gap = ngắt đoạn
                    color: Colors.transparent,
                  ),
                ),
                // ⭐ Line
                LineSeries<BieuDoGiaPlattData, String>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.ngay,
                  yValueMapper: (d, _) => d.value,  // ⭐ Nullable
                  name: 'Giá Platts',
                  color: const Color(0xFF1F77B4),
                  width: 2.5,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                    shape: DataMarkerType.circle,
                    color: Color(0xFF1F77B4),
                  ),
                  enableTooltip: true,
                  // ⭐ Ngắt đoạn khi null
                  emptyPointSettings: EmptyPointSettings(
                    mode: EmptyPointMode.gap,
                    color: Colors.transparent,
                  ),
                ),
              ],
              legend: const Legend(isVisible: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}