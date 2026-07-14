import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/QTTT/QtttViewModel.dart';

class MarketFilterSheet extends StatelessWidget {
  const MarketFilterSheet({super.key, required this.controller});
  final QtttViewModel controller;

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'Bộ lọc',
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FilterTile(
              leading: const Icon(Icons.shield_outlined, size: 20),
              title: 'Mức độ',
              value: controller.marketLevel.value,
              onTap:
                  () => _openPicker(
                    context,
                    title: 'Mức độ',
                    options: controller.levelOptions,
                    getter: () => controller.marketLevel.value,
                    setter: (v) => controller.marketLevel.value = v,
                  ),
            ),
            const SizedBox(height: 8),
            _FilterTile(
              leading: const Icon(Icons.article_outlined, size: 20),
              title: 'Loại thông tin',
              value: controller.marketInfoType.value,
              onTap:
                  () => _openPicker(
                    context,
                    title: 'Loại thông tin',
                    options: controller.infoTypeOptions,
                    getter: () => controller.marketInfoType.value,
                    setter: (v) => controller.marketInfoType.value = v,
                  ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      onReset: controller.resetMarketFilter,
      onApply: () {
        controller.applyMarketFilter();
        Get.back();
      },
    );
  }
}

class ShareFilterSheet extends StatelessWidget {
  const ShareFilterSheet({super.key, required this.controller});
  final QtttViewModel controller;

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'Bộ lọc',
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FilterTile(
              leading: const Icon(Icons.flight_takeoff, size: 20),
              title: 'Sân bay',
              value: controller.shareAirport.value,
              onTap:
                  () => _openPicker(
                    context,
                    title: 'Sân bay',
                    options: controller.airportOptions,
                    getter: () => controller.shareAirport.value,
                    setter: (v) => controller.shareAirport.value = v,
                  ),
            ),
            const SizedBox(height: 8),
            _FilterTile(
              leading: const Icon(Icons.airplane_ticket_outlined, size: 20),
              title: 'Chuyến bay',
              value: controller.shareFlight.value,
              onTap:
                  () => _openPicker(
                    context,
                    title: 'Chuyến bay',
                    options: controller.flightOptions,
                    getter: () => controller.shareFlight.value,
                    setter: (v) => controller.shareFlight.value = v,
                  ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      onReset: controller.resetShareFilter,
      onApply: () {
        controller.applyShareFilter();
        Get.back();
      },
    );
  }
}

// khung bottom sheet + picker con
class _BaseSheet extends StatelessWidget {
  const _BaseSheet({
    required this.title,
    required this.child,
    required this.onReset,
    required this.onApply,
  });

  final String title;
  final Widget child;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final view = MediaQuery.of(context).viewInsets.bottom;
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.only(bottom: view),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              SizedBox(
                height: 48,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Bộ lọc',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Body
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: child,
              ),

              // Footer buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReset,
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Đặt lại'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onApply,
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
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.title,
    required this.value,
    required this.onTap,
    this.leading,
  });
  final String title;
  final String value;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F9FD),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openPicker(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String Function() getter,
  required void Function(String) setter,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => _PickerSheet(
          title: title,
          options: options,
          getter: getter,
          setter: setter,
        ),
  );
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.getter,
    required this.setter,
  });

  final String title;
  final List<String> options;
  final String Function() getter;
  final void Function(String) setter;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.getter();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
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
              // Header with title
              SizedBox(
                height: 48,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Options
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemBuilder: (_, i) {
                    final o = widget.options[i];
                    final selected = o == _selected;
                    final style = TextStyle(
                      color:
                          selected
                              ? const Color(0xFF1F2A37)
                              : const Color(0xFF374151),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    );
                    return InkWell(
                      onTap: () => setState(() => _selected = o),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(child: Text(o, style: style)),
                            if (selected)
                              const Icon(
                                Icons.check,
                                size: 18,
                                color: Color(0xFF1F2A37),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder:
                      (_, __) => const Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                        ), // canh thẳng với text (tuỳ bạn)
                        child: DashedDivider(
                          dash: 6, // độ dài mỗi nét
                          gap: 4, // khoảng trống giữa các nét
                          thickness: 1,
                          color: Color(0xFFE0E6F1), // xám nhạt như thiết kế
                        ),
                      ),
                  itemCount: widget.options.length,
                ),
              ),

              // Footer buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _selected = 'Tất cả'),
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
                          widget.setter(_selected);
                          Navigator.of(context).pop();
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
    );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.color = const Color(0xFFE0E6F1),
    this.dash = 6,
    this.gap = 4,
    this.thickness = 1,
  });

  final Color color;
  final double dash;
  final double gap;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: math.max(thickness, 1),
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color,
          dash: dash,
          gap: gap,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.dash,
    required this.gap,
    required this.thickness,
  });

  final Color color;
  final double dash;
  final double gap;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness;

    final y = size.height / 2;
    double x = 0.0;
    while (x < size.width) {
      final double x2 = (x + dash) > size.width ? size.width : (x + dash);
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) =>
      old.color != color ||
      old.dash != dash ||
      old.gap != gap ||
      old.thickness != thickness;
}
