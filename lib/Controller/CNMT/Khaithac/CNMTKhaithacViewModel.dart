import 'package:get/get.dart';
import 'package:skypec/Route/AppRoutes.dart';

class CNMTKhaithacModuleItem {
  final String title;
  final String svg;
  final bool enabled;
  final String route; // route để điều hướng

  const CNMTKhaithacModuleItem({
    required this.title,
    required this.svg,
    this.enabled = true,
    this.route = '',
  });
}

class CNMTKhaithacViewModel extends GetxController {
  final modules = <CNMTKhaithacModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _initModules();
  }

  void _initModules() {
    modules.assignAll([
      const CNMTKhaithacModuleItem(
        title: 'Báo cáo khai thác ngày',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.cnmtBaocaokhaithacngay,
      ),
      const CNMTKhaithacModuleItem(
        title: 'Chưa có',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.cnmtBaocaokhaithacngay,
      ),
    ]);
  }

  void openModule(CNMTKhaithacModuleItem m) {
    if (!m.enabled) return;
    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
    }
  }
}