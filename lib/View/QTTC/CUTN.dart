import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/QTTC/CUTNViewModel.dart';

class CUTN extends GetView<CUTNViewModel> {
  const CUTN({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lợi nhuận cung ứng tra nạp'),
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
            children: [
              _Tabs(vm: vm),
              const SizedBox(height: 12),
              _SummaryCard(vm: vm),
              const SizedBox(height: 12),
              _TableCard(vm: vm),
            ],
          ),
        );
      }),
    );
  }
}

/* -------------------- Tabs -------------------- */

class _Tabs extends StatelessWidget {
  const _Tabs({required this.vm});
  final CUTNViewModel vm;

  ChoiceChip _chip(String label, int idx) {
    final selected = vm.tab.value == idx;
    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      selected: selected,
      shape: const StadiumBorder(side: BorderSide(color: Color(0xFFE6ECF5))),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? Colors.white : const Color(0xFF1F2A37),
      ),
      selectedColor: const Color(0xFF3568DB),
      backgroundColor: Colors.white,
      onSelected: (_) => vm.switchTab(idx),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [_chip('Nhóm hàng HK', 0), _chip('Loại bay', 1)],
      ),
    );
  }
}

/* -------------------- Summary -------------------- */

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.vm});
  final CUTNViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDeco,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Thống kê',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            _sumRow('TOTAL:', vm.fmtNum(vm.currentTotal)),
            _sumRow('Chi phí cố định:', vm.fmtNum(vm.currentFixed)),
          ],
        ),
      ),
    );
  }

  Widget _sumRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

/* -------------------- Table -------------------- */

class _TableCard extends StatelessWidget {
  const _TableCard({required this.vm});
  final CUTNViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDeco,
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Thông tin lợi nhuận cung ứng tra nạp',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // Header
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF4D73B2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Obx(() {
              final col2 = vm.tab.value == 0 ? 'Hãng HK' : 'Loại bay';
              return Row(
                children: [
                  const _HeadCell('STT', flex: 1),
                  _HeadCell(col2, flex: 2),
                  const _HeadCell('Sản lượng', flex: 2),
                  const _HeadCell('% Sản lượng so với tháng trước', flex: 3),
                  const _HeadCell('Tổng lãi trên biến phí', flex: 3),
                  const _HeadCell('Tăng/giảm so với tháng trước', flex: 3),
                ],
              );
            }),
          ),
          const Divider(height: 1, color: Color(0xFFE6ECF5)),
          // Body
          Obx(() {
            final rows = vm.currentRows;
            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: rows.length,
              separatorBuilder:
                  (_, __) => const Divider(height: 1, color: Color(0xFFE6ECF5)),
              itemBuilder: (_, i) => _RowFlex(vm: vm, r: rows[i]),
            );
          }),
        ],
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell(this.text, {this.flex = 1});
  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _RowFlex extends StatelessWidget {
  const _RowFlex({required this.vm, required this.r});
  final CUTNViewModel vm;
  final SPRow r;

  @override
  Widget build(BuildContext context) {
    final pctColor =
        r.pct >= 0 ? const Color(0xFF059669) : const Color(0xFFEF4444);
    final tgColor =
        r.tg >= 0 ? const Color(0xFF059669) : const Color(0xFFEF4444);

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          _cellCenter('${r.index}', flex: 1),
          _cellLeft(r.label, flex: 2),
          _cellCenter(vm.fmtNum(r.sanLuong), flex: 2),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                vm.fmtPct(r.pct),
                style: TextStyle(fontWeight: FontWeight.w600, color: pctColor),
              ),
            ),
          ),
          _cellCenter(vm.fmtNum(r.lai), flex: 3),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                vm.fmtPct(r.tg),
                style: TextStyle(fontWeight: FontWeight.w600, color: tgColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cellLeft(String s, {int flex = 1}) => Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    ),
  );

  Widget _cellCenter(String s, {int flex = 1}) => Expanded(
    flex: flex,
    child: Center(
      child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600)),
    ),
  );
}

/* -------------------- misc -------------------- */

final _cardDeco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
  ],
);
