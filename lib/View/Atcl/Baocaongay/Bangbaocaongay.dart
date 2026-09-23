// views/bangbaocaongay_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/Atcl/Baocaongay/BangbaocaongayViewModel.dart';
import 'package:skypec/Components/Atcl/Baocaongay/BangbaocaongayCard.dart';

class Bangbaocaongay extends GetView<BangbaocaongayViewModel> {
  const Bangbaocaongay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('BẢNG BÁO CÁO NGÀY'),
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
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    // ====== Card Bảng báo cáo ngày ======
                    Obx(() {
                      if (controller.bangBaoCaoNgay.isEmpty) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Không có dữ liệu',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return BangbaocaongayCard(
                        data: controller.bangBaoCaoNgay.toList(),
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