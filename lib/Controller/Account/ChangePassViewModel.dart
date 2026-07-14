import 'package:get/get.dart';
import 'package:skypec/Global/Constant.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class ChangePassViewModel extends GetxController {
  // state
  final oldPwd = ''.obs;
  final newPwd = ''.obs;
  final rePwd = ''.obs;

  final obsOld = true.obs;
  final obsNew = true.obs;
  final obsRe = true.obs;

  final submitting = false.obs;

  // chữ thường + CHỮ HOA + số + ký tự đặc biệt, tối thiểu 8
  static final RegExp _pwdRe = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s]).{8,}$',
  );

  String? validateOld(String v) =>
      v.isEmpty ? 'Vui lòng nhập mật khẩu cũ' : null;

  String? validateNew(String v) {
    if (v.length < 8) return 'Tối thiểu 8 ký tự';
    if (!_pwdRe.hasMatch(v)) {
      return 'Phải gồm chữ thường, CHỮ HOA, số và ký tự đặc biệt';
    }
    if (v == oldPwd.value) return 'Mật khẩu mới không được trùng mật khẩu cũ';
    return null;
  }

  String? validateRe(String v) =>
      v != newPwd.value ? 'Mật khẩu nhập lại không khớp' : null;

  bool get canSubmit =>
      validateOld(oldPwd.value) == null &&
      validateNew(newPwd.value) == null &&
      validateRe(rePwd.value) == null;

  Future<void> submit() async {
    if (!canSubmit) return;
    submitting.value = true;
    try {
      var param = {
        "Password": oldPwd.value,
        "ConfirmPassword": rePwd.value,
        "NewPassword": newPwd.value,
        "userId": GlobalValue.getInstance().getUuid(),
      };
      var data = await APICaller.getInstance().post(
        'Login/ChangePassword',
        param,
      );
      if (data != null) {
        if (data != "Mật khẩu xác nhận không đúng") {
          Utils.showSnackBar(
            title: 'Thông báo',
            message: 'Đổi mật khẩu thành công',
          );
          Utils.saveStringWithKey(Constant.PASSWORD, newPwd.value);
          oldPwd.value = '';
          newPwd.value = '';
          rePwd.value = '';
        }
      }
    } finally {
      submitting.value = false;
    }
  }
}
