import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:skypec/Components/Qttt/NewsReader.dart';
import 'package:skypec/Controller/QTTT/QtttViewModel.dart';

const Color kTabBackground = Color(0xFFF3F6FA);
const Color kSectionBG = Color(0xFFF1F5FB);
const Color kDanger = Color(0xFFE11D48);

class MarketTab extends GetView<QtttViewModel> {
  const MarketTab({super.key});

  int _badgeCount(QtttViewModel vm) =>
      (vm.selectedLevelCode.value == null ? 0 : 1) +
      (vm.selectedTypeCode.value == null ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      color: kTabBackground,
      child: Obx(() {
        final items = controller.filteredMarket;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // --- SEARCH pill ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: _SearchBarWithFilter(
                onChanged: controller.onSearchChanged,
                onOpenFilter: () => controller.openMarketFilter(context),
                badge:
                    _badgeCount(controller) == 0
                        ? null
                        : _badgeCount(controller),
              ),
            ),

            // --- CHIP hiển thị tiêu chí + Bỏ lọc ---
            const _ActiveFiltersBar(),

            // --- Label SỐ LƯỢNG TIN ---
            Container(
              width: double.infinity,
              color: kSectionBG,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Text(
                'SỐ LƯỢNG TIN TỨC : ${controller.all.length}',
                style: text.bodyMedium?.copyWith(
                  letterSpacing: .2,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // --- DANH SÁCH TIN ---
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('Không có dữ liệu phù hợp')),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Column(
                  children: [
                    for (final item in items) ...[
                      _NewsCard(item: item),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 12),
                    const _PaginationBar(),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }
}

/* ---------------------- SEARCH PILL ---------------------- */
class _SearchBarWithFilter extends StatelessWidget {
  const _SearchBarWithFilter({
    required this.onChanged,
    required this.onOpenFilter,
    this.badge,
    this.hint = 'Nhập từ khóa tìm kiếm',
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onOpenFilter;
  final int? badge;
  final String hint;

  @override
  Widget build(BuildContext context) {
    const double h = 52, r = 28;
    return SizedBox(
      height: h,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FB),
                borderRadius: BorderRadius.circular(r),
              ),
            ),
          ),
          Positioned.fill(
            left: 14,
            right: 56,
            child: Row(
              children: [
                const Icon(Icons.search, size: 22, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Nhập từ khóa tìm kiếm',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F2A37),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            bottom: 8,
            child: _FilterCircle(onTap: onOpenFilter, badge: badge),
          ),
        ],
      ),
    );
  }
}

class _FilterCircle extends StatelessWidget {
  const _FilterCircle({this.onTap, this.badge});
  final VoidCallback? onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              height: 36,
              width: 36,
              child: Center(
                child: Icon(
                  CupertinoIcons.slider_horizontal_3,
                  size: 18,
                  color: Color(0xFF1F2A37),
                ),
              ),
            ),
          ),
        ),
        if (badge != null && badge! > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFEB3B3B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/* ----------------- CHIP HIỂN THỊ TIÊU CHÍ + BỎ LỌC ----------------- */
class _ActiveFiltersBar extends StatelessWidget {
  const _ActiveFiltersBar();

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<QtttViewModel>();
    return Obx(() {
      final level = vm.selectedLevelLabel; // '' nếu không chọn
      final type = vm.selectedTypeLabel; // '' nếu không chọn
      final hasAny = level.isNotEmpty || type.isNotEmpty;
      if (!hasAny) return const SizedBox.shrink();

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (level.isNotEmpty)
                    const _ChipPill(icon: Icons.label).buildWithText(level),
                  if (type.isNotEmpty)
                    const _ChipPill(icon: Icons.category).buildWithText(type),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: vm.clearFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: kDanger,
                side: const BorderSide(color: kDanger),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text('Bỏ lọc'),
            ),
          ],
        ),
      );
    });
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({required this.icon});
  final IconData icon;

  Widget buildWithText(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: const ShapeDecoration(
      color: Color(0xFF1F7BD8),
      shape: StadiumBorder(),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/* --------------------------- NEWS CARD --------------------------- */
class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});
  final MarketNews item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    String dd(int n) => n.toString().padLeft(2, '0');
    final dateStr =
        '${dd(item.date.day)}/${dd(item.date.month)}/${item.date.year}';

    final tagLabel = MarketNews.levelLabelFromCode(item.mucDo);
    final tagColor = MarketNews.levelColorFromCode(item.mucDo);
    final outerTint = tagColor.withOpacity(0.08);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: outerTint,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(1),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: text.bodySmall?.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: const Color(0xFFF3F6FA)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // _RoundBtn(icon: Icons.bookmark_border),
                        // SizedBox(width: 8),
                        _RoundBtn(
                          icon: Icons.link,
                          onTap: () {
                            final url = item.path;
                            if (url.isNotEmpty) {
                              Get.to(
                                () => NewsReader(
                                  initialUrl: url,
                                  title: item.title,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bài viết không tồn tại'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: ShapeDecoration(
              color: tagColor.withOpacity(0.12),
              shape: const StadiumBorder(),
            ),
            child: Text(
              tagLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: tagColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE7EFFB),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          height: 36,
          width: 36,
          child: Icon(Icons.link, color: Color(0xFF1F7BD8)),
        ),
      ),
    );
  }
}

/* --------------------------- PAGINATION --------------------------- */
class _PaginationBar extends StatelessWidget {
  const _PaginationBar();

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<QtttViewModel>();
    return Obx(() {
      final total = vm.totalPages;
      if (total <= 1) return const SizedBox.shrink();

      // tạo dải số trang gọn (hiển thị quanh trang hiện tại)
      final cur = vm.page.value;
      final start = (cur - 2).clamp(1, total);
      final end = (cur + 2).clamp(1, total);

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Row(
          children: [
            IconButton(
              onPressed: cur > 1 ? vm.prevPage : null,
              icon: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: 6),
            for (int i = start; i <= end; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ChoiceChip(
                  label: Text('$i'),
                  selected: i == cur,
                  showCheckmark: false,
                  onSelected: (_) => vm.goPage(i),
                  selectedColor: const Color(0xFF1F7BD8),
                  labelStyle: TextStyle(
                    color: i == cur ? Colors.white : const Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: cur < total ? vm.nextPage : null,
              icon: const Icon(Icons.chevron_right),
            ),
            const Spacer(),
            Text(
              'Trang $cur / $total',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    });
  }
}
