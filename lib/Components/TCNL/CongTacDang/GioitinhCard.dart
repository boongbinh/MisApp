import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GioiTinhData {
  final String label;
  final double value;
  final Color color;
  GioiTinhData({required this.label, required this.value, required this.color});
}

String _fmt2(num v) => NumberFormat('#,##0.##', 'vi_VN').format(v);

class GioiTinhCard extends StatelessWidget {
  const GioiTinhCard({
    super.key,
    required this.dataList, // bắt buộc
    this.title = 'GIỚI TÍNH',
    this.strokeWidth = 70,
    this.showPercents = true,
  });

  final List<GioiTinhData> dataList;
  final String title;
  final double strokeWidth;
  final bool showPercents;

  @override
  Widget build(BuildContext context) {
    if (dataList.isEmpty) return const SizedBox.shrink();

    final total = dataList.fold(0.0, (sum, item) => sum + item.value);
    final segments = dataList.map((e) {
      final percent = total == 0 ? 0.0 : e.value / total;
      return _Seg(percent: percent, color: e.color);
    }).toList();
    final totalText = _fmt2(total);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1F2A37),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE6ECF5)),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: AnimatedDonutChart(
                segments: segments,
                stroke: strokeWidth,
                centerText: totalText,
                showPercents: showPercents,
                labelMinPercent: 0.05,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...dataList.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LegendRow(
                  color: item.color,
                  label: item.label,
                  value: item.value,
                ),
              )),
        ],
      ),
    );
  }
}

// ========== Donut Chart Classes (giữ nguyên) ==========
class _Seg {
  final double percent;
  final Color color;
  const _Seg({required this.percent, required this.color});
}

class AnimatedDonutChart extends StatefulWidget {
  const AnimatedDonutChart({
    super.key,
    required this.segments,
    required this.stroke,
    required this.centerText,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.showPercents = true,
    this.labelMinPercent = 0.07,
    this.labelStyle,
  });

  final List<_Seg> segments;
  final double stroke;
  final String centerText;
  final Duration duration;
  final Curve curve;
  final bool showPercents;
  final double labelMinPercent;
  final TextStyle? labelStyle;

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  late String _sig;

  String _signature(List<_Seg> s) => s.map((e) => '${e.percent.toStringAsFixed(6)}-${e.color.value}').join('|');

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _a = CurvedAnimation(parent: _c, curve: widget.curve);
    _sig = _signature(widget.segments);
    _c.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final sig = _signature(widget.segments);
    if (sig != _sig) {
      _sig = sig;
      _c..reset()..forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) {
        return CustomPaint(
          painter: _DonutPainter(
            segments: widget.segments,
            stroke: widget.stroke,
            progress: _a.value,
            showPercents: widget.showPercents,
            labelMinPercent: widget.labelMinPercent,
            labelStyle: widget.labelStyle,
          ),
          child: Center(
            child: LayoutBuilder(
              builder: (_, c) {
                final size = math.min(c.maxWidth, c.maxHeight);
                final inner = size - widget.stroke - 26;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: inner, maxHeight: inner),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.centerText,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.stroke,
    required this.progress,
    required this.showPercents,
    required this.labelMinPercent,
    this.labelStyle,
  });

  final List<_Seg> segments;
  final double stroke;
  final double progress;
  final bool showPercents;
  final double labelMinPercent;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - stroke / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFE6ECF5);
    canvas.drawCircle(center, r, basePaint);

    double start = -math.pi / 2;
    for (final s in segments) {
      final fullSweep = s.percent.clamp(0.0, 1.0) * 2 * math.pi;
      final sweep = fullSweep * progress;

      if (sweep > 0) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt
          ..color = s.color;
        canvas.drawArc(Rect.fromCircle(center: center, radius: r), start, sweep, false, paint);
      }

      if (showPercents && s.percent >= labelMinPercent && progress > 0) {
        final percentText = '${(s.percent * 100).round()}%';
        final midAngle = start + fullSweep / 2;
        final radiusForText = r;
        final offset = center + Offset(math.cos(midAngle), math.sin(midAngle)) * radiusForText;

        final tp = TextPainter(
          text: TextSpan(
            text: percentText,
            style: labelStyle ??
                const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black26)],
                ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();

        final drawAt = offset - Offset(tp.width / 2, tp.height / 2);
        tp.paint(canvas, drawAt);
      }

      start += fullSweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.segments != segments ||
      old.stroke != stroke ||
      old.progress != progress ||
      old.showPercents != showPercents ||
      old.labelMinPercent != labelMinPercent ||
      old.labelStyle != labelStyle;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2A37)))),
        Text(_fmt2(value), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1F2A37))),
        const SizedBox(width: 4),
      ],
    );
  }
}