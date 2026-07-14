import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoanhthuCacthangCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String donViTien;

  const DoanhthuCacthangCard({
    super.key,
    required this.data,
    required this.donViTien,
  });

  @override
  Widget build(BuildContext context) {
    final sortedData = List<Map<String, dynamic>>.from(data)
      ..sort((a, b) => (a['month'] as int).compareTo(b['month'] as int));

    if (sortedData.isEmpty) return const SizedBox.shrink();

    final List<_ChartData> chartData = sortedData.map((item) {
      return _ChartData(
        x: 'Thg ${item['month']}',
        nn: (item['nn'] as num).toDouble(),
        tn: (item['tn'] as num).toDouble(),
      );
    }).toList();

    final tooltipBehavior = TooltipBehavior(enable: true, header: '');
    final ZoomPanBehavior zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doanh thu qua các tháng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.blue, label: 'HKNN'),
                const SizedBox(width: 24),
                _LegendItem(color: Colors.amber, label: 'HKTN'),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Chiều rộng khả dụng
                final availableWidth = constraints.maxWidth;
                // Tính số cột, mỗi cột chiếm 1/12 chiều rộng (có thể điều chỉnh)
                // Nhưng Syncfusion tự động chia đều, ta chỉ cần set width series phù hợp
                return SizedBox(
                  height: 350,
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelPlacement: LabelPlacement.betweenTicks,
                      labelIntersectAction: AxisLabelIntersectAction.rotate45,
                      arrangeByIndex: true,
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(text: 'Đơn vị: ${donViTien == 'VND' ? 'VNĐ' : 'USD'}'),
                    ),
                    series: _buildStackedColumnSeries(chartData),
                    tooltipBehavior: tooltipBehavior,
                    zoomPanBehavior: zoomPanBehavior,
                    legend: const Legend(isVisible: false),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<CartesianSeries<_ChartData, String>> _buildStackedColumnSeries(
      List<_ChartData> chartData) {
    // width: 0.8 để cột chiếm 80% khoảng trống, vừa đẹp, không bị tràn
    return [
      StackedColumnSeries<_ChartData, String>(
        dataSource: chartData,
        xValueMapper: (_ChartData data, _) => data.x,
        yValueMapper: (_ChartData data, _) => data.nn,
        name: 'HKNN',
        color: Colors.blue,
        width: 0.8,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.outer,
        ),
      ),
      StackedColumnSeries<_ChartData, String>(
        dataSource: chartData,
        xValueMapper: (_ChartData data, _) => '', // x đã map ở series trên, để trống cho series sau
        yValueMapper: (_ChartData data, _) => data.tn,
        name: 'HKTN',
        color: Colors.amber,
        width: 0.8,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.outer,
        ),
      ),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ChartData {
  final String x;
  final double nn;
  final double tn;
  _ChartData({required this.x, required this.nn, required this.tn});
}