import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/Account/ChangePassViewModel.dart';

class ChangePass extends GetView<ChangePassViewModel> {
  ChangePass({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2B71C9), Color(0xFF2E8AC7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _PwdField(
              label: 'Mật khẩu cũ',
              obscureRx: controller.obsOld,
              onChanged: (v) => controller.oldPwd.value = v,
              validator: (v) => controller.validateOld(v ?? ''),
            ),
            const SizedBox(height: 12),
            _PwdField(
              label: 'Mật khẩu mới',
              obscureRx: controller.obsNew,
              onChanged: (v) => controller.newPwd.value = v,
              validator: (v) => controller.validateNew(v ?? ''),
              helper:
                  'Tối thiểu 8 ký tự, gồm chữ thường, CHỮ HOA, số và ký tự đặc biệt.',
            ),
            const SizedBox(height: 12),
            _PwdField(
              label: 'Nhập lại mật khẩu mới',
              obscureRx: controller.obsRe,
              onChanged: (v) => controller.rePwd.value = v,
              validator: (v) => controller.validateRe(v ?? ''),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final enabled =
                  controller.canSubmit && !controller.submitting.value;
              return SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed:
                      enabled
                          ? () {
                            if (_formKey.currentState!.validate()) {
                              controller.submit();
                            }
                          }
                          : null,
                  style: FilledButton.styleFrom(shape: const StadiumBorder()),
                  child:
                      controller.submitting.value
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                          : const Text('Đổi mật khẩu mới'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PwdField extends StatelessWidget {
  const _PwdField({
    required this.label,
    required this.obscureRx,
    required this.onChanged,
    required this.validator,
    this.helper,
  });

  final String label;
  final RxBool obscureRx;
  final void Function(String) onChanged;
  final String? Function(String?) validator;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        obscureText: obscureRx.value,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
            icon: Icon(
              obscureRx.value ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () => obscureRx.toggle(),
          ),
        ),
      ),
    );
  }
}
