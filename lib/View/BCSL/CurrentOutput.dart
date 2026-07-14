import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/BCSL/CurrentOutputViewModel.dart';

const List<Color> _donutColors = [
  Color(0xFFF87171),
  Color(0xFF34D399),
  Color(0xFFF59E0B),
  Color(0xFF8B5CF6),
  Color(0xFF60A5FA),
  Color(0xFF22C5BB),
  Color(0xFFEC4899),
  Color(0xFF94A3B8),
];

class CurrentOutput extends GetView<CurrentOutputViewModel> {
  const CurrentOutput({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = controller;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Chi tiết sản lượng'),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [Color(0xFF2B71C9), Color(0xFF2E8AC7)],
        //       begin: Alignment.topCenter,
        //       end: Alignment.bottomCenter,
        //     ),
        //   ),
        // ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/images/background_inside.png', // ảnh của bạn
              fit: BoxFit.fill, // giữ tỉ lệ, không méo
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: DefaultTabController(
              length: 2,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _StatsCard(vm: vm),
                  const SizedBox(height: 12),
                  _Tabs(vm: vm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.vm});
  final CurrentOutputViewModel vm;

  @override
  Widget build(BuildContext context) {
    Widget row(
      IconData icon,
      Color bg,
      String title,
      String value, [
      String? sub,
    ]) => Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (sub != null)
                Text(
                  sub,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return Container(
      decoration: _cardDeco,
      child: Column(
        children: [
          // header
          Obx(() {
            final expanded = vm.statsExpanded.value;
            return InkWell(
              onTap: () => vm.statsExpanded.toggle(),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Thống kê sản lượng',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Divider(height: 1),
          // body
          Obx(
            () =>
                vm.statsExpanded.value
                    ? Column(
                      children: [
                        row(
                          Icons.all_inbox,
                          const Color(0xFF10B981),
                          'Tổng sản lượng',
                          vm.fmt(vm.tongSanLuong.value),
                        ),
                        const Divider(height: 1),
                        row(
                          Icons.task_alt,
                          const Color(0xFF3B82F6),
                          'Sản lượng thực hiện',
                          vm.fmt(vm.sanLuongUocTh.value),
                          'So với kế hoạch tháng',
                        ),
                        const Divider(height: 1),
                        row(
                          Icons.calendar_month,
                          const Color(0xFF06B6D4),
                          '% Sản lượng tháng trước',
                          vm.pct(vm.pctThangTruoc.value),
                          vm.fmt(vm.sanLuongThangTruoc.value),
                        ),
                        const Divider(height: 1),
                        row(
                          Icons.history_toggle_off,
                          const Color(0xFFF59E0B),
                          '% Sản lượng cùng kỳ',
                          vm.pct(vm.pctCungKy.value),
                          vm.fmt(vm.sanLuongCungKy.value),
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/* ---------------- TABS ---------------- */

class _Tabs extends StatelessWidget {
  const _Tabs({required this.vm});
  final CurrentOutputViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDeco,
      child: Column(
        children: [
          TabBar(
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF2563EB),
            tabs: const [Tab(text: 'Sản lượng bán'), Tab(text: 'Cơ cấu bán')],
            onTap: (i) => vm.tabIndex.value = i,
          ),
          const Divider(height: 1),
          SizedBox(
            // ~70% chiều cao màn hình, tránh overflow trên nhiều máy
            height: MediaQuery.of(context).size.height * 0.7,
            child: TabBarView(
              children: [_TabSales(vm: vm), _TabStructure(vm: vm)],
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- TAB 1: Sản lượng bán ---------------- */

class _TabSales extends StatelessWidget {
  const _TabSales({required this.vm});
  final CurrentOutputViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Row(
              children: [
                _seg('Tấn', 0, vm.unitIndex),
                const SizedBox(width: 8),
                _seg('M3', 1, vm.unitIndex),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(child: _BarChart(vm: vm)),
          const SizedBox(height: 8),
          // legend with eye
          Obx(
            () => Column(
              children: [
                _legendRow(const Color(0xFF22C5BB), 'Thực tế', vm.showThucTe),
                _legendRow(const Color(0xFFF59E0B), 'Kế hoạch', vm.showKeHoach),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seg(String label, int i, RxInt rx) => ChoiceChip(
    label: Text(label),
    selected: rx.value == i,
    selectedColor: const Color(0xFF2563EB),
    labelStyle: TextStyle(
      fontWeight: FontWeight.w700,
      color: rx.value == i ? Colors.white : const Color(0xFF1F2A37),
    ),
    backgroundColor: const Color(0xFFF3F4F6),
    showCheckmark: false,
    shape: const StadiumBorder(),
    onSelected: (_) => rx.value = i,
  );

  Widget _legendRow(Color c, String label, RxBool rx) => Container(
    height: 40,
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Color(0xFFE5EAF2), width: 1)),
    ),
    child: Row(
      children: [
        const SizedBox(width: 8),
        _Dot(color: c),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        IconButton(
          onPressed: rx.toggle,
          icon: Icon(
            rx.value ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    ),
  );
}

class _BarChart extends StatefulWidget {
  const _BarChart({required this.vm});
  final CurrentOutputViewModel vm;

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart> {
  double t = 0; // 0..1 for first load animation

  @override
  void initState() {
    super.initState();
    // animate once after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 60), () async {
        for (int i = 0; i <= 20; i++) {
          await Future.delayed(const Duration(milliseconds: 16));
          if (!mounted) return;
          setState(() => t = i / 20);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return Obx(() {
      final unit = vm.unitIndex.value;
      final showA = vm.showThucTe.value;
      final showB = vm.showKeHoach.value;

      final a = unit == 0 ? vm.thucTeTan : vm.thucTeM3;
      final b = unit == 0 ? vm.keHoachTan : vm.keHoachM3;
      final labels = vm.labelDays;

      final rodsA = showA;
      final rodsB = showB;

      final groups = <BarChartGroupData>[];
      for (int i = 0; i < labels.length; i++) {
        final rods = <BarChartRodData>[];
        if (rodsA) {
          rods.add(
            BarChartRodData(
              toY: (i < a.length ? a[i] : 0) * t,
              width: 5,
              color: const Color(0xFF22C5BB),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          );
        }
        if (rodsB) {
          rods.add(
            BarChartRodData(
              toY: (i < b.length ? b[i] : 0) * t,
              width: 5,
              color: const Color(0xFFF59E0B),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          );
        }
        groups.add(BarChartGroupData(x: i + 1, barRods: rods));
      }

      return BarChart(
        BarChartData(
          maxY: vm.maxYBar,
          minY: 0,
          barGroups: groups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingVerticalLine:
                (_) =>
                    const FlLine(color: Color(0xFFE6ECF5), dashArray: [4, 4]),
            getDrawingHorizontalLine:
                (_) => const FlLine(color: Color(0xFFE6ECF5), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 46,
                showTitles: true,
                getTitlesWidget:
                    (v, _) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(fontSize: 11),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt() - 1;
                  return Text(
                    idx >= 0 && idx < labels.length
                        ? labels[idx].split('/')[0]
                        : '',
                    style: const TextStyle(fontSize: 10),
                  );
                },
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
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (g, gi, r, ri) {
                final idx = g.x - 1;
                final header =
                    idx >= 0 && idx < labels.length ? labels[idx] : '';
                final isA = r.color == const Color(0xFF22C5BB);
                final label = isA ? 'Thực tế' : 'Kế hoạch';
                final value = r.toY;
                return BarTooltipItem(
                  '$header\n',
                  const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '$label: ${value.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                );
              },
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              tooltipBorderRadius: BorderRadius.circular(10),
              tooltipBorder: const BorderSide(
                color: Color(0x22000000),
                width: 0.5,
              ),
              tooltipMargin: 6,
            ),
          ),
        ),
      );
    });
  }
}

/* ---------------- TAB 2: Cơ cấu bán ---------------- */

class _TabStructure extends StatelessWidget {
  const _TabStructure({required this.vm});
  final CurrentOutputViewModel vm;

  String _fmt(num v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Obx(() {
        final idx = vm.ccIndex.value;
        final labels = idx == 0 ? vm.khuVucLabel : vm.changBayLabel;
        final values = idx == 0 ? vm.khuVucData : vm.changBayData;
        final total = idx == 0 ? vm.khuVucSum : vm.changBaySum;

        // ⚠️ Bọc cuộn để tránh overflow
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _seg('Khu vực', 0, vm.ccIndex),
                  const SizedBox(width: 8),
                  _seg('Chặng bay', 1, vm.ccIndex),
                ],
              ),
              const SizedBox(height: 12),

              // Cố định cao 320 để 2 chart đứng cùng vị trí và không đè ghi chú
              SizedBox(
                height: 320,
                child: Center(
                  child: _DonutFanOut(
                    key: ValueKey(
                      '${labels.join("|")}-$total',
                    ), // restart anim khi đổi data
                    labels: labels,
                    values: values,
                    total: total,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              _legendList(labels, values),
            ],
          ),
        );
      }),
    );
  }

  Widget _seg(String label, int i, RxInt rx) => ChoiceChip(
    label: Text(label),
    selected: rx.value == i,
    selectedColor: const Color(0xFF2563EB),
    labelStyle: TextStyle(
      fontWeight: FontWeight.w700,
      color: rx.value == i ? Colors.white : const Color(0xFF1F2A37),
    ),
    backgroundColor: const Color(0xFFF3F4F6),
    showCheckmark: false,
    shape: const StadiumBorder(),
    onSelected: (_) => rx.value = i,
  );

  // Ghi chú dưới chart
  Widget _legendList(List<String> labels, List<double> values) {
    final n = min(labels.length, values.length);
    return Column(
      children: List.generate(n, (i) {
        return Container(
          height: 44,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE5EAF2), width: 1)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              _Dot(color: _donutColors[i % _donutColors.length]),
              const SizedBox(width: 8),
              Expanded(child: Text(labels[i])),
              Text(
                '${_fmt(values[i])} Tấn',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 12),
            ],
          ),
        );
      }),
    );
  }
}

/* ---------------- Donut + fan-out + tooltip ---------------- */

class _DonutFanOut extends StatefulWidget {
  const _DonutFanOut({
    super.key, // để dùng ValueKey(...) khi đổi chart
    required this.labels,
    required this.values,
    required this.total,
    this.height = 320,
  });

  final List<String> labels;
  final List<dynamic> values; // nhận int/double đều OK
  final double total;
  final double height;

  @override
  State<_DonutFanOut> createState() => _DonutFanOutState();
}

class _DonutFanOutState extends State<_DonutFanOut> {
  int? _touchedRawIndex;
  bool _showTip = false;
  Offset _pos = Offset.zero;
  double _t = 0;

  static const _colors = [
    Color(0xFFF87171),
    Color(0xFF34D399),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF60A5FA),
    Color(0xFF22C5BB),
    Color(0xFFEC4899),
    Color(0xFF94A3B8),
  ];

  @override
  void initState() {
    super.initState();
    _playFanOut();
  }

  @override
  void didUpdateWidget(covariant _DonutFanOut oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mỗi lần đổi chart/dữ liệu: reset tương tác & chạy lại animate
    _touchedRawIndex = null;
    _showTip = false;
    _t = 0;
    _playFanOut();
  }

  Future<void> _playFanOut() async {
    for (int i = 0; i <= 22; i++) {
      if (!mounted) return;
      setState(() => _t = i / 22);
      await Future.delayed(const Duration(milliseconds: 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels;
    // Ép kiểu an toàn: int/double/num -> double
    final values =
        widget.values
            .map<double>(
              (e) => (e is num) ? e.toDouble() : (double.tryParse('$e') ?? 0.0),
            )
            .toList();

    final sum = values.fold<double>(0, (p, e) => p + e);
    final target = sum * _t;

    double cum = 0;
    final sections = <PieChartSectionData>[];
    final secToRawIndex = <int>[]; // map sectionIndex -> rawIndex

    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      final visible = (target - cum).clamp(0.0, v); // luôn là double
      cum += v;
      if (visible <= 0) continue;

      final isTouched = (i == _touchedRawIndex);
      sections.add(
        PieChartSectionData(
          value: visible,
          color: _colors[i % _colors.length],
          title: sum > 0 ? '${(v / sum * 100).toStringAsFixed(1)}%' : '0%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          radius: isTouched ? 88 : 70,
        ),
      );
      secToRawIndex.add(i);
    }

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (_, c) {
          return Stack(
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 58,
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (evt, res) {
                      final ti = res?.touchedSection?.touchedSectionIndex ?? -1;
                      final pos = evt.localPosition;
                      if (!evt.isInterestedForInteractions ||
                          ti < 0 ||
                          ti >= secToRawIndex.length ||
                          pos == null) {
                        setState(() {
                          _touchedRawIndex = null;
                          _showTip = false;
                        });
                        return;
                      }
                      final rawIdx = secToRawIndex[ti];
                      if (rawIdx < 0 ||
                          rawIdx >= labels.length ||
                          rawIdx >= values.length) {
                        setState(() {
                          _touchedRawIndex = null;
                          _showTip = false;
                        });
                        return;
                      }
                      setState(() {
                        _touchedRawIndex = rawIdx;
                        _pos = pos;
                        _showTip = true;
                      });

                      if (evt is FlPanEndEvent ||
                          evt is FlTapUpEvent ||
                          evt is FlPointerExitEvent ||
                          evt is FlLongPressEnd) {
                        setState(() => _showTip = false);
                      }
                    },
                  ),
                ),
                swapAnimationDuration: Duration.zero, // tránh chồng animate
              ),

              // Tổng ở giữa (giữ số nguyên, không giật)
              Positioned.fill(
                child: Center(
                  child: Text(
                    _fmtInt(widget.total),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),

              // Tooltip
              if (_showTip && _touchedRawIndex != null)
                Positioned(
                  left: _clampX(_pos.dx, c.maxWidth, 180),
                  top: _clampY(_pos.dy, c.maxHeight, 72, 8),
                  child: _WhiteTooltip(
                    title: labels[_touchedRawIndex!],
                    value:
                        '${_fmtThousand(values[_touchedRawIndex!])} Tấn · '
                        '${sum > 0 ? (values[_touchedRawIndex!] / sum * 100).toStringAsFixed(1) : '0'}%',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Helpers
  double _clampX(double x, double maxW, double w) {
    final left = x - w / 2;
    return left.clamp(4.0, (maxW - w - 4).clamp(4.0, maxW));
  }

  double _clampY(double y, double maxH, double h, double gap) {
    final top = y - h - gap;
    if (top >= 4) return top;
    final bottom = y + gap;
    return (maxH - h - 4).clamp(bottom, maxH - h - 4);
  }

  String _fmtInt(double v) => (v / 1e3).round().toString(); // ví dụ "8000"
  String _fmtThousand(num v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
}

/* ---------------- small ---------------- */

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

final _cardDeco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
  ],
);

class _WhiteTooltip extends StatelessWidget {
  const _WhiteTooltip({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Container(
      width: 180,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
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
              ),
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ),
  );
}
