import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Controller/QTTC/FixCostViewModel.dart';

class FixCost extends GetView<FixCostViewModel> {
  const FixCost({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi phí cố định'),
        centerTitle: true,
        elevation: 0,
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
        if (vm.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.error.isNotEmpty) {
          return Center(child: Text(vm.error.value));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Card(
                title: 'Chi phí',
                child: Column(
                  children: [_Donut(vm: vm), const SizedBox(height: 8)],
                ),
              ),
              const SizedBox(height: 10),
              _ListBreakdown(vm: vm),
            ],
          ),
        );
      }),
    );
  }
}

/* ---------- Donut ---------- */

class _Donut extends StatelessWidget {
  const _Donut({required this.vm, this.height = 300});
  final FixCostViewModel vm;
  final double height;

  @override
  Widget build(BuildContext context) {
    // chạy lại tween khi data lần đầu tới (hoặc thay đổi)
    final restartKey = ValueKey(vm.items.map((e) => e.cd).join(','));

    return SizedBox(
      height: height,
      child: TweenAnimationBuilder<double>(
        key: restartKey,
        tween: Tween(begin: 0, end: 1), // t: 0 → 1
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic, // mượt hơn
        builder: (_, t, __) {
          // tổng (chỉ lấy item > 0)
          final total = vm.items.fold<double>(
            0,
            (s, e) => s + (e.cd > 0 ? e.cd : 0),
          );

          final totalTy = vm.totalCD.value / 1e9; // tổng theo Tỷ
          final totalTxt = NumberFormat(
            '#,##0.##',
            'vi_VN',
          ).format(totalTy * t);

          // gom các lát theo hiệu ứng quét
          final sections = <PieChartSectionData>[];
          double cum = 0; // tỉ lệ tích lũy đã “đi qua”
          double shownSum =
              0; // tổng value đã hiển thị (để thêm lát trong suốt)

          for (final e in vm.items) {
            if (e.cd <= 0) continue;

            final part = e.cd / total; // tỉ lệ của lát
            final start = cum; // bắt đầu của lát trên trục 0..1
            final end = cum + part; // kết thúc của lát
            cum = end;

            // phần tỉ lệ đã mở của lát này
            double openedPortion;
            if (t <= start) {
              openedPortion = 0; // chưa tới lát này
            } else if (t >= end) {
              openedPortion = part; // đã mở trọn lát
            } else {
              openedPortion = (t - start); // đang mở dở
            }

            final value = openedPortion * total; // giữ tổng cố định
            shownSum += value;

            sections.add(
              PieChartSectionData(
                value: value,
                radius: 76, // có thể kèm animate radius nếu thích
                color: e.color,
                showTitle: true,
                title: '${e.percent.toStringAsFixed(1)}%',
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            );
          }

          // lát trong suốt = phần còn lại để tổng không đổi → tạo cảm giác “xòe quạt”
          final double remaining =
              ((total - shownSum).clamp(0.0, total)) as double;
          if (remaining > 0.0001) {
            sections.add(
              PieChartSectionData(
                value: 0, // placeholder, set below
                showTitle: false,
                color: Colors.transparent,
                radius: 76,
              ),
            );
            // fl_chart yêu cầu value > 0, nên sửa phần tử cuối cùng:
            sections[sections.length - 1] = sections.last.copyWith(
              value: remaining,
            );
          }

          return Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 78,
                  sections: sections,
                ),
                // tắt animation nội bộ để không chồng với tween tay
                swapAnimationDuration: Duration.zero,
                swapAnimationCurve: Curves.linear,
              ),
              // số tổng ở giữa (giữ nguyên hoặc bạn cũng có thể animate số nếu muốn)
              Positioned.fill(
                child: Center(
                  // cố định bề rộng để tránh layout nhảy khi thay đổi độ dài chuỗi
                  child: SizedBox(
                    width: 140, // tuỳ bạn, ~ 120–160 là hợp lý
                    child: TweenAnimationBuilder<double>(
                      // animate trực tiếp giá trị TỶ thay vì nhân t ngoài
                      tween: Tween(begin: 0, end: vm.totalCD.value / 1e9),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) {
                        final totalTxt = NumberFormat(
                          '#,##0.00',
                          'vi_VN',
                        ).format(v);
                        return Text(
                          '$totalTxt Tỷ',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            // số có độ rộng cố định -> mượt hơn hẳn
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        );
                      },
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

/* ---------- Danh sách hạng mục ---------- */

class _ListBreakdown extends StatelessWidget {
  const _ListBreakdown({required this.vm});
  final FixCostViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      child: Obx(
        () => Column(
          children: [
            for (int i = 0; i < vm.items.length; i++) ...[
              _RowItem(item: vm.items[i], vm: vm),
              if (i != vm.items.length - 1)
                const Divider(height: 1, color: Color(0xFFE6ECF5)),
            ],
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({required this.item, required this.vm});
  final CostItem item;
  final FixCostViewModel vm;

  @override
  Widget build(BuildContext context) {
    final deltaBg = item.up ? const Color(0x1427AE60) : const Color(0x14EF4444);
    final deltaFg = item.up ? const Color(0xFF27AE60) : const Color(0xFFEF4444);
    final deltaIcon = item.up ? Icons.trending_up : Icons.trending_down;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        children: [
          // dòng tiêu đề + số tiền bên phải
          Row(
            children: [
              _Dot(color: item.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _beautifyName(item.name),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                vm.fmtNum(item.cd.toInt()),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // "Số tiền (Tỷ)" + "So sánh % tháng trước"
          Row(
            children: [
              const SizedBox(width: 20), // canh theo chấm tròn
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Số tiền (Tỷ) :',
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
              // badge phần trăm thay đổi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: deltaBg,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  children: [
                    Icon(deltaIcon, size: 14, color: deltaFg),
                    const SizedBox(width: 4),
                    Text(
                      item.deltaLabel,
                      style: TextStyle(
                        color: deltaFg,
                        fontWeight: FontWeight.w700,
                      ),
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

  String _beautifyName(String s) {
    // đồng nhất một vài nhãn giống ảnh
    return s
        .replaceAll('CP Hoạt động sân bay', 'CP hoạt động sân bay')
        .replaceAll('CP Hoạt động chi nhánh', 'CP hoạt động chi nhánh')
        .replaceAll('CP Quản lý', 'CP quản lý');
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/* ---------- small ---------- */

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
          Padding(padding: const EdgeInsets.all(25), child: child),
        ],
      ),
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
  ],
);
