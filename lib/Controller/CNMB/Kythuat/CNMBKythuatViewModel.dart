import 'package:get/get.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:flutter/material.dart';

class CNMBKythuatModuleItem {
  final String title;
  final IconData icon;
  final bool enabled;
  final String route; // route để điều hướng

  const CNMBKythuatModuleItem({
    required this.title,
    required this.icon,
    this.enabled = true,
    this.route = '',
  });
}

class CNMBKythuatViewModel extends GetxController {
  final modules = <CNMBKythuatModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _initModules();
  }

  void _initModules() {
    modules.assignAll([
      const CNMBKythuatModuleItem(
        title: 'Thông tin chung',
        icon: Icons.dashboard_outlined,
        route: Routes.cnmbThongtinchung,
      ),
      const CNMBKythuatModuleItem(
        title: 'Phân tích chi phí',
        icon: Icons.bar_chart_outlined,
        route: Routes.cnmbPhantichchiphi,
      ),
      const CNMBKythuatModuleItem(
        title: 'Dữ liệu kỹ thuật',
        icon: Icons.engineering_outlined,
        route: Routes.cnmbDulieukythuat,
      ),
    ]);
  }

  void openModule(CNMBKythuatModuleItem m) {
    if (!m.enabled) return;
    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
    }
  }
}