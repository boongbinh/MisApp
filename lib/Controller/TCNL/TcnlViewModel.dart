import 'dart:convert';
import 'package:get/get.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';

class TcnlModuleItem {
  final String title;
  final String svg; // đường dẫn icon SVG
  final bool enabled;
  const TcnlModuleItem(this.title, this.svg, {this.enabled = true});
}

class TcnlViewModel extends GetxController {
  final userName = ''.obs;
  final modules = <TcnlModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _applyPermission(GlobalValue.getInstance().getPermission());
    GetProfileInfo();
  }


void openModule(TcnlModuleItem m) {
    if (!m.enabled) return;

    if (m.title == 'Phát triển nhân lực') {
      Get.toNamed(Routes.tcnlPtnl);
    }
    else if (m.title == 'Năng suất lao động') {
      Get.toNamed(Routes.tcnlNsld);
    } else if (m.title == 'Tiền lương chính sách') {
      Get.toNamed(Routes.tcnlTlcs);
    } else if (m.title == 'Công tác Đảng') {
      Get.toNamed(Routes.tcnlCtd);
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
    final hasPTNL = isAdmin || has("5. TCNL:Dashboard");// Phát triển nhân lực
    //final hasNSLD = isAdmin || has("5. TCNL:Dashboard2");// Năng suất lao động
    final hasTLCS = isAdmin || has("5. TCNL:Dashboard3");// Tiền lương chính sách
    final hasCTD = isAdmin || has("5. TCNL:Dashboard4");// Công tác đảng


    final list = <TcnlModuleItem>[
      TcnlModuleItem(
        "Phát triển nhân lực",
        "asset/icons/icon_tcnl_ptnl.svg",
        enabled: hasPTNL,
      ),
      
      TcnlModuleItem(
        "Tiền lương chính sách",
        "asset/icons/icon_tcnl_ptnl.svg",
        enabled: hasTLCS,
      ),
      TcnlModuleItem(
        "Công tác Đảng",
        "asset/icons/icon_tcnl_ptnl.svg",
        enabled: hasCTD,
      ),
    ];

    modules.assignAll(list);
  }

  /// Khi user nhấn vào module con
  void openMenu() => Get.toNamed(Routes.menu);
  void openNotice() => Get.toNamed(Routes.notify);
}
