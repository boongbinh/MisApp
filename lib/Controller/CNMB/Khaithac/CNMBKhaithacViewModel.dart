import 'package:get/get.dart';
import 'package:skypec/Route/AppRoutes.dart';

class CNMBKhaithacModuleItem {
  final String title;
  final String svg;
  final bool enabled;
  final String route; // route để điều hướng

  const CNMBKhaithacModuleItem({
    required this.title,
    required this.svg,
    this.enabled = true,
    this.route = '',
  });
}

class CNMBKhaithacViewModel extends GetxController {
  final modules = <CNMBKhaithacModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _initModules();
  }

  void _initModules() {
    modules.assignAll([
      const CNMBKhaithacModuleItem(
        title: 'Báo cáo khai thác ngày',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.cnmbBaocaokhaithacngay,
      ),
      const CNMBKhaithacModuleItem(
        title: 'Chưa có',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.cnmbBaocaokhaithacngay,
      ),
    ]);
  }

  void openModule(CNMBKhaithacModuleItem m) {
    if (!m.enabled) return;
    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
    }
  }
}