// components/Atcl/Bangbaocaongay/bangbaocaongay_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Controller/Atcl/Baocaongay/ChitietsucosuviecViewModel.dart';
import 'package:skypec/View/Atcl/Baocaongay/Chitietsucosuviec.dart';

class BangbaocaongayRow {
  final int maBaoCao;
  final String nguoiThucHien;
  final DateTime ngayBaoCao;
  final String coSuKienMatAnToanString;
  final DateTime thoiGianXacNhan;
  final String tileHoanThanh;
  final String? orgStructureName;
  final String? gioTaiNan;
  final String? phuongTienThietBi;
  final String? canhanlienquan;

  BangbaocaongayRow({
    required this.maBaoCao,
    required this.nguoiThucHien,
    required this.ngayBaoCao,
    required this.coSuKienMatAnToanString,
    required this.thoiGianXacNhan,
    required this.tileHoanThanh,
    this.orgStructureName,
    this.gioTaiNan,
    this.phuongTienThietBi,
    this.canhanlienquan,
  });

  factory BangbaocaongayRow.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return BangbaocaongayRow(
      maBaoCao: (map['MaBaoCao'] as num?)?.toInt() ?? 0,
      nguoiThucHien: map['NguoiThucHien']?.toString() ?? '',
      ngayBaoCao: parseDate(map['NgayBaoCao']),
      coSuKienMatAnToanString: map['CoSuKienMatAnToanString']?.toString() ?? 'Không có',
      thoiGianXacNhan: parseDate(map['ThoiGianXacNhan']),
      tileHoanThanh: map['TileHoanThanh']?.toString() ?? '0/0',
      orgStructureName: map['OrgStructureName']?.toString(),
      gioTaiNan: map['GioTaiNan']?.toString(),
      phuongTienThietBi: map['PhuongTienThietBi']?.toString(),
      canhanlienquan: map['Canhanlienquan']?.toString(),
    );
  }
}

class BangbaocaongayController extends GetxController {
  final allRows = <BangbaocaongayRow>[].obs;
  final displayRows = <BangbaocaongayRow>[].obs;
  final loading = false.obs;

  final currentPage = 1.obs;
  final pageSize = 20.obs;
  final totalPages = 1.obs;

  void loadData(List<Map<String, dynamic>> data) {
    allRows.assignAll(data.map((e) => BangbaocaongayRow.fromMap(e)).toList());
    _updateDisplayRows();
  }

  void _updateDisplayRows() {
    final start = (currentPage.value - 1) * pageSize.value;
    final end = (start + pageSize.value).clamp(0, allRows.length);
    displayRows.assignAll(allRows.sublist(start, end));
    totalPages.value = (allRows.length / pageSize.value).ceil();
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;
    currentPage.value = page;
    _updateDisplayRows();
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      _updateDisplayRows();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      _updateDisplayRows();
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}

class _ColDef {
  final String key;
  final String title;
  final double width; // Width cố định

