// components/CUDV/MultiColumnUocTinhSanLuongBanCard.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class UocTinhSanLuongBanData {
  final String kv;
  final double thucTe;
  final double duKien;
  final double keHoach;

  UocTinhSanLuongBanData({
    required this.kv,
    required this.thucTe,
    required this.duKien,
    required this.keHoach,
  });
}

class MultiColumnUocTinhSanLuongBanCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final double height;

  const MultiColumnUocTinhSanLuongBanCard({
    super.key,
    required this.data,
    this.title = 'ƯỚC TÍNH SẢN LƯỢNG BÁN',
    this.height = 380,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmpty();

    final chartData = data.map((item) {
      return UocTinhSanLuongBanData(
        kv: item['KV']?.toString() ?? '',
        thucTe: (item['ThucTe_KG'] as num?)?.toDouble() ?? 0,
        duKien: (item['DuKien_KG'] as num?)?.toDouble() ?? 0,
        keHoach: (item['KeHoach_KG'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

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
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2A37),
                ),
                rangePadding: ChartRangePadding.additional,
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Sản lượng (kg)',
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                numberFormat: NumberFormat.compact(),
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
              series: <CartesianSeries<UocTinhSanLuongBanData, String>>[
                // ⭐ Thực tế
                ColumnSeries<UocTinhSanLuongBanData, String>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.kv,
                  yValueMapper: (d, _) => d.thucTe,
                  name: 'Thực tế',
                  color: const Color(0xFF1F77B4),
                  width: 0.25,
                  spacing: 0.1,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  enableTooltip: true,
                ),
                // ⭐ Dự kiến
                ColumnSeries<UocTinhSanLuongBanData, String>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.kv,
                  yValueMapper: (d, _) => d.duKien,
                  name: 'Dự kiến',
                  color: const Color(0xFFFF7F0E),
                  width: 0.25,
                  spacing: 0.1,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  enableTooltip: true,
                ),
                // ⭐ Kế hoạch
                ColumnSeries<UocTinhSanLuongBanData, String>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.kv,
                  yValueMapper: (d, _) => d.keHoach,
                  name: 'Kế hoạch',
                  color: const Color(0xFF2CA02C),
                  width: 0.25,
                  spacing: 0.1,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  enableTooltip: true,
                ),
              ],
              legend: Legend(
                isVisible: true,
                position: LegendPosition.top,
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