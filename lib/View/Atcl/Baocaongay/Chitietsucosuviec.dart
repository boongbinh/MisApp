// views/chitietsucosuviec_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/Atcl/Baocaongay/ChitietsucosuviecViewModel.dart';

class Chitietsucosuviec extends GetView<ChitietsucosuviecViewModel> {
  const Chitietsucosuviec({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('CHI TIẾT SỰ CỐ SỰ VIỆC'),
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final args = Get.arguments;
                          final maBaoCao = args is Map ? args['MaBaoCao'] as int? : null;
                          if (maBaoCao != null) controller.loadData(maBaoCao);
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              final ct = controller.chiTiet.value;
              if (ct == null) {
                return const Center(child: Text('Không có dữ liệu'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    // Card 1: Thông tin báo cáo
                    _InfoCard(
                      title: 'THÔNG TIN BÁO CÁO',
                      icon: Icons.description_outlined,
                      color: const Color(0xFF003266),
                      children: [
                        _InfoRow(
                          label: 'Đơn vị thực hiện',
                          value: ct.nguoiThucHien,
                        ),
                        _InfoRow(
                          label: 'Ngày báo cáo',
                          value: controller.formatDate(ct.ngayBaoCao),
                        ),
                        _InfoRow(
                          label: 'Giờ báo cáo',
                          value: controller.formatTime(ct.gioBaoCao),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Sự kiện
                    _InfoCard(
                      title: 'SỰ KIỆN',
                      icon: controller.getIconForSuKien(ct.coSuKienMatAnToan),
                      color: controller.getColorForSuKien(ct.coSuKienMatAnToan),
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: controller
                                .getColorForSuKien(ct.coSuKienMatAnToan)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: controller
                                  .getColorForSuKien(ct.coSuKienMatAnToan)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                controller.getIconForSuKien(ct.coSuKienMatAnToan),
                                size: 20,
                                color: controller.getColorForSuKien(ct.coSuKienMatAnToan),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ct.coSuKienMatAnToan,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: controller.getColorForSuKien(ct.coSuKienMatAnToan),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Card 3: Xác nhận
                    _InfoCard(
                      title: 'XÁC NHẬN',
                      icon: Icons.verified_outlined,
                      color: const Color(0xFFFDC000),
                      children: [
                        _InfoRow(
                          label: 'Ngày xác nhận',
                          value: controller.formatDate(ct.thoiGianXacNhan),
                        ),
                        _InfoRow(
                          label: 'Giờ xác nhận',
                          value: controller.formatTime(ct.gioXacNhan),
                        ),
                        const Divider(height: 16, color: Color(0xFFE6ECF5)),
                        _InfoRow(
                          label: 'Nội dung xác nhận',
                          value: ct.noiDungXacNhan,
                          valueColor: controller.getColorForNoiDungXacNhan(ct.noiDungXacNhan),
                          valueBold: true,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Xác nhận nội dung sự việc',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ct.xacNhanNoiDung
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    ct.xacNhanNoiDung
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 14,
                                    color: ct.xacNhanNoiDung
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ct.xacNhanNoiDung ? 'Đã xác nhận' : 'Chưa xác nhận',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: ct.xacNhanNoiDung
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Card 4: Chi tiết sự việc
                    _InfoCard(
                      title: 'CHI TIẾT SỰ VIỆC MẤT AN TOÀN',
                      icon: Icons.report_problem_outlined,
                      color: Colors.red,
                      children: [
                        _InfoRow(
                          label: 'Ngày lập sự việc',
                          value: controller.formatDate(ct.ngayLapSuViec),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Sự việc',
                          value: ct.suViec,
                          valueBold: true,
                        ),
                        const SizedBox(height: 8),
                        _InfoBlock(
                          label: 'Nội dung sự việc',
                          content: ct.noiDungSuViec,
                          backgroundColor: Colors.red.withOpacity(0.05),
                          borderColor: Colors.red.withOpacity(0.2),
                        ),
                      ],
                    ),

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

// ============================================================
// INFO CARD
// ============================================================

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE6ECF5)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? const Color(0xFF1F2A37),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO BLOCK (cho nội dung dài)
// ============================================================

class _InfoBlock extends StatelessWidget {
  final String label;
  final String content;
  final Color backgroundColor;
  final Color borderColor;

  const _InfoBlock({
    required this.label,
    required this.content,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            content.isEmpty ? '--' : content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF1F2A37),
            ),
          ),
        ),
      ],
    );
  }
}