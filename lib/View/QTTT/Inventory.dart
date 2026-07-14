import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/QTTT/InventoryViewModel.dart';

class Inventory extends GetView<InventoryViewModel> {
  const Inventory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Cân đối hàng tồn'),
        foregroundColor: Colors.white,
        centerTitle: true,
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
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _InventoryTable(),
        );
      }),
    );
  }
}

class _InventoryTable extends GetView<InventoryViewModel> {
  @override
  Widget build(BuildContext context) {
    final headerStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );
    final cellStyle = const TextStyle(color: Color(0xFF111827), fontSize: 14);

    // Bảng trong thẻ trắng bo góc + đổ bóng nhẹ
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          // kẻ vạch trong bảng
          border: const TableBorder(
            horizontalInside: BorderSide(color: Color(0xFFE6ECF5), width: 1),
            verticalInside: BorderSide(color: Color(0xFFE6ECF5), width: 1),
          ),
          columnWidths: const {
            0: FlexColumnWidth(1.2), // Tháng
            1: FlexColumnWidth(1.6), // Tồn đầu
            2: FlexColumnWidth(1.2), // Nhập
            3: FlexColumnWidth(1.2), // Bán
            4: FlexColumnWidth(1.3), // Chênh lệch
          },
          children: [
            // Header xanh
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF2E6D90)),
              children: const [
                _HeaderCell('Tháng'),
                _HeaderCell('Tồn đầu'),
                _HeaderCell('Nhập'),
                _HeaderCell('Bán'),
                _HeaderCell('Chênh lệch'),
              ],
            ),
            // Dòng dữ liệu
            ...controller.rows.map((r) {
              final chenh = r.chenhLech;
              final chenhColor =
                  chenh > 0
                      ? const Color(0xFF16A34A) // xanh
                      : (chenh < 0
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF111827));
              return TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _Cell(
                    controller.monthLabel(r),
                    style: cellStyle,
                    align: TextAlign.center,
                  ),
                  _Cell(
                    controller.fmt3(r.tonDau),
                    style: cellStyle,
                    align: TextAlign.right,
                  ),
                  _Cell(
                    controller.fmt2(r.nhap),
                    style: cellStyle,
                    align: TextAlign.right,
                  ),
                  _Cell(
                    controller.fmt2(r.ban),
                    style: cellStyle,
                    align: TextAlign.right,
                  ),
                  _Cell(
                    controller.fmt3(chenh),
                    style: cellStyle.copyWith(color: chenhColor),
                    align: TextAlign.right,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {this.align = TextAlign.left, this.style});
  final String text;
  final TextAlign align;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(text, textAlign: align, style: style),
    );
  }
}
