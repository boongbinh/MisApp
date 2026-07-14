import 'package:flutter/material.dart';

class DotuoiCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final int tuoiTrungBinh; // Thêm tham số

  const DotuoiCard({super.key, required this.data, required this.tuoiTrungBinh});


  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxSoNguoi = data.map((e) => e['SoNguoi'] as int).reduce((a, b) => a > b ? a : b).toDouble();
    if (maxSoNguoi == 0) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Độ tuổi (Tuổi trung bình $tuoiTrungBinh)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240, // tăng chiều cao để chứa nhãn
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final widthPerBar = constraints.maxWidth / data.length;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(data.length, (index) {
                      final item = data[index];
                      final soNguoi = (item['SoNguoi'] as int).toDouble();
                      final percent = soNguoi / maxSoNguoi;
                      final barHeight = percent * 180;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${soNguoi.toInt()}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: widthPerBar * 0.6, // giảm một chút để thoáng
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Nhãn trục x - dùng Flexible để xuống dòng tự nhiên
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                item['TenNhom'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 16, height: 16, color: Colors.blue),
                const SizedBox(width: 4),
                const Text('Số người', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}