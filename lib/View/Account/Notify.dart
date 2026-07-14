import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/Account/NotifyViewModel.dart';

class Notify extends GetWidget<NotifyViewModel> {
  const Notify({super.key});

  @override
  Widget build(BuildContext context) {
    // đảm bảo controller có trong DI
    if (!Get.isRegistered<NotifyViewModel>()) {
      Get.put(NotifyViewModel());
    }
    // lần đầu load
    controller.fetch();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
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
      body: Obx(() {
        if (controller.loading.value && controller.list.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.list.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetch(),
            child: ListView(
              children: const [
                SizedBox(height: 160),
                Center(child: Text('Không có thông báo')),
                SizedBox(height: 160),
              ],
            ),
          );
        }

        final sections = controller.sections;
        final now = DateTime.now();

        final widgets = <Widget>[
          // ====== thanh lọc theo Page ======
          _PageFilterBar(vm: controller),
          const Divider(height: 1),
        ];

        for (final s in sections) {
          widgets.add(
            _SectionHeader(title: controller.sectionLabel(s.date, now)),
          );
          for (final n in s.items) {
            widgets.add(_NotificationTile(n: n));
          }
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetch(),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: widgets,
          ),
        );
      }),
    );
  }
}

/// ----------------- thanh lọc category (Page) -----------------
class _PageFilterBar extends StatelessWidget {
  const _PageFilterBar({required this.vm});
  final NotifyViewModel vm;

  @override
  Widget build(BuildContext context) {
    final pages = vm.pageKeys;
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (_, i) {
          final key = pages[i];
          final selected = vm.selectedPage.value == key;
          final label =
              key == 'all'
                  ? 'Tất cả'
                  : (NotifyViewModel.pageLabel[key] ?? key.toUpperCase());
          final count = vm.countForPage(key);

          return Obx(() {
            final isSel = vm.selectedPage.value == key;
            return InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: () => vm.selectedPage.value = key,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: ShapeDecoration(
                  color: isSel ? const Color(0xFF2B71C9) : Colors.white,
                  shape: const StadiumBorder(
                    side: BorderSide(color: Color(0xFFE6ECF5)),
                  ),
                ),
                child: Text(
                  '$label ($count)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isSel ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ),
            );
          });
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: pages.length,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FB),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}

class _NotificationTile extends GetView<NotifyViewModel> {
  const _NotificationTile({required this.n});
  final AppNotification n;

  @override
  Widget build(BuildContext context) {
    // ưu tiên nhóm theo PAGE
    final color = controller.colorForPage(n.page.isNotEmpty ? n.page : n.type);
    final iconName = controller.iconNameForPage(
      n.page.isNotEmpty ? n.page : n.type,
    );
    final iconData = _materialIcon(iconName);

    return InkWell(
      onTap: () {
        controller.markRead(n);
      },
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(iconData, color: Colors.white, size: 18),
            ),
            // ====== 2. title + body show full, không ... ======
            title: Text(
              n.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(n.body, style: const TextStyle(color: Color(0xFF4B5563))),
                const SizedBox(height: 4),
                Text(
                  controller.timeAgo(n.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  /// Chuyển tên icon string -> IconData
  IconData _materialIcon(String name) {
    switch (name) {
      case 'swap_vert':
        return Icons.swap_vert;
      case 'swap_vert_circle':
        return Icons.swap_vert_circle;
      case 'trending_down':
        return Icons.trending_down;
      case 'trending_up':
        return Icons.trending_up;
      case 'ssid_chart':
        return Icons.ssid_chart;
      case 'show_chart':
        return Icons.show_chart;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'inventory_2_rounded':
        return Icons.inventory_2_rounded;
      case 'trending_up_rounded':
        return Icons.trending_up_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }
}
