import 'dart:convert';
import 'package:get/get.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:flutter/material.dart';

class AnNinhModuleItem {
  final String title;
  final IconData icon;
  final bool enabled;
  final List<AnNinhModuleItem> children; // ⭐ Thêm children cho menu con

  const AnNinhModuleItem(
    this.title,
    this.icon, {
    this.enabled = true,
    this.children = const [],
  });

  // ⭐ Kiểm tra có menu con không
  bool get hasChildren => children.isNotEmpty;
}

class AnNinhViewModel extends GetxController {
  final userName = ''.obs;
  final modules = <AnNinhModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _applyPermission(GlobalValue.getInstance().getPermission());
    GetProfileInfo();
  }

  void openModule(AnNinhModuleItem m) {
    if (!m.enabled) return;

    if (m.title == 'Báo cáo sản lượng – chuyến bay') {
      Get.toNamed(Routes.anNinhSanluongchuyenbay);
    } else if (m.title == 'Xuất nhập tồn kho sân bay') {
      Get.toNamed(Routes.anninhTheodoiXNT_SB);
    }else if (m.title == 'Xuất nhập tồn kho cảng') {
      Get.toNamed(Routes.anninhTheodoiXNT);
    } else if (m.title == 'Báo cáo ngày') {
      Get.toNamed(Routes.anninhBaocaongay);
    }else if (m.title == 'Dữ liệu kỹ thuật') {
      Get.toNamed(Routes.anninhDulieukythuat);
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
    final hasBaocaosanluong = isAdmin || has("Mobileapp:AN:App_Baocaosanluong_chuyenbay");// Báo cáo sản lượng – chuyến bay
    final hasXuatnhaptonkhosb = isAdmin || has("Mobileapp:AN:App_Xuatnhaptonkhosb");
    final hasXuatnhaptonkhocang = isAdmin || has("Mobileapp:AN:App_Xuatnhaptonkho");
    final hasBaocaongay = isAdmin || has("Mobileapp:AN:App_Baocaongay");
    final hasDulieukythuat = isAdmin || has("Mobileapp:AN:App_Dulieukythuat");

    final list = <AnNinhModuleItem>[
      AnNinhModuleItem(
        "Báo cáo sản lượng – chuyến bay",
        Icons.bar_chart,
        enabled: hasBaocaosanluong,
      ),
      AnNinhModuleItem(
        "Xuất nhập tồn kho sân bay",
        Icons.inventory_2_outlined,
        enabled: hasXuatnhaptonkhosb,
      ),
      AnNinhModuleItem(
        "Xuất nhập tồn kho cảng",
        Icons.inventory_2_outlined,
        enabled: hasXuatnhaptonkhocang,
      ),
      AnNinhModuleItem(
        "Báo cáo ngày",
        Icons.today_outlined,
        enabled: hasBaocaongay,
      ),
      AnNinhModuleItem(
        "Dữ liệu kỹ thuật",
        Icons.data_usage,
        enabled: hasDulieukythuat,
      ),
    ];

    modules.assignAll(list);
  }

  /// Khi user nhấn vào module con
  void openMenu() => Get.toNamed(Routes.menu);
  void openNotice() => Get.toNamed(Routes.notify);
}