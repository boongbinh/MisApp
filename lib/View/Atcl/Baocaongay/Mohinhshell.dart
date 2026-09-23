// views/mohinhshell_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/Atcl/Baocaongay/MohinhshellViewModel.dart';
import 'package:skypec/Components/Atcl/Baocaongay/MohinhshellChart.dart';

const Color _colorNavy = Color(0xFF003266);
const Color _colorGold = Color(0xFFFDC000);
const Color _colorRed = Color(0xFFE74C3C);
const Color _colorGreen = Color(0xFF2ECC71);

class Mohinhshell extends GetView<MohinhshellViewModel> {
  const Mohinhshell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('MÔ HÌNH SHELL'),
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
                      
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    // ====== Card Mô hình Shell Tháng ======
                    Obx(() {
                      if (controller.mohinhShellThangData.isEmpty) {
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
                              'Không có dữ liệu tháng',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return MohinhshellChart(
                        dataList: controller.mohinhShellThangData.toList(),
                        title: 'PHÂN TÍCH MÔ HÌNH SHELL - THÁNG',
                      );
                    }),

                    const SizedBox(height: 16),

                    // ====== Thống kê chi tiết Tháng ======
                    _buildStatisticCard(
                      controller,
                      title: 'THỐNG KÊ CHI TIẾT - THÁNG',
                      data: controller.mohinhShellThangData.toList(),
                      total: controller.totalValueThang,
                      loaiNhieuNhat: controller.loaiNhieuNhatThang,
                      soLuongNhieuNhat: controller.soLuongNhieuNhatThang,
                      loaiItNhat: controller.loaiItNhatThang,
                      soLuongItNhat: controller.soLuongItNhatThang,
                    ),

                    const SizedBox(height: 16),

                    // ====== Card Mô hình Shell Quý ======
                    Obx(() {
                      if (controller.mohinhShellQuyData.isEmpty) {
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
                              'Không có dữ liệu quý',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return MohinhshellChart(
                        dataList: controller.mohinhShellQuyData.toList(),
                        title: 'PHÂN TÍCH MÔ HÌNH SHELL - QUÝ',
                      );
                    }),

                    const SizedBox(height: 16),

                    // ====== Thống kê chi tiết Quý ======
                    _buildStatisticCard(
                      controller,
                      title: 'THỐNG KÊ CHI TIẾT - QUÝ',
                      data: controller.mohinhShellQuyData.toList(),
                      total: controller.totalValueQuy,
                      loaiNhieuNhat: controller.loaiNhieuNhatQuy,
                      soLuongNhieuNhat: controller.soLuongNhieuNhatQuy,
                      loaiItNhat: controller.loaiItNhatQuy,
                      soLuongItNhat: controller.soLuongItNhatQuy,
                    ),

                    const SizedBox(height: 16),

                    // ====== Card Mô hình Shell Năm ======
                    Obx(() {
                      if (controller.mohinhShellNamData.isEmpty) {
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
                              'Không có dữ liệu năm',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return MohinhshellChart(
                        dataList: controller.mohinhShellNamData.toList(),
                        title: 'PHÂN TÍCH MÔ HÌNH SHELL - NĂM',
                      );
                    }),


                    const SizedBox(height: 16),

                    // ====== Thống kê chi tiết Năm ======
                    _buildStatisticCard(
                      controller,
                      title: 'THỐNG KÊ CHI TIẾT - NĂM',
                      data: controller.mohinhShellNamData.toList(),
                      total: controller.totalValueNam,
                      loaiNhieuNhat: controller.loaiNhieuNhatNam,
                      soLuongNhieuNhat: controller.soLuongNhieuNhatNam,
                      loaiItNhat: controller.loaiItNhatNam,
                      soLuongItNhat: controller.soLuongItNhatNam,
                    ),

                    const SizedBox(height: 16),



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

  Widget _buildStatisticCard(
    MohinhshellViewModel controller, {
    required String title,
    required List<MohinhshellData> data,
    required double total,
    required List<String> loaiNhieuNhat,
    required double soLuongNhieuNhat,
    required List<String> loaiItNhat,
    required double soLuongItNhat,
  }) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 12),
          
          // Tổng số
          _buildStatRow(
            'Tổng số hồ sơ',
            total.toInt().toString(),
            icon: Icons.description,
          ),
          
          const Divider(height: 1, color: Color(0xFFE6ECF5)),
          
          // Loại nhiều nhất (có thể nhiều loại)
          _buildStatRowMulti(
            'Loại nhiều nhất',
            loaiNhieuNhat,
            value2: '${soLuongNhieuNhat.toInt()} hồ sơ',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
          
          const Divider(height: 1, color: Color(0xFFE6ECF5)),
          
          // Loại ít nhất (có thể nhiều loại)
          _buildStatRowMulti(
            'Loại ít nhất',
            loaiItNhat,
            value2: '${soLuongItNhat.toInt()} hồ sơ',
            icon: Icons.trending_down,
            color: Colors.red,
          ),
          
          
        ],
      ),
    );
  }

  // Widget hiển thị nhiều loại (cho max và min)
  Widget _buildStatRowMulti(
    String label,
    List<String> values, {
    String? value2,
    IconData? icon,
    Color? color,
  }) {
    final displayText = values.isNotEmpty ? values.join(' / ') : '--';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 18,
              color: color ?? Colors.grey,
            ),
          if (icon != null) const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? const Color(0xFF1F2A37),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (value2 != null)
            Text(
              value2,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
        ],
      ),
    );
  }

  // Widget hiển thị 1 loại (cho danh sách chi tiết)
  Widget _buildStatRow(
    String label,
    String value, {
    String? value2,
    IconData? icon,
    Color? color,
    bool showColor = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (showColor && color != null)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          if (showColor) const SizedBox(width: 8),
          if (icon != null)
            Icon(
              icon,
              size: 18,
              color: color ?? Colors.grey,
            ),
          if (icon != null) const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color ?? const Color(0xFF6B7280),
                fontWeight: showColor ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (value2 != null)
            Text(
              value2,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          if (value2 != null) const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? const Color(0xFF1F2A37),
            ),
          ),
        ],
      ),
    );
  }



}