import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Global/Constant.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Utils/Utils.dart';

class MenuViewModel extends GetxController {
  // dữ liệu hồ sơ
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString avatarUrl = ''.obs; // để trống => dùng ảnh mặc định
  RxString version = '1.1'.obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    loadInfo();
  }

  void loadInfo() {
    name.value = GlobalValue.getInstance().getFullname();
    email.value = GlobalValue.getInstance().getMail();
    avatarUrl.value = GlobalValue.getInstance().getPath();

    print('---------- ' + name.value);
  }

  // actions
  void onChangePassword() {
    Get.toNamed(Routes.changepass);
  }

  Future<void> onLogout() async {
    final ok =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Đồng ý'),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;

    if (!ok) return;

    Utils.saveStringWithKey(Constant.ACCESS_TOKEN, '');
    Utils.saveStringWithKey(Constant.USERNAME, '');
    Utils.saveStringWithKey(Constant.PASSWORD, '');
    Get.offAndToNamed(Routes.login);
  }
}
