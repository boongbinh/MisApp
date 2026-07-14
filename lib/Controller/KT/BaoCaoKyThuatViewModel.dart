import 'package:get/get.dart';
import 'package:skypec/Route/AppRoutes.dart';

class BaoCaoKyThuatModuleItem {
  final String title;
  final String svg;
  final bool enabled;
  final String route; // route để điều hướng

  const BaoCaoKyThuatModuleItem({
    required this.title,
    required this.svg,
    this.enabled = true,
    this.route = '',
  });
}

class BaoCaoKyThuatViewModel extends GetxController {
  final modules = <BaoCaoKyThuatModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _initModules();
  }

  void _initModules() {
    modules.assignAll([
      const BaoCaoKyThuatModuleItem(
        title: 'BC Tuần-Tháng QT70',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.ktQT70, // ⭐ Sửa thành Routes.ktQT70
      ),
    ]);
  }

  void openModule(BaoCaoKyThuatModuleItem m) {
    if (!m.enabled) return;

    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
    }
  }
}