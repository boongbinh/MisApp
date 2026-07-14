import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class ChartGiohoatdongxetranapCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final double height;

  const ChartGiohoatdongxetranapCard({
    super.key,
    required this.data,
    this.title = 'GIỜ HOẠT ĐỘNG XÉ',
    this.height = 450,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2A37),
              ),
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
      );
    }

    // ⭐ Lọc bỏ các item có dữ liệu null
    final validData = data.where((item) {
      final thang = item['Thang'];
      final chinhanh = item['Chinhanh'];
      final gioHD = item['GioHD'];
      return thang != null && chinhanh != null && gioHD != null;
    }).toList();

    if (validData.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2A37),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Dữ liệu không hợp lệ',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Lấy danh sách các tháng - xử lý an toàn
    final months = validData
        .map((e) {
          final thang = e['Thang'];
          if (thang is int) return thang;
          if (thang is num) return thang.toInt();
          return null;
        })
        .where((e) => e != null)
        .cast<int>()
        .toSet()
        .toList()
      ..sort();

    // Lấy danh sách các chi nhánh - xử lý an toàn
    final chinhanh = validData
        .map((e) => e['Chinhanh']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    if (months.isEmpty || chinhanh.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2A37),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Không có dữ liệu hợp lệ',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Tạo dữ liệu cho biểu đồ
    final List<ChartData> chartData = [];
    for (var month in months) {
      for (var cn in chinhanh) {
        final item = validData.firstWhere(
          (e) => e['Thang'] == month && e['Chinhanh']?.toString() == cn,
          orElse: () => {},
        );
        final gioHD = (item['GioHD'] as num?)?.toDouble() ?? 0;
        final soSC = (item['SoSC'] as num?)?.toInt() ?? 0;
        chartData.add(ChartData(
          thang: 'Tháng $month',
          chinhanh: cn,
          gioHD: gioHD,
          soSC: soSC,
        ));
      }
    }

    // Bảng màu cho các chi nhánh
    final colorPalette = [
      Colors.blue.shade700,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            //height: height,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              primaryXAxis: CategoryAxis(
                labelPlacement: LabelPlacement.onTicks,
                labelIntersectAction: AxisLabelIntersectAction.rotate45,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
                rangePadding: ChartRangePadding.additional,
                //spacing: 0.2,
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Giờ',
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                interval: 500,
                maximum: _getMaxY(chartData),
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
                format: 'point.x\npoint.seriesName: point.y giờ',
                color: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 1,
                textStyle: const TextStyle(color: Color(0xFF1F2A37)),
              ),
              series: _buildSeries(chartData, chinhanh, colorPalette),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildSoSCInfo(chartData, months, chinhanh),
        ],
      ),
    );
  }

  List<ColumnSeries<ChartData, String>> _buildSeries(
    List<ChartData> data,
    List<String> chinhanh,
    List<Color> colorPalette,
  ) {
    return chinhanh.asMap().entries.map((entry) {
      final index = entry.key;
      final cn = entry.value;
      return ColumnSeries<ChartData, String>(
        dataSource: data.where((d) => d.chinhanh == cn).toList(),
        xValueMapper: (ChartData d, _) => d.thang,
        yValueMapper: (ChartData d, _) => d.gioHD,
        name: 'CN $cn',
        color: colorPalette[index % colorPalette.length],
        width: 0.7,
        spacing: 0.1,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2A37),
          ),
        ),
        enableTooltip: true,
      );
    }).toList();
  }

  Widget _buildSoSCInfo(List<ChartData> data, List<int> months, List<String> chinhanh) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SỐ SỰ CỐ (SC)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...months.map((month) {
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tháng $month',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...chinhanh.map((cn) {
                          final item = data.firstWhere(
                            (d) => d.thang == 'Tháng $month' && d.chinhanh == cn,
                            orElse: () => ChartData(thang: '', chinhanh: '', gioHD: 0, soSC: 0),
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getColor(cn, chinhanh),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'CN $cn: ${item.soSC}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF1F2A37),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String chinhanh, List<String> allChinhanh) {
    final colorPalette = [
      Colors.blue.shade700,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
    ];
    final index = allChinhanh.indexOf(chinhanh);
    if (index >= 0 && index < colorPalette.length) {
      return colorPalette[index];
    }
    return Colors.grey;
  }

  double _getMaxY(List<ChartData> data) {
    double max = 0;
    for (var item in data) {
      if (item.gioHD > max) max = item.gioHD;
    }
    return ((max / 500).ceil() * 500).toDouble() + 500;
  }
}

class ChartData {
  final String thang;
  final String chinhanh;
  final double gioHD;
  final int soSC;

  ChartData({
    required this.thang,
    required this.chinhanh,
    required this.gioHD,
    required this.soSC,
  });
}