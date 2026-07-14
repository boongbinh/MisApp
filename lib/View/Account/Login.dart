import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Components/GlassCard.dart';
import 'package:skypec/Controller/Account/LoginViewModel.dart';

class Login extends GetView<LoginViewModel> {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('asset/images/background.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.15)),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Center(
                          child: Image.asset(
                            'asset/images/logo.png',
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      Text('Tài khoản', style: text.titleMedium),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.userCtl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Tên tài khoản',
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Mật khẩu', style: text.titleMedium),
                      const SizedBox(height: 8),

                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Giữ nguyên border mặc định từ Theme (không override viền đỏ)
                            TextField(
                              controller: controller.passCtl,
                              obscureText: controller.obscure.value,
                              decoration: InputDecoration(
                                hintText: 'Mật khẩu',
                                suffixIcon: IconButton(
                                  tooltip:
                                      controller.obscure.value
                                          ? 'Hiện mật khẩu'
                                          : 'Ẩn mật khẩu',
                                  onPressed: controller.toggleObscure,
                                  icon: Icon(
                                    controller.obscure.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                            ),

                            // Chỉ hiển thị dòng báo lỗi bên dưới
                            if (controller.passError.value != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 18,
                                      color: Color(0xFFEF4444),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      controller.passError.value!,
                                      style: const TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: controller.login,
                        child: SizedBox(
                          height: 30,
                          child: Center(child: const Text('Đăng nhập')),
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
