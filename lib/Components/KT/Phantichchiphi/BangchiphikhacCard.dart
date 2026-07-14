import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ====== MODEL ======
class BangchiphikhacRow {
  final String chinhanh;
  final int soLuong;
  final double sanLuong;
  final double tongCP;
  final double donGia;

  BangchiphikhacRow({
    required this.chinhanh,
    required this.soLuong,
    required this.sanLuong,
    required this.tongCP,
    required this.donGia,
  });

  factory BangchiphikhacRow.fromMap(Map<String, dynamic> map, String type) {
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll(',', '');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    final soLuongField = type == 'kho_be' ? 'Sobe' : 'Sophong_TN';
    final tongCPField = type == 'kho_be' ? 'TONG_CP' : 'TONG_CP';
    final donGiaField = type == 'kho_be' ? 'Don_gia' : 'Don_gia';

    final tongCP = _parseDouble(map[tongCPField]);
    final donGia = _parseDouble(map[donGiaField]);
    final soLuong = (map[soLuongField] as num?)?.toInt() ?? 0;
    final sanLuong = _parseDouble(map['SanLuong']);

    return BangchiphikhacRow(
      chinhanh: map['Chinhanh']?.toString() ?? '',
      soLuong: soLuong,
      sanLuong: sanLuong,
      tongCP: tongCP,
      donGia: donGia,
    );
  }
}

// ====== CONTROLLER ======
class BangchiphikhacController extends GetxController {
  final rows = <BangchiphikhacRow>[].obs;
  final loading = false.obs;

  // Cài đặt cột
  final showChiNhanh = true.obs;
  final showSoLuong = true.obs;
  final showSanLuong = true.obs;
  final showTongChiPhiKT = true.obs;
  final showDonGia = true.obs;

  void loadData(List<Map<String, dynamic>> data, String type) {
    rows.assignAll(data.map((e) => BangchiphikhacRow.fromMap(e, type)).toList());
  }

  String fmt(num? v, {int decimals = 0}) {
    if (v == null || v == 0) return '--';
    if (decimals == 0) {
      return NumberFormat('#,##0', 'vi_VN').format(v);
    }
    return NumberFormat('#,##0.${'0' * decimals}', 'vi_VN').format(v);
  }

  String fmtTrieu(num? v) {
    if (v == null || v == 0) return '--';
    final n = v / 1e6;
    return NumberFormat('#,##0.##', 'vi_VN').format(n) + ' Triệu';
  }

  String fmtSanLuong(num? v) {
    if (v == null || v == 0) return '--';
    return NumberFormat('#,##0.##', 'vi_VN').format(v);
  }

  void openColumnSettings() {
    final ctx = Get.context;
    if (ctx == null) return;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ColumnSettingsSheet(controller: this),
    );
  }
}

// ====== COLUMN DEFINITION ======
class _ColDef {
  final String key;
  final String title;
  final double flex;

  const _ColDef(this.key, this.title, this.flex);
}

// ====== WIDGET CHÍNH ======
class BangchiphikhacCard extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final String type; // 'kho_be' hoặc 'hang_hiem'

  const BangchiphikhacCard({
    super.key,
    required this.data,
    required this.title,
    required this.type,
  });

  @override
  State<BangchiphikhacCard> createState() => _BangchiphikhacCardState();
}

class _BangchiphikhacCardState extends State<BangchiphikhacCard> {
  late BangchiphikhacController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(BangchiphikhacController(), tag: widget.type);
    _controller.loadData(widget.data, widget.type);
  }

  @override
  void didUpdateWidget(BangchiphikhacCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data || oldWidget.type != widget.type) {
      _controller.loadData(widget.data, widget.type);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: _controller.openColumnSettings,
            ),
          ),
          _TableHeader(controller: _controller),
          const Divider(height: 1),
          _TableBody(controller: _controller),
        ],
      ),
    );
  }
}

