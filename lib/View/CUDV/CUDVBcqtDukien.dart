// views/cudv_bcqt_dukien_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/CUDV/CUDVBcqtDukienViewModel.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/BangCanDoiHangHoaCard.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/PieChartSanLuongTheoKhuVucCard.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/PieChartSanLuongTheoKhachHangCard.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/MultiColumnUocTinhSanLuongBanCard.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/PlattsSummaryCard.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/BangPlattsDuKienCard.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/LineChartBieuDoGiaPlattCard.dart';

import 'package:skypec/Components/CUDV/Baocaoquantri/BangBienDongLoiNhuanCard.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/BangPhanTichLoiNhuanCard.dart';

class CUDVBcqtDukien extends GetView<CUDVBcqtDukienViewModel> {
  const CUDVBcqtDukien({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('BÁO CÁO QUẢN TRỊ - DỰ KIẾN'),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refreshData,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/images/background_inside.png',
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error.value.isNotEmpty) {
                return Center(child: Text(controller.error.value));
              }
              if (!controller.hasData) {
                return const Center(child: Text('Không có dữ liệu'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ═══════════════════════════════════════
                    // 1. CÂN ĐỐI HÀNG HÓA KINH DOANH
                    // ═══════════════════════════════════════
                    const _SectionHeader(
                      title: 'CÂN ĐỐI HÀNG HÓA KINH DOANH',
                      icon: Icons.inventory_2,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => _CommentBox(text: controller.commentCanDoi.value)),
                    const SizedBox(height: 12),
                    Obx(() => BangCanDoiHangHoaCard(
                          data: controller.bangCanDoiHangHoa.toList(),
                        )),

                    const SizedBox(height: 32),

                    // ═══════════════════════════════════════
                    // 2. CƠ CẤU BÁN
                    // ═══════════════════════════════════════
                    const _SectionHeader(
                      title: 'CƠ CẤU BÁN',
                      icon: Icons.pie_chart,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => _CommentBox(text: controller.commentCoCauBan.value)),
                    const SizedBox(height: 12),
                    Obx(() => PieChartSanLuongTheoKhuVucCard(
                          data: controller.sanLuongTheoKV.toList(),
                          title: 'SẢN LƯỢNG THEO KHU VỰC',
                        )),
                    const SizedBox(height: 16),
                    Obx(() => PieChartSanLuongTheoKhachHangCard(
                          data: controller.sanLuongTheoKH.toList(),
                          title: 'SẢN LƯỢNG THEO KHÁCH HÀNG',
                        )),
                    const SizedBox(height: 16),
                    Obx(() => MultiColumnUocTinhSanLuongBanCard(
                          data: controller.uocTinhSanLuongBan.toList(),
                          title: 'ƯỚC TÍNH SẢN LƯỢNG BÁN',
                        )),

                    const SizedBox(height: 32),

                    // ═══════════════════════════════════════
                    // 3. BIẾN ĐỘNG GIÁ PLATTS
                    // ═══════════════════════════════════════
                    const _SectionHeader(
                      title: 'BIẾN ĐỘNG GIÁ PLATTS',
                      icon: Icons.trending_up,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => PlattsSummaryCard(
                          plattsThangTruoc: controller.plattsThangTruoc,
                          plattsHienTai: controller.plattsHienTai,
                          diff: controller.plattsDiff,
                          diffPercent: controller.plattsDiffPercent,
                        )),
                    const SizedBox(height: 16),
                    Obx(() => BangPlattsDuKienCard(
                          data: controller.plattsBQDuKien.toList(),
                          title: 'BẢNG PLATTS DỰ KIẾN',
                        )),
                    const SizedBox(height: 16),
                    Obx(() => LineChartBieuDoGiaPlattCard(
                          data: controller.bieuDoGiaPlatt.toList(),
                          title: 'BIỂU ĐỒ GIÁ PLATTS',
                        )),

                    const SizedBox(height: 32),

                    // ═══════════════════════════════════════
                    // ⭐ 4. LỢI NHUẬN THÁNG
                    // ═══════════════════════════════════════
                    const _SectionHeader(
                      title: 'LỢI NHUẬN THÁNG',
                      icon: Icons.attach_money,
                    ),
                    const SizedBox(height: 8),

                    // Bảng biến động lợi nhuận
                    Obx(() => BangBienDongLoiNhuanCard(
                          data: controller.bangBienDongLoiNhuan.toList(),
                          title: 'BIẾN ĐỘNG LỢI NHUẬN THÁNG',
                        )),
                    const SizedBox(height: 16),

                    // Bảng phân tích lợi nhuận
                    Obx(() => BangPhanTichLoiNhuanCard(
                          data: controller.bangPhanTichLoiNhuan.toList(),
                          title: 'PHÂN TÍCH LỢI NHUẬN',
                        )),

                    const SizedBox(height: 80),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F7BD8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// COMMENT BOX
// ═══════════════════════════════════════════════════════════
class _CommentBox extends StatelessWidget {
  final String text;

  const _CommentBox({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1F2A37),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}