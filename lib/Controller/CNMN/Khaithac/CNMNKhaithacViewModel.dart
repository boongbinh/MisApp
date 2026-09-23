import 'package:get/get.dart';
import 'package:skypec/Route/AppRoutes.dart';

class CNMNKhaithacModuleItem {
  final String title;
  final String svg;
  final bool enabled;
  final String route; // route để điều hướng

  const CNMNKhaithacModuleItem({
    required this.title,
    required this.svg,
    this.enabled = true,
    this.route = '',
  });
}

class CNMNKhaithacViewModel extends GetxController {
  final modules = <CNMNKhaithacModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _initModules();
  }

  void _initModules() {
    modules.assignAll([
      const CNMNKhaithacModuleItem(
        title: 'Báo cáo khai thác ngày',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.cnmnBaocaokhaithacngay,
      ),
      const CNMNKhaithacModuleItem(
        title: 'Chưa có',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.cnmnBaocaokhaithacngay,
      ),
    ]);
  }

  void openModule(CNMNKhaithacModuleItem m) {
    if (!m.enabled) return;
    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
    }
  }
}