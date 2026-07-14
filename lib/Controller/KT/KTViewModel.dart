import 'dart:convert';
import 'package:get/get.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';

class KtModuleItem {
  final String title;
  final String svg; // đường dẫn icon SVG
  final bool enabled;
  final List<KtModuleItem> children; // ⭐ Thêm children cho menu con

  const KtModuleItem(
    this.title,
    this.svg, {
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

    final isAdmin = has('administration') || has('admin');

    final list = <KtModuleItem>[
      KtModuleItem(
        "Thông tin chung",
        "asset/icons/icon_kt_thongtinchung.svg",
        enabled: true,
      ),
      KtModuleItem(
        "Dữ liệu kĩ thuật",
        "asset/icons/icon_kt_dulieukythuat.svg",
        enabled: true,
      ),
      KtModuleItem(
        "Phân tích chi phí",
        "asset/icons/icon_kt_baocao.svg",
        enabled: true,
      ),
      KtModuleItem(
        "Báo cáo kỹ thuật",
        "asset/icons/icon_kt_baocao.svg",
        enabled: true,
      ),
    ];

    modules.assignAll(list);
  }

  /// Khi user nhấn vào module con
  void openMenu() => Get.toNamed(Routes.menu);
  void openNotice() => Get.toNamed(Routes.notify);
}