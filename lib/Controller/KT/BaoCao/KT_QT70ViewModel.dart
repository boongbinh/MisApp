import 'package:get/get.dart';
import 'package:skypec/Route/AppRoutes.dart';

class KT_QT70ModuleItem {
  final String title;
  final String svg;
  final bool enabled;
  final String route; // route để điều hướng

  const KT_QT70ModuleItem({
    required this.title,
    required this.svg,
    this.enabled = true,
    this.route = '',
  });
}

class KT_QT70ViewModel extends GetxController {
  final modules = <KT_QT70ModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _initModules();
  }

  void _initModules() {
    modules.assignAll([
      const KT_QT70ModuleItem(
        title: 'Phương Tiện',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.ktQT70huongTien,
      ),
      const KT_QT70ModuleItem(
        title: 'Kho bể',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: 'kho_be',
      ),
    ]);
  }

  void openModule(KT_QT70ModuleItem m) {
    if (!m.enabled) return;
    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
    }
  }
}