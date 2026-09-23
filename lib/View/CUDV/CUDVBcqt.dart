// views/cudv_bcqt_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/CUDV/CUDVBcqtViewModel.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/BangBienDongLoiNhuanCard.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/BangCanDoiHangHoaCard.dart';
import 'package:skypec/Components/CUDV/Baocaoquantri/BangPhanTichLoiNhuanCard.dart';

class CUDVBcqt extends GetView<CUDVBcqtViewModel> {
  const CUDVBcqt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('BÁO CÁO QUẢN TRỊ'),
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.error.value,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.refreshData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (!controller.hasData) {
                return const Center(
                  child: Text(
                    'Không có dữ liệu',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    // ═══════════════════════════════════════
                    // BẢNG 1: BIẾN ĐỘNG LỢI NHUẬN
                    // ═══════════════════════════════════════
                    const _SectionHeader(
                      title: 'BIẾN ĐỘNG LỢI NHUẬN',
                      icon: Icons.trending_up,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => BangBienDongLoiNhuanCard(
                          data: controller.bangBienDongLoiNhuan.toList(),
                        )),
                    const SizedBox(height: 24),

                    // ═══════════════════════════════════════
                    // BẢNG 2: CÂN ĐỐI HÀNG HÓA
                    // ═══════════════════════════════════════
                    const _SectionHeader(
                      title: 'CÂN ĐỐI HÀNG HÓA',
                      icon: Icons.inventory_2,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => BangCanDoiHangHoaCard(
                          data: controller.bangCanDoiHangHoa.toList(),
                        )),
                    const SizedBox(height: 24),

                    // ═══════════════════════════════════════
                    // BẢNG 3: PHÂN TÍCH LỢI NHUẬN
                    // ═══════════════════════════════════════
                    const _SectionHeader(
                      title: 'PHÂN TÍCH LỢI NHUẬN',
                      icon: Icons.analytics,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => BangPhanTichLoiNhuanCard(
                          data: controller.bangPhanTichLoiNhuan.toList(),
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
        color: const Color(0xFF003366),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFDC003), size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFDC003),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}