  const _ColDef(this.key, this.title, this.width);
}

class BangbaocaongayCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const BangbaocaongayCard({
    super.key,
    required this.data,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BangbaocaongayController())..loadData(data);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF1F2A37),
              ),
            ),
          ),
          _TableContent(controller: controller),
          const SizedBox(height: 8),
          _PaginationBar(controller: controller),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TableContent extends StatelessWidget {
  const _TableContent({required this.controller});

  final BangbaocaongayController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.displayRows;

      if (rows.isEmpty) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      final defs = _buildDefs();

      // Header
      List<Widget> headerChildren = [];
      for (int i = 0; i < defs.length; i++) {
        headerChildren.add(
          Container(
            width: defs[i].width,
            height: 42,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF4D73B2),
              border: Border(
                right: BorderSide(color: Colors.white, width: 0.5),
              ),
            ),
            child: Text(
              defs[i].title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        );
      }

      // Data rows
      List<Widget> dataRows = [];
      for (int index = 0; index < rows.length; index++) {
        final row = rows[index];
        List<Widget> rowCells = [];
        for (int i = 0; i < defs.length; i++) {
          rowCells.add(
            SizedBox(
              width: defs[i].width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: _cell(defs[i].key, row),
              ),
            ),
          );
        }

        dataRows.add(
          Container(
            color: index % 2 == 0 ? Colors.white : const Color(0xFFF8F9FA),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: rowCells,
            ),
          ),
        );

        if (index < rows.length - 1) {
          dataRows.add(
            const Divider(height: 1, thickness: 1, color: Color(0xFFE6ECF5)),
          );
        }
      }

      final totalWidth = defs.fold(0.0, (sum, def) => sum + def.width);

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: totalWidth + 18,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xFFDEE2E6), width: 1),
              right: BorderSide(color: Color(0xFFDEE2E6), width: 1),
            ),
          ),
          child: Column(
            children: [
              Row(children: headerChildren),
              const Divider(height: 1, thickness: 1, color: Color(0xFF94A3B8)),
              ...dataRows,
            ],
          ),
        ),
      );
    });
  }

  List<_ColDef> _buildDefs() {
    return const [
      // ID - nhỏ đi 1 nửa (120 -> 60)
      _ColDef('maBaoCao', 'ID', 60),
      
      // Đơn vị thực hiện - 3/4 (120 -> 90)
      _ColDef('nguoiThucHien', 'ĐƠN VỊ\nTHỰC HIỆN', 90),
      
      // Ngày báo cáo - giữ nguyên
      _ColDef('ngayBaoCao', 'NGÀY\nBÁO CÁO', 100),
      
      // Sự kiện - tăng width
      _ColDef('coSuKien', 'SỰ KIỆN', 140),
      
      // Ngày xác nhận - giữ nguyên
      _ColDef('thoiGianXacNhan', 'NGÀY\nXÁC NHẬN', 100),
      
      // Hoàn thành - nhỏ đi 1 nửa (120 -> 60)
      _ColDef('tileHoanThanh', 'HOÀN\nTHÀNH', 60),
      
      // Đơn vị/Chi nhánh - tăng width
      _ColDef('orgStructureName', 'ĐƠN VỊ CHI NHÁNH', 200),
      
      // Giờ xảy ra - 3/4 (120 -> 90)
      _ColDef('gioTaiNan', 'GIỜ\nXẢY RA', 90),
      
      // Biển kiểm soát - tăng width
      _ColDef('phuongTien', 'BIỂN KIỂM SOÁT', 160),
      
      // Cá nhân liên quan - tăng width
      _ColDef('canhanlienquan', 'CÁ NHÂN\nLIÊN QUAN', 180),
    ];
  }

  Widget _cell(String key, BangbaocaongayRow row) {
    switch (key) {
      case 'maBaoCao':
  return InkWell(
    onTap: () {
      Get.to(
        () => const Chitietsucosuviec(),
        arguments: {'MaBaoCao': row.maBaoCao},
        binding: BindingsBuilder(() {
          Get.put(ChitietsucosuviecViewModel());
        }),
      );
    },
    child: Text(
      row.maBaoCao.toString(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2563EB),
        decoration: TextDecoration.underline,
      ),
      textAlign: TextAlign.center,
    ),
  );

      case 'nguoiThucHien':
        return Text(
          row.nguoiThucHien,
          style: const TextStyle(fontSize: 12),
        );
      case 'ngayBaoCao':
        return Text(
          controller.formatDate(row.ngayBaoCao),
          style: const TextStyle(fontSize: 12),
        );
      case 'coSuKien':
        return Text(
          row.coSuKienMatAnToanString,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: row.coSuKienMatAnToanString != 'Không có' 
                ? Colors.red 
                : Colors.green,
          ),
        );
      case 'thoiGianXacNhan':
        return Text(
          controller.formatDate(row.thoiGianXacNhan),
          style: const TextStyle(fontSize: 12),
        );
      case 'tileHoanThanh':
        return Text(
          row.tileHoanThanh,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: row.tileHoanThanh == '1/1' ? Colors.green : Colors.grey,
          ),
          textAlign: TextAlign.center,
        );
      case 'orgStructureName':
        return Text(
          row.orgStructureName ?? '--',
          style: const TextStyle(fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case 'gioTaiNan':
        return Text(
          row.gioTaiNan ?? '--',
          style: const TextStyle(fontSize: 12),
        );
      case 'phuongTien':
        return Text(
          row.phuongTienThietBi ?? '--',
          style: const TextStyle(fontSize: 12),
        );
      case 'canhanlienquan':
        return Text(
          row.canhanlienquan ?? '--',
          style: const TextStyle(fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      default:
        return const Text('--');
    }
  }
}

// ============================================================
// PAGINATION BAR
// ============================================================

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.controller});

  final BangbaocaongayController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.currentPage.value;
      final total = controller.totalPages.value;
      final totalRecords = controller.allRows.length;

      if (totalRecords == 0) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hiển thị ${controller.displayRows.length}/${totalRecords} bản ghi',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            
            Row(
              children: [
                IconButton(
                  onPressed: current > 1 ? controller.previousPage : null,
                  icon: const Icon(Icons.chevron_left),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 24,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5EAF2)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$current / $total',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: current < total ? controller.nextPage : null,
                  icon: const Icon(Icons.chevron_right),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 24,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}