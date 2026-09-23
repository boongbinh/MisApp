import 'dart:convert';
import 'package:get/get.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:flutter/material.dart';


class AtclModuleItem {
  final String title;
  final IconData icon;
  final bool enabled;
  final List<AtclModuleItem> children; // ⭐ Thêm children cho menu con

  const AtclModuleItem(
    this.title,
    this.icon, {
    this.enabled = true,
    this.children = const [],
  });

  // ⭐ Kiểm tra có menu con không
  bool get hasChildren => children.isNotEmpty;
}

class AtclViewModel extends GetxController {
  final userName = ''.obs;
  final modules = <AtclModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _applyPermission(GlobalValue.getInstance().getPermission());
    GetProfileInfo();
  }

  void openModule(AtclModuleItem m) {
    if (!m.enabled) return;

    if (m.title == 'Báo cáo ngày') {
      Get.toNamed(Routes.atclBaocaongay);
    } else if (m.title == 'Báo cáo tự nguyện') {
      Get.toNamed(Routes.atclBaocaotunguyen);
    }
    else if (m.title == 'Phiếu CAR') {
      Get.toNamed(Routes.atclPhieuCAR);
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

    // Kiểm tra từng quyền 
    //bao cao ngay dung chung bao cao tu nguyen
    final hasBaocaongay = isAdmin || has("10.ATCL:Nhập liệu:ATCL_BaocaosucoTunguyen");
    final hasPhieuCAR = isAdmin || has("10.ATCL:Nhập liệu:ATCL_PhieuCAR");

    final list = <AtclModuleItem>[
      AtclModuleItem(
        "Báo cáo ngày",
        Icons.today_outlined,
        enabled: hasBaocaongay,
      ),
      AtclModuleItem(
        "Báo cáo tự nguyện",
        Icons.feedback_outlined,
        enabled: hasBaocaongay,
      ),
      AtclModuleItem(
        "Phiếu CAR",
        Icons.assignment_outlined,
        enabled: hasPhieuCAR,
      ),
    ];

    modules.assignAll(list);
  }

  /// Khi user nhấn vào module con
  void openMenu() => Get.toNamed(Routes.menu);
  void openNotice() => Get.toNamed(Routes.notify);
}