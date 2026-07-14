import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:skypec/Global/Constant.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class LoginViewModel extends GetxController {
  //đọc nội dung text trong các TextField
  final userCtl = TextEditingController();
  final passCtl = TextEditingController();

  final obscure = true.obs;       //ẩn hiện mật khẩu
  final isValid = false.obs;      //kiểm tra xem form có hợp lệ
  final isSubmitting = false.obs; //trạng thái đang gửi đăng nhập

  final passError = RxnString();  //lỗi hiển thị dưới TextField mật khẩu--lưu thông báo lỗi

//Hàm được gọi mỗi khi user nhập ký tự mới
  void _recalc() {
    isValid.value =
        userCtl.text.trim().isNotEmpty && passCtl.text.trim().isNotEmpty;
    passError.value = null;
  }
//Khi controller được tạo, nó bắt đầu lắng nghe sự thay đổi của input
  @override
  void onInit() {
    super.onInit();
    userCtl.addListener(_recalc);
    passCtl.addListener(_recalc);
  }
//Khi controller bị huỷ (rời trang login), nó giải phóng bộ nhớ
  @override
  void onClose() {
    userCtl.dispose();
    passCtl.dispose();
    super.onClose();
  }

  void toggleObscure() => obscure.toggle();

  void login() async {
    if (!isValid.value || isSubmitting.value) {
      passError.value = 'Vui lòng nhập đầy đủ thông tin';
      return;
    }
    isSubmitting.value = true;

    try {
      try {
        var param = {
          "username": userCtl.text.trim(),
          "password": passCtl.text.trim(),
          "fcmtoken": GlobalValue.getInstance().getFCMToken(),
        };
        //Gọi API /Login qua APICaller--Gửi username, password và FCM token lên server
        var data = await APICaller.getInstance().post('Login', param);
        /*
        Nếu đăng nhập thành công
          -Lưu token tạm thời (trong GlobalValue – singleton)
          -Lưu token vào storage (qua Utils.saveStringWithKey)
          -Ghi lại quyền truy cập (data['quyen'])
          -Chuyển sang màn hình Home, đồng thời xoá toàn bộ stack navigation trước đó (nghĩa là user không thể back về login nữa)
         */
        if (data != null) {
          GlobalValue.getInstance().setToken('Bearer ${data['token']}');
          Utils.saveStringWithKey(Constant.ACCESS_TOKEN, data['token']);
          GlobalValue.getInstance().setPermission(data['quyen']);
          print(data['token']);
          Utils.saveStringWithKey(Constant.USERNAME, userCtl.text.trim());
          Utils.saveStringWithKey(Constant.PASSWORD, passCtl.text.trim());
          Get.offAllNamed(Routes.home);
        } else {
          //backLogin(true);
        }
      } catch (e) {
        Utils.showSnackBar(title: 'Thông báo', message: '$e');
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  void forgotPassword() {}
}
