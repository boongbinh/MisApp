import 'dart:convert';
import 'package:get/get.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:flutter/material.dart';


class KtModuleItem {
  final String title;
final IconData icon;
  final bool enabled;
  final List<KtModuleItem> children; // ⭐ Thêm children cho menu con

  const KtModuleItem(
    this.title,
    this.icon, {
    this.enabled = true,
    this.children = const [],
  });

  // ⭐ Kiểm tra có menu con không
  bool get hasChildren => children.isNotEmpty;
}

class KtViewModel extends GetxController {
  final userName = ''.obs;
  final modules = <KtModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _applyPermission(GlobalValue.getInstance().getPermission());
    GetProfileInfo();
  }

  void openModule(KtModuleItem m) {
    if (!m.enabled) return;

    if (m.title == 'Thông tin chung') {
      Get.toNamed(Routes.ktThongtinchung);
    } else if (m.title == 'Dữ liệu kĩ thuật') {
      Get.toNamed(Routes.ktDulieukythuat);
    } else if (m.title == 'Phân tích chi phí') {
      Get.toNamed(Routes.ktPhantichchiphi);
    } else if (m.title == 'Báo cáo kỹ thuật') {
      Get.toNamed(Routes.ktBaoCaoKyThuat);
    }
  }

  Future<void> GetProfileInfo() async {
    try {
      final res = await APICaller.getInstance().get('Login/GetInfoUser');
      if (res == null) return;

      final data = jsonDecode(res) as Map<String, dynamic>;
      userName.value = data['DisplayName'] ?? '';

      GlobalValue.getInstance().setFullname(data['DisplayName']);
      GlobalValue.getInstance().setUuid(data['UserId']);
      GlobalValue.getInstance().setAvatar(data['UserImage']);
    } catch (e) {}
  }

  /// Kiểm tra quyền và gán danh sách module con
  void _applyPermission(String perm) {
    final lower = perm.toLowerCase();
    bool has(String key) => lower.contains(key.toLowerCase());

    final isAdmin = has('administration:general');

    // Kiểm tra từng quyền TCNL
    final hasThongtinchung = isAdmin || has("6. KT:Thông tin quản trị:THONGTINCHUNG");
    final hasDulieukythuat = isAdmin || has("6. KT:Thông tin quản trị:DULIEUKYTHUAT");
    final hasPhantichchiphi = isAdmin || has("6. KT:Thông tin quản trị:PHANTICHCHIPHI");
    final hasBaocaokythuat = isAdmin || has("6. KT:QT70");

    final list = <KtModuleItem>[
      KtModuleItem(
        "Thông tin chung",
        Icons.dashboard_outlined,
        enabled: hasThongtinchung,
      ),
      KtModuleItem(
        "Dữ liệu kĩ thuật",
        Icons.engineering_outlined,
        enabled: hasDulieukythuat,
      ),
      KtModuleItem(
        "Phân tích chi phí",
        Icons.bar_chart_outlined,
        enabled: hasPhantichchiphi,
      ),
      KtModuleItem(
        "Báo cáo kỹ thuật",
        Icons.fact_check_outlined,
        enabled: hasBaocaokythuat,
      ),
    ];

    modules.assignAll(list);
  }

  /// Khi user nhấn vào module con
  void openMenu() => Get.toNamed(Routes.menu);
  void openNotice() => Get.toNamed(Routes.notify);
}