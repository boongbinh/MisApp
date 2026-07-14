import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/QTTC/FinancePlanViewModel.dart';

class FinancePlan extends GetView<FinancePlanViewModel> {
  const FinancePlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(),
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
            child: Obx(() {
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
                    _FilterRow(
                      label1: controller.monthLabel,
                      label2: controller.selectedAirport.value,
                      onPickMonth:
                          () => _openMonthYearPicker(context, controller),
                      onPickAirport:
                          () => _openAirportPicker(context, controller),
                    ),
                    const SizedBox(height: 12),
                    _StatsCard(vm: controller),
                    const SizedBox(height: 16),
                    _TableCard(vm: controller),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() => AppBar(
    elevation: 0,
    title: const Text('Phương án tài chính'),
    centerTitle: true,
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
  );
}

/* -------------------- Filters -------------------- */

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label1,
    required this.label2,
    required this.onPickMonth,
    required this.onPickAirport,
  });
  final String label1, label2;
  final VoidCallback onPickMonth, onPickAirport;

  static const _b = BorderSide(color: Color(0xFFE6ECF5));

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Material(
        //   color: Colors.white,
        //   shape: const CircleBorder(side: _b),
        //   child: InkWell(
        //     customBorder: const CircleBorder(),
        //     onTap: onPickMonth,
        //     child: const SizedBox(
        //       height: 36,
        //       width: 36,
        //       child: Icon(Icons.tune, color: Color(0xFF1F2A37)),
        //     ),
        //   ),
        // ),
        // const SizedBox(width: 8),
        _pill(label1, onPickMonth),
        const SizedBox(width: 8),
        _pill(label2, onPickAirport),
      ],
    );
  }

  Widget _pill(String text, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: StadiumBorder(side: _b),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

/* -------------------- Stats card -------------------- */

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.vm});
  final FinancePlanViewModel vm;

  // map label -> icon & color (bạn có thể đổi cho khớp brand)
  (IconData, Color) _iconFor(String label) {
    // gán theo từ khóa để không phụ thuộc đúng tuyệt đối kí tự
    final l = label.toLowerCase();
    if (l.contains('hàng tồn'))
      return (Icons.inventory_2_outlined, const Color(0xFF22C55E)); // xanh lá
    if (l.contains('giá bán'))
      return (Icons.sell_outlined, const Color(0xFF0EA5E9)); // xanh dương nhạt
    if (l.contains('lãi trên biến đổi'))
      return (Icons.trending_up, const Color(0xFF06B6D4)); // teal
    if (l.contains('chi phí cố định'))
      return (
        Icons.account_balance_wallet_outlined,
        const Color(0xFFF59E0B),
      ); // cam
    if (l.contains('lãi trên biến phí'))
      return (Icons.show_chart, const Color(0xFFFB923C)); // cam nhạt
    if (l.contains('sản lượng hoàn vốn'))
      return (Icons.factory_outlined, const Color(0xFFEF4444)); // đỏ
    if (l.contains('chênh lệch tỷ giá') || l.contains('giá vốn'))
      return (Icons.currency_exchange, const Color(0xFF6366F1)); // indigo
    // mặc định
    return (Icons.insert_chart_outlined_rounded, const Color(0xFF94A3B8));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = vm.statsExpanded.value;
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
            ListTile(
              title: const Text(
                'Thống kê tài chính',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: IconButton(
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: vm.toggleStats,
              ),
            ),
            if (expanded) const Divider(height: 1),
            if (expanded)
              Obx(() {
                final items = vm.stats; // List<StatItem {label, value}>
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                  child: Column(
                    children: [
                      for (final s in items)
                        _statRow(
                          icon: _iconFor(s.label).$1,
                          color: _iconFor(s.label).$2,
                          label: s.label,
                          value: vm.fmt(s.value),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ),
      );
    });
  }

  Widget _statRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _IconBadge(icon: icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF111827)),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

/* -------------------- Table card -------------------- */

// ---- styles cho bảng ----
const _numMutedStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Color(0xFF9CA3AF), // xám khi hiển thị "--"
);

const _numStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: Color(0xFF4B5563), // màu số của dòng con
);

const _numTotalStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800, // đậm hơn
  color: Color(0xFF111827), // sẫm hơn
);

class _TableCard extends StatelessWidget {
  const _TableCard({required this.vm});
  final FinancePlanViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // TÍNH CỘT 1 LẦN THEO TRẠNG THÁI toggle
      final defs = _colDefs(vm);

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
            ListTile(
              title: const Text(
                'Danh sách tài chính',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: vm.openColumnSettings,
              ),
            ),
            _TableHeader(defs: defs), // ← truyền defs cho header
            const Divider(height: 1),
            _TableBody(vm: vm, defs: defs), // ← truyền defs cho body
          ],
        ),
      );
    });
  }
}

