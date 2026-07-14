import 'dart:math' as math;
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Controller/QTTT/RateDetailViewModel.dart';

class RateDetail extends GetView<RateDetailViewModel> {
  const RateDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Header gradient đúng thiết kế
      appBar: AppBar(
        elevation: 0,
        title: const Text('Chi tiết tỉ giá'),
        foregroundColor: Colors.white,
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
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterBar(
                label: controller.monthYearLabel,
                onTap: () => _openMonthYearPicker(context, controller),
              ),
              const SizedBox(height: 12),
              _ChartCard(
                chartKey: const ValueKey('buy_chart'),
                title: 'Tỉ giá mua theo ngày',
                points: controller.buy,
                color: const Color(0xFF2D8CFF),
                yFormatter: controller.fmtY,
                month: controller.selectedMonth.value,
                year: controller.selectedYear.value,
                minYOverride: controller.buyMin.value,
                maxYOverride: controller.buyMax.value,
              ),
              const SizedBox(height: 16),
              _ChartCard(
                chartKey: const ValueKey('sell_chart'),
                title: 'Tỉ giá bán theo ngày',
                points: controller.sell,
                color: const Color(0xFF35C189),
                yFormatter: controller.fmtY,
                month: controller.selectedMonth.value,
                year: controller.selectedYear.value,
                minYOverride: controller.sellMin.value,
                maxYOverride: controller.sellMax.value,
              ),
            ],
          ),
        );
      }),
    );
  }
}

