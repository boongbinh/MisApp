import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';

class CudvModuleItem {
  final String title;
  final IconData icon; // ⭐ Đổi từ String svg sang IconData
  final bool enabled;
  final String route;  // ⭐ Thêm route
  final List<CudvModuleItem> children;

  const CudvModuleItem({
    required this.title,
    required this.icon,
    this.enabled = true,
    this.route = '',
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;
}

class CUDVViewModel extends GetxController {
  final userName = ''.obs;
  final modules = <CudvModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _applyPermission(GlobalValue.getInstance().getPermission());
    GetProfileInfo();
  }

  void openModule(CudvModuleItem m) {
    if (!m.enabled) return;

    // ⭐ Dùng route trực tiếp
    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
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
    final hasKHNH = isAdmin || has("1.CUDV:Nhập liệu:CUDV_KehoachNhaphang");// Kế hoạch nhập hàng
    final hasTDDV= isAdmin || has("1.CUDV:Báo cáo:CUDV_theodoidieuvan");// Theo dõi diều vận
    final hasBCQT= isAdmin || has("1.CUDV:Thông tin quản trị:BAOCAOQUANTRI");// Báo cáo quản trị

    final list = <CudvModuleItem>[
       CudvModuleItem(
        title: 'Kế hoạch nhập hàng',
        icon: Icons.content_paste, // ⭐ Icon kho
        enabled: hasKHNH,
        route: Routes.cudvKehoachnhaphang,
      ),
       CudvModuleItem(
        title: 'Theo dõi điều vận',
        icon: Icons.local_shipping_outlined, // 
        enabled: hasTDDV,
        route: Routes.cudvTheodoidieuvan,
      ),
       CudvModuleItem(
        title: 'Báo cáo quản trị',
        icon: Icons.dashboard, // 
        enabled: hasBCQT,
        route: Routes.cudvBaocaoquantri,
      ),
      CudvModuleItem(
        title: 'Báo cáo quản trị dự kiến',
        icon: Icons.dashboard, // 
        enabled: hasBCQT,
        route: Routes.cudvBaocaoquantriDukien,
      ),
    ];

    modules.assignAll(list);
  }

  /// Khi user nhấn vào module con
  void openMenu() => Get.toNamed(Routes.menu);
  void openNotice() => Get.toNamed(Routes.notify);
}