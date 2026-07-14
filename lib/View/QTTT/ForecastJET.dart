import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypec/Controller/QTTT/ForecastJETViewModel.dart';

class ForecastJET extends StatelessWidget {
  ForecastJET({super.key});
  final vm = Get.put(ForecastJETViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Bảng dự đoán giá JET A1'),
        foregroundColor: Colors.white,
        centerTitle: true,
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
      body: Obx(() {
        if (vm.loading.value && vm.rows.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _TableMerged(vm: vm),
          ),
        );
      }),
    );
  }
}

class _TableMerged extends StatelessWidget {
  const _TableMerged({required this.vm});
  final ForecastJETViewModel vm;

  static const _headerColor = Color(0xFF2C6E93); // xanh đậm như mẫu
  static const _borderColor = Color(0xFFE6ECF5); // viền xám nhạt
  static const _headerDivider = Colors.white24; // vạch dọc trong header

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min, // CHỈ cao theo content
        children: [
          // HEADER: nền xanh, chữ trắng, có vạch dọc & bo 2 góc trên
          Container(
            decoration: const BoxDecoration(
              color: _headerColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: DefaultTextStyle(
              style: theme.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              child: IntrinsicHeight(
                // giúp vạch dọc cao bằng hàng header
                child: Row(
                  children: const [
                    _H('Tháng', flex: 10, center: true),
                    _VLine(color: _headerDivider),
                    _H('Giá dự đoán Singapore', flex: 18, center: true),
                    _VLine(color: _headerDivider),
                    _H('Thời gian dự đoán Singapore', flex: 20, center: true),
                    _VLine(color: _headerDivider),
                    _H('Giá dự đoán Altview', flex: 18, center: true),
                    _VLine(color: _headerDivider),
                    _H('Thời gian dự đoán Altview', flex: 20, center: true),
                    _VLine(color: _headerDivider),
                    _H('Giá thực tế', flex: 14, center: true),
                  ],
                ),
              ),
            ),
          ),

          // BODY: mỗi dòng có vạch dọc ngăn cột và gạch chân
          ...vm.rows.map(
            (r) => Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _borderColor, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: IntrinsicHeight(
                // giúp vạch dọc cao bằng hàng
                child: Row(
                  children: [
                    _C(
                      Text(r.monthLabel, textAlign: TextAlign.center),
                      flex: 10,
                    ),
                    const _VLine(color: _borderColor),
                    _C(
                      Text(
                        r.singaporePrice.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                      ),
                      flex: 18,
                    ),
                    const _VLine(color: _borderColor),
                    _C(
                      Text(
                        vm.formatDate(r.singaporeModifiedDate),
                        textAlign: TextAlign.center,
                      ),
                      flex: 20,
                    ),
                    const _VLine(color: _borderColor),
                    _C(
                      Text(
                        r.altViewPrice.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                      ),
                      flex: 18,
                    ),
                    const _VLine(color: _borderColor),
                    _C(
                      Text(
                        vm.formatDate(r.altViewModifiedDate),
                        textAlign: TextAlign.center,
                      ),
                      flex: 20,
                    ),
                    const _VLine(color: _borderColor),
                    _C(
                      Text(
                        r.actualPrice == 0
                            ? ''
                            : r.actualPrice.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                      ),
                      flex: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  const _H(this.text, {this.flex = 1, this.center = false});
  final String text;
  final int flex;
  final bool center;

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(text, textAlign: center ? TextAlign.center : TextAlign.start),
  );
}

class _C extends StatelessWidget {
  const _C(this.child, {this.flex = 1});
  final Widget child;
  final int flex;

  @override
  Widget build(BuildContext context) => Expanded(flex: flex, child: child);
}

/// Vạch dọc ngăn cột – cao full hàng
class _VLine extends StatelessWidget {
  const _VLine({this.color = const Color(0xFFE6ECF5)});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: double.infinity, color: color);
}