// ====== HÀM XÂY DỰNG DEFS ======
List<_ColDef> _buildDefs(BangchiphikhacController c) {
  final defs = <_ColDef>[];

  if (c.showChiNhanh.value) {
    defs.add(const _ColDef('chiNhanh', 'Chi nhánh', 1.2));
  }
  if (c.showSoLuong.value) {
    defs.add(const _ColDef('soLuong', 'Số lượng', 0.8));
  }
  if (c.showSanLuong.value) {
    defs.add(const _ColDef('sanLuong', 'Sản lượng', 1.2));
  }
  if (c.showTongChiPhiKT.value) {
    defs.add(const _ColDef('tongChiPhiKT', 'Tổng chi phí\nkỹ thuật', 1.2));
  }
  if (c.showDonGia.value) {
    defs.add(const _ColDef('donGia', 'Đơn giá chi\n/sản lượng', 1.2));
  }

  return defs;
}

double _getTotalFlex(BangchiphikhacController c) {
  double total = 0;
  if (c.showChiNhanh.value) total += 1.2;
  if (c.showSoLuong.value) total += 0.8;
  if (c.showSanLuong.value) total += 1.2;
  if (c.showTongChiPhiKT.value) total += 1.2;
  if (c.showDonGia.value) total += 1.2;
  return total;
}

// ====== HEADER BẢNG ======
class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.controller});
  final BangchiphikhacController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final defs = _buildDefs(controller);
      final totalFlex = _getTotalFlex(controller);
      
      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - 16;
          final columnWidth = availableWidth / totalFlex;
          
          return Container(
            color: const Color(0xFF4D73B2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < defs.length; i++)
                    SizedBox(
                      width: columnWidth * defs[i].flex,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Text(
                          defs[i].title,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

// ====== BODY BẢNG ======
class _TableBody extends StatelessWidget {
  const _TableBody({required this.controller});
  final BangchiphikhacController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.rows;
      if (rows.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }
      
      final defs = _buildDefs(controller);
      final totalFlex = _getTotalFlex(controller);
      
      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - 16;
          final columnWidth = availableWidth / totalFlex;
          
          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE6ECF5)),
            itemBuilder: (_, index) => _RowWidget(
              controller: controller,
              row: rows[index],
              index: index,
              defs: defs,
              columnWidth: columnWidth,
            ),
          );
        },
      );
    });
  }
}

// ====== ROW WIDGET ======
class _RowWidget extends StatelessWidget {
  final int index;
  final BangchiphikhacRow row;
  final List<_ColDef> defs;
  final double columnWidth;
  final BangchiphikhacController controller;

  const _RowWidget({
    required this.controller,
    required this.row,
    required this.index,
    required this.defs,
    required this.columnWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: index % 2 == 0 ? Colors.white : const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < defs.length; i++)
              SizedBox(
                width: columnWidth * defs[i].flex,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: _cell(defs[i].key, row),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String key, BangchiphikhacRow row) {
    final text = switch (key) {
      'chiNhanh' => row.chinhanh,
      'soLuong' => row.soLuong.toString(),
      'sanLuong' => controller.fmtSanLuong(row.sanLuong),
      'tongChiPhiKT' => controller.fmt(row.tongCP),
      'donGia' => controller.fmt(row.donGia),
      _ => '--',
    };

    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: text == '--' ? Colors.grey.shade400 : Colors.black87,
        fontWeight: text == '--' ? FontWeight.w400 : FontWeight.w500,
        height: 1.2,
      ),
    );
  }
}

// ====== COLUMN SETTINGS SHEET ======
class _ColumnSettingsSheet extends StatelessWidget {
  const _ColumnSettingsSheet({required this.controller});
  final BangchiphikhacController controller;

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Cài đặt hiển thị',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _switch('Chi nhánh', controller.showChiNhanh),
                        _switch('Số lượng', controller.showSoLuong),
                        _switch('Sản lượng', controller.showSanLuong),
                        _switch('Tổng chi phí kỹ thuật', controller.showTongChiPhiKT),
                        _switch('Đơn giá chi/sản lượng', controller.showDonGia),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.showChiNhanh.value = true;
                          controller.showSoLuong.value = true;
                          controller.showSanLuong.value = true;
                          controller.showTongChiPhiKT.value = true;
                          controller.showDonGia.value = true;
                          controller.update();
                        },
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Mặc định'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Áp dụng'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switch(String title, RxBool bind) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
          Obx(() => Switch(
            value: bind.value,
            onChanged: (v) => bind.value = v,
          )),
        ],
      ),
    );
  }
}