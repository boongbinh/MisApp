import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/CNMB/Khaithac/CNMBBaocaokhaithacngayViewModel.dart';
import 'package:skypec/Components/CNKV/Khaithac/SanluongtuansanbayChart.dart';
import 'package:skypec/Components/CNKV/Khaithac/SanluongtuancndpChart.dart';
import 'package:skypec/Components/CNKV/Khaithac/KehoachtranaptrongngayChart.dart';
import 'package:skypec/Components/CNKV/Khaithac/TyletonkhosanbayChart.dart';
import 'package:skypec/Components/CNKV/Khaithac/BangsogiohdsanbayCard.dart';
import 'package:skypec/Components/CNKV/Khaithac/BangsogiohdcndpCard.dart';

import 'package:skypec/Components/CNKV/Khaithac/SogiohoatdongxeChart.dart';
import 'package:intl/intl.dart';

class CNMBBaocaokhaithacngay extends GetView<CNMBBaocaokhaithacngayViewModel> {
  const CNMBBaocaokhaithacngay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Báo cáo khai thác ngày CNMB'),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
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
              if (controller.error.isNotEmpty) {
                return Center(child: Text(controller.error.value));
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  // Header thời gian
                  _DateHeader(vm: controller),
                  const SizedBox(height: 16),

                  // Thông tin điều hành khai thác
                  _ThongTinDieuHanh(vm: controller),
                  const SizedBox(height: 16),

                  // Biểu đồ sản lượng tuần sân bay
                  Obx(() {
                    if (controller.sanLuongTuanSanBay.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return SanluongtuansanbayChart(
                      data: controller.sanLuongTuanSanBay.toList(),
                      title: 'Sân bay Nội Bài-Sản lượng tuần',
                      height: 300,
                    );
                  }),
                  const SizedBox(height: 16),

                  // Biểu đồ sản lượng tuần CNDP
                  Obx(() {
                    if (controller.sanLuongTuanCNDP.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return SanluongtuancndpChart(
                      data: controller.sanLuongTuanCNDP.toList(),
                      title: 'Chi nhánh địa phương-Sản lượng tuần',
                      height: 300,
                    );
                  }),
                  const SizedBox(height: 16),
                  // Biểu đồ kế hoạch tra nạp trong ngày
                  Obx(() {
                    if (controller.keHoachTraNapTrongNgay.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return KehoachtranaptrongngayChart(
                      data: controller.keHoachTraNapTrongNgay.value,
                      title: 'Thông tin kế hoạch tra nạp trong ngày các sân bay',
                      height: 300,
                    );
                  }),
                  const SizedBox(height: 16),
                  // Biểu đồ tỷ lệ tồn kho sân bay
                  Obx(() {
                    if (controller.tyLeTonKhoSanBay.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return TyletonkhosanbayChart(
                      data: controller.tyLeTonKhoSanBay.toList(),
                      title: 'Tỷ lệ tồn kho sân bay',
                      height: 300,
                    );
                  }),
                  const SizedBox(height: 16),
                 
                  //GIỜ HOẠT ĐỘNG SÂN BAY
                  Obx(() {
                    final hasTable =controller.soGioHoatDongXeSanBay.isNotEmpty;
                    final hasChart = controller.soGioHoatDongXeSanBayChart.isNotEmpty;

                    // Cả 2 loại dữ liệu đều không có
                    if (!hasTable && !hasChart) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TabBar(
                                  labelColor: Color(0xFF1F7BD8),
                                  unselectedLabelColor: Color(0xFF6B7280),
                                  indicatorColor: Color(0xFF1F7BD8),
                                  indicatorWeight: 3,
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  tabs: [
                                    Tab(
                                      text: 'Bảng số giờ hoạt động sân bay',
                                    ),
                                    Tab(
                                      text: 'Biểu đồ số giờ hoạt động sân bay',
                                    ),
                                  ],
                                ),

                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                ),

                                SizedBox(
                                  height: 420,
                                  child: TabBarView(
                                    children: [
                                      // BẢNG SỐ GIỜ HOẠT ĐỘNG SÂN BAY
                                      Obx(() {
                                        if (controller.soGioHoatDongXeSanBay.isEmpty) {
                                          return const Center(
                                            child: Text(
                                              'Không có dữ liệu',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }

                                        return BangsogiohdsanbayCard(
                                          data: controller.soGioHoatDongXeSanBay .toList(),
                                          title:
                                              'BẢNG SỐ GIỜ HOẠT ĐỘNG SÂN BAY',
                                          selectedDate:
                                              controller.selectedDate.value,
                                        );
                                      }),

                                      //  BIỂU ĐỒ SỐ GIỜ HOẠT ĐỘNG SÂN BAY
                                      Obx(() {
                                        if (controller .soGioHoatDongXeSanBayChart .isEmpty) {
                                          return const Center(
                                            child: Text(
                                              'Không có dữ liệu',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }

                                        return SogiohoatdongxeChart( data: controller.soGioHoatDongXeSanBayChart.toList(),
                                          title:'SỐ GIỜ HOẠT ĐỘNG XE HÀNG NGÀY SÂN BAY',
                                          height: 400,
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),

                  // GIỜ HOẠT ĐỘNG CNDP
                  Obx(() {
                    final hasTable =controller.soGioHoatDongXeCndp.isNotEmpty;
                    final hasChart =controller.soGioHoatDongXeCndpChart.isNotEmpty;

                    // Cả 2 loại dữ liệu đều không có
                    if (!hasTable && !hasChart) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TabBar(
                              labelColor: Color(0xFF1F7BD8),
                              unselectedLabelColor: Color(0xFF6B7280),
                              indicatorColor: Color(0xFF1F7BD8),
                              indicatorWeight: 3,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              tabs: [
                                Tab(
                                  text: 'Bảng số giờ hoạt động CNDP',
                                ),
                                Tab(
                                  text: 'Biểu đồ số giờ hoạt động CNDP',
                                ),
                              ],
                            ),

                            const Divider(
                              height: 1,
                              thickness: 1,
                            ),

                            SizedBox(
                              height: 420,
                              child: TabBarView(
                                children: [
                                  //BẢNG SỐ GIỜ HOẠT ĐỘNG CNDP
                                  Obx(() {
                                    if (controller.soGioHoatDongXeCndp.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'Không có dữ liệu',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    }

                                    return BangsogiohdcndpCard(
                                      data: controller.soGioHoatDongXeCndp .toList(),
                                      title:
                                          'BẢNG SỐ GIỜ HOẠT ĐỘNG CNDP',
                                      selectedDate:
                                          controller.selectedDate.value,
                                    );
                                  }),

                                  //  BIỂU ĐỒ SỐ GIỜ HOẠT ĐỘNG CNDP
                                  Obx(() {
                                    if (controller.soGioHoatDongXeCndpChart.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'Không có dữ liệu',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    }

                                    return SogiohoatdongxeChart(
                                      data: controller.soGioHoatDongXeCndpChart.toList(),
                                      title:
                                          'SỐ GIỜ HOẠT ĐỘNG XE HÀNG NGÀY CNDP',
                                      height: 400,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ====== DATE HEADER ======
class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.vm});
  final CNMBBaocaokhaithacngayViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F7BD8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Color(0xFF1F7BD8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BÁO CÁO KHAI THÁC NGÀY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                Obx(() => Text(
                  DateFormat('dd/MM/yyyy').format(vm.selectedDate.value),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2A37),
                  ),
                )),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 24),
                onPressed: vm.goToPreviousDay,
                color: const Color(0xFF6B7280),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 24),
                onPressed: vm.goToNextDay,
                color: const Color(0xFF6B7280),
              ),
              IconButton(
                icon: const Icon(Icons.today, size: 20),
                onPressed: vm.goToToday,
                color: const Color(0xFF1F7BD8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ====== THÔNG TIN ĐIỀU HÀNH KHAI THÁC ======
class _ThongTinDieuHanh extends StatelessWidget {
  const _ThongTinDieuHanh({required this.vm});
  final CNMBBaocaokhaithacngayViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1F7BD8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                const Text(
                  'THÔNG TIN ĐIỀU HÀNH KHAI THÁC',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final text = vm.thongTinDieuHanhKhaiThac.value;
              if (text.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Không có dữ liệu',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE8EDF5),
                    width: 1,
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.8,
                    color: Color(0xFF1F2A37),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}