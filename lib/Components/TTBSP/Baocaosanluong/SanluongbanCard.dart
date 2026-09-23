// components/TTBSP/SanluongbanCard.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SanluongbanData {
  final String ngay;
  final double hktnBayNuocNgoai;
  final double hktnBayTrongNuoc;
  final double hknn;
  final double bayKhac;
  final double tongSLKH;
  final double ton;

  SanluongbanData({
    required this.ngay,
    required this.hktnBayNuocNgoai,
    required this.hktnBayTrongNuoc,
    required this.hknn,
    required this.bayKhac,
    required this.tongSLKH,
    required this.ton,
  });

  double get tongThucHien =>
      hktnBayNuocNgoai + hktnBayTrongNuoc + hknn + bayKhac;
}

// ⭐ Enum đơn vị
enum DonViTinh { ton, m3 }

class SanluongbanCard extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final double height;

  const SanluongbanCard({
    super.key,
    required this.data,
    this.title = 'SẢN LƯỢNG BÁN THEO NGÀY',
    this.height = 350,
  });

  @override
  State<SanluongbanCard> createState() => _SanluongbanCardState();
}

class _SanluongbanCardState extends State<SanluongbanCard> {
  DonViTinh _donVi = DonViTinh.ton; // ⭐ Mặc định Tấn

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildNoData();
    }

    // ⭐ Map dữ liệu theo đơn vị đang chọn
    final chartData = widget.data.map((item) {
      final isTon = _donVi == DonViTinh.ton;
      return SanluongbanData(
        ngay: item['VoucherDate']?.toString() ?? '',
        hktnBayNuocNgoai: isTon
            ? ((item['HKTN_BayNuocNgoai_Ton'] as num?)?.toDouble() ?? 0)
            : ((item['HKTN_BayNuocNgoai_m3'] as num?)?.toDouble() ?? 0),
        hktnBayTrongNuoc: isTon
            ? ((item['HKTN_BayTrongNuoc_Ton'] as num?)?.toDouble() ?? 0)
            : ((item['HKTN_BayTrongNuoc_m3'] as num?)?.toDouble() ?? 0),
        hknn: isTon
            ? ((item['HKNN_Ton'] as num?)?.toDouble() ?? 0)
            : ((item['HKNN_m3'] as num?)?.toDouble() ?? 0),
        bayKhac: isTon
            ? ((item['BayKhac_Ton'] as num?)?.toDouble() ?? 0)
            : ((item['BayKhac_m3'] as num?)?.toDouble() ?? 0),
        tongSLKH: isTon
            ? ((item['Tong_SL_KH'] as num?)?.toDouble() ?? 0)
            : ((item['Tong_KH_m3'] as num?)?.toDouble() ?? 0),
        ton: isTon
            ? ((item['Ton'] as num?)?.toDouble() ?? 0)
            : ((item['m3'] as num?)?.toDouble() ?? 0),
      );
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐ Header với toggle đơn vị
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildUnitToggle(),
              ],
            ),
            const SizedBox(height: 8),
            _buildSummary(chartData),
            const SizedBox(height: 12),
            SizedBox(
              height: widget.height,
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
                    text: _donVi == DonViTinh.ton ? 'Tấn' : 'm³',
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
                series: <CartesianSeries<SanluongbanData, String>>[
                  StackedColumnSeries<SanluongbanData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.ngay,
                    yValueMapper: (d, _) => d.hktnBayNuocNgoai,
                    name: 'HKTN bay NĐ',
                    color: Colors.blue.shade700,
                    width: 0.5,
                    enableTooltip: true,
                  ),
                  StackedColumnSeries<SanluongbanData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.ngay,
                    yValueMapper: (d, _) => d.hktnBayTrongNuoc,
                    name: 'HKTN bay QT',
                    color: Colors.red.shade600,
                    width: 0.5,
                    enableTooltip: true,
                  ),
                  StackedColumnSeries<SanluongbanData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.ngay,
                    yValueMapper: (d, _) => d.hknn,
                    name: 'HKNN',
                    color: const Color(0xFF9ACD32),
                    width: 0.5,
                    enableTooltip: true,
                  ),
                  StackedColumnSeries<SanluongbanData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.ngay,
                    yValueMapper: (d, _) => d.bayKhac,
                    name: 'Bán khác',
                    color: Colors.purple.shade600,
                    width: 0.5,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    enableTooltip: true,
                  ),
                  LineSeries<SanluongbanData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.ngay,
                    yValueMapper: (d, _) => d.tongSLKH,
                    name: 'Tổng SL KH',
                    color: Colors.black87,
                    width: 2,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 6,
                      width: 6,
                      shape: DataMarkerType.circle,
                      color: Colors.black87,
                    ),
                    dashArray: const [5, 3],
                    enableTooltip: true,
                  ),
                ],
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
      ),
    );
  }

  // ⭐ Widget toggle đơn vị
  Widget _buildUnitToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleBtn(
            label: 'Tấn',
            isActive: _donVi == DonViTinh.ton,
            onTap: () => setState(() => _donVi = DonViTinh.ton),
          ),
          _buildToggleBtn(
            label: 'm³',
            isActive: _donVi == DonViTinh.m3,
            onTap: () => setState(() => _donVi = DonViTinh.m3),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? const Color(0xFF1F7BD8) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildNoData() {
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

  Widget _buildSummary(List<SanluongbanData> data) {
    final totalThucHien =
        data.fold(0.0, (sum, item) => sum + item.tongThucHien);
    final totalKH = data.fold(0.0, (sum, item) => sum + item.tongSLKH);
    final chenhLech = totalThucHien - totalKH;
    final tyLe = totalKH > 0 ? (totalThucHien / totalKH) * 100 : 0;
    final donViText = _donVi == DonViTinh.ton ? 'Tấn' : 'm³';

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
            'Tổng KH ($donViText)',
            NumberFormat('#,##0', 'vi_VN').format(totalKH),
            Colors.black87,
          ),
          _buildSummaryItem(
            'Tổng TH ($donViText)',
            NumberFormat('#,##0', 'vi_VN').format(totalThucHien),
            Colors.blue.shade700,
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

  double _getMaxY(List<SanluongbanData> data) {
    double max = 0;
    for (var item in data) {
      final maxItem =
          item.tongThucHien > item.tongSLKH ? item.tongThucHien : item.tongSLKH;
      if (maxItem > max) max = maxItem;
    }
    if (max <= 0) return 100;
    return ((max / 500).ceil() * 500).toDouble() + 200;
  }

  double _getInterval(double max) {
    if (max <= 100) return 20;
    if (max <= 500) return 100;
    if (max <= 1000) return 200;
    if (max <= 2000) return 500;
    if (max <= 5000) return 1000;
    if (max <= 10000) return 2000;
    return 5000;
  }
}