/* ---------- filter pill ---------- */
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: const Color(0xFFF1F5FB),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              height: 36,
              width: 36,
              child: Icon(Icons.tune, color: Color(0xFF1F2A37)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const ShapeDecoration(
              color: Color(0xFFE7EFFB),
              shape: StadiumBorder(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ---------- month/year picker ---------- */
Future<void> _openMonthYearPicker(
  BuildContext context,
  RateDetailViewModel vm,
) {
  final months = List<int>.generate(12, (i) => i + 1);
  final years = List<int>.generate(7, (i) => DateTime.now().year - 2 + i);

  int m = vm.selectedMonth.value;
  int y = vm.selectedYear.value;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => Material(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 48,
                    child: Stack(
                      children: [
                        const Center(
                          child: Text(
                            'Thời gian',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    height: 220,
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: m - 1,
                            ),
                            itemExtent: 36,
                            onSelectedItemChanged: (i) => m = months[i],
                            children:
                                months
                                    .map(
                                      (e) => Center(
                                        child: Text(
                                          'Tháng ${e.toString().padLeft(2, '0')}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        Container(width: 1, color: const Color(0xFFE6ECF5)),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: years.indexOf(y),
                            ),
                            itemExtent: 36,
                            onSelectedItemChanged: (i) => y = years[i],
                            children:
                                years
                                    .map((e) => Center(child: Text('$e')))
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              final now = DateTime.now();
                              m = now.month;
                              y = now.year;
                            },
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('Đặt lại'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              vm.setMonthYear(m, y);
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('Áp dụng'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}

/* ---------- chart card ---------- */
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.chartKey,
    required this.title,
    required this.points,
    required this.color,
    required this.yFormatter,
    required this.month,
    required this.year,
    this.minYOverride,
    this.maxYOverride,
  });

  final Key chartKey;
  final String title;
  final List<RatePoint> points;
  final Color color;
  final String Function(num) yFormatter;
  final int month, year;
  final double? minYOverride;
  final double? maxYOverride;

  @override
  Widget build(BuildContext context) {
    final ready =
        points.isNotEmpty && minYOverride != null && maxYOverride != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 220,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child:
                  ready
                      ? _LineChartWithOverlayTooltip(
                        key: chartKey,
                        points: points,
                        color: color,
                        yFormatter: yFormatter,
                        month: month,
                        year: year,
                        minY:
                            minYOverride!, // dùng đúng range server ngay từ frame đầu
                        maxY: maxYOverride!,
                        minX: points.first.day.toDouble(),
                        maxX: points.last.day.toDouble(),
                      )
                      : const _ChartPlaceholder(),
            ),
          ),

          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.center,
            child: Text(
              'Tháng này',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/* ---------- tooltip builder (đúng như thiết kế) ---------- */
class _LineChartWithOverlayTooltip extends StatefulWidget {
  const _LineChartWithOverlayTooltip({
    super.key,
    required this.points,
    required this.color,
    required this.yFormatter,
    required this.month,
    required this.year,
    required this.minY,
    required this.maxY,
    required this.minX,
    required this.maxX,
  });

  final List<RatePoint> points;
  final Color color;
  final String Function(num) yFormatter;
  final int month, year;
  final double minY, maxY, minX, maxX;

  @override
  State<_LineChartWithOverlayTooltip> createState() =>
      _LineChartWithOverlayTooltipState();
}

class _LineChartWithOverlayTooltipState
    extends State<_LineChartWithOverlayTooltip>
    with SingleTickerProviderStateMixin {
  // Tooltip state
  bool _show = false;
  Offset _pos = Offset.zero;
  int _day = 1;
  RatePoint? _rp;

  // Animation
  late final AnimationController _ctrl;
  final Curve _curve = Curves.easeOutCubic;
  String _dataKey = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _maybeAnimate();
  }

  @override
  void didUpdateWidget(covariant _LineChartWithOverlayTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeAnimate();
  }

  void _maybeAnimate() {
    if (widget.points.isEmpty) return;

    // Key đặc trưng cho dataset: tháng, năm, số điểm, min/max
    final key =
        '${widget.month}-${widget.year}-'
        '${widget.points.length}-'
        '${widget.minY}-${widget.maxY}';
    if (key == _dataKey) return;
    _dataKey = key;

    // Frame đầu: t=0 (line nằm baseline), frame kế tiếp mới forward
    _ctrl.value = 0.0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _hide() => setState(() => _show = false);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (_, constraints) => Stack(
            clipBehavior: Clip.none,
            children: [
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    final t = _curve.transform(_ctrl.value);

                    // Trục/grid fade-in mượt (xuất hiện từ 25% → 100%)
                    double axisOpacity = ((_ctrl.value - 0.25) / 0.75).clamp(
                      0.0,
                      1.0,
                    );
                    axisOpacity = Curves.easeOut.transform(axisOpacity);

                    // Điểm nội suy
                    final animSpots = <List<FlSpot>>[];
                    List<FlSpot> currentSegment = [];

                    for (final e in widget.points) {
                      if (e.value == null) {
                        if (currentSegment.isNotEmpty) {
                          animSpots.add(currentSegment);
                          currentSegment = [];
                        }
                      } else {
                        final y = widget.minY + (e.value! - widget.minY) * t;
                        currentSegment.add(FlSpot(e.day.toDouble(), y));
                      }
                    }
                    if (currentSegment.isNotEmpty) {
                      animSpots.add(currentSegment);
                    }

                    return LineChart(
                      LineChartData(
                        minY: widget.minY,
                        maxY: widget.maxY,
                        minX: widget.minX,
                        maxX: widget.maxX,

                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine:
                              (v) => FlLine(
                                color: const Color(
                                  0xFFE6ECF5,
                                ).withOpacity(0.8 * axisOpacity),
                                strokeWidth: 1,
                              ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 56,
                              getTitlesWidget:
                                  (v, _) => Opacity(
                                    opacity: axisOpacity,
                                    child: Transform.translate(
                                      offset: Offset(0, (1 - axisOpacity) * 4),
                                      child: Text(
                                        widget.yFormatter(v),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: 5,
                              getTitlesWidget:
                                  (v, _) => Opacity(
                                    opacity: axisOpacity,
                                    child: Transform.translate(
                                      offset: Offset(0, (1 - axisOpacity) * 4),
                                      child: Text(
                                        v.toInt().toString(),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
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
                          border: Border(
                            left: BorderSide(
                              color: const Color(
                                0xFFE6ECF5,
                              ).withOpacity(axisOpacity),
                            ),
                            bottom: BorderSide(
                              color: const Color(
                                0xFFE6ECF5,
                              ).withOpacity(axisOpacity),
                            ),
                            right: const BorderSide(color: Colors.transparent),
                            top: const BorderSide(color: Colors.transparent),
                          ),
                        ),

                        // Bật touch sau khi axis đã fade-in (mượt hơn)
                        lineTouchData: LineTouchData(
                          enabled: axisOpacity >= 0.999,
                          handleBuiltInTouches: false,
                          touchSpotThreshold: 28,
                          getTouchedSpotIndicator:
                              (bar, idx) =>
                                  idx
                                      .map(
                                        (_) => TouchedSpotIndicatorData(
                                          const FlLine(
                                            color: Color(0xFF9CA3AF),
                                            strokeWidth: 1,
                                          ),
                                          FlDotData(
                                            show: true,
                                            getDotPainter:
                                                (s, p, b, i) =>
                                                    FlDotCirclePainter(
                                                      radius: 3,
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                      strokeColor: widget.color,
                                                    ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                          touchCallback: (event, resp) {
                            if (!event.isInterestedForInteractions ||
                                resp == null ||
                                resp.lineBarSpots?.isEmpty != false) {
                              _hide();
                              return;
                            }
                            final spot = resp.lineBarSpots!.first;
                            final d = spot.x.toInt();
                            final rp = widget.points.firstWhere(
                              (e) => e.day == d && e.value != null,
                              orElse:
                                  () => widget.points.firstWhere(
                                    (e) => e.value != null,
                                  ),
                            );
                            setState(() {
                              _show = true;
                              _pos = event.localPosition!;
                              _day = d;
                              _rp = rp;
                            });
                            if (event is FlPanEndEvent ||
                                event is FlTapUpEvent ||
                                event is FlPointerExitEvent) {
                              _hide();
                            }
                          },
                        ),

                        lineBarsData:
                            animSpots
                                .map(
                                  (segment) => LineChartBarData(
                                    spots: segment,
                                    isCurved: true,
                                    color: widget.color,
                                    barWidth: lerpDouble(1.0, 2.0, t)!,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: t > .7,
                                      getDotPainter:
                                          (spot, p, bar, i) =>
                                              FlDotCirclePainter(
                                                radius: 3,
                                                color: Colors.white,
                                                strokeWidth: 2,
                                                strokeColor: widget.color,
                                              ),
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          widget.color.withOpacity(.20 * t),
                                          widget.color.withOpacity(.04 * t),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    );
                  },
                ),
              ),

              // Tooltip overlay (không bị repaint mỗi frame)
              if (_show && _rp != null)
                Positioned(
                  left: _clampX(_pos.dx, constraints.maxWidth, 220),
                  top: _clampY(_pos.dy, 220, 96, 8),
                  child: _TooltipBox(
                    colorDot: widget.color,
                    date: DateTime(widget.year, widget.month, _day),
                    valueText: widget.yFormatter(_rp!.value as num),
                    dQuarter: _rp!.dQuarter,
                    dStart: _rp!.dStart,
                  ),
                ),
            ],
          ),
    );
  }

  double _clampX(double x, double maxWidth, double boxWidth) {
    final w = boxWidth.toDouble();
    final left = x - w / 2;
    return left.clamp(4.0, math.max(4.0, maxWidth - w - 4.0));
  }

  double _clampY(double y, double chartH, double boxH, double gap) {
    final top = y - boxH - gap;
    if (top >= 4) return top;
    final bottom = y + gap;
    return math.min(bottom, chartH - boxH - 4);
  }
}

// Hộp tooltip theo thiết kế (nền trắng, bo 10, shadow nhẹ)
class _TooltipBox extends StatelessWidget {
  const _TooltipBox({
    required this.colorDot,
    required this.date,
    required this.valueText,
    this.dQuarter,
    this.dStart,
  });

  final Color colorDot;
  final DateTime date;
  final String valueText;
  final double? dQuarter;
  final double? dStart;

  @override
  Widget build(BuildContext context) {
    const tHeader = TextStyle(
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
      fontSize: 12,
    );
    const tLabel = TextStyle(color: Color(0xFF6B7280), fontSize: 12);
    const tValue = TextStyle(
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
      fontSize: 12,
    );
    const green = Color(0xFF10B981);
    const red = Color(0xFFEF4444);

    String pct(double v) =>
        '${v >= 0 ? '+' : ''}${(v * 100).toStringAsFixed(2)}%';

    return Material(
      elevation: 6,
      color: Colors.transparent,
      child: Container(
        width: 220,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xF5FFFFFF), // ~96% opacity
          borderRadius: BorderRadius.circular(10),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 12, color: Color(0xFF111827)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chi tiết ngày ${DateFormat('dd/MM/yyyy').format(date)}',
                style: tHeader,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('● ', style: TextStyle(color: colorDot, fontSize: 14)),
                  const Text('Tháng này: ', style: tLabel),
                  Text(valueText, style: tValue),
                ],
              ),
              if (dQuarter != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text('Trượt giá quý trước: ', style: tLabel),
                    Text(
                      pct(dQuarter!),
                      style: TextStyle(
                        color: dQuarter! >= 0 ? green : red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
              if (dStart != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text('Trượt giá đầu kì: ', style: tLabel),
                    Text(
                      pct(dStart!),
                      style: TextStyle(
                        color: dStart! >= 0 ? green : red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
