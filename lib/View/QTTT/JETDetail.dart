import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Controller/QTTT/JETDetailViewModel.dart';

class JETDetail extends GetView<JETDetailViewModel> {
  const JETDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = controller;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết giá JET A1',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
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
      body: Obx(() {
        if (vm.loading.value)
          return const Center(child: CircularProgressIndicator());
        if (vm.error.isNotEmpty) return Center(child: Text(vm.error.value));

        final (minY, maxY) = vm.currentYRange();

        // dựng series từ RxList -> List thường
        final series = <_Serie>[
          _Serie(
            'Tháng này',
            const Color(0xFF2D8CFF),
            vm.thisMonth.toList(),
            vm.thisRaw.toList(),
            vm.showThis.value,
          ),
          _Serie(
            'Tháng trước',
            const Color(0xFFF59E0B),
            vm.prevMonth.toList(),
            vm.prevRaw.toList(),
            vm.showPrev.value,
          ),
          _Serie(
            'Tháng này năm ngoái',
            const Color(0xFF22C5BB),
            vm.lastYear.toList(),
            vm.lastRaw.toList(),
            vm.showLast.value,
          ),
        ];

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterBar(
                label: vm.monthLabel,
                onTap: () => _openMonthYearPicker(context, vm),
              ),
              SizedBox(height: 12),
              Text(
                'Giá JET A1 (TB tháng: ${vm.avgMonth.value.isEmpty ? '--' : vm.avgMonth.value})',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),

              // Chart quan sát cả flags show/ẩn + dữ liệu
              _JetLineChart(
                minY: minY,
                maxY: maxY,
                month: vm.selectedMonth.value,
                year: vm.selectedYear.value,
                yFmt: vm.fmt,
                series: [
                  _Serie(
                    'Tháng này',
                    const Color(0xFF2D8CFF),
                    vm.thisMonth.toList(),
                    vm.thisRaw.toList(),
                    vm.showThis.value,
                  ),
                  _Serie(
                    'Tháng trước',
                    const Color(0xFFF59E0B),
                    vm.prevMonth.toList(),
                    vm.prevRaw.toList(),
                    vm.showPrev.value,
                  ),
                  _Serie(
                    'Tháng này năm ngoái',
                    const Color(0xFF22C5BB),
                    vm.lastYear.toList(),
                    vm.lastRaw.toList(),
                    vm.showLast.value,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Legend cũng quan sát flags
              _LegendPanel(
                showThis: vm.showThis.value,
                showPrev: vm.showPrev.value,
                showLast: vm.showLast.value,
                onToggleThis: () => vm.showThis.toggle(),
                onTogglePrev: () => vm.showPrev.toggle(),
                onToggleLast: () => vm.showLast.toggle(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/* ---------------- filter pill ---------------- */
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  static const _border = BorderSide(color: Color(0xFFE6ECF5), width: 1.2);
  static const _pillColor = Colors.white;
  static const _iconColor = Color(0xFF4B5563);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _pillColor,
              borderRadius: BorderRadius.circular(18),
              border: const Border.fromBorderSide(_border),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.slider_horizontal_3,
              size: 18,
              color: _iconColor,
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
              color: _pillColor,
              shape: StadiumBorder(side: _border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, color: _iconColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _openMonthYearPicker(BuildContext context, JETDetailViewModel vm) {
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

/* ---------------- legend ---------------- */
class _LegendPanel extends StatelessWidget {
  const _LegendPanel({
    required this.showThis,
    required this.showPrev,
    required this.showLast,
    required this.onToggleThis,
    required this.onTogglePrev,
    required this.onToggleLast,
  });
  final bool showThis, showPrev, showLast;
  final VoidCallback onToggleThis, onTogglePrev, onToggleLast;

  @override
  Widget build(BuildContext context) {
    Widget row(Color c, String label, bool show, VoidCallback onTap) {
      return Container(
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6ECF5))),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            _Dot(color: c),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Color(0xFF111827)),
              ),
            ),
            IconButton(
              onPressed: onTap,
              icon: Icon(
                show ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

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
          row(const Color(0xFF2D8CFF), 'Tháng này', showThis, onToggleThis),
          row(const Color(0xFFF59E0B), 'Tháng trước', showPrev, onTogglePrev),
          row(
            const Color(0xFF22C5BB),
            'Tháng này năm ngoái',
            showLast,
            onToggleLast,
          ),
        ],
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

/* ---------------- chart ---------------- */
class _Serie {
  final String name;
  final Color color;
  final List<RatePoint> points; // các điểm đã bỏ null
  final List<double?> raw; // mảng gốc có thể null, index = day-1
  final bool visible;
  _Serie(this.name, this.color, this.points, this.raw, this.visible);
}

class _JetLineChart extends StatefulWidget {
  const _JetLineChart({
    required this.series,
    required this.minY,
    required this.maxY,
    required this.month,
    required this.year,
    required this.yFmt,
  });

  final List<_Serie> series;
  final double minY, maxY;
  final int month, year;
  final String Function(num) yFmt;

  @override
  State<_JetLineChart> createState() => _JetLineChartState();
}

class _JetLineChartState extends State<_JetLineChart>
    with SingleTickerProviderStateMixin {
  bool _show = false;
  Offset _pos = Offset.zero;
  int _day = 1;

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 850),
          )
          ..addListener(() => setState(() {}))
          ..forward();
  }

  @override
  void didUpdateWidget(covariant _JetLineChart old) {
    super.didUpdateWidget(old);
    if (old.month != widget.month || old.year != widget.year) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  RatePoint? _pointAtDay(List<RatePoint> pts, int day) {
    for (final p in pts) {
      if (p.day == day) return p;
    }
    return null;
  }

  void _hide() => setState(() => _show = false);

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutCubic.transform(_ctrl.value);

    // ==== TÍNH minX/maxX theo các series đang HIỂN THỊ ====
    final visible = widget.series.where((s) => s.visible);
    final allPts = visible.expand((s) => s.points).toList();
    final double minX =
        allPts.isEmpty
            ? 1.0
            : allPts.map((e) => e.day).reduce(math.min).toDouble();
    final double maxX =
        allPts.isEmpty
            ? 31.0
            : allPts.map((e) => e.day).reduce(math.max).toDouble();

    // ==== DỰNG BARS: chia thành từng đoạn (segment) theo null trong raw ====
    final bars = <LineChartBarData>[];
    for (final s in visible) {
      final segs = _segmentsFromRaw(
        s.raw,
        widget.minY,
        t,
      ); // list<List<FlSpot>>
      for (final seg in segs) {
        bars.add(
          LineChartBarData(
            spots: seg,
            isCurved: true,
            color: s.color,
            barWidth: ui.lerpDouble(1, 2, t)!,
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, _, __, ___) => ValueDotPainter(
                    value: spot.y,
                    color: s.color,
                    radius: ui.lerpDouble(0, 3, t)!,
                  ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        );
      }
    }

    return Container(
      height: 260,
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
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
      child: LayoutBuilder(
        builder:
            (_, c) => Stack(
              clipBehavior: Clip.none,
              children: [
                LineChart(
                  LineChartData(
                    minY: widget.minY,
                    maxY: widget.maxY,
                    minX: minX,
                    maxX: maxX,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      verticalInterval: 2,
                      getDrawingVerticalLine:
                          (v) => FlLine(
                            color: const Color(0xFFE6ECF5).withOpacity(.9),
                            strokeWidth: 1,
                            dashArray: [4, 4],
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
                          reservedSize: 50,
                          getTitlesWidget:
                              (v, _) => Opacity(
                                opacity: t,
                                child: Text(
                                  widget.yFmt(v),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 2,
                          getTitlesWidget:
                              (v, _) => Opacity(
                                opacity: t,
                                child: Text(
                                  v.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
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
                        left: BorderSide(color: Color(0xFFE6ECF5)),
                        bottom: BorderSide(color: Color(0xFFE6ECF5)),
                        right: BorderSide(color: Colors.transparent),
                        top: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      enabled: _ctrl.isCompleted,
                      handleBuiltInTouches: false,
                      touchCallback: (event, resp) {
                        if (!event.isInterestedForInteractions ||
                            resp == null ||
                            resp.lineBarSpots == null ||
                            resp.lineBarSpots!.isEmpty) {
                          _hide();
                          return;
                        }
                        setState(() {
                          _show = true;
                          _pos = event.localPosition!;
                          _day = resp.lineBarSpots!.first.x.toInt();
                        });
                        if (event is FlPanEndEvent ||
                            event is FlTapUpEvent ||
                            event is FlPointerExitEvent) {
                          _hide();
                        }
                      },
                      getTouchedSpotIndicator:
                          (bar, idx) =>
                              idx
                                  .map(
                                    (_) => const TouchedSpotIndicatorData(
                                      FlLine(
                                        color: Color(0xFF9CA3AF),
                                        strokeWidth: 1,
                                      ),
                                      FlDotData(show: true),
                                    ),
                                  )
                                  .toList(),
                    ),
                    lineBarsData: bars,
                  ),
                ),

                // Tooltip tổng hợp 3 series
                if (_show)
                  Builder(
                    builder: (_) {
                      final idx = _day - 1;
                      final items = <(Color, String, String)>[];

                      for (final s in visible) {
                        // có dữ liệu thật ở ngày _day không?
                        final hasData =
                            idx >= 0 &&
                            idx < s.raw.length &&
                            s.raw[idx] != null;
                        if (!hasData) continue;

                        // tìm đúng điểm ngày _day trong list đã bỏ null
                        final rp = _pointAtDay(s.points, _day);
                        if (rp == null) continue;

                        items.add((s.color, s.name, widget.yFmt(rp.value)));
                      }

                      // ngày này không series nào có dữ liệu -> không vẽ tooltip
                      if (items.isEmpty) return const SizedBox.shrink();

                      return Positioned(
                        left: _clampX(_pos.dx, c.maxWidth, 210),
                        top: _clampY(_pos.dy, 260, 110, 8),
                        child: _TooltipBox3Series(
                          date: DateTime(widget.year, widget.month, _day),
                          items: items,
                        ),
                      );
                    },
                  ),
              ],
            ),
      ),
    );
  }

  // Tách dữ liệu thành nhiều đoạn (đứt khi gặp null) + áp animation theo minY -> value
  List<List<FlSpot>> _segmentsFromRaw(
    List<double?> raw,
    double minY,
    double t,
  ) {
    final segs = <List<FlSpot>>[];
    var cur = <FlSpot>[];
    for (var i = 0; i < raw.length; i++) {
      final v = raw[i];
      if (v == null) {
        if (cur.isNotEmpty) {
          segs.add(cur);
          cur = <FlSpot>[];
        }
        continue;
      }
      final day = (i + 1).toDouble();
      final y = minY + (v - minY) * t; // animate
      cur.add(FlSpot(day, y));
    }
    if (cur.isNotEmpty) segs.add(cur);
    return segs;
  }

  double _clampX(double x, double maxWidth, double w) {
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

class _TooltipBox3Series extends StatelessWidget {
  const _TooltipBox3Series({required this.date, required this.items});
  final DateTime date;
  // (màu, nhãn, giá trị)
  final List<(Color, String, String)> items;

  @override
  Widget build(BuildContext context) {
    const tHeader = TextStyle(
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
      fontSize: 12,
    );
    const tLabel = TextStyle(color: Color(0xFF6B7280), fontSize: 12);
    return Material(
      elevation: 6,
      color: Colors.transparent,
      child: Container(
        width: 210,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xF5FFFFFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat("dd/MM/yyyy").format(date), style: tHeader),
            const SizedBox(height: 6),
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    _Dot(color: e.$1),
                    const SizedBox(width: 6),
                    Expanded(child: Text(e.$2, style: tLabel)),
                    Text(
                      e.$3,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ValueDotPainter extends FlDotPainter {
  final double value;
  final Color color;
  final double radius;

  ValueDotPainter({
    required this.value,
    required this.color,
    required this.radius,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    // Vẽ chấm
    final dotPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final strokePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(offsetInCanvas, radius, dotPaint);

    canvas.drawCircle(offsetInCanvas, radius, strokePaint);

    // Hiển thị giá trị
    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toStringAsFixed(2),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout();

    // Đặt số phía trên điểm
    textPainter.paint(
      canvas,
      Offset(
        offsetInCanvas.dx - textPainter.width / 2,
        offsetInCanvas.dy - radius - textPainter.height - 4,
      ),
    );
  }

  @override
  Size getSize(FlSpot spot) {
    return const Size(30, 30);
  }

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    if (a is ValueDotPainter && b is ValueDotPainter) {
      return ValueDotPainter(
        value: a.value + (b.value - a.value) * t,
        color: Color.lerp(a.color, b.color, t)!,
        radius: a.radius + (b.radius - a.radius) * t,
      );
    }

    return this;
  }

  @override
  List<Object?> get props => [value, color, radius];

  @override
  Color get mainColor => color;
}
