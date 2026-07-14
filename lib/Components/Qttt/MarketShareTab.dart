import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/QTTT/QtttViewModel.dart';
import 'package:intl/intl.dart' hide TextDirection;

// ===== Formatter dùng chung =====
final NumberFormat _fmtInt = NumberFormat('#,##0', 'vi_VN'); // 1.234
final NumberFormat _fmt2 = NumberFormat('#,##0.##', 'vi_VN'); // 1.234,56
String fmt0(num v) => _fmtInt.format(v);
String fmt2(num v) => _fmt2.format(v);

const Color _bgTab = Color(0xFFF3F6FA); // nền xám rất nhạt
const Color _cardShadow = Color(0x14000000);
const Color _chipBG = Color(0xFFE7EFFB);
const Color _iconBG = Color(0xFFF1F5FB);
const double _radius = 14;

class MarketShareTab extends GetView<QtttViewModel> {
  const MarketShareTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 700;
    final cross = isTablet ? 2 : 1;

    return Container(
      color: _bgTab,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        child: Column(
          children: [
            // ===== Hàng filter: icon tròn + 2 pill =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: _cardShadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // nút mở popup lọc
                  _RoundIcon(onTap: () => controller.openShareFilter(context)),
                  const SizedBox(width: 8),

                  // pill Sân bay: đổi theo Rx
                  Obx(
                    () => _DropdownPill(
                      text:
                          controller.shareAirport.value == 'Tất cả'
                              ? 'Sân bay'
                              : controller.shareAirport.value,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // pill Chuyến bay: đổi theo Rx
                  Obx(
                    () => _DropdownPill(
                      text:
                          controller.shareFlight.value == 'Tất cả'
                              ? 'Chuyến bay'
                              : controller.shareFlight.value,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ===== Lưới card (iPad = 2 cột, mobile = 1 cột) =====
            Obx(() {
              final cards = controller.shareCards;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 400,
                ),
                itemBuilder: (_, i) => _ShareCard(data: cards[i]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/* -------------------- header filter -------------------- */

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F5FB),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap, // ← dùng callback
        child: const SizedBox(
          height: 36,
          width: 36,
          child: Icon(Icons.tune, color: Color(0xFF1F2A37)),
        ),
      ),
    );
  }
}

class _DropdownPill extends StatelessWidget {
  const _DropdownPill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const ShapeDecoration(color: _chipBG, shape: StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Color(0xFF1F2A37),
          ),
        ],
      ),
    );
  }
}

/* -------------------- Card + Chart -------------------- */

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.data});
  final ShareCardData data;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    assert(
      data.segments.length == 2,
      'ShareCardData.segments must be exactly 2',
    );
    final s0 = data.segments[0];
    final s1 = data.segments[1];

    final double total = data.total; // hoặc s0.value + s1.value
    final double p0 = total == 0 ? 0.0 : s0.value / total;
    final double p1 = 1.0 - p0;
    final String totalText = fmt2(total); // ⬅️ format tổng

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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title + tổng (đơn vị) ở góc phải
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2A37),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.tight,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$totalText ${data.unitTopRight}',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2A37),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE6ECF5),
          ), // ─ line 1 ─
          const SizedBox(height: 12),

          // chart ở giữa
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: AnimatedDonutChart(
                segments: [
                  _Seg(percent: p0, color: s0.color),
                  _Seg(percent: p1, color: s1.color),
                ],
                stroke: 75,
                centerText: totalText, // ⬅️ text giữa donut đã format
                showPercents: true, // bật % trên cung
                labelMinPercent: 0.07, // ẩn label nếu phần < 7%
                // labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // dòng dữ liệu 1 (segments[0])
          _ValueRow(
            bulletColor: s0.color,
            label: s0.label,
            value: s0.value,
            unit: s0.unit,
          ),

          const SizedBox(height: 10),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE6ECF5),
          ), // ─ line 2 ─
          const SizedBox(height: 10),

          // dòng dữ liệu 2 (segments[1])
          _ValueRow(
            bulletColor: s1.color,
            label: s1.label,
            value: s1.value,
            unit: s1.unit,
          ),
        ],
      ),
    );
  }
}

// Dòng số liệu (bullet trái, nhãn trái, số liệu phải)
class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.bulletColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  final Color bulletColor;
  final String label;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bulletColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: text.bodyMedium?.copyWith(color: const Color(0xFF1F2A37)),
          ),
        ),
        Text(
          '${fmt2(value)} ', // ⬅️ format double với nghìn + 2 số thập phân
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2A37),
          ),
        ),
        Text(
          unit,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: text.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

// Vạch phân cách dọc (màu như trong thiết kế)
class _VDivider extends StatelessWidget {
  const _VDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: double.infinity,
      color: const Color(0xFFE6ECF5),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

// Dòng số liệu ở cột phải (căn phải, đơn vị xám)
class _RightValueRow extends StatelessWidget {
  const _RightValueRow({required this.value, required this.unit});
  final int value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${fmt0(value)} ', // ⬅️ format int có nghìn
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2A37),
          ),
        ),
        Text(
          unit,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: text.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}
