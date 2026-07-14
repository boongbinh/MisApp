import 'package:get/get.dart';
import 'package:skypec/Global/Constant.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class SplashViewModel extends GetxController {
  void checkLogin() {
    Future.delayed(const Duration(seconds: 1), () async {
      var username = await Utils.getStringValueWithKey(Constant.USERNAME);
      if (username != '') {
        String pass =
            await Utils.getStringValueWithKey(Constant.PASSWORD) as String;
        login(username, pass);
      } else {
        Get.offAllNamed(Routes.login);
      }
    });
  }

  void login(String user, String pass) async {
    try {
      var param = {
        "username": user,
        "password": pass,
        "fcmtoken": GlobalValue.getInstance().getFCMToken(),
      };
      var data = await APICaller.getInstance().post('Login', param);
      if (data != null) {
        GlobalValue.getInstance().setToken('Bearer ${data['token']}');
        Utils.saveStringWithKey(Constant.ACCESS_TOKEN, data['token']);
        GlobalValue.getInstance().setPermission(data['quyen']);
        print(data['token']);
        Get.offAllNamed(Routes.home);
      } else {
        //backLogin(true);
      }
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }
}
