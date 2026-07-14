import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:skypec/Controller/QTTC/ChangeCostViewModel.dart';

class ChangeCost extends GetView<ChangeCostViewModel> {
  const ChangeCost({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi phí biến đổi'),
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
      body: Obx(() {
        if (vm.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.error.isNotEmpty) {
          return Center(
            child: Text(vm.error.value, textAlign: TextAlign.center),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TabsChips(vm: vm),
              const SizedBox(height: 12),
              // nội dung theo tab
              switch (vm.tab.value) {
                0 => _TabTongQuan(vm: vm),
                1 => _TabTheoThang(vm: vm),
                2 => _TabDuongThuy(vm: vm),
                _ => _TabDuongBo(vm: vm),
              },
            ],
          ),
        );
      }),
    );
  }
}

/* ---------------- Tabs ---------------- */

class _TabsChips extends StatelessWidget {
  const _TabsChips({required this.vm});
  final ChangeCostViewModel vm;

  ChoiceChip _chip(String label, int idx) {
    final selected = vm.tab.value == idx;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,

      shape: const StadiumBorder(side: BorderSide(color: Color(0xFFE6ECF5))),
      labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? Colors.white : const Color(0xFF1F2A37),
      ),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF3568DB),

      onSelected: (_) => vm.switchTab(idx),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _chip('Tổng quan', 0),
          _chip('Chi phí theo tháng', 1),
          _chip('Sản lượng đường thủy', 2),
          _chip('Sản lượng đường bộ', 3),
        ],
      ),
    );
  }
}

/* ---------------- Tab 0: Tổng quan ---------------- */

class _TabTongQuan extends StatelessWidget {
  const _TabTongQuan({required this.vm});
  final ChangeCostViewModel vm;

  @override
  Widget build(BuildContext context) {
    final totalForDonut =
        (vm.sumTotal.value > 0 ? vm.sumTotal.value : vm.totalBD.value);

    return Column(
      children: [
        // ✅ Box thống kê thêm vào đây
        _Card(title: 'Thống kê chi phí biến đổi', child: _SummaryBox(vm: vm)),
        const SizedBox(height: 12),

        // ✅ Biểu đồ
        _Card(
          title: 'Biểu đồ chi phí biến đổi',

          // child: _DonutFanOut(
          //   restartKey: ValueKey(vm.tqItems.map((e) => e.value).join(',')),
          //   totalVnd: totalForDonut,
          //   raw: [
          //     for (int i = 0; i < vm.tqItems.length; i++)
          //       _Slice(
          //         value: vm.tqItems[i].value,
          //         name: vm.tqItems[i].name,
          //         percent: vm.tqItems[i].percent,
          //         color: _palette[i % _palette.length],
          //       ),
          //   ],
          // ),
          child: _CostTreemap(
            items: [
              for (int i = 0; i < vm.tqItems.length; i++)
                _Slice(
                  value: vm.tqItems[i].value,
                  name: vm.tqItems[i].name,
                  percent: vm.tqItems[i].percent,
                  color: _palette[i % _palette.length],
                ),
            ],
            totalVnd:
                (vm.sumTotal.value > 0 ? vm.sumTotal.value : vm.totalBD.value),
          ),
        ),
        const SizedBox(height: 12),

        _Card(
          title: 'Chi tiết',
          child: Column(
            children: [
              for (int i = 0; i < vm.tqItems.length; i++) ...[
                _BreakdownRow(
                  item: vm.tqItems[i],
                  vm: vm,
                  color: _palette[i % _palette.length],
                ),
                if (i != vm.tqItems.length - 1)
                  const Divider(height: 1, color: Color(0xFFE6ECF5)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Slice {
  final String name; // ⬅️ tên tiêu chí (VD: TenLoaiChiPhi)
  final double value; // VND
  final double percent; // %
  final Color color;

  const _Slice({
    required this.name,
    required this.value,
    required this.percent,
    required this.color,
  });

  String get percentLabel => '${percent.toStringAsFixed(1)}%';
}

class _DonutFanOut extends StatefulWidget {
  const _DonutFanOut({
    required this.raw,
    required this.totalVnd,
    this.restartKey,
    this.radius = 100,
  });

  final List<_Slice> raw;
  final double totalVnd; // tổng VND (để hiển thị giữa vòng)
  final Key? restartKey;
  final double radius;

  @override
  State<_DonutFanOut> createState() => _DonutFanOutState();
}

class _DonutFanOutState extends State<_DonutFanOut> {
  int? _touched;
  bool _showTip = false;
  Offset _pos = Offset.zero;

  String _fmtTy(num vnd) {
    final ty = (vnd / 1e9).round();
    final s = ty.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final ri = s.length - 1 - i;
      buf.write(s[ri]);
      if (i % 3 == 2 && ri != 0) buf.write('.');
    }
    return buf.toString().split('').reversed.join();
  }

  double _clampX(double x, double maxW, double boxW) {
    final left = x - boxW / 2;
    return left.clamp(4.0, (maxW - boxW - 4).clamp(4.0, maxW));
  }

  double _clampY(double y, double chartH, double boxH, double gap) {
    final top = y - boxH - gap;
    if (top >= 4) return top;
    final bottom = y + gap;
    return (chartH - boxH - 4).clamp(bottom, chartH - boxH - 4);
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.raw;

    // khi data đổi (restartKey khác), TweenAnimationBuilder sẽ reset về 0 -> 1
    return SizedBox(
      height: 400,
      child: TweenAnimationBuilder<double>(
        key: widget.restartKey,
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, t, __) {
          final total = raw.fold<double>(0, (p, e) => p + e.value);
          final target = total * t;
          double cum = 0;

          final sections = <PieChartSectionData>[];
          for (int i = 0; i < raw.length; i++) {
            final s = raw[i];
            final left = (target - cum);
            final visible = left.clamp(0, s.value).toDouble();
            cum += s.value;

            if (visible <= 0) continue;

            final isTouched = (i == _touched);
            sections.add(
              PieChartSectionData(
                value: visible,
                radius: isTouched ? widget.radius + 8 : widget.radius,
                color: s.color,
                showTitle: true,
                title: s.percentLabel,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          final totalShow = lerpDouble(0, widget.totalVnd, t)!;

          return LayoutBuilder(
            builder:
                (_, c) => Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60, // giữ “donut” đều
                        sections: sections,
                        pieTouchData: PieTouchData(
                          enabled: true,
                          touchCallback: (evt, resp) {
                            if (!evt.isInterestedForInteractions ||
                                resp == null ||
                                resp.touchedSection == null ||
                                evt.localPosition == null) {
                              setState(() {
                                _touched = null;
                                _showTip = false;
                              });
                              return;
                            }
                            final touchedInSections =
                                resp.touchedSection!.touchedSectionIndex;

                            final mapIdx = <int, int>{};
                            double cum2 = 0;
                            int secCounter = 0;
                            for (int i = 0; i < raw.length; i++) {
                              final s = raw[i];
                              final left2 = (total * t - cum2);
                              final vis2 = left2.clamp(0, s.value).toDouble();
                              cum2 += s.value;
                              if (vis2 > 0) {
                                mapIdx[secCounter] =
                                    i; // section thứ secCounter đến từ raw[i]
                                secCounter++;
                              }
                            }

                            final rawIdx = mapIdx[touchedInSections];
                            if (rawIdx == null) {
                              setState(() {
                                _touched = null;
                                _showTip = false;
                              });
                              return;
                            }

                            setState(() {
                              _touched = rawIdx;
                              _pos = evt.localPosition!;
                              _showTip = true;
                            });

                            if (evt is FlTapUpEvent ||
                                evt is FlPointerExitEvent) {}
                          },
                        ),
                      ),
                      swapAnimationDuration: Duration.zero,
                      swapAnimationCurve: Curves.linear,
                    ),

                    // tổng ở giữa
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '${_fmtTy(totalShow)} Tỷ',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),

                    if (_showTip && _touched != null && _touched! < raw.length)
                      Positioned(
                        left: _clampX(_pos.dx, c.maxWidth, 200),
                        top: _clampY(_pos.dy, 320, 86, 8),
                        child: _WhiteTooltip(
                          title:
                              raw[_touched!]
                                  .name, // nếu _Slice dùng `name`, đổi thành `.name`
                          value:
                              '${_fmtTy(raw[_touched!].value)} Tỷ • ${raw[_touched!].percentLabel}',
                        ),
                      ),
                  ],
                ),
          );
        },
      ),
    );
  }
}

/* ---------- Tooltip nền trắng + bo góc + shadow ---------- */

class _WhiteTooltip extends StatelessWidget {
  const _WhiteTooltip({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 200,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F7BD8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
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

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({required this.vm});
  final ChangeCostViewModel vm;

  @override
  Widget build(BuildContext context) {
    final up = vm.deltaPct.value >= 0;
    final chipBg = up ? const Color(0x1427AE60) : const Color(0x14EF4444);
    final chipFg = up ? const Color(0xFF27AE60) : const Color(0xFFEF4444);
    final chipIcon = up ? Icons.trending_up : Icons.trending_down;

    Widget row(String label, Widget trailing) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          trailing,
        ],
      ),
    );

    return Column(
      children: [
        row(
          'Tổng (VND):',
          Text(
            vm.fmt(vm.sumTotal.value),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),

        row(
          'Tăng/giảm so với tháng trước:',
          Text(
            vm.fmt(vm.deltaAbs.value),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        row(
          'So sánh % tháng trước :',
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: ShapeDecoration(
              color: chipBg,
              shape: const StadiumBorder(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(chipIcon, size: 14, color: chipFg),
                const SizedBox(width: 4),
                Text(
                  '${vm.deltaPct.value.toStringAsFixed(2)}%',
                  style: TextStyle(color: chipFg, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),

        row(
          'Phí tra nạp (VND):',
          Text(
            vm.fmt(vm.refuelFee.value),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.item,
    required this.vm,
    required this.color,
  });
  final CCItem item;
  final ChangeCostViewModel vm;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final up = item.up;
    final bg = up ? const Color(0x1427AE60) : const Color(0x14EF4444);
    final fg = up ? const Color(0xFF27AE60) : const Color(0xFFEF4444);
    final icon = up ? Icons.trending_up : Icons.trending_down;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              _Dot(color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                vm.fmt(item.value),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Số tiền (VND) :',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'So sánh % tháng trước :',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: bg,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: fg),
                    const SizedBox(width: 4),
                    Text(
                      item.deltaLabel,
                      style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ---------------- Tab 1: Theo tháng ---------------- */

class _TabTheoThang extends StatelessWidget {
  const _TabTheoThang({required this.vm});
  final ChangeCostViewModel vm;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Chi phí biến đổi theo tháng',
      child: _MonthlyBarChartAnimated(vm: vm),
    );
  }
}

class _MonthlyBarChartAnimated extends StatefulWidget {
  const _MonthlyBarChartAnimated({required this.vm});
  final ChangeCostViewModel vm;

  @override
  State<_MonthlyBarChartAnimated> createState() =>
      _MonthlyBarChartAnimatedState();
}

class _MonthlyBarChartAnimatedState extends State<_MonthlyBarChartAnimated> {
  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    // restart tween mỗi khi data đổi
    final key = ValueKey('${vm.barAnimTick.value}-${vm.monthly.join(",")}');

    return SizedBox(
      height: 280,
      child: TweenAnimationBuilder<double>(
        key: key,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0, end: 1),
        builder: (_, t, __) {
          final bars = <BarChartGroupData>[];
          for (int i = 0; i < vm.monthly.length; i++) {
            final m = i + 1;
            final isSel = (m == vm.selectedMonth.value);
            bars.add(
              BarChartGroupData(
                x: m,
                barRods: [
                  BarChartRodData(
                    toY: vm.monthly[i] * t,
                    width: 25,
                    color:
                        isSel
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF22C5BB),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            );
          }

          return BarChart(
            BarChartData(
              maxY: vm.maxY,
              barGroups: bars,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine:
                    (_) =>
                        const FlLine(color: Color(0xFFE6ECF5), strokeWidth: 1),
                getDrawingVerticalLine:
                    (_) => const FlLine(
                      color: Color(0xFFE6ECF5),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (v, _) => Text(vm.fmt(v.toInt())),
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
            ),
          );
        },
      ),
    );
  }
}

/* ---------------- Tab 2: Đường thủy (bảng) ---------------- */

class _TabDuongThuy extends StatelessWidget {
  const _TabDuongThuy({required this.vm});
  final ChangeCostViewModel vm;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Thống kê sản lượng vận chuyển đường thủy',
      child: Obx(() {
        final rows = vm.waterRows; // List<WaterRow> của bạn
        if (rows.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Không có dữ liệu'),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _WaterHeader(), // Header fill ngang
            const Divider(height: 1, color: _kSepColor),
            ListView.separated(
              // Body fill ngang
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder:
                  (_, __) => const Divider(height: 1, color: _kSepColor),
              itemBuilder:
                  (_, i) => _WaterRow(
                    index: i,
                    item: rows[i],
                    fmt: vm.fmt, // hàm format số bạn đã có
                  ),
            ),
          ],
        );
      }),
    );
  }
}

/* -------------------- định nghĩa cột dùng chung -------------------- */

class _ColDef {
  final String key;
  final String title;
  final int flex;
  final Alignment align;
  const _ColDef(
    this.key,
    this.title,
    this.flex, {
    this.align = Alignment.center,
  });
}

// Header + body đều dùng chung danh sách cột này
const _kWaterCols = <_ColDef>[
  _ColDef('stt', 'STT', 1),
  _ColDef('xuat', 'Khu vực xuất', 2, align: Alignment.centerLeft),
  _ColDef('kho', 'Kho nhập', 2, align: Alignment.centerLeft),
  _ColDef('so', 'Số chuyến', 1),
  _ColDef('lit', 'Tổng khối lượng (Lít15)', 2, align: Alignment.centerRight),
  _ColDef('loai', 'Loại', 1),
];

// màu & ngăn cách
const _kBlue = Color(0xFF4D73B2);
const _kSepColor = Color(0xFFE6ECF5);

/* ----------------------------- Header ----------------------------- */

class _WaterHeader extends StatelessWidget {
  const _WaterHeader();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: SizedBox(
        height: 44,
        width: double.infinity,
        child: Row(
          children: [
            for (int i = 0; i < _kWaterCols.length; i++)
              Expanded(
                flex: _kWaterCols[i].flex,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: _kBlue, // ✅ đưa màu vào BoxDecoration
                    border: Border(
                      right: BorderSide(
                        color:
                            (i == _kWaterCols.length - 1)
                                ? Colors.transparent
                                : _kSepColor,
                      ),
                    ),
                  ),
                  child: Text(
                    _kWaterCols[i].title,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------- Row ------------------------------ */

class _WaterRow extends StatelessWidget {
  const _WaterRow({required this.index, required this.item, required this.fmt});

  final int index;
  final dynamic item; // WaterRow model của bạn
  final String Function(num?) fmt;

  @override
  Widget build(BuildContext context) {
    // Model của bạn có thể là {stt,khuXuat/khuVucXuat,khoNhap,soChuyen,lit15,loai}
    final stt = (item.stt ?? index + 1);
    final khuXuat = (item.khuXuat ?? item.khuVucXuat ?? '');
    final khoNhap = (item.khoNhap ?? '');
    final soChuyen = (item.soChuyen ?? 0);
    final lit15 = (item.lit15 ?? 0);
    final loai = (item.loai ?? '');

    Widget cell(String key) {
      switch (key) {
        case 'stt':
          return Text('$stt');
        case 'xuat':
          return Text(khuXuat);
        case 'kho':
          return Text(khoNhap);
        case 'so':
          return Text('$soChuyen');
        case 'lit':
          return Text(fmt(lit15)); // căn phải theo _ColDef
        case 'loai':
          return _typeBadge(loai);
        default:
          return const SizedBox.shrink();
      }
    }

    return SizedBox(
      height: 48,
      width: double.infinity, // 👈 fill full width
      child: Row(
        children: [
          for (int i = 0; i < _kWaterCols.length; i++)
            Expanded(
              flex: _kWaterCols[i].flex,
              child: Container(
                alignment: _kWaterCols[i].align,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color:
                          (i == _kWaterCols.length - 1)
                              ? Colors.transparent
                              : _kSepColor,
                    ),
                  ),
                ),
                child: cell(_kWaterCols[i].key),
              ),
            ),
        ],
      ),
    );
  }
}

/* ------------------------- Badge “Loại” -------------------------- */

Widget _typeBadge(String t) {
  final upper = t.toUpperCase();
  final isDotXuat = upper.contains('ĐỘT'); // ĐỘT XUẤT
  final isDinhKy = upper.contains('ĐỊNH'); // ĐỊNH KÌ

  final Color fg, bg;
  if (isDinhKy) {
    fg = const Color(0xFF27AE60);
    bg = fg.withOpacity(.14);
  } else if (isDotXuat) {
    fg = const Color(0xFFF59E0B);
    bg = fg.withOpacity(.14);
  } else {
    fg = const Color(0xFF4B5563);
    bg = fg.withOpacity(.10);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
    child: Text(
      t,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: TextStyle(color: fg, fontWeight: FontWeight.w700),
    ),
  );
}

/* ---------------- Tab 3: Đường bộ (donut xoay) ---------------- */

class _TabDuongBo extends StatelessWidget {
  const _TabDuongBo({required this.vm});
  final ChangeCostViewModel vm;

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[
      for (int i = 0; i < vm.roadValues.length; i++)
        PieChartSectionData(
          value: vm.roadValues[i],
          color: _palette[i % _palette.length],
          radius: 70,
          showTitle: true,
          title:
              '${((vm.roadValues[i] / (vm.roadSum == 0 ? 1 : vm.roadSum)) * 100).toStringAsFixed(1)}%',
          titleStyle: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
    ];

    return Column(
      children: [
        _Card(
          title: 'Thống kê sản lượng vận chuyển đường bộ',
          child: SizedBox(
            height: 320,
            child: Obx(() {
              final rotateKey = ValueKey(vm.pieRotateTick.value);
              return TweenAnimationBuilder<double>(
                key: rotateKey,
                tween: Tween(begin: 0, end: 360),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, deg, __) {
                  return Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 70,
                          sections: sections,
                          startDegreeOffset: deg,
                        ),
                        swapAnimationDuration: Duration.zero,
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            vm.fmt(vm.roadSum),
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
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        _RoadLegend(vm: vm),
      ],
    );
  }
}

class _RoadLegend extends StatelessWidget {
  const _RoadLegend({required this.vm});
  final ChangeCostViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: _cardDecoration,
        child: Column(
          children: [
            for (int i = 0; i < vm.roadLabels.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: Row(
                  children: [
                    _Dot(color: _palette[i % _palette.length]),
                    const SizedBox(width: 8),
                    Expanded(child: Text(vm.roadLabels[i])),
                    Text('${vm.fmt(vm.roadValues[i])}'),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

/* ---------------- Shared widgets ---------------- */

class _DonutAnimated extends StatelessWidget {
  const _DonutAnimated({
    required this.restartKey,
    required this.totalLabel,
    required this.sections,
    this.height = 300,
  });

  final Key restartKey;
  final String totalLabel;
  final List<PieChartSectionData> sections;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TweenAnimationBuilder<double>(
        key: restartKey,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0, end: 1),
        builder: (_, t, __) {
          final anim = <PieChartSectionData>[
            for (final s in sections)
              s.copyWith(value: (s.value ?? 0) * t), // xòe quạt
          ];
          return Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 78,
                  sections: anim,
                ),
                swapAnimationDuration: Duration.zero,
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    totalLabel,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
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

const _palette = <Color>[
  Color(0xFF5C9CF0),
  Color(0xFF55CDA1),
  Color(0xFFF5A33E),
  Color(0xFFEB6A6A),
  Color(0xFF8B6DFB),
  Color(0xFF22C5BB),
  Color(0xFFEC9CC3),
];

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
  ],
);

class _CostTreemap extends StatefulWidget {
  const _CostTreemap({
    required this.items,
    required this.totalVnd,
    this.height = 400,
  });
  final List<_Slice> items;
  final double totalVnd;
  final double height;

  @override
  State<_CostTreemap> createState() => _CostTreemapState();
}

class _CostTreemapState extends State<_CostTreemap> {
  Offset? _tipPos;
  _Slice? _tipItem;

  String _fmtTy(num vnd) {
    final ty = (vnd / 1e9).round();
    final s = ty.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final ri = s.length - 1 - i;
      buf.write(s[ri]);
      if (i % 3 == 2 && ri != 0) buf.write('.');
    }
    return buf.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items.where((e) => e.value > 0).toList();
    final sum = items.fold<double>(0, (p, e) => p + e.value);
    if (sum == 0) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text('Không có dữ liệu')),
      );
    }

    // sắp to → nhỏ cho bố cục dễ đọc
    items.sort((a, b) => b.value.compareTo(a.value));

    List<Rect> _layoutTreemapRows(
      Rect area,
      List<double> values, {
      int minRows = 2,
      int maxRows = 4,
    }) {
      final total = values.fold<double>(0, (p, e) => p + e);
      if (total <= 0) return List.filled(values.length, Rect.zero);

      // gợi ý số hàng theo số lượng item (6–8 item ~ 2 hàng, >12 item ~ 3–4 hàng)
      int rows = (values.length / 6).ceil().clamp(minRows, maxRows);

      // phân item vào từng hàng sao cho tổng mỗi hàng gần nhau
      final target = total / rows;
      final List<List<int>> buckets = List.generate(rows, (_) => []);
      final sums = List<double>.filled(rows, 0);

      int r = 0;
      for (int i = 0; i < values.length; i++) {
        // nếu hàng hiện tại vượt quota nhiều và còn hàng sau → nhảy hàng
        if (sums[r] >= target && r < rows - 1) r++;
        buckets[r].add(i);
        sums[r] += values[i];
      }

      // tỉ lệ chiều cao từng hàng
      final heights = [for (final s in sums) area.height * (s / total)];

      // tạo rects kết quả theo thứ tự item gốc
      final rects = List<Rect>.filled(values.length, Rect.zero);
      double y = area.top;

      for (int row = 0; row < rows; row++) {
        final h = heights[row];
        final rowRect = Rect.fromLTWH(area.left, y, area.width, h);
        y += h;

        final idxs = buckets[row];
        final rowSum = sums[row] <= 0 ? 1.0 : sums[row];

        double x = rowRect.left;
        for (final i in idxs) {
          final w = rowRect.width * (values[i] / rowSum);
          rects[i] = Rect.fromLTWH(x, rowRect.top, w, rowRect.height);
          x += w;
        }
      }
      return rects;
    }

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (_, c) {
          final rects = _layoutTreemapRows(
            Rect.fromLTWH(0, 0, c.maxWidth, widget.height),
            items.map((e) => e.value).toList(),
            minRows: 4,
            maxRows: 8,
          );

          return Stack(
            children: [
              // Ô treemap + bắt tương tác
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) {
                    final local = d.localPosition;
                    for (int i = 0; i < rects.length; i++) {
                      if (rects[i].contains(local)) {
                        setState(() {
                          _tipPos = local;
                          _tipItem = items[i];
                        });
                        return;
                      }
                    }
                    setState(() {
                      _tipPos = null;
                      _tipItem = null;
                    });
                  },
                  onTapUp:
                      (_) =>
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted)
                              setState(() {
                                _tipPos = null;
                                _tipItem = null;
                              });
                          }),
                  child: CustomPaint(
                    painter: _TreemapPainter(
                      items: items,
                      rects: rects,
                      sum: sum,
                    ),
                  ),
                ),
              ),

              // Tổng ở góc (tuỳ bạn muốn giữa/đầu)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22000000), blurRadius: 8),
                    ],
                  ),
                  child: Text(
                    'Tổng: ${_fmtTy(widget.totalVnd)} Tỷ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),

              // Tooltip
              if (_tipPos != null && _tipItem != null)
                Positioned(
                  left: (_tipPos!.dx - 100).clamp(4, c.maxWidth - 200),
                  top: (_tipPos!.dy - 86).clamp(4, widget.height - 86),
                  child: _WhiteTooltip(
                    title: _tipItem!.name,
                    value:
                        '${_fmtTy(_tipItem!.value)} Tỷ • ${_tipItem!.percentLabel}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Vẽ từng ô + nhãn bên trong
class _TreemapPainter extends CustomPainter {
  _TreemapPainter({
    required this.items,
    required this.rects,
    required this.sum,
  });
  final List<_Slice> items;
  final List<Rect> rects;
  final double sum;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    // nền trắng (phù hợp trong thẻ Card)
    final bg = Paint()..color = Colors.white;
    canvas.drawRect(r, bg);

    final border =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFFE6ECF5);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    );

    for (int i = 0; i < items.length; i++) {
      final s = items[i];
      final rect = rects[i].deflate(2); // chừa biên

      // fill
      final fill = Paint()..color = s.color.withOpacity(.85);
      canvas.drawRect(rect, fill);
      canvas.drawRect(rect, border);

      // nhãn: tên + % (ưu tiên % nếu ô nhỏ)
      final pct =
          (s.value / (sum == 0 ? 1 : sum) * 100).toStringAsFixed(1) + '%';
      final name = s.name;

      final canShowName = rect.width > 70 && rect.height > 32;
      final label = canShowName ? '$name\n$pct' : pct;

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      );
      textPainter.layout(maxWidth: rect.width - 8);
      textPainter.paint(canvas, Offset(rect.left + 4, rect.top + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _TreemapPainter old) =>
      old.items != items || old.rects != rects || old.sum != sum;
}

/// Bố cục treemap kiểu slice-and-dice (nhẹ & không phụ thuộc package)
List<Rect> _layoutTreemap(Rect area, List<double> values) {
  final total = values.fold<double>(0, (p, e) => p + e);
  if (total == 0) return List.filled(values.length, Rect.zero);

  final rects = <Rect>[];
  void split(Rect r, int start, int end, bool horizontal) {
    final localTotal = values
        .sublist(start, end)
        .fold<double>(0, (p, v) => p + v);
    double offset = horizontal ? r.left : r.top;

    for (int i = start; i < end; i++) {
      final frac = values[i] / localTotal;
      if (horizontal) {
        final w = r.width * frac;
        rects.add(Rect.fromLTWH(offset, r.top, w, r.height));
        offset += w;
      } else {
        final h = r.height * frac;
        rects.add(Rect.fromLTWH(r.left, offset, r.width, h));
        offset += h;
      }
    }
  }

  // để đơn giản: một tầng slice theo chiều dài lớn hơn
  final horizontal = area.width >= area.height;
  split(area, 0, values.length, horizontal);
  return rects;
}
