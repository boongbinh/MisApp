import 'package:get/get.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:flutter/material.dart';

class CNMTKythuatModuleItem {
  final String title;
  final IconData icon;
  final bool enabled;
  final String route; // route để điều hướng

  const CNMTKythuatModuleItem({
    required this.title,
    required this.icon,
    this.enabled = true,
    this.route = '',
  });
}

class CNMTKythuatViewModel extends GetxController {
  final modules = <CNMTKythuatModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _initModules();
  }

  void _initModules() {
    modules.assignAll([
      const CNMTKythuatModuleItem(
        title: 'Thông tin chung',
        icon: Icons.dashboard_outlined,
        route: Routes.cnmtThongtinchung,
      ),
      const CNMTKythuatModuleItem(
        title: 'Phân tích chi phí',
        icon: Icons.bar_chart_outlined,
        route: Routes.cnmtPhantichchiphi,
      ),
      const CNMTKythuatModuleItem(
        title: 'Dữ liệu kỹ thuật',
        icon: Icons.engineering_outlined,
        route: Routes.cnmtDulieukythuat,
      ),
    ]);
  }

  void openModule(CNMTKythuatModuleItem m) {
    if (!m.enabled) return;
    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
    }
  }
}