import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skypec/Controller/QTTT/QtttViewModel.dart';

class QtttCard extends StatelessWidget {
  const QtttCard({
    super.key,
    required this.title,
    required this.leftLabel,
    required this.leftValue,
    required this.cardInfo,
    this.rightLabel,
    this.rightValue,
    this.onBoxTap,
    this.onEyeTap,
    this.accentLeft = const Color(0xFF22C55E), // xanh lá nhạt
    this.accentRight = const Color(0xFF22C55E), // giống hình: cả 2 ô viền xanh
    this.headerColor = const Color(0xFF006C98), // xanh header
  });

  final String title;
  final String leftLabel;
  final String leftValue;
  final String? rightLabel;
  final String? rightValue;
  final KpiItem? cardInfo;

  final VoidCallback? onBoxTap;
  final VoidCallback? onEyeTap;

  final Color accentLeft;
  final Color accentRight;
  final Color headerColor;

  @override
  Widget build(BuildContext context) {
    final hasRight = rightLabel != null && rightValue != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---------- HEADER ----------
            Container(
              height: 44,
              color: headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // nút vàng (placeholder)
                  if (cardInfo!.id == 2 || cardInfo!.id == 3)
                    _CircleIcon(
                      bg: const Color(0xFFF5C443),
                      icon: Icons.inventory_2_outlined,
                      iconColor: Colors.white,
                      onTap: onBoxTap,
                    ),
                  const SizedBox(width: 8),
                  // nút con mắt trắng
                  _CircleIcon(
                    bg: Colors.white,
                    icon: Icons.visibility_outlined,
                    iconColor: headerColor,
                    onTap: onEyeTap,
                  ),
                ],
              ),
            ),

            // ---------- BODY ----------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _ValueCellFancy(
                      label: leftLabel,
                      value: leftValue,
                      accent: accentLeft,
                    ),
                  ),
                  if (hasRight) const SizedBox(width: 10),
                  if (hasRight)
                    Expanded(
                      child: _ValueCellFancy(
                        label: rightLabel!,
                        value: rightValue!,
                        accent: accentRight,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nút tròn nhỏ trên header
class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.bg,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  final Color bg;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 28,
          width: 28,
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }
}

// Ô giá trị với VIỀN GRADIENT mờ dần (đậm trên -> mờ dưới)
class _ValueCellFancy extends StatelessWidget {
  const _ValueCellFancy({
    required this.label,
    required this.value,
    required this.accent,
    this.height = 84,
  });

  final String label;
  final String value;
  final Color accent;
  final double height;

  @override
  Widget build(BuildContext context) {
    const r = 12.0;
    return CustomPaint(
      // ❗ vẽ TRÊN child để không bị che
      foregroundPainter: _FadeBorderPainter(
        color: accent,
        radius: r,
        strokeWidth: 2.4, // dày hơn cho dễ thấy
        topOpacity: 0.85, // trên đậm
        midOpacity: 0.30, // giữa mờ
        bottomOpacity: 0.0, // dưới trong suốt
        midStop: 0.40,
      ),
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeBorderPainter extends CustomPainter {
  _FadeBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    this.topOpacity = .85,
    this.midOpacity = .30,
    this.bottomOpacity = 0.0,
    this.midStop = .40,
  });

  final Color color;
  final double radius, strokeWidth;
  final double topOpacity, midOpacity, bottomOpacity, midStop;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // vẽ NỘI biên để không bị cắt
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(topOpacity),
        color.withOpacity(midOpacity),
        color.withOpacity(bottomOpacity),
      ],
      stops: [0.0, midStop, 1.0],
    ).createShader(rect);

    final paint =
        Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..shader = shader;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _FadeBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.topOpacity != topOpacity ||
      old.midOpacity != midOpacity ||
      old.bottomOpacity != bottomOpacity ||
      old.midStop != midStop;
}
