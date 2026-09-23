// views/danhgiavapheduyet_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/Atcl/Baocaongay/DanhgiavapheduyetViewModel.dart';
import 'package:skypec/Components/Atcl/Baocaongay/DanhgiabaocaongayCard.dart';

class Danhgiavapheduyet extends GetView<DanhgiavapheduyetViewModel> {
  const Danhgiavapheduyet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('ĐÁNH GIÁ VÀ PHÊ DUYỆT BÁO CÁO NGÀY'),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        actions: [
          // Chỉ giữ nút refresh
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
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    // ====== Card Đánh giá báo cáo ngày ======
                    Obx(() {
                      if (controller.danhGiaBaoCaoNgayData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return DanhgiabaocaongayCard(
                        dataList: controller.danhGiaBaoCaoNgayData.toList(),
                        title: 'TẦN SUẤT BÁO CÁO NGÀY',
                      );
                    }),
                    
                    const SizedBox(height: 16),

                    // ====== Card Đánh giá báo cáo tháng ======
                    Obx(() {
                      if (controller.danhGiaBaoCaoThangData.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return DanhgiabaocaongayCard(
                        dataList: controller.danhGiaBaoCaoThangData.toList(),
                        title: 'TẦN SUẤT BÁO CÁO THÁNG',
                      );
                    }),

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