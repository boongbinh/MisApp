// components/TTBSP/SanluongbantheothangCard.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SanluongbantheothangData {
  final String category;
  final double hktnBayNoiDia;
  final double hktnBayQuocTe;
  final double hknn;
  final double bayKhac;

  SanluongbantheothangData({
    required this.category,
    required this.hktnBayNoiDia,
    required this.hktnBayQuocTe,
    required this.hknn,
    required this.bayKhac,
  });

  double get tongThucHien =>
      hktnBayNoiDia + hktnBayQuocTe + hknn + bayKhac;
}

class SanluongbantheothangCard extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final double height;

  const SanluongbantheothangCard({
    super.key,
    required this.data,
    this.title = 'SẢN LƯỢNG BÁN THEO THÁNG',
    this.height = 400,
  });

  @override
  State<SanluongbantheothangCard> createState() =>
      _SanluongbantheothangCardState();
}

class _SanluongbantheothangCardState extends State<SanluongbantheothangCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Không có dữ liệu',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ⭐ Lấy item đầu tiên (API trả về 1 item tổng hợp)
    final item = widget.data.first;

    // ⭐ Tạo 4 category cố định
    final chartData = <SanluongbantheothangData>[
      // 1. Thực hiện
      SanluongbantheothangData(
        category: 'Thực hiện',
        hktnBayNoiDia:
            (item['HKTN_BayNoiDia'] as num?)?.toDouble() ?? 0,
        hktnBayQuocTe:
            (item['HKTN_BayQuocTe'] as num?)?.toDouble() ?? 0,
        hknn: (item['HKNN'] as num?)?.toDouble() ?? 0,
        bayKhac: (item['BayKhac'] as num?)?.toDouble() ?? 0,
      ),
      // 2. KHDH
      SanluongbantheothangData(
        category: 'KHDH',
        hktnBayNoiDia:
            (item['KH_HKTN_BayNoiDia'] as num?)?.toDouble() ?? 0,
        hktnBayQuocTe:
            (item['KH_HKTN_BayQuocTe'] as num?)?.toDouble() ?? 0,
        hknn: (item['KH_HKNN'] as num?)?.toDouble() ?? 0,
        bayKhac: (item['KH_BayKhac'] as num?)?.toDouble() ?? 0,
      ),
      // 3. KHPD
      SanluongbantheothangData(
        category: 'KHPD',
        hktnBayNoiDia:
            (item['KHPD_HKTN_BayNoiDia'] as num?)?.toDouble() ?? 0,
        hktnBayQuocTe:
            (item['KHPD_HKTN_BayQuocTe'] as num?)?.toDouble() ?? 0,
        hknn: (item['KHPD_HKNN'] as num?)?.toDouble() ?? 0,
        bayKhac: (item['KHPD_BayKhac'] as num?)?.toDouble() ?? 0,
      ),
      // 4. Cùng kỳ
      SanluongbantheothangData(
        category: 'Cùng kỳ',
        hktnBayNoiDia:
            (item['HKTN_BayNoiDia_CungKy'] as num?)?.toDouble() ?? 0,
        hktnBayQuocTe:
            (item['HKTN_BayQuocTe_CungKy'] as num?)?.toDouble() ?? 0,
        hknn: (item['HKNN_CungKy'] as num?)?.toDouble() ?? 0,
        bayKhac: (item['BayKhac_CungKy'] as num?)?.toDouble() ?? 0,
      ),
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
              widget.title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _buildSummary(chartData),
            const SizedBox(height: 12),
            SizedBox(
              height: widget.height,
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
                    text: 'Sản lượng',
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  maximum: _getMaxY(chartData),
                  interval: _getInterval(_getMaxY(chartData)),
                  numberFormat: NumberFormat.decimalPattern(),
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
                series: <CartesianSeries<SanluongbantheothangData, String>>[
                  // 1. HKTN bay nội địa (xanh dương - dưới cùng)
                  StackedColumnSeries<SanluongbantheothangData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.category,
                    yValueMapper: (d, _) => d.hktnBayNoiDia,
                    name: 'HKTN bay nđ',
                    color: const Color(0xFF1F77B4),
                    width: 0.5,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.inside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      labelAlignment: ChartDataLabelAlignment.middle,
                      // ⭐ Format số rút gọn (K)
                      builder: (data, point, series, pointIndex, seriesIndex) {
                        final val = (data as SanluongbantheothangData)
                            .hktnBayNoiDia;
                        return Text(
                          _formatShort(val),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    enableTooltip: true,
                  ),
                  // 2. HKTN bay quốc tế (cam)
                  StackedColumnSeries<SanluongbantheothangData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.category,
                    yValueMapper: (d, _) => d.hktnBayQuocTe,
                    name: 'HKTN bay qt',
                    color: const Color(0xFFFF7F0E),
                    width: 0.5,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.inside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      labelAlignment: ChartDataLabelAlignment.middle,
                      builder: (data, point, series, pointIndex, seriesIndex) {
                        final val = (data as SanluongbantheothangData)
                            .hktnBayQuocTe;
                        return Text(
                          _formatShort(val),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    enableTooltip: true,
                  ),
                  // 3. HKNN (xanh lá)
                  StackedColumnSeries<SanluongbantheothangData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.category,
                    yValueMapper: (d, _) => d.hknn,
                    name: 'HKNN',
                    color: const Color(0xFF2CA02C),
                    width: 0.5,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.inside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      labelAlignment: ChartDataLabelAlignment.middle,
                      builder: (data, point, series, pointIndex, seriesIndex) {
                        final val =
                            (data as SanluongbantheothangData).hknn;
                        return Text(
                          _formatShort(val),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    enableTooltip: true,
                  ),
                  // 4. Bán khác (đỏ - trên cùng)
                  StackedColumnSeries<SanluongbantheothangData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.category,
                    yValueMapper: (d, _) => d.bayKhac,
                    name: 'Bán khác',
                    color: const Color(0xFFD62728),
                    width: 0.5,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.inside,
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      labelAlignment: ChartDataLabelAlignment.middle,
                      builder: (data, point, series, pointIndex, seriesIndex) {
                        final val =
                            (data as SanluongbantheothangData).bayKhac;
                        return Text(
                          _formatShort(val),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      },
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
      ),
    );
  }

  // ⭐ Format số rút gọn (K)
  String _formatShort(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildSummary(List<SanluongbantheothangData> data) {
    // Tìm item "Thực hiện" và "KHDH"
    final thucHien = data.firstWhere(
      (d) => d.category == 'Thực hiện',
      orElse: () => SanluongbantheothangData(
        category: '',
        hktnBayNoiDia: 0,
        hktnBayQuocTe: 0,
        hknn: 0,
        bayKhac: 0,
      ),
    );
    final khdh = data.firstWhere(
      (d) => d.category == 'KHDH',
      orElse: () => SanluongbantheothangData(
        category: '',
        hktnBayNoiDia: 0,
        hktnBayQuocTe: 0,
        hknn: 0,
        bayKhac: 0,
      ),
    );
    final chenhLech = thucHien.tongThucHien - khdh.tongThucHien;
    final tyLe = khdh.tongThucHien > 0
        ? (thucHien.tongThucHien / khdh.tongThucHien) * 100
        : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE6ECF5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Thực hiện',
            NumberFormat('#,##0', 'vi_VN').format(thucHien.tongThucHien),
            const Color(0xFF1F77B4),
          ),
          _buildSummaryItem(
            'KHDH',
            NumberFormat('#,##0', 'vi_VN').format(khdh.tongThucHien),
            const Color(0xFF6B7280),
          ),
          _buildSummaryItem(
            'Chênh lệch',
            '${chenhLech >= 0 ? '+' : ''}${NumberFormat('#,##0', 'vi_VN').format(chenhLech)}',
            chenhLech >= 0 ? Colors.green : Colors.red,
          ),
          _buildSummaryItem(
            'Tỷ lệ',
            '${tyLe.toStringAsFixed(1)}%',
            tyLe >= 100 ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  double _getMaxY(List<SanluongbantheothangData> data) {
    double max = 0;
    for (var item in data) {
      if (item.tongThucHien > max) max = item.tongThucHien;
    }
    if (max <= 0) return 100;
    return ((max / 50000).ceil() * 50000).toDouble() + 10000;
  }

  double _getInterval(double max) {
    if (max <= 1000) return 200;
    if (max <= 5000) return 1000;
    if (max <= 20000) return 5000;
    if (max <= 50000) return 10000;
    if (max <= 100000) return 25000;
    if (max <= 200000) return 50000;
    return 100000;
  }
}