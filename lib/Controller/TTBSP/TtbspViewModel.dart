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
    else if (m.title == 'Báo cáo sản lượng theo ngày') {
      Get.toNamed(Routes.ttbspBaocaosanluongtheongay);
    }
    else if (m.title == 'Báo cáo sản lượng theo tháng') {
      Get.toNamed(Routes.ttbspBaocaosanluongtheothang);
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

    // Kiểm tra từng quyền ttbsp
    final hasDt = isAdmin || has("2. TTBSP:Thông Tin Quản Trị:DOANHTHU");// doanh thu
    final hasBaocaosanluongtheongay = isAdmin || has("Mobileapp:TTBSP:App_Baocaosanluongtheongay");// báo cáo sản lượng theo ngày
    final hasBaocaosanluongtheothang = isAdmin || has("Mobileapp:TTBSP:App_Baocaosanluongtheothang");// báo cáo sản lượng theo tháng



    final list = <TtbspModuleItem>[
      TtbspModuleItem(
        "Doanh thu",
        "asset/icons/icon_ttbsp_dt.svg",
        enabled: hasDt,
      ),
      TtbspModuleItem(
        "Báo cáo sản lượng theo ngày",
        "asset/icons/icon_ttbsp_dt.svg",
        enabled: hasBaocaosanluongtheongay,
      ),
      TtbspModuleItem(
        "Báo cáo sản lượng theo tháng",
        "asset/icons/icon_ttbsp_dt.svg",
        enabled: hasBaocaosanluongtheothang,
      ),
    ];

    modules.assignAll(list);
  }

  /// Khi user nhấn vào module con
  void openMenu() => Get.toNamed(Routes.menu);
  void openNotice() => Get.toNamed(Routes.notify);
}
