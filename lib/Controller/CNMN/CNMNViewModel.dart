import 'dart:convert';
import 'package:get/get.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:flutter/material.dart';

class CNMNModuleItem {
  final String title;
  final IconData icon; // icon
  final bool enabled;
  final List<CNMNModuleItem> children; // ⭐ Thêm children cho menu con

  const CNMNModuleItem(
    this.title,
    this.icon, {
    this.enabled = true,
    this.children = const [],
  });

  // ⭐ Kiểm tra có menu con không
  bool get hasChildren => children.isNotEmpty;
}

class CNMNViewModel extends GetxController {
  final userName = ''.obs;
  final modules = <CNMNModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _applyPermission(GlobalValue.getInstance().getPermission());
    GetProfileInfo();
  }

  void openModule(CNMNModuleItem m) {
    if (!m.enabled) return;

    if (m.title == 'Nhóm khai thác') {
      Get.toNamed(Routes.cnmnKhaithac);
    } else if (m.title == 'Nhóm kỹ thuật') {
      Get.toNamed(Routes.cnmnKythuat);
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
    final hasNhomkhaithac = isAdmin || has("7.3. CNKVMN:Nhóm khai thác");
    final haskythuat = isAdmin || has("7.3. CNKVMN:Nhóm kỹ thuật");

    final list = <CNMNModuleItem>[
      CNMNModuleItem(
        "Nhóm khai thác",
        Icons.engineering_outlined,
        enabled: hasNhomkhaithac,
      ),
      CNMNModuleItem(
        "Nhóm kỹ thuật",
        Icons.assignment_outlined,
        enabled: haskythuat,
      ),
    ];

    modules.assignAll(list);
  }

  /// Khi user nhấn vào module con
  void openMenu() => Get.toNamed(Routes.menu);
  void openNotice() => Get.toNamed(Routes.notify);
}