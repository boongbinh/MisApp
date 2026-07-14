import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/Account/MenuViewModel.dart';

class Menu extends GetView<MenuViewModel> {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2B71C9), Color(0xFF2E8AC7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            // --- Card thông tin người dùng ---
            Container(
              decoration: _cardDeco,
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Row(
                  children: [
                    _Avatar(url: vm.avatarUrl.value),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vm.name.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vm.email.value,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- Card các hành động ---
            Container(
              decoration: _cardDeco,
              child: Obx(
                () => Column(
                  children: [
                    // Không có "Chỉnh sửa thông tin" theo yêu cầu
                    _ActionTile(
                      icon: Icons.shield_outlined,
                      title: 'Đổi mật khẩu',
                      onTap: controller.onChangePassword,
                    ),
                    const Divider(
                      height: 1,
                      color: Color.fromARGB(255, 236, 236, 236),
                    ),
                    _ActionTile(
                      icon: Icons.logout_rounded,
                      title: 'Đăng xuất',
                      iconColor: const Color(0xFFEF4444),
                      onTap: controller.onLogout,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Phiên bản ${controller.version.value}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Small widgets ---------- */

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;

    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child:
          hasUrl
              ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackAvatar(),
              )
              : _fallbackAvatar(),
    );
  }

  Widget _fallbackAvatar() {
    // Dùng ảnh mặc định; nếu chưa có asset thì icon sẽ hiển thị thay thế.
    return Image.asset(
      'assets/images/avatar_default.png',
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => const ColoredBox(
            color: Color(0xFFE5E7EB),
            child: Center(
              child: Icon(
                Icons.person_rounded,
                size: 36,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = const Color(0xFF3568DB),
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF9CA3AF),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      visualDensity: VisualDensity.compact,
    );
  }
}

/* ---------- Shared styles ---------- */

final _cardDeco = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
  ],
);