const double kNameW = 220; // cột "Nội dung"
const double kNumW = 140; // mỗi cột số

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.defs});
  final List<_ColDef> defs;

  static const _blue = Color(0xFF4D73B2);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Container(
        height: 44,
        color: _blue,
        child: Row(
          children: [
            for (int i = 0; i < defs.length; i++)
              Expanded(
                flex: defs[i].flex,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color:
                            i == defs.length - 1
                                ? Colors.transparent
                                : const Color(0xFFE6ECF5),
                      ),
                    ),
                  ),
                  child: Text(
                    defs[i].title,
                    textAlign: TextAlign.center,
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

class _TableBody extends StatelessWidget {
  const _TableBody({required this.vm, required this.defs});
  final FinancePlanViewModel vm;
  final List<_ColDef> defs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = vm.rows;
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: rows.length,
        separatorBuilder:
            (_, __) => const Divider(height: 1, color: Color(0xFFE6ECF5)),
        itemBuilder:
            (_, i) => _RowWidget(vm: vm, row: rows[i], defs: defs, rowIndex: i),
      );
    });
  }
}

class _RowWidget extends StatelessWidget {
  const _RowWidget({
    required this.vm,
    required this.row,
    required this.defs,
    required this.rowIndex,
  });
  final FinancePlanViewModel vm;
  final FinanceRow row;
  final List<_ColDef> defs;
  final int rowIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _line(row, isChild: false),
        Obx(
          () =>
              row.expanded.value
                  ? Column(
                    children: [
                      for (final c in row.children) _line(c, isChild: true),
                    ],
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _line(FinanceRow r, {required bool isChild}) {
    return Row(
      children: [
        for (int i = 0; i < defs.length; i++)
          Expanded(
            flex: defs[i].flex,
            child: Container(
              height: 44,
              alignment:
                  defs[i].key == 'name'
                      ? Alignment.centerLeft
                      : Alignment.center,
              padding: EdgeInsets.only(
                left: defs[i].key == 'name' ? (isChild ? 28 : 12) : 8,
                right: 8,
              ),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color:
                        i == defs.length - 1
                            ? Colors.transparent
                            : const Color(0xFFE6ECF5),
                  ),
                ),
              ),
              child: _cell(defs[i].key, r, i),
            ),
          ),
      ],
    );
  }

  Widget _cell(String key, FinanceRow r, int rowIdx) {
    if (key == 'name') {
      final clickable = vm.canOpenDetail(r);

      final label = Text(
        r.loai,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: r.isParent ? const Color(0xFF1F7BD8) : const Color(0xFF111827),
          fontWeight: r.isParent ? FontWeight.w700 : FontWeight.w400,
          // decoration:
          //     clickable ? TextDecoration.underline : TextDecoration.none,
        ),
      );
      return Row(
        children: [
          if (r.isParent)
            Obx(
              () => IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                onPressed: r.expanded.toggle,
                icon: Icon(
                  r.expanded.value ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF1F2A37),
                ),
              ),
            )
          else
            const SizedBox(width: 18),
          Expanded(
            child:
                clickable
                    ? InkWell(
                      onTap: () => vm.openCellDetail(r),
                      child: Row(
                        children: [
                          Flexible(child: label),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.insights_rounded,
                            size: 20,
                            color: Color.fromARGB(255, 216, 142, 31),
                          ),
                        ],
                      ),
                    )
                    : label,
          ),
        ],
      );
    }

    // ô số
    final text = switch (key) {
      'ngay' => vm.fmtFinanceCell(rowIndex, r.ngay),
      'luyKe' => vm.fmtFinanceCell(rowIndex, r.luyKe),
      'uoc' => vm.fmtFinanceCell(rowIndex, r.uocTh),
      'thang' => vm.fmtFinanceCell(rowIndex, r.thang),
      'lkt' => vm.fmtFinanceCell(rowIndex, r.luyKeDenThang),
      _ => '--',
    };

    final style =
        (text == '--')
            ? _numMutedStyle
            : (r.isParent ? _numTotalStyle : _numStyle);
    return Text(text, textAlign: TextAlign.center, style: style);
  }
}

class _ColDef {
  final String key;
  final String title;
  final int flex;
  const _ColDef(this.key, this.title, this.flex);
}

