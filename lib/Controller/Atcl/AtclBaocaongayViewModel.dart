import 'package:get/get.dart';
import 'package:skypec/Route/AppRoutes.dart';

class AtclBaocaongayModuleItem {
  final String title;
  final String svg;
  final bool enabled;
  final String route; // route để điều hướng

  const AtclBaocaongayModuleItem({
    required this.title,
    required this.svg,
    this.enabled = true,
    this.route = '',
  });
}

class AtclBaocaongayViewModel extends GetxController {
  final modules = <AtclBaocaongayModuleItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    _initModules();
  }

  void _initModules() {
    modules.assignAll([
      const AtclBaocaongayModuleItem(
        title: 'Theo dõi bảng',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.atclBaocaongayBang,
      ),
      const AtclBaocaongayModuleItem(
        title: 'Đánh giá và phê duyệt',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.atclBaocaongayDanhgia,
      ),
      const AtclBaocaongayModuleItem(
        title: 'Báo cáo an toàn theo mô hình SHELL',
        svg: 'asset/icons/icon_kt_baocao.svg',
        route: Routes.atclBaocaongayMohinhshell,
      ),
    ]);
  }

  void openModule(AtclBaocaongayModuleItem m) {
    if (!m.enabled) return;
    if (m.route.isNotEmpty) {
      Get.toNamed(m.route);
    }
  }
}