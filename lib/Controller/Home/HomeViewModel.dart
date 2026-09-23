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
  // void onReady() {
  //   super.onReady();
  //   _applyPermission(GlobalValue.getInstance().getPermission());
  //   GetProfileInfo();
  // }
void onReady() {
  super.onReady();

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
    else if (m.title == 'Phòng An ninh') {
      Get.toNamed(Routes.anNinhMain);
    }
    else if (m.title == 'An toàn chất lượng') {
      Get.toNamed(Routes.atclMain);
    }
    else if (m.title == 'Chi nhánh miền Bắc') {
      Get.toNamed(Routes.cnmbMain);
    }
    else if (m.title == 'Chi nhánh miền Trung') {
      Get.toNamed(Routes.cnmtMain);
    }
    else if (m.title == 'Chi nhánh miền Nam') {
      Get.toNamed(Routes.cnmnMain);
    }
    else if (m.title == 'Cung ứng điều vận') {
      Get.toNamed(Routes.cudvMain);
    }
    
  }

 
Future<void> GetProfileInfo() async {
  print('>>> GetProfileInfo START');

  try {
    final res = await APICaller.getInstance().get('Login/GetInfoUser');
    if (res == null) {
      return;
    }

    final data = jsonDecode(res) as Map<String, dynamic>;
    // =========================
    // THÔNG TIN USER
    // =========================

    userName.value = data['DisplayName']?.toString() ?? '';

    GlobalValue.getInstance().setFullname(
      data['DisplayName']?.toString() ?? '',
    );

    GlobalValue.getInstance().setUuid(
      data['UserId'] ?? 0,
    );

    GlobalValue.getInstance().setAvatar(
      data['UserImage']?.toString() ?? '',
    );

    // =========================
    // QUYỀN
    // =========================

    final permission = data['PermissionKey']?.toString() ?? '';

    GlobalValue.getInstance().setPermission(permission);

    // =========================
    // ÁP DỤNG QUYỀN
    // =========================

    _applyPermission(permission);


  } catch (e) {}
}



  void _applyPermission(String perm) {
  // Tách danh sách quyền thành Set
  final permissions = perm
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toSet();

  bool has(String key) {
    return permissions.contains(key.toLowerCase());
  }

  bool hasPrefix(String prefix) {
    final p = prefix.toLowerCase();

    return permissions.any((permission) {
      return permission.startsWith(p);
    });
  }

  // Admin có toàn quyền
  final isAdmin = has('administration:general');

  // =========================
  // QUYỀN TỪNG MODULE
  // =========================

  final hasCommonInfo =
      isAdmin || has('mobileapp:quantrithongtin');

  final hasCommonFinance =
      isAdmin || has('mobileapp:quantritaichinhmobileapp');

  final hasCommonOutput =
      isAdmin || has('mobileapp:baocaosanluongmobileapp');

  final hasCuDv =
      isAdmin || hasPrefix('1.cudv:');

  final hasTtbsp =
      isAdmin || hasPrefix('2. ttbsp:');

  final hasAnNinh =
      isAdmin || hasPrefix('4. anninh:');

  final hasTcnl =
      isAdmin || hasPrefix('tcnl');

  final hasKt =
      isAdmin || hasPrefix('6. kt:');

  final hasAtcl =
      isAdmin || hasPrefix('mobileapp:atcl');

  final hasCnkvMb =
      isAdmin || hasPrefix('7.1. cnkvmb:');

  final hasCnkvMt =
      isAdmin || hasPrefix('7.2. cnkvmt:');

  final hasCnkvMn =
      isAdmin || hasPrefix('7.3. cnkvmn:');

  final hasCnvt =
      isAdmin ||
      (
        hasPrefix('cnkv:') &&
        !hasCnkvMb
      );

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
      'Phòng An ninh',
      'asset/icons/icon_home_pan.svg',
      enabled: hasAnNinh,
    ),

    ModuleItem(
      'Phòng kỹ thuật',
      'asset/icons/icon_home_pkt.svg',
      enabled: hasKt,
    ),

    ModuleItem(
      'An toàn chất lượng',
      'asset/icons/icon_home_pan.svg',
      enabled: hasAtcl,
    ),

    ModuleItem(
      'Chi nhánh miền Bắc',
      'asset/icons/icon_home_cnmb.svg',
      enabled: hasCnkvMb,
    ),

    ModuleItem(
      'Chi nhánh miền Trung',
      'asset/icons/icon_home_cnvt.svg',
      enabled: hasCnkvMt,
    ),

    ModuleItem(
      'Chi nhánh miền Nam',
      'asset/icons/icon_home_cnmb.svg',
      enabled: hasCnkvMn,
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
