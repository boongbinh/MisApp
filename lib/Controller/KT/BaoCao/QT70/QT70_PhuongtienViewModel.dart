import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Route/AppRoutes.dart';

class QT70_PhuongtienModuleItem {
  final String title;
  final IconData icon; // ⭐ Đổi từ String svg sang IconData icon
  final bool enabled;
  final String route;

  const QT70_PhuongtienModuleItem({
    required this.title,
    required this.icon,
    this.enabled = true,
    this.route = '',
  });
}

class QT70_PhuongtienViewModel extends GetxController {
  final modules = <QT70_PhuongtienModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _initModules();
  }

  void _initModules() {
    modules.assignAll([
      const QT70_PhuongtienModuleItem(
        title: 'HSSS xe tra nạp (tuần)',
        icon: Icons.timeline, // ⭐ Icon cho biểu đồ tuần
        route: Routes.hsssXeTraNapTuan,
      ),
      const QT70_PhuongtienModuleItem(
        title: 'HSSS xe tra nạp (Tháng)',
        icon: Icons.calendar_month, // ⭐ Icon cho tháng
        route: Routes.hsssXeTraNapThang,
      ),
      const QT70_PhuongtienModuleItem(
        title: 'HSSS xe vận CNVT (tuần)',
        icon: Icons.local_shipping, // ⭐ Icon cho xe vận chuyển
        route: Routes.hsssXeVanCNVTTuan,
      ),
      const QT70_PhuongtienModuleItem(
        title: 'HSSS xe vận CNVT (tháng)',
        icon: Icons.local_shipping, // ⭐ Icon cho xe vận chuyển
        route: Routes.hsssXeVanCNVTThang,
      ),
    ]);
  }

  void openModule(QT70_PhuongtienModuleItem m) {
    if (!m.enabled) return;


    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
    }
  }
}