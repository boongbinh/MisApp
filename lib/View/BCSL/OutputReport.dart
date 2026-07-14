import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Components/ComboField.dart';
import 'package:skypec/Controller/BCSL/OutputReportViewModel.dart';

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

class OutputReport extends GetView<OutputReportViewModel> {
  const OutputReport({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = controller;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Báo cáo sản lượng'),
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
                  _SearchAndFilterBar(vm: vm),
                  const SizedBox(height: 12),
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

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.vm});
  final OutputReportViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search box
        Expanded(
          child: _AirportAutocomplete(
            vm: vm,
          ), // ⬅️ thay cho SizedBox + TextField cũ
        ),
        const SizedBox(width: 8),
        // Filter button
        InkWell(
          onTap: () => _FilterSheet.open(context, vm),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: const Icon(Icons.tune, size: 20, color: Color(0xFF1F2A37)),
          ),
        ),
      ],
    );
  }
}

// _StatsCard sử dụng vm.tongSanLuong, vm.sanLuongUocTh, ... để hiển thị.
// Khi người dùng nhấn vào header của thẻ, vm.statsExpanded.toggle() được gọi để ẩn/hiện chi tiết.
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.vm});
  final OutputReportViewModel vm;

  @override
  Widget build(BuildContext context) {
    Widget tile(
      IconData icon,
      Color bg,
      String title,
      String value, [
      String? sub,
    ]) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            if (sub != null)
              Text(
                sub,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
          ],
        ),
      );
    }

    return Container(
      decoration: _cardDeco,
      child: Column(
        children: [
          // header line (title left, expand icon right)
          Obx(() {
            final expanded = vm.statsExpanded.value;
            return InkWell(
              onTap: vm.statsExpanded.toggle,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Thống kê sản lượng',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Divider(height: 1),
          Obx(() {
            if (!vm.statsExpanded.value) return const SizedBox.shrink();
            return Column(
              children: [
                tile(
                  Icons.all_inbox,
                  const Color(0xFF10B981),
                  'Tổng sản lượng',
                  vm.fmt(vm.tongSanLuong.value),
                ),
                const Divider(height: 1),
                tile(
                  Icons.task_alt,
                  const Color(0xFF3B82F6),
                  'Sản lượng thực hiện',
                  vm.fmt(vm.sanLuongUocTh.value),
                  'So với kế hoạch tháng',
                ),
                const Divider(height: 1),
                tile(
                  Icons.calendar_month,
                  const Color(0xFF06B6D4),
                  '% Sản lượng tháng trước',
                  vm.pct(vm.pctThangTruoc.value),
                  vm.fmt(vm.sanLuongThangTruoc.value),
                ),
                const Divider(height: 1),
                tile(
                  Icons.history_toggle_off,
                  const Color(0xFFF59E0B),
                  '% Sản lượng cùng kỳ',
                  vm.pct(vm.pctCungKy.value),
                  vm.fmt(vm.sanLuongCungKy.value),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
/* ---------------- TABS ---------------- */

class _Tabs extends StatelessWidget {
  const _Tabs({required this.vm});
  final OutputReportViewModel vm;

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
            height: 700,
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
  final OutputReportViewModel vm;

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

// _BarChart sử dụng vm.unitIndex, vm.showThucTe, vm.showKeHoach, vm.thucTeTan, ... để vẽ biểu đồ.
// Khi vm.unitIndex thay đổi, biểu đồ được rebuild với dữ liệu mới (Tấn hoặc M3).
class _BarChart extends StatefulWidget {
  const _BarChart({required this.vm});
  final OutputReportViewModel vm;

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
  final OutputReportViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Obx(() {
        final idx = vm.ccIndex.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thứ tự chip: Khu vực, Chặng bay, Nhóm khách hàng, Sân bay
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _seg('Khu vực', 0, vm.ccIndex),
                _seg('Chặng bay', 1, vm.ccIndex),
                _seg('Nhóm khách hàng', 2, vm.ccIndex),
                _seg('Sân bay', 3, vm.ccIndex),
              ],
            ),
            const SizedBox(height: 12),

            // Nội dung theo tab
            if (idx == 0)
              Expanded(
                child: _StructureDonut(
                  labelsRx: vm.khuVucLabel,
                  dataRx: vm.khuVucData,
                  totalRx: vm.khuVucSumRx,
                ),
              )
            else if (idx == 1)
              Expanded(
                child: _StructureDonut(
                  labelsRx: vm.changBayLabel,
                  dataRx: vm.changBayData,
                  totalRx: vm.changBaySumRx,
                ),
              )
            else if (idx == 2)
              Expanded(
                child: _StructureDonut(
                  labelsRx: vm.nhomKhLabel,
                  dataRx: vm.nhomKhData,
                  totalRx: vm.nhomKhSumRx,
                ),
              )
            else
              // Sân bay: biểu đồ cột ngang (ranking)
              Expanded(
                child: _AirportBar(
                  labels: vm.sanBayLabel,
                  values: vm.sanBayData,
                  maxX: vm.sanBayMax * 1.1, // headroom
                ),
              ),
          ],
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
}

class _AirportBar extends StatefulWidget {
  const _AirportBar({
    required this.labels,
    required this.values,
    required this.maxX,
  });

  final List<String> labels;
  final List<double> values;
  final double maxX;

  @override
  State<_AirportBar> createState() => _AirportBarState();
}

class _AirportBarState extends State<_AirportBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late Animation<double> _t;

  Offset? _tipPos; // vị trí tooltip (theo hệ tọa độ không xoay)
  String? _tipLabel; // nhãn (sân bay)
  double? _tipValue; // giá trị tấn

  // lưu thứ tự sắp xếp để dùng cho tooltip/titles
  late List<int> _idxs;

  double _tickStep(double maxY, {int target = 6}) {
    if (maxY <= 0) return 1;
    final raw = maxY / target;
    final mag = pow(10, (log(raw) / ln10).floor()).toDouble();
    final k = raw / mag; // 1..10
    final mult =
        (k <= 1)
            ? 1
            : (k <= 2)
            ? 2
            : (k <= 5)
            ? 5
            : 10;
    return mult * mag; // bước 1/2/5 * 10^n
  }

  String _fmtNum(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _t = CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic);
    _recomputeSortAndPlay();
  }

  @override
  void didUpdateWidget(covariant _AirportBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu dữ liệu đổi (độ dài/giá trị), sắp xếp lại và phát lại animation
    if (!listEquals(oldWidget.values, widget.values) ||
        !listEquals(oldWidget.labels, widget.labels) ||
        oldWidget.maxX != widget.maxX) {
      _recomputeSortAndPlay();
    }
  }

  void _recomputeSortAndPlay() {
    _idxs = List<int>.generate(widget.values.length, (i) => i)
      ..sort((a, b) => widget.values[b].compareTo(widget.values[a]));
    _ctl
      ..stop()
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxY = widget.maxX <= 0 ? 1.0 : widget.maxX;
    final step = _tickStep(maxY); // << thêm dòng này

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (ctx, cons) {
          // cons.maxWidth: chiều rộng vùng hiển thị
          // cons.maxHeight: chiều cao vùng hiển thị
          return Stack(
            children: [
              // Biểu đồ: xoay 90° để được cột ngang
              RotatedBox(
                quarterTurns: 1,
                child: AnimatedBuilder(
                  animation: _t,
                  builder: (_, __) {
                    final groups = <BarChartGroupData>[];
                    for (int i = 0; i < _idxs.length; i++) {
                      final v = widget.values[_idxs[i]] * _t.value; // animate
                      groups.add(
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: v,
                              width: 14,
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    }

                    return BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: maxY,
                        barGroups: groups,
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          getDrawingHorizontalLine:
                              (_) => const FlLine(
                                color: Color(0xFFE6ECF5),
                                strokeWidth: 1,
                              ),
                          drawVerticalLine: false,
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 52,
                              showTitles: true,
                              interval:
                                  step, // yêu cầu fl_chart đặt khoảng cách nhãn
                              getTitlesWidget: (v, _) {
                                // Nếu lib bạn không tôn trọng interval, vẫn lọc lại thủ công:
                                final show =
                                    ((v / step).roundToDouble() - (v / step))
                                        .abs() <
                                    1e-6;
                                if (!show || v < 0 || v > maxY + 1e-6)
                                  return const SizedBox.shrink();
                                return RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    _fmtNum(v),
                                    style: const TextStyle(fontSize: 11),
                                  ),
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
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 72,
                              showTitles: true,
                              getTitlesWidget: (v, meta) {
                                final i = v.toInt();
                                if (i < 0 || i >= _idxs.length) {
                                  return const SizedBox.shrink();
                                }
                                final label = widget.labels[_idxs[i]];
                                return RotatedBox(
                                  quarterTurns: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Text(
                                      label,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            left: BorderSide(color: Color(0xFFE6ECF5)),
                            bottom: BorderSide(color: Color(0xFFE6ECF5)),
                          ),
                        ),

                        // Tắt tooltip built-in, tự xử lý vị trí + nội dung
                        barTouchData: BarTouchData(
                          enabled: true,
                          handleBuiltInTouches: false,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (_, __, ___, ____) => null,
                          ),
                          touchCallback: (evt, resp) {
                            final lp = evt.localPosition;
                            if (!evt.isInterestedForInteractions ||
                                lp == null ||
                                resp == null ||
                                resp.spot == null) {
                              setState(() {
                                _tipPos = null;
                                _tipLabel = null;
                                _tipValue = null;
                              });
                              return;
                            }

                            // lp đang ở hệ trục đã xoay 90°. Đổi về hệ trục không xoay:
                            // Với quarterTurns: 1, điểm (x, y) -> (cons.maxWidth - y, x)
                            final unrotated = Offset(
                              cons.maxWidth - lp.dy,
                              lp.dx,
                            );

                            final i = resp.spot!.touchedBarGroupIndex;
                            if (i < 0 || i >= _idxs.length) {
                              setState(() {
                                _tipPos = null;
                                _tipLabel = null;
                                _tipValue = null;
                              });
                              return;
                            }

                            final rawIdx = _idxs[i];
                            setState(() {
                              _tipPos = unrotated;
                              _tipLabel = widget.labels[rawIdx];
                              _tipValue = widget.values[rawIdx];
                            });

                            // Nhả tay/ra ngoài thì ẩn
                            if (evt is FlPanEndEvent ||
                                evt is FlTapUpEvent ||
                                evt is FlPointerExitEvent ||
                                evt is FlLongPressEnd) {
                              setState(() {
                                _tipPos = null;
                                _tipLabel = null;
                                _tipValue = null;
                              });
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Tooltip tự vẽ (không bị xoay)
              if (_tipPos != null && _tipLabel != null && _tipValue != null)
                Positioned(
                  left: _clamp(_tipPos!.dx - 80, 4, cons.maxWidth - 160),
                  top: _clamp(_tipPos!.dy - 56, 4, cons.maxHeight - 72),
                  child: _WhiteTooltip(
                    title: _tipLabel!,
                    value: '${_tipValue!.toStringAsFixed(0)} Tấn',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);
}

class _StructureDonut extends StatelessWidget {
  const _StructureDonut({
    required this.labelsRx,
    required this.dataRx,
    required this.totalRx,
  });

  final RxList<String> labelsRx;
  final RxList<double> dataRx;
  final RxDouble totalRx;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final labels = labelsRx.toList();
      final values = dataRx.toList();
      final total = totalRx.value;

      return Column(
        children: [
          SizedBox(
            height: 320,
            child: Center(
              child: _DonutFanOut(
                // 👉 không dùng key động để tránh jank khi đổi tab
                labels: labels,
                values: values,
                total: total,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _legendList(labels: labels, values: values),
        ],
      );
    });
  }

  // legend ghi chú dưới chart
  Widget _legendList({
    required List<String> labels,
    required List<double> values,
  }) {
    const colors = [
      Color(0xFFF87171),
      Color(0xFF34D399),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFF60A5FA),
      Color(0xFF22C5BB),
      Color(0xFFEC4899),
      Color(0xFF94A3B8),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: const Color(0xFFE5EAF2))),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(labels.length, (i) {
            return Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _Dot(color: colors[i % colors.length]),
                  const SizedBox(width: 8),
                  Expanded(child: Text(labels[i])),
                  Text(
                    '${_fmt(values[i])} Tấn',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  String _fmt(num v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
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

// _FilterSheet sử dụng các biến filter trong controller (vm.filterFromMonth, vm.khachHangFilter, ...) để hiển thị giá trị hiện tại.
// Khi người dùng thay đổi và nhấn "Áp dụng", view cập nhật các biến filter và gọi vm.applyFilters().
class _FilterSheet extends StatefulWidget {
  static Future<void> open(
    BuildContext context,
    OutputReportViewModel vm,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FilterSheet(vm: vm),
    );
  }

  const _FilterSheet({required this.vm});
  final OutputReportViewModel vm;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  @override
  void initState() {
    super.initState();
    widget.vm.ensureFilterOptionsLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    // sân bay có thể chọn nhiều
    final RxSet<String> _airports = {...vm.selectedAirports}.obs;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 42,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const Text(
                'Bộ lọc',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // TỪ THÁNG
                  Expanded(
                    child: Obx(
                      () => ComboField(
                        label: 'Từ tháng',
                        value: vm.filterFromMonth.value.toString().padLeft(
                          2,
                          '0',
                        ),
                        onTap:
                            () => _pickMonth(
                              context,
                              initial: vm.filterFromMonth.value,
                              onSelected: vm.setFromMonth,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ĐẾN THÁNG
                  Expanded(
                    child: Obx(
                      () => ComboField(
                        label: 'Đến tháng',
                        value: vm.filterToMonth.value.toString().padLeft(
                          2,
                          '0',
                        ),
                        onTap:
                            () => _pickMonth(
                              context,
                              initial: vm.filterToMonth.value,
                              onSelected: vm.setToMonth,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // NĂM
                  Expanded(
                    child: Obx(
                      () => ComboField(
                        label: 'Năm',
                        value: vm.filterYear.value.toString(),
                        onTap:
                            () => _pickYear(
                              context,
                              initial: vm.filterYear.value,
                              onSelected: vm.setFilterYear,
                            ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Nhóm KH (single)
              _dropdown(
                label: 'Nhóm khách hàng',
                value: vm.khachHangFilter.value,
                items:
                    vm.khachHangOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.label),
                          ),
                        )
                        .toList(),
                onChanged: (v) => vm.khachHangFilter.value = v ?? '0',
              ),
              const SizedBox(height: 12),

              // Chặng bay (single)
              _dropdown(
                label: 'Chặng bay',
                value: vm.changBayFilter.value,
                items:
                    vm.changBayOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.label),
                          ),
                        )
                        .toList(),
                onChanged: (v) => vm.changBayFilter.value = v ?? 'all',
              ),
              const SizedBox(height: 12),

              // Phiên bản (single)
              _dropdown(
                label: 'Phiên bản',
                value: vm.version.value,
                items:
                    vm.versionOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.label),
                          ),
                        )
                        .toList(),
                onChanged: (v) => vm.version.value = v ?? '',
              ),
              const SizedBox(height: 12),

              // Sân bay (multi select)
              ComboField(
                label: 'Sân bay',
                value:
                    vm.airportsLabel, // hiển thị "Tất cả" hoặc danh sách đã chọn
                onTap: () => _pickAirports(context, vm),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        vm.filterFromMonth.value = DateTime.now().month;
                        vm.filterToMonth.value = DateTime.now().month;
                        vm.filterYear.value = DateTime.now().year;

                        // chọn giá trị đầu tiên nếu có; nếu chưa có options thì để fallback
                        vm.khachHangFilter.value =
                            vm.khachHangOptions.isNotEmpty
                                ? vm.khachHangOptions.first.value
                                : '0';
                        vm.changBayFilter.value =
                            vm.changBayOptions.isNotEmpty
                                ? vm.changBayOptions.first.value
                                : 'all';
                        vm.version.value =
                            vm.versionOptions.isNotEmpty
                                ? vm.versionOptions.first.value
                                : '';

                        vm.selectedAirports.clear();
                      },
                      child: const Text('Đặt lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        vm.fromMonth.value = vm.filterFromMonth.value;
                        vm.toMonth.value = vm.filterToMonth.value;
                        vm.toYear.value = vm.filterYear.value;

                        Get.back();
                        vm.applyFilters();
                      },
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _monthField(
    String label,
    int m,
    int y, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          border: Border.all(color: const Color(0xFFE5EAF2)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(label),
            const Spacer(),
            Text(
              '${m.toString().padLeft(2, '0')}/$y',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAirports(
    BuildContext context,
    OutputReportViewModel vm,
  ) async {
    final sel = vm.selectedAirports.toSet(); // copy tạm để thao tác

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder:
                  (_, controller) => Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Chọn sân bay',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Expanded(
                        child: ListView.builder(
                          controller: controller,
                          itemCount: vm.airports.length,
                          itemBuilder: (_, i) {
                            final code = vm.airports[i];
                            final checked = sel.contains(code);
                            return CheckboxListTile(
                              value: checked,
                              onChanged: (b) {
                                setState(() {
                                  if (b == true)
                                    sel.add(code);
                                  else
                                    sel.remove(code);
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(code),
                            );
                          },
                        ),
                      ),

                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(sel.clear);
                                },
                                child: const Text('Bỏ chọn'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  vm.selectedAirports.assignAll(sel.toList());
                                  Navigator.of(context).pop();
                                },
                                style: FilledButton.styleFrom(
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text('Xong'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickMonth(
    BuildContext context, {
    required int initial,
    required ValueChanged<int> onSelected,
  }) async {
    final items = List<int>.generate(12, (i) => i + 1);
    final sel = await _showListPicker<int>(
      context,
      title: 'Chọn tháng',
      items: items,
      display: (m) => m.toString().padLeft(2, '0'),
      initial: items.indexOf(initial.clamp(1, 12)),
    );
    if (sel != null) onSelected(sel);
  }

  Future<void> _pickYear(
    BuildContext context, {
    required int initial,
    required ValueChanged<int> onSelected,
  }) async {
    final nowY = DateTime.now().year;
    final years = List<int>.generate(20, (i) => nowY - 19 + i);
    if (!years.contains(initial)) years.add(initial);
    years.sort((a, b) => b.compareTo(a));

    final sel = await _showListPicker<int>(
      context,
      title: 'Chọn năm',
      items: years,
      display: (y) => y.toString(),
      initial: years.indexOf(initial),
    );
    if (sel != null) onSelected(sel);
  }

  Future<T?> _showListPicker<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) display,
    int? initial,
  }) {
    int current = (initial ?? 0).clamp(0, items.length - 1);
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final isSel = i == current;
                    return ListTile(
                      onTap: () => Navigator.pop(ctx, items[i]),
                      leading:
                          isSel
                              ? const Icon(
                                Icons.radio_button_checked,
                                color: Color(0xFF2563EB),
                              )
                              : const Icon(
                                Icons.radio_button_off,
                                color: Color(0xFF9CA3AF),
                              ),
                      title: Text(
                        display(items[i]),
                        style: TextStyle(
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// Simple multi-select
class _MultiSelect extends StatelessWidget {
  const _MultiSelect({
    required this.label,
    required this.allOptions,
    required this.selected,
  });

  final String label;
  final List<String> allOptions;
  final RxSet<String> selected;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                allOptions.map((s) {
                  final sel = selected.contains(s);
                  return ChoiceChip(
                    label: Text(s),
                    selected: sel,
                    showCheckmark: false,
                    selectedColor: const Color(0xFF2563EB),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : const Color(0xFF1F2A37),
                    ),
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: const StadiumBorder(),
                    onSelected: (v) {
                      if (v) {
                        selected.add(s);
                      } else {
                        selected.remove(s);
                      }
                    },
                  );
                }).toList(),
          ),
        ],
      );
    });
  }
}


// Widget này sử dụng vm.airports (danh sách sân bay từ API) để gợi ý.
// Khi người dùng chọn một sân bay, nó gọi vm.onSearchAirport(value) để tìm kiếm.
class _AirportAutocomplete extends StatelessWidget {
  const _AirportAutocomplete({required this.vm});
  final OutputReportViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      // lọc theo mã (hoặc tên nếu bạn có)
      optionsBuilder: (TextEditingValue tev) {
        final q = tev.text.trim().toUpperCase();
        if (q.isEmpty) return const Iterable<String>.empty();
        return vm.airports.where((e) => e.toUpperCase().contains(q)).take(20);
      },
      onSelected: (value) {
        vm.searchCtrl.text = value;
        vm.onSearchAirport(value); // gọi tìm kiếm/áp lọc
      },

      // style của ô nhập
      fieldViewBuilder: (context, textCtrl, focusNode, onFieldSubmitted) {
        // đồng bộ với controller sẵn có
        if (vm.searchCtrl.text.isNotEmpty && textCtrl.text.isEmpty) {
          textCtrl.text = vm.searchCtrl.text;
          textCtrl.selection = TextSelection.collapsed(
            offset: textCtrl.text.length,
          );
        }
        return SizedBox(
          height: 40,
          child: TextField(
            controller: textCtrl,
            focusNode: focusNode,
            onSubmitted: (_) => vm.onSearchAirport(textCtrl.text),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sân bay',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon:
                  (textCtrl.text.isEmpty)
                      ? null
                      : IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          textCtrl.clear();
                          vm.searchCtrl.clear();
                        },
                      ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
              ),
            ),
          ),
        );
      },

      // style popup gợi ý
      optionsViewBuilder: (context, onSelected, options) {
        final width =
            MediaQuery.of(context).size.width -
            16 -
            16 -
            48; // ~full width trừ icon filter
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 280, maxWidth: width),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final code = options.elementAt(i);
                  return ListTile(
                    dense: true,
                    title: Text(
                      code,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () => onSelected(code),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
