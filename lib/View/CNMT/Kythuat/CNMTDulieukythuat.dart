import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/CNMT/Kythuat/CNMTDulieukythuatViewModel.dart';

class CNMTDulieukythuat extends GetView<CNMTDulieukythuatViewModel> {
  const CNMTDulieukythuat({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final pad = MediaQuery.of(context).padding;
    final isTablet = size.width >= 600;
    final headerH = isTablet ? 260.0 : 200.0;

    return Scaffold(
      body: Stack(
        children: [
          // ===== HEADER ẢNH =====
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'asset/images/background_header.png',
                  fit: BoxFit.cover,
                ),
                Container(color: Colors.black.withOpacity(0.10)),
                Positioned(
                  top: pad.top + 12,
                  left: 16,
                  child: _CircleIcon(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Get.back(),
                  ),
                ),
                Positioned(
                  top: pad.top + 12,
                  right: 12,
                  child: Row(
                    children: [
                      _CircleIcon(
                        icon: Icons.home_rounded,
                        onTap: () => Get.offAllNamed('/home'),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 24,
                  child: Text(
                    "Dữ liệu kỹ thuật - CNMT",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== NỘI DUNG =====
          Positioned.fill(
            top: headerH - 20,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Card 1: Xe tra nạp (Orange)
                    _StatCard(
                      color: const Color(0xFFFFF7ED),
                      borderColor: Colors.orange.shade100,
                      icon: Icons.local_shipping,
                      gradient: const [Color(0xFFFB923C), Color(0xFFEA580C)],
                      title: 'Xe tra nạp',
                      value: controller.xeTNTong.value,
                      shadowColor: Colors.orange.shade200,
                      items: controller.xeTNChiTiet.toList(),
                      onTap: () => controller.onCardTap('xe_tranap'),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Xe vận chuyển (Green)
                    _StatCard(
                      color: const Color(0xFFF0FDF4),
                      borderColor: Colors.green.shade100,
                      icon: Icons.local_shipping,
                      gradient: const [Color(0xFF34D399), Color(0xFF059669)],
                      title: 'Xe vận chuyển',
                      value: controller.xeVCTong.value,
                      shadowColor: Colors.green.shade200,
                      items: controller.xeVCChiTiet.toList(),
                      onTap: () => controller.onCardTap('xe_vanchuyen'),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: Bể / Dung tích (Pink)
                    _StatCard(
                      color: const Color(0xFFFFF1F2),
                      borderColor: Colors.pink.shade100,
                      icon: Icons.opacity,
                      gradient: const [Color(0xFFFB7185), Color(0xFFE11D48)],
                      title: 'Bể / Dung tích',
                      value: controller.beChuaTong.value,
                      valueSize: 20,
                      shadowColor: Colors.pink.shade200,
                      items: controller.beChuaChiTiet.toList(),
                      onTap: () => controller.onCardTap('be_dungtich'),
                    ),
                    const SizedBox(height: 16),

                    // Card 4: Bầu lọc (Sky Blue)
                    _StatCard(
                      color: const Color(0xFFF0F9FF),
                      borderColor: Colors.blue.shade100,
                      icon: Icons.filter_alt,
                      gradient: const [Color(0xFF38BDF8), Color(0xFF2563EB)],
                      title: 'Bầu lọc',
                      value: controller.bauLocTong.value,
                      shadowColor: Colors.blue.shade200,
                      subtitle: 'Số lượng theo đơn vị',
                      items: controller.bauLocChiTiet.toList(),
                      onTap: () => controller.onCardTap('bau_loc'),
                    ),
                    const SizedBox(height: 16),

                    // Card 5: Máy bơm (Purple)
                    _StatCard(
                      color: const Color(0xFFF5F3FF),
                      borderColor: Colors.indigo.shade100,
                      icon: Icons.water_drop,
                      gradient: const [Color(0xFF818CF8), Color(0xFF7C3AED)],
                      title: 'Máy bơm',
                      value: controller.mayBomTong.value,
                      shadowColor: Colors.indigo.shade200,
                      subtitle: 'Số lượng theo đơn vị',
                      items: controller.mayBomChiTiet.toList(),
                      onTap: () => controller.onCardTap('may_bom'),
                    ),
                    const SizedBox(height: 16),

                    // Card 6: Đồng hồ (Teal)
                    _StatCard(
                      color: const Color(0xFFF0FDFA),
                      borderColor: Colors.teal.shade100,
                      icon: Icons.timer,
                      gradient: const [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                      title: 'Đồng hồ',
                      value: controller.dongHoTong.value,
                      shadowColor: Colors.teal.shade200,
                      subtitle: 'Số lượng theo đơn vị',
                      items: controller.dongHoChiTiet.toList(),
                      onTap: () => controller.onCardTap('dong_ho'),
                    ),
                    const SizedBox(height: 16),

                    // Info Banner
                    _InfoBanner(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====== STAT CARD ======
class _StatCard extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String value;
  final double valueSize;
  final Color shadowColor;
  final String? subtitle;
  final List<String> items;
  final VoidCallback onTap;

  const _StatCard({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.gradient,
    required this.title,
    required this.value,
    required this.shadowColor,
    required this.items,
    required this.onTap,
    this.valueSize = 36,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Phần 3/10: Icon + Title + Value
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: valueSize,
                            fontWeight: FontWeight.bold,
                            color: gradient[1],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Phần 7/10: Items xếp hàng ngang + Chevron
            Expanded(
              flex: 7,
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: items.map((item) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: gradient[1],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: gradient[1],
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====== INFO BANNER ======
class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'i',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chạm vào bất kỳ thẻ nào để xem chi tiết thông tin',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.blue.shade500,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: Colors.white.withOpacity(0.75),
          child: InkWell(
            onTap: onTap,
            child: const SizedBox(
              height: 36,
              width: 36,
              child: Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF374151)),
            ),
          ),
        ),
      ),
    );
  }
}