import 'package:get/get.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:flutter/material.dart';

class CNMNKythuatModuleItem {
  final String title;
  final IconData icon;
  final bool enabled;
  final String route; // route để điều hướng

  const CNMNKythuatModuleItem({
    required this.title,
    required this.icon,
    this.enabled = true,
    this.route = '',
  });
}

class CNMNKythuatViewModel extends GetxController {
  final modules = <CNMNKythuatModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _initModules();
  }

  void _initModules() {
    modules.assignAll([
      const CNMNKythuatModuleItem(
        title: 'Thông tin chung',
        icon: Icons.dashboard_outlined,
        route: Routes.cnmnThongtinchung,
      ),
      const CNMNKythuatModuleItem(
        title: 'Phân tích chi phí',
        icon: Icons.bar_chart_outlined,
        route: Routes.cnmnPhantichchiphi,
      ),
      const CNMNKythuatModuleItem(
        title: 'Dữ liệu kỹ thuật',
        icon: Icons.engineering_outlined,
        route: Routes.cnmnDulieukythuat,
      ),
    ]);
  }

  void openModule(CNMNKythuatModuleItem m) {
    if (!m.enabled) return;
    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
    }
  }
}