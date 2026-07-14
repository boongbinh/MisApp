import 'package:flutter/material.dart';

class ThamnienCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final int thamNienTrungBinh;

  const ThamnienCard({super.key, required this.data, required this.thamNienTrungBinh});

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
              'Thâm niên bình quân $thamNienTrungBinh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240, // tăng chiều cao
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
                              width: widthPerBar * 0.6,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 8),
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
                Container(width: 16, height: 16, color: Colors.amber),
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