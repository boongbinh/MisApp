import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


// ============================================================
// MODEL
// ============================================================

class ChartsogiohdcndpData {
  final String maTd1;
  final String maKx;
  final String maXe;
  final double gioHD;
  final DateTime ngay;
  final int loai;
  final String chiNhanh;

  ChartsogiohdcndpData({
    required this.maTd1,
    required this.maKx,
    required this.maXe,
    required this.gioHD,
    required this.ngay,
    required this.loai,
    required this.chiNhanh,
  });

  factory ChartsogiohdcndpData.fromMap(
    Map<String, dynamic> map,
  ) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        return double.tryParse(
              value.replaceAll(',', ''),
            ) ??
            0;
      }

      return 0;
    }

    return ChartsogiohdcndpData(
      maTd1: map['ma_td1']?.toString() ?? '',
      maKx: map['ma_kx']?.toString() ?? '',
      maXe: map['ma_xe']?.toString() ?? '',
      gioHD: parseDouble(map['gioHD']),
      ngay: DateTime.tryParse(
            map['Ngay']?.toString() ?? '',
          ) ??
          DateTime.now(),
      loai: (map['Loai'] as num?)?.toInt() ?? 1,
      chiNhanh: map['Chinhanh']?.toString() ?? '',
    );
  }
}


// ============================================================
// MODEL CHO DỮ LIỆU ĐÃ TỔNG HỢP THEO NGÀY
// ============================================================

class _ChartDayData {
  final DateTime ngay;
  final double gioHD;
  final int loai;

  _ChartDayData({
    required this.ngay,
    required this.gioHD,
    required this.loai,
  });
}


// ============================================================
// CARD
// ============================================================

class ChartsogiohdcndpCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const ChartsogiohdcndpCard({
    super.key,
    required this.data,
    this.title = 'Số giờ hoạt động xe sân bay',
  });

  @override
  Widget build(BuildContext context) {
    final rows = data
        .map(
          (e) => ChartsogiohdcndpData.fromMap(e),
        )
        .toList();

    if (rows.isEmpty) {
      return Container(
        height: 280,
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
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                4,
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Không có dữ liệu',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final chartData = _buildChartData(rows);

    final loaiList = rows
        .map((e) => e.loai)
        .toSet()
        .toList()
      ..sort();

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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              0,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 4),

          SizedBox(
            height: 270,
            child: SfCartesianChart(
              margin: const EdgeInsets.fromLTRB(
                8,
                8,
                16,
                8,
              ),

              primaryXAxis: DateTimeAxis(
                intervalType:
                    DateTimeIntervalType.days,

                dateFormat:
                    DateFormat('dd/MM'),

                majorGridLines:
                    const MajorGridLines(
                  width: 0,
                ),

                axisLine: const AxisLine(
                  width: 0,
                ),

                majorTickLines:
                    const MajorTickLines(
                  width: 0,
                ),

                labelStyle:
                    const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),

              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Giờ',
                  textStyle:
                      const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),

                minimum: 0,

                majorGridLines:
                    const MajorGridLines(
                  width: 0.6,
                  dashArray: <double>[
                    4,
                    4,
                  ],
                ),

                axisLine: const AxisLine(
                  width: 0,
                ),

                majorTickLines:
                    const MajorTickLines(
                  width: 0,
                ),

                labelStyle:
                    const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),

              tooltipBehavior:
                  TooltipBehavior(
                enable: true,
                canShowMarker: true,
                format:
                    'point.x : point.y giờ',
              ),

              legend: Legend(
                isVisible: loaiList.length > 1,
                position:
                    LegendPosition.bottom,
                overflowMode:
                    LegendItemOverflowMode.wrap,
                textStyle:
                    const TextStyle(
                  fontSize: 10,
                ),
              ),

              series: _buildSeries(
                chartData,
                loaiList,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ==========================================================
  // TỔNG HỢP DỮ LIỆU
  // ==========================================================

  List<_ChartDayData> _buildChartData(
    List<ChartsogiohdcndpData> rows,
  ) {
    final Map<String, double> totals = {};

    for (final row in rows) {
      final date = DateTime(
        row.ngay.year,
        row.ngay.month,
        row.ngay.day,
      );

      final key =
          '${date.year}-${date.month}-${date.day}-${row.loai}';

      totals[key] =
          (totals[key] ?? 0) + row.gioHD;
    }

    final result = <_ChartDayData>[];

    for (final entry in totals.entries) {
      final parts = entry.key.split('-');

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final loai = int.parse(parts[3]);

      result.add(
        _ChartDayData(
          ngay: DateTime(
            year,
            month,
            day,
          ),
          gioHD: entry.value,
          loai: loai,
        ),
      );
    }

    result.sort(
      (a, b) => a.ngay.compareTo(b.ngay),
    );

    return result;
  }


  // ==========================================================
  // BUILD SERIES
  // ==========================================================

  List<CartesianSeries<_ChartDayData, DateTime>>
      _buildSeries(
    List<_ChartDayData> data,
    List<int> loaiList,
  ) {
    return loaiList.map((loai) {
      final seriesData = data
          .where(
            (e) => e.loai == loai,
          )
          .toList();

      return ColumnSeries<_ChartDayData, DateTime>(
        name: 'Loại $loai',

        dataSource: seriesData,

        xValueMapper:
            (_ChartDayData item, _) =>
                item.ngay,

        yValueMapper:
            (_ChartDayData item, _) =>
                item.gioHD,

        width: 0.7,

        spacing: 0.15,

        dataLabelSettings:
            const DataLabelSettings(
          isVisible: true,
          textStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          labelAlignment:
              ChartDataLabelAlignment.top,
        ),

        borderRadius:
            const BorderRadius.only(
          topLeft: Radius.circular(3),
          topRight: Radius.circular(3),
        ),
      );
    }).toList();
  }
}