import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/QTTC/RevenueDetailViewModel.dart';

class RevenueDetail extends GetView<RevenueDetailViewModel> {
  const RevenueDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết doanh thu'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2B71C9), Color(0xFF2E8AC7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardSection(
              title: 'Doanh thu theo từng tháng',
              child: _MonthlyBarChart(vm: vm), // bản dưới đã có Obx bên trong
            ),
            const SizedBox(height: 16),
            _CardSection(
              title: 'Doanh thu theo khách hàng',
              child: _DonutChart(vm: vm), // bản dưới đã có Obx bên trong
            ),
            const SizedBox(height: 8),
            _PieLegend(vm: vm), // bản dưới đã có Obx
          ],
        ),
      ),
    );
  }
}

/* ---------------- BAR CHART ---------------- */

class _MonthlyBarChart extends StatefulWidget {
  const _MonthlyBarChart({required this.vm});
  final RevenueDetailViewModel vm;

  @override
  State<_MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<_MonthlyBarChart> {
  static const barColor = Color(0xFF4DB6AC);
  static const selectedColor = Color(0xFFF59E0B);

  bool _showTip = false;
  Offset _pos = Offset.zero;
  int _month = 1;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return Obx(() {
      final totals = vm.monthlyTotal;
      final sel = vm.selectedMonth.value;
      final maxY =
          vm.maxY > 0
              ? vm.maxY
              : (totals.isEmpty
                      ? 1
                      : (totals.reduce((a, b) => a > b ? a : b) * 1.1))
                  as double;

      // key để restart animation mỗi khi data/tháng chọn đổi
      final restartKey = ValueKey(
        'bars-${totals.join(',')}-${sel}-${maxY.toStringAsFixed(2)}',
      );

      return SizedBox(
        height: 280,
        child: TweenAnimationBuilder<double>(
          key: restartKey,
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (_, t, __) {
            // build bars: chiều cao và bề rộng cùng “lớn dần”
            final bars = <BarChartGroupData>[];
            for (int i = 0; i < totals.length; i++) {
              final m = i + 1;
              final isSel = (m == sel);
              bars.add(
                BarChartGroupData(
                  x: m,
                  barRods: [
                    BarChartRodData(
                      toY: totals[i] * t, // 👈 animate height
                      width: 8 + 17 * t, // 👈 animate width (8 → 25)
                      color: isSel ? selectedColor : barColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder:
                  (_, c) => Stack(
                    children: [
                      BarChart(
                        BarChartData(
                          maxY: maxY,
                          minY: 0,
                          barGroups: bars,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingVerticalLine:
                                (_) => const FlLine(
                                  color: Color(0xFFE6ECF5),
                                  dashArray: [4, 4],
                                  strokeWidth: 1,
                                ),
                            getDrawingHorizontalLine:
                                (_) => const FlLine(
                                  color: Color(0xFFE6ECF5),
                                  strokeWidth: 1,
                                ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 48,
                                getTitlesWidget:
                                    (v, _) => Text(vm.fmt(v.toInt())),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (v, _) => Text(
                                      'T${v.toInt()}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              left: BorderSide(color: Color(0xFFE6ECF5)),
                              bottom: BorderSide(color: Color(0xFFE6ECF5)),
                            ),
                          ),
                          barTouchData: BarTouchData(
                            enabled: true,
                            handleBuiltInTouches: false,
                            touchCallback: (evt, resp) {
                              if (!evt.isInterestedForInteractions ||
                                  resp?.spot == null ||
                                  evt.localPosition == null) {
                                setState(() => _showTip = false);
                                return;
                              }
                              final m = resp!.spot!.touchedBarGroup.x.toInt();
                              setState(() {
                                _showTip = true;
                                _pos = evt.localPosition!;
                                _month = m;
                              });
                              if (evt is FlPanEndEvent ||
                                  evt is FlTapUpEvent ||
                                  evt is FlPointerExitEvent) {
                                setState(() => _showTip = false);
                              }
                            },
                          ),
                        ),
                        // tắt built-in animation để không chồng với tween tay
                        swapAnimationDuration: Duration.zero,
                      ),

                      if (_showTip)
                        Positioned(
                          left: _clampX(_pos.dx, c.maxWidth, 160),
                          top: _clampY(_pos.dy, 280, 86, 8),
                          child: _WhiteTooltip(
                            title:
                                '${_month.toString().padLeft(2, '0')}/${vm.selectedYear.value}',
                            value: vm.fmt(totals[_month - 1]) + ' (TỶ)',
                          ),
                        ),
                    ],
                  ),
            );
          },
        ),
      );
    });
  }

  double _clampX(double x, double maxW, double w) {
    final left = x - w / 2;
    return left.clamp(4.0, (maxW - w - 4).clamp(4.0, maxW));
  }

  double _clampY(double y, double chartH, double boxH, double gap) {
    final top = y - boxH - gap;
    if (top >= 4) return top;
    final bottom = y + gap;
    return (chartH - boxH - 4).clamp(bottom, chartH - boxH - 4);
  }
}

class _WhiteTooltip extends StatelessWidget {
  const _WhiteTooltip({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 160,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white, // ✅ nền trắng
          borderRadius: BorderRadius.circular(12), // ✅ bo góc
          boxShadow: const [
            // ✅ đổ bóng
            BoxShadow(
              color: Color(0x33000000), // 20% đen
              blurRadius: 14,
              spreadRadius: 0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Color(0xFF111827)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Doanh thu: $value',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/* ---------------- DONUT CHART ---------------- */

class _DonutChart extends StatelessWidget {
  const _DonutChart({required this.vm});
  final RevenueDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // restart animation khi dữ liệu đổi
      final restartKey = ValueKey(vm.pieValues.join(','));

      return SizedBox(
        height: 320,
        child: TweenAnimationBuilder<double>(
          key: restartKey,
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, t, __) {
            // sections bung dần theo t
            final sections = <PieChartSectionData>[];
            for (int i = 0; i < vm.pieValues.length; i++) {
              final label = i < vm.pieLabels.length ? vm.pieLabels[i] : '';
              final color =
                  (label == 'HKVN')
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF22C5BB);
              sections.add(
                PieChartSectionData(
                  value: vm.pieValues[i] * t, // <-- bung lát
                  radius: 70,
                  showTitle: true,
                  title: '${vm.sectionPercent(i).toStringAsFixed(1)}%',
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  color: color,
                ),
              );
            }

            // xoay tròn toàn bộ chart
            final angle = 2 * math.pi * (1 - t); // quay từ 360° -> 0°
            return Stack(
              children: [
                Transform.rotate(
                  angle: angle,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 70,
                      sections: sections,
                    ),
                    swapAnimationDuration: Duration.zero, // tránh xung đột
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      vm.fmt(vm.pieSum.round()),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}

/* -------- legend dưới donut: màu + nhãn + giá trị -------- */

class _PieLegend extends StatelessWidget {
  const _PieLegend({required this.vm});
  final RevenueDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget row(String label, Color c, double value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            const _Dot(color: Colors.transparent), // placeholder, set below
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            Text(
              '${vm.fmt(value)} TỶ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );

      final hkqtIdx = vm.pieLabels.indexOf('HKQT');
      final hkvnIdx = vm.pieLabels.indexOf('HKVN');

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
          children: [
            if (hkvnIdx >= 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: Row(
                  children: [
                    const _Dot(color: Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('HKVN')),
                    Text(
                      '${vm.fmt(vm.pieValues[hkvnIdx])} TỶ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            if (hkqtIdx >= 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: Row(
                  children: [
                    const _Dot(color: Color(0xFF22C5BB)),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('HKQT')),
                    Text(
                      '${vm.fmt(vm.pieValues[hkqtIdx])} TỶ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

/* ---------------- small reusable ---------------- */

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}
