import 'dart:convert';
import 'package:get/get.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';

class ModuleItem {
  final String title;
  final String svg; // đường dẫn SVG
  final bool enabled;
  const ModuleItem(this.title, this.svg, {this.enabled = true});
}

class HomeViewModel extends GetxController {
  final userName = ''.obs;
  final modules = <ModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _applyPermission(GlobalValue.getInstance().getPermission());
    GetProfileInfo();
  }

  void openModule(ModuleItem m) {
    if (!m.enabled) return;

    if (m.title == 'Quản trị thông tin') {
      Get.toNamed(Routes.qttt);
    } else if (m.title == 'Quản trị tài chính') {
      Get.toNamed(Routes.financeplan);
    } else if (m.title == 'Báo cáo sản lượng') {
      Get.toNamed(Routes.outputreport);
    } else if (m.title == 'Tổ chức nhân lực') {
      Get.toNamed(Routes.tcnlMain);
    }
     else if (m.title == 'Tiếp thị bán sản phẩm') {
      Get.toNamed(Routes.ttbspMain);
    }
    else if (m.title == 'Phòng kỹ thuật') {
      Get.toNamed(Routes.ktMain);
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

  void _applyPermission(String perm) {
    final lower = perm.toLowerCase();
    bool has(String key) => lower.contains(key.toLowerCase());

    // ✅ Nếu có quyền admin → bật tất cả module
    final isAdmin = has('administration') || has('admin');

    // nếu admin → tất cả quyền đều true
    final hasCommonInfo = isAdmin || has('commmon_quantrithongtin');
    final hasCommonFinance = isAdmin || has('commmon_quantritaichinh');
    final hasCommonOutput = isAdmin || has('commmon_baocaosanluong');
    final hasCuDv = isAdmin || has('1.cudv:');
    final hasTtbsp = isAdmin || has('2. ttbsp:');
    final hasAnNinh = isAdmin || has('4. anninh:');
    final hasTcnl = isAdmin || has('tcnl');
    final hasKt = isAdmin || has('6. kt:');
    final hasCnkvMb = isAdmin || has('cnkvmb:');
    final hasCnvt = isAdmin || (has('cnkv:') && !hasCnkvMb);

    final list = <ModuleItem>[
      ModuleItem(
        'Quản trị thông tin',
        'asset/icons/icon_home_qttt.svg',
        enabled: hasCommonInfo,
      ),
      ModuleItem(
        'Quản trị tài chính',
        'asset/icons/icon_home_qttc.svg',
        enabled: hasCommonFinance,
      ),
      ModuleItem(
        'Báo cáo sản lượng',
        'asset/icons/icon_home_bcsl.svg',
        enabled: hasCommonOutput,
      ),
      ModuleItem(
        'Cung ứng điều vận',
        'asset/icons/icon_home_cudv.svg',
        enabled: hasCuDv,
      ),
      ModuleItem(
        'Tổ chức nhân lực',
        'asset/icons/icon_home_tcnl.svg',
        enabled: hasTcnl,
      ),
      ModuleItem(
        'Tiếp thị bán sản phẩm',
        'asset/icons/icon_home_qlkh.svg',
        enabled: hasTtbsp,
      ),
      ModuleItem(
        'Phòng an ninh',
        'asset/icons/icon_home_pan.svg',
        enabled: hasAnNinh,
      ),
      ModuleItem(
        'Phòng kỹ thuật',
        'asset/icons/icon_home_pkt.svg',
        enabled: hasKt,
      ),
      ModuleItem(
        'Chi nhánh miền Bắc',
        'asset/icons/icon_home_cnmb.svg',
        enabled: hasCnkvMb,
      ),
      ModuleItem(
        'Chi nhánh vận tải',
        'asset/icons/icon_home_cnvt.svg',
        enabled: hasCnvt,
      ),
    ];

    modules.assignAll(list);
  }

  void openMenu() => Get.toNamed(Routes.menu);
  void openNotice() => Get.toNamed(Routes.notify);
}
