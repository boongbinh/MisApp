import 'dart:convert';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';

class NotifyViewModel extends GetxController {
  /// state
  final loading = false.obs;
  final list = <AppNotification>[].obs;

  /// page đang chọn để lọc (all/tigia/jeta1/...)
  final selectedPage = 'all'.obs;

  /// ====== meta theo PAGE (ưu tiên dùng cái này) ======
  /// bạn có thể đổi label/icon/color ở đây
  static const Map<String, String> pageLabel = {
    'tigia': 'Tỷ giá',
    'jeta1': 'Giá JET A1',
    'sanluong': 'Sản lượng',
  };

  static const Map<String, String> pageIcon = {
    'tigia': 'swap_vert',
    'jeta1': 'local_gas_station',
    'sanluong': 'inventory_2_rounded',
  };

  static const Map<String, Color> pageColor = {
    'tigia': Color(0xFF2B71C9),
    'jeta1': Color(0xFFF59E0B),
    'sanluong': Color(0xFF10B981),
  };

  // ====== icon/màu theo TYPE cũ (giữ lại để fallback) ======
  static const typeIcon = <String, String>{
    'daily_tigia_sell': 'swap_vert',
    'daily_tigia_buy': 'swap_vert_circle',
    'daily_tigia_sell_chenhlechquy': 'trending_down',
    'daily_tigia_buy_chenhlechquy': 'trending_up',
    'daily_tigia_sell_chechlech_daunam': 'ssid_chart',
    'daily_tigia_buy_chechlech_daunam': 'show_chart',
    'daily_jeta1': 'local_gas_station',
    'daily_jeta1_month': 'calendar_month',
    'daily_jeta1_chenhlech': 'trending_up_rounded',
  };

  static const Map<String, Color> typeColor = {
    'daily_tigia_sell': Color(0xFF3B82F6), // xanh dương
    'daily_tigia_buy': Color(0xFF6366F1), // chàm
    'daily_tigia_sell_chenhlechquy': Color(0xFFEF4444), // đỏ
    'daily_tigia_buy_chenhlechquy': Color(0xFF10B981), // xanh lá
    'daily_tigia_sell_chechlech_daunam': Color(0xFFEF4444),
    'daily_tigia_buy_chechlech_daunam': Color(0xFF10B981),
    'daily_jeta1': Color(0xFFF59E0B), // cam
    'daily_jeta1_month': Color(0xFF8B5CF6), // tím
    'daily_jeta1_chenhlech': Color(0xFFE11D48), // hồng đậm
  };

  // ====== ưu tiên màu / icon theo PAGE ======
  Color colorForPage(String page) {
    if (pageColor.containsKey(page)) return pageColor[page]!;
    return const Color(0xFF94A3B8);
  }

  String iconNameForPage(String page) {
    if (pageIcon.containsKey(page)) return pageIcon[page]!;
    return 'notifications_active_rounded';
  }

  // ====== fallback theo TYPE (để phòng dữ liệu cũ chưa có Page) ======
  Color colorFor(String type) =>
      typeColor[type] ??
      (type.startsWith('daily_tigia_')
          ? const Color(0xFF60A5FA)
          : type.startsWith('daily_jeta1')
          ? const Color(0xFFF59E0B)
          : const Color(0xFF94A3B8));

  String iconNameFor(String type) =>
      typeIcon[type] ?? 'notifications_active_rounded';

  /// ====== data ======
  Future<void> fetch() async {
    loading.value = true;
    try {
      final resp = await APICaller.getInstance().get("PushNoti/ThongbaoList");
      if (resp == null) return;
      final parsed =
          (jsonDecode(resp) as List)
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList();

      parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      list.assignAll(parsed);
    } finally {
      loading.value = false;
    }
  }

  /// các page hiện có trong data + 'all'
  List<String> get pageKeys {
    final set = <String>{};
    for (final n in list) {
      if (n.page.isNotEmpty) set.add(n.page);
    }
    final arr = set.toList()..sort();
    return ['all', ...arr];
  }

  /// đếm thông báo theo page (all = tổng)
  int countForPage(String page) {
    if (page == 'all') return list.length;
    return list.where((e) => e.page == page).length;
  }

  /// Group theo ngày (desc) sau khi đã filter theo page
  List<NotifySection> get sections {
    // lọc trước
    final Iterable<AppNotification> source =
        selectedPage.value == 'all'
            ? list
            : list.where((e) => e.page == selectedPage.value);

    final map = <DateTime, List<AppNotification>>{};
    for (final n in source) {
      final k = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      (map[k] ??= []).add(n);
    }
    final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final d in days)
        NotifySection(
          date: d,
          items: (map[d]!..sort((a, b) => b.createdAt.compareTo(a.createdAt)))!,
        ),
    ];
  }

  /// Helpers cho view
  String timeAgo(DateTime t, {DateTime? now}) {
    now ??= DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  String sectionLabel(DateTime day, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(day.year, day.month, day.day);
    final df = DateFormat('dd/MM/yyyy');
    if (d == today) return 'Hôm nay (${df.format(day)})';
    if (d == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua (${df.format(day)})';
    }
    return df.format(day);
  }

  void markRead(AppNotification n) {
    final i = list.indexWhere((e) => e.id == n.id);
    if (i >= 0) {
      list[i] = AppNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        createdAt: n.createdAt,
        type: n.type,
        page: n.page,
        isRead: true,
      );
    }
  }
}

class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String type;
  final String page; // <--- thêm
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    required this.page,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['Id'],
    title: j['Title'] ?? '',
    body: j['Body'] ?? '',
    createdAt: DateTime.parse(j['CreatedAt']),
    type: j['Type'] ?? '',
    page: j['Page']?.toString().toLowerCase() ?? '', // <-- lấy Page
  );
}

/// Header + items theo ngày
class NotifySection {
  final DateTime date; // yyyy-MM-dd
  final List<AppNotification> items; // đã sort desc theo time
  NotifySection({required this.date, required this.items});
}
