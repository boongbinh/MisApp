import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Components/Qttt/MarketShareTab.dart';
import 'package:skypec/Components/Qttt/MarketTab.dart';
import 'package:skypec/Components/Qttt/QtttCard.dart';
import 'package:skypec/Controller/QTTT/QtttViewModel.dart';
import 'package:skypec/Route/AppRoutes.dart';

class Qttt extends GetView<QtttViewModel> {
  const Qttt({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Stack(
          children: [
            // === ẢNH BACKGROUND TOÀN MÀN ===
            Positioned.fill(
              child: Image.asset(
                'asset/images/background_inside.png', // ảnh của bạn
                fit: BoxFit.fill, // giữ tỉ lệ, không méo
                alignment: Alignment.topCenter,
              ),
            ),
            // overlay nhẹ để text dễ đọc (có thể bỏ)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(.12), Colors.transparent],
                    stops: const [0, .25],
                  ),
                ),
              ),
            ),

            // === NỘI DUNG: AppBar trong suốt + 4 KPI + Tabs + Body trắng ===
            NestedScrollView(
              headerSliverBuilder:
                  (context, inner) => [
                    // AppBar TRONG SUỐT
                    SliverAppBar(
                      pinned: false,
                      elevation: 0,
                      backgroundColor:
                          Colors.transparent, // <- không còn nền xanh
                      systemOverlayStyle:
                          SystemUiOverlayStyle.light, // status bar icon trắng
                      foregroundColor: Colors.white, // icon/back/title trắng
                      centerTitle: true,
                      title: const Text(
                        'Quản trị thông tin',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.chevron_left, size: 28),
                        onPressed: () => Get.back(),
                      ),
                    ),

                    // 4 KPI (không có nền, để lộ ảnh phía sau)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Obx(() {
                          final items = controller.overview;
                          return Column(
                            children: [
                              for (final it in items) ...[
                                QtttCard(
                                  title: it.subtitle ?? it.title,
                                  leftLabel: it.leftLabel,
                                  leftValue: it.leftValue,
                                  rightLabel: it.rightLabel,
                                  rightValue: it.rightValue,
                                  cardInfo: it,
                                  // truyền màu viền mờ dần tuỳ item
                                  accentLeft:
                                      it.id == 1
                                          ? Color(0xFF4F9CFB)
                                          : it.id == 2
                                          ? Color(0xFF22C55E)
                                          : it.id == 3
                                          ? Color(0xFFE97070)
                                          : Color(0xFF8B5CF6),
                                  accentRight:
                                      it.id == 1
                                          ? Color(0xFF4F9CFB)
                                          : it.id == 2
                                          ? Color(0xFF22C55E)
                                          : it.id == 3
                                          ? Color(0xFFE97070)
                                          : Color(0xFF8B5CF6),
                                  onBoxTap: () {
                                    if (it.id == 2) {
                                      Get.toNamed(Routes.inventory);
                                    } else if (it.id == 3) {
                                      Get.toNamed(Routes.forecastjet);
                                    }
                                  },
                                  onEyeTap: () {
                                    if (it.id == 1) {
                                      Get.toNamed(Routes.ratedetail);
                                    } else if (it.id == 2) {
                                      String time = DateFormat(
                                        'yyyy-MM',
                                      ).format(DateTime.now());
                                      Get.toNamed(
                                        Routes.currentoutput,
                                        arguments: time,
                                      );
                                    } else if (it.id == 3) {
                                      Get.toNamed(Routes.jetdetail);
                                    } else if (it.id == 4) {
                                      Get.toNamed(Routes.financeplan);
                                    }
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ],
                          );
                        }),
                      ),
                    ),

                    // TabBar PINNED (nền TRẮNG)
                    SliverPersistentHeader(
                      pinned: false,
                      delegate: _TabsHeaderDelegate(
                        TabBar(
                          labelColor: const Color(0xFF1F7BD8),
                          unselectedLabelColor: const Color(0xFF6B7280),
                          indicatorColor: const Color(0xFF1F7BD8),
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                          tabs: [
                            Tab(text: 'Thông tin thị trường'),
                            Obx(
                              () => Tab(
                                text:
                                    'Thị phần (Đến ${controller.currentDate})',
                              ),
                            ),
                          ],
                          onTap: (value) {
                            if (value == 1) {
                              controller.getMarketShareInfo();
                            }
                          },
                        ),
                      ),
                    ),
                  ],

              body: Container(
                color: Color(0xFFF3F6FA),
                child: TabBarView(
                  children: const [MarketTab(), MarketShareTab()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- TAB HEADER (pinned) ---------------- */

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabsHeaderDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      elevation: overlapsContent ? 2 : 0,
      child: SizedBox(height: maxExtent, child: Center(child: tabBar)),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate old) => false;
}

class _TabList extends StatelessWidget {
  const _TabList({required this.searchBuilder, required this.listBuilder});
  final Widget Function() searchBuilder;
  final Widget Function() listBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ô tìm kiếm + nút lọc (giống ảnh, nằm ngay trên list)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: searchBuilder(),
        ),
        Expanded(child: listBuilder()),
      ],
    );
  }
}

class _CardListTile extends StatelessWidget {
  const _CardListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading; // SvgPicture.asset(...)
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
                subtitle == null
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: leading,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B1F36),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: Color(0xFF9CA3AF),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- Search row (ô tìm kiếm + icon lọc) ---------------- */

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.onChanged, required this.onFilter});
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // TextField tròn
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5FA),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      hintText: 'Nhập từ khóa tìm kiếm',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Nút lọc tròn
        InkWell(
          onTap: onFilter,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF1F7BD8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.filter_list_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
