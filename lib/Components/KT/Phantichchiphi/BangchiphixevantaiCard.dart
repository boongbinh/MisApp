import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ====== MODEL ======
class BangchiphixevantaiRow {
  final String donvi;
  final String maKX;
  final int soLuongMaKX;
  final double tongSoGio;
  final double tongTongchiphi;
  final double donGiaXe;
  final double donGiaGio;

  BangchiphixevantaiRow({
    required this.donvi,
    required this.maKX,
    required this.soLuongMaKX,
    required this.tongSoGio,
    required this.tongTongchiphi,
    required this.donGiaXe,
    required this.donGiaGio,
  });

  factory BangchiphixevantaiRow.fromMap(Map<String, dynamic> map) {
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll(',', '');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    final tongTongchiphi = _parseDouble(map['TongTongchiphi']);
    final soLuongMaKX = (map['SoLuongMaKX'] as num?)?.toInt() ?? 1;
    final tongSoGio = _parseDouble(map['TongSo_gio']);

    return BangchiphixevantaiRow(
      donvi: map['DONVI']?.toString() ?? '',
      maKX: map['ma_kx']?.toString() ?? '',
      soLuongMaKX: soLuongMaKX,
      tongSoGio: tongSoGio,
      tongTongchiphi: tongTongchiphi,
      donGiaXe: soLuongMaKX > 0 ? tongTongchiphi / soLuongMaKX : 0,
      donGiaGio: tongSoGio > 0 ? tongTongchiphi / tongSoGio : 0,
    );
  }
}

// ====== CONTROLLER ======
class BangchiphixevantaiController extends GetxController {
  final rows = <BangchiphixevantaiRow>[].obs;
  final loading = false.obs;

  // Cài đặt cột
  final showChungLoaiXe = true.obs;
  final showSoLuongXe = true.obs;
  final showSoGioHoatDong = true.obs;
  final showTongChiPhiKT = true.obs;
  final showDonGiaXe = true.obs;
  final showDonGiaGio = true.obs;

  void loadData(List<Map<String, dynamic>> data) {
    rows.assignAll(data.map((e) => BangchiphixevantaiRow.fromMap(e)).toList());
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
class BangchiphixevantaiCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const BangchiphixevantaiCard({
    super.key,
    required this.data,
    this.title = 'BẢNG CHI PHÍ XE VẬN TẢI',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BangchiphixevantaiController())..loadData(data);

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
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: controller.openColumnSettings,
            ),
          ),
          _TableHeader(controller: controller),
          const Divider(height: 1),
          _TableBody(controller: controller),
        ],
      ),
    );
  }
}

// ====== HÀM XÂY DỰNG DEFS ======
List<_ColDef> _buildDefs(BangchiphixevantaiController c) {
  final defs = <_ColDef>[];

  if (c.showChungLoaiXe.value) {
    defs.add(const _ColDef('maKX', 'Chủng loại xe', 2.0));
  }
  if (c.showSoLuongXe.value) {
    defs.add(const _ColDef('soLuong', 'Số lượng xe', 0.7));
  }
  if (c.showSoGioHoatDong.value) {
    defs.add(const _ColDef('soGio', 'Số giờ\nhoạt động', 0.9));
  }
  if (c.showTongChiPhiKT.value) {
    defs.add(const _ColDef('tongChiPhiKT', 'Tổng chi phí\nkỹ thuật', 1.1));
  }
  if (c.showDonGiaXe.value) {
    defs.add(const _ColDef('donGiaXe', 'Đơn giá chi\nphí/xe', 1.0));
  }
  if (c.showDonGiaGio.value) {
    defs.add(const _ColDef('donGiaGio', 'Đơn giá chi phí\n/giờ hoạt động', 1.0));
  }

  return defs;
}

double _getTotalFlex(BangchiphixevantaiController c) {
  double total = 0;
  if (c.showChungLoaiXe.value) total += 2.0;
  if (c.showSoLuongXe.value) total += 0.7;
  if (c.showSoGioHoatDong.value) total += 0.9;
  if (c.showTongChiPhiKT.value) total += 1.1;
  if (c.showDonGiaXe.value) total += 1.0;
  if (c.showDonGiaGio.value) total += 1.0;
  return total;
}

// ====== HEADER BẢNG ======
class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.controller});
  final BangchiphixevantaiController controller;

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
  final BangchiphixevantaiController controller;

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
  final BangchiphixevantaiRow row;
  final List<_ColDef> defs;
  final double columnWidth;
  final BangchiphixevantaiController controller;

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

  Widget _cell(String key, BangchiphixevantaiRow row) {
    final text = switch (key) {
      'maKX' => row.maKX,
      'soLuong' => row.soLuongMaKX.toString(),
      'soGio' => controller.fmt(row.tongSoGio, decimals: 0),
      'tongChiPhiKT' => controller.fmt(row.tongTongchiphi),
      'donGiaXe' => controller.fmt(row.donGiaXe),
      'donGiaGio' => controller.fmt(row.donGiaGio),
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
  final BangchiphixevantaiController controller;

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
                        _switch('Chủng loại xe', controller.showChungLoaiXe),
                        _switch('Số lượng xe', controller.showSoLuongXe),
                        _switch('Số giờ hoạt động', controller.showSoGioHoatDong),
                        _switch('Tổng chi phí kỹ thuật', controller.showTongChiPhiKT),
                        _switch('Đơn giá chi phí/xe', controller.showDonGiaXe),
                        _switch('Đơn giá chi phí/giờ hoạt động', controller.showDonGiaGio),
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
                          controller.showChungLoaiXe.value = true;
                          controller.showSoLuongXe.value = true;
                          controller.showSoGioHoatDong.value = true;
                          controller.showTongChiPhiKT.value = true;
                          controller.showDonGiaXe.value = true;
                          controller.showDonGiaGio.value = true;
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