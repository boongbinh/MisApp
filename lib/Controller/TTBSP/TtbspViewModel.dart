import 'dart:convert';
import 'package:get/get.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';

class TtbspModuleItem {
  final String title;
  final String svg; // đường dẫn icon SVG
  final bool enabled;
  const TtbspModuleItem(this.title, this.svg, {this.enabled = true});
}

class TtbspViewModel extends GetxController {
  final userName = ''.obs;
  final modules = <TtbspModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _applyPermission(GlobalValue.getInstance().getPermission());
    GetProfileInfo();
  }


void openModule(TtbspModuleItem m) {
    if (!m.enabled) return;

    if (m.title == 'Doanh thu') {
      Get.toNamed(Routes.ttbspDt);
    }
    else if (m.title == 'Thông tin chuyến bay') {
      Get.toNamed(Routes.ttbspTtcb);
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

    // Kiểm tra từng quyền ttbsp
    final hasDt = isAdmin || has("2. TTBSP");// doanh thu
    final hasTTCB = isAdmin || has("2. TTBSP:Thông Tin Quản Trị:THONGTINCHUYENBAY");// thông tin chuyến bay



    final list = <TtbspModuleItem>[
      TtbspModuleItem(
        "Doanh thu",
        "asset/icons/icon_ttbsp_dt.svg",
        enabled: hasDt,
      ),
      TtbspModuleItem(
        "Thông tin chuyến bay",
        "asset/icons/icon_ttbsp_t tcb.svg",
        enabled: hasTTCB,
      ),
      
    ];

    modules.assignAll(list);
  }

  /// Khi user nhấn vào module con
  void openMenu() => Get.toNamed(Routes.menu);
  void openNotice() => Get.toNamed(Routes.notify);
}
