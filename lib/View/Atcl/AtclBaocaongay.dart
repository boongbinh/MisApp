import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/Atcl/AtclBaocaongayViewModel.dart';

class AtclBaocaongay extends GetView<AtclBaocaongayViewModel> {
  const AtclBaocaongay({super.key});

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
                // Tiêu đề module
                Positioned(
                  bottom: 16,
                  left: 24,
                  child: Text(
                    "Báo cáo ngày",
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
              child: Obx(() {
                final modules = controller.modules;
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final m = modules[index];
                    return _ModuleCard(
                      title: m.title,
                      svg: m.svg,
                      enabled: m.enabled,
                      onTap: () => controller.openModule(m),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// =================== WIDGETS TÁI SỬ DỤNG ===================

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
              gradient: enabled
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2F6DF6), Color(0xFF6BB4F3)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFD7E4EE), Color(0xFFE9F1F7)],
                    ),
              boxShadow: enabled
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
                  width: 80,
                  height: 80,
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