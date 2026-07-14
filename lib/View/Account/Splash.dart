import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/Account/SplashViewModel.dart';

class Splash extends GetView<SplashViewModel> {
  @override
  Widget build(BuildContext context) {
    controller.checkLogin();
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 2,
            child: Image.asset('asset/images/logo.png', fit: BoxFit.fitWidth),
          ),
          Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }
}
