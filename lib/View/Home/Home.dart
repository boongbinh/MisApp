import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/Home/HomeViewModel.dart';

class Home extends GetView<HomeViewModel> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final pad = MediaQuery.of(context).padding;
    final isTablet = size.width >= 600;

    // chiều cao khu vực HEADER
    final headerH = isTablet ? 260.0 : 200.0;

    return Scaffold(
      body: Stack(
        children: [
          // ===== HEADER ẢNH (chỉ ở phần trên cùng) =====
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
                  right: 12,
                  child: Row(
                    children: [
                      _CircleIcon(
                        icon: Icons.notifications_none_rounded,
                        onTap: () => controller.openNotice(),
                      ),
                      const SizedBox(width: 10),
                      _CircleIcon(
                        icon: Icons.account_circle_rounded,
                        onTap: () => controller.openMenu(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===== SHEET TRẮNG (nội dung) =====
          Positioned.fill(
            top: headerH,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 24 : 16,
                  16,
                  isTablet ? 24 : 16,
                  24 + pad.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào mừng trở lại !',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        controller.userName.value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // GRID MODULES (SVG + responsive)
                    Obx(
                      () => GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: isTablet ? 180 : 160,
                          mainAxisSpacing: isTablet ? 28 : 20,
                          crossAxisSpacing: isTablet ? 28 : 16,
                          childAspectRatio: isTablet ? 0.95 : 0.9,
                        ),
                        itemCount: controller.modules.length,
                        itemBuilder: (_, i) {
                          final m = controller.modules[i];
                          return _ModuleCard(
                            title: m.title,
                            svg: m.svg,
                            enabled: m.enabled,
                            onTap: () => controller.openModule(m),
                          );
                        },
                      ),
                    ),
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

/// Icon tròn nổi trên header (kính mờ)
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
            child: SizedBox(
              height: 36,
              width: 36,
              child: Icon(icon, size: 20, color: const Color(0xFF374151)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thẻ module dùng SVG của Figma
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.svg,
    required this.enabled,
    this.onTap,
  });

  final String title;
  final String svg;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: enabled ? const Color(0xFF1F2A37) : const Color(0xFF9CA3AF),
    );

    final iconColor = enabled ? Colors.white : const Color(0xFF9FB6C8);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient:
                  enabled
                      ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2F6DF6), Color(0xFF6BB4F3)],
                      )
                      : const LinearGradient(
                        colors: [Color(0xFFD7E4EE), Color(0xFFE9F1F7)],
                      ),
              boxShadow:
                  enabled
                      ? const [
                        BoxShadow(
                          color: Color(0x332F6DF6),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ]
                      : null,
            ),
            child: Center(
              child: Opacity(
                opacity: enabled ? 1 : 0.4,
                child: SvgPicture.asset(
                  svg,
                  width: 64,
                  height: 64,
                  //colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: labelStyle,
          ),
        ],
      ),
    );
  }
}
