import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/QTTC/FuelProfitViewModel.dart';

class FuelProfit extends GetView<FuelProfitViewModel> {
  const FuelProfit({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin lợi nhuận nhiên liệu'),
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
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsCard(vm: vm),
              const SizedBox(height: 12),
              _AnalysisCard(vm: vm),
            ],
          ),
        );
      }),
    );
  }
}

/* ------------ Stats -------------- */

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.vm});
  final FuelProfitViewModel vm;

  static const _labelStyle = TextStyle(
    fontWeight: FontWeight.w600,
    color: Color(0xFF6B7280),
  );
  static const _valueStyle = TextStyle(
    fontWeight: FontWeight.w700,
    color: Color(0xFF111827),
  );

  @override
  Widget build(BuildContext context) {
    Widget statRow(String label, String value) => Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _labelStyle)),
          Text(value, style: _valueStyle), // số nằm cùng hàng, bên phải
        ],
      ),
    );

    return Container(
      decoration: _cardDeco,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          statRow('Tổng lượng xuất:', vm.fmtInt(vm.totalLuongXuat.value)),
          const Divider(height: 1),
          statRow('Tổng lượng lợi nhuận:', vm.fmtInt(vm.totalLoiNhuan.value)),
        ],
      ),
    );
  }
}

/* ------------ Table -------------- */

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.vm});
  final FuelProfitViewModel vm;

  static const _blue = Color(0xFF4D73B2);

  @override
  Widget build(BuildContext context) {
    final rows = vm.rows;

    return Container(
      decoration: _cardDeco,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'Phân tích lượng hàng bán',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Header
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              height: 44,
              color: _blue,
              child: Row(
                children: const [
                  _HeadCell('STT', flex: 1),
                  _HeadCell('Tháng nhập', flex: 3),
                  _HeadCell('Giá', flex: 2),
                  _HeadCell('Lượng xuất', flex: 3),
                  _HeadCell('Lợi nhuận', flex: 3),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Body
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: rows.length,
            separatorBuilder:
                (_, __) => const Divider(height: 1, color: Color(0xFFE6ECF5)),
            itemBuilder: (_, i) {
              final r = rows[i];
              final isLast = i == rows.length - 1;
              final profit = r.loiNhuan;
              final profitStyle = TextStyle(
                fontWeight: FontWeight.w700,
                color:
                    profit >= 0
                        ? const Color(0xFF059669)
                        : const Color(0xFFEF4444),
              );

              Widget cell(
                String text,
                int flex, {
                bool left = false,
                TextStyle? style,
                bool last = false,
              }) {
                return Expanded(
                  flex: flex,
                  child: Container(
                    height: 44,
                    alignment: left ? Alignment.centerLeft : Alignment.center,
                    padding: EdgeInsets.only(left: left ? 12 : 8, right: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color:
                              last
                                  ? Colors.transparent
                                  : const Color(0xFFE6ECF5),
                        ),
                      ),
                    ),
                    child: Text(text, style: style),
                  ),
                );
              }

              return Row(
                children: [
                  cell('${i + 1}', 1),
                  cell(r.thangNhap, 3, left: true),
                  cell(vm.fmtDec(r.platts, 3), 2),
                  cell(vm.fmtInt(r.luongXuat), 3),
                  cell(
                    vm.fmtInt(profit.abs()) * (profit < 0 ? -1 : 1) is String
                        ? (profit < 0
                            ? '-${vm.fmtInt(profit.abs())}'
                            : vm.fmtInt(profit))
                        : vm.fmtInt(profit),
                    3,
                    style: profitStyle,
                    last: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell(this.title, {required this.flex});
  final String title;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Color(0xFFE6ECF5))),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          child: Text(title),
        ),
      ),
    );
  }
}

/* ------------ common -------------- */

final _cardDeco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
  ],
);