/* -------------------- Donut (CustomPaint) -------------------- */

class _Seg {
  final double percent; // 0..1
  final Color color;
  const _Seg({required this.percent, required this.color});
}

/// Donut chart có animation vẽ từ 0% -> 100%
/// - Tự chạy mỗi khi `segments` thay đổi (ví dụ load API xong)
class AnimatedDonutChart extends StatefulWidget {
  const AnimatedDonutChart({
    super.key,
    required this.segments,
    required this.stroke,
    required this.centerText,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.showPercents = true,
    this.labelMinPercent = .07, // <7% thì ẩn để đỡ chồng chéo
    this.labelStyle,
  });

  final List<_Seg> segments;
  final double stroke;
  final String centerText;
  final Duration duration;
  final Curve curve;

  // --- % labels ---
  final bool showPercents;
  final double labelMinPercent;
  final TextStyle? labelStyle;

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late Animation<double> _a;
  late String _sig;

  String _signature(List<_Seg> s) => s
      .map((e) => '${e.percent.toStringAsFixed(6)}-${e.color.value}')
      .join('|');

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
      _c
        ..reset()
        ..forward();
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
                    constraints: BoxConstraints(
                      maxWidth: inner,
                      maxHeight: inner,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // tự co cho vừa "inner"
                      child: Text(
                        widget.centerText,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13, // cỡ "gốc", sẽ co lại nếu vượt giới hạn
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
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
  final double progress; // 0..1
  final bool showPercents;
  final double labelMinPercent;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - stroke / 2;

    // vòng nền
    final base =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = const Color(0xFFE6ECF5);
    canvas.drawCircle(center, r, base);

    // vẽ cung + label
    double start = -math.pi / 2;
    for (final s in segments) {
      final fullSweep = s.percent.clamp(0.0, 1.0) * 2 * math.pi;
      final sweep = fullSweep * progress;

      if (sweep > 0) {
        final p =
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = stroke
              ..strokeCap = StrokeCap.butt
              ..color = s.color;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: r),
          start,
          sweep,
          false,
          p,
        );
      }

      // Label % (hiển thị khi phần cung đủ lớn)
      if (showPercents && s.percent >= labelMinPercent && progress > 0) {
        final percentText = '${(s.percent * 100).round()}%';
        final midAngle = start + fullSweep / 2; // đặt theo cung thực tế
        final radiusForText = r; // ngay giữa vành
        final offset =
            center +
            Offset(math.cos(midAngle), math.sin(midAngle)) * radiusForText;

        final tp = TextPainter(
          text: TextSpan(
            text: percentText,
            style:
                labelStyle ??
                const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black26)],
                ),
          ),
          textDirection: TextDirection.ltr, // ⬅️ đúng kiểu
        )..layout();

        final drawAt = offset - Offset(tp.width / 2, tp.height / 2);
        tp.paint(canvas, drawAt);
      }

      // tăng start theo sweep đầy đủ để giữ vị trí ổn định trong suốt animation
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
/* -------------------- Legend dòng -------------------- */

class _LegendLine extends StatelessWidget {
  const _LegendLine({
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
  });

  final Color color;
  final String label;
  final int value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // bullet màu
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),

        // nhãn bên trái
        Text(
          label,
          style: text.bodyMedium?.copyWith(color: const Color(0xFF1F2A37)),
        ),

        // —— gạch phân cách (liền, mảnh) giữa nhãn và số liệu ——
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            height: 1,
            color: const Color(0xFFE6ECF5),
          ),
        ),

        // số liệu bên phải
        Text(
          '${fmt0(value)} ', // có nghìn
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2A37),
          ),
        ),
        Text(
          unit,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: text.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

// --- Đường leader dạng chấm (… … …) ---
class _LeaderDivider extends StatelessWidget {
  const _LeaderDivider({
    this.color = const Color(0xFFE6ECF5),
    this.dash = 4,
    this.gap = 4,
  });
  final Color color;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _LeaderPainter(color: color, dash: dash, gap: gap),
    );
  }
}

class _LeaderPainter extends CustomPainter {
  _LeaderPainter({required this.color, required this.dash, required this.gap});
  final Color color;
  final double dash, gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;

    double x = 0;
    while (x < size.width) {
      final double x2 = ((x + dash).clamp(0.0, size.width)).toDouble();
      canvas.drawLine(Offset(x, 0), Offset(x2, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _LeaderPainter old) =>
      old.color != color || old.dash != dash || old.gap != gap;
}