List<_ColDef> _colDefs(FinancePlanViewModel vm) {
  return [
    const _ColDef('name', 'Nội dung', 3), // luôn có
    if (vm.showNgay.value) const _ColDef('ngay', 'Ngày', 2),
    if (vm.showLuyKe.value) const _ColDef('luyKe', 'Lũy kế', 2),
    if (vm.showUocTH.value) const _ColDef('uoc', 'Ước thực hiện', 2),
    if (vm.showThang.value) const _ColDef('thang', 'Tháng', 2),
    if (vm.showLuyKeDenThang.value) const _ColDef('lkt', 'Lũy kế đến tháng', 2),
  ];
}

class _TopFilterBar extends StatelessWidget {
  const _TopFilterBar({required this.vm});
  final FinancePlanViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Nút mở cài đặt ẩn/hiện cột
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: vm.openColumnSettings,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.tune, color: Color(0xFF1F2A37)),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Tháng/Năm
        _Pill(
          label: vm.monthLabel, // ví dụ: 'Tháng 8/2025'
          onTap: () => _openMonthYearPicker(context, vm),
        ),
        const SizedBox(width: 8),

        // Sân bay
        _Pill(
          label: vm.selectedAirport.value, // ví dụ: 'Sân bay'
          onTap: () => _openAirportPicker(context, vm),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: StadiumBorder(
            side: BorderSide(color: Color(0xFFE6ECF5), width: 1.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4B5563)),
          ],
        ),
      ),
    );
  }
}

Future<void> _openMonthYearPicker(
  BuildContext context,
  FinancePlanViewModel vm,
) {
  final months = List<int>.generate(12, (i) => i + 1);
  final years = List<int>.generate(7, (i) => DateTime.now().year - 2 + i);

  int m = vm.selectedMonth.value;
  int y = vm.selectedYear.value;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder:
        (_) => _MonthYearSheet(
          title: 'Thời gian',
          months: months,
          years: years,
          initMonth: m,
          initYear: y,
          onApply: (mm, yy) => vm.setMonthYear(mm, yy),
        ),
  );
}

class _MonthYearSheet extends StatefulWidget {
  const _MonthYearSheet({
    required this.title,
    required this.months,
    required this.years,
    required this.initMonth,
    required this.initYear,
    required this.onApply,
  });
  final String title;
  final List<int> months, years;
  final int initMonth, initYear;
  final void Function(int m, int y) onApply;

  @override
  State<_MonthYearSheet> createState() => _MonthYearSheetState();
}

class _MonthYearSheetState extends State<_MonthYearSheet> {
  late int m = widget.initMonth;
  late int y = widget.initYear;

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
                        onSelectedItemChanged: (i) => m = widget.months[i],
                        children:
                            widget.months
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
                          initialItem: widget.years.indexOf(y),
                        ),
                        itemExtent: 36,
                        onSelectedItemChanged: (i) => y = widget.years[i],
                        children:
                            widget.years
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
                          setState(() {});
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
                          widget.onApply(m, y);
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
    );
  }
}

Future<void> _openAirportPicker(BuildContext context, FinancePlanViewModel vm) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder:
        (_) => _SimpleListSheet(
          title: 'Sân bay',
          options: vm.airportOptions, // List<String>
          initial: vm.selectedAirport.value,
          onApply: vm.setAirport, // (String v) {}
        ),
  );
}

class _SimpleListSheet extends StatefulWidget {
  const _SimpleListSheet({
    required this.title,
    required this.options,
    required this.initial,
    required this.onApply,
  });
  final String title;
  final List<String> options;
  final String initial;
  final void Function(String) onApply;

  @override
  State<_SimpleListSheet> createState() => _SimpleListSheetState();
}

class _SimpleListSheetState extends State<_SimpleListSheet> {
  late String _picked = widget.initial;
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
              SizedBox(
                height: 48,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        widget.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemBuilder: (_, i) {
                    final o = widget.options[i];
                    final selected = o == _picked;
                    return ListTile(
                      onTap: () => setState(() => _picked = o),
                      title: Text(
                        o,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      trailing: selected ? const Icon(Icons.check) : null,
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: widget.options.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            () =>
                                setState(() => _picked = widget.options.first),
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
                          widget.onApply(_picked);
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
    );
  }
}

class _NumCell extends StatelessWidget {
  const _NumCell(this.text, {this.width = 140});
  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 44,
      alignment: Alignment.center, // trung tâm cả dọc + ngang
      child: Text(
        text,
        textAlign: TextAlign.center, // căn giữa chữ trong ô
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis, // tránh xuống dòng số bị xấu
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

const Color _kVLine = Color(0xFFE6ECF5);

class _VSep extends StatelessWidget {
  const _VSep({this.h = 44, this.color = _kVLine});
  final double h;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 1, height: h, child: ColoredBox(color: color));
}

class _Hdr extends StatelessWidget {
  const _Hdr(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }
}
