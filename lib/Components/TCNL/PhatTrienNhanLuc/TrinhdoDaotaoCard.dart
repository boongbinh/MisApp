import 'package:flutter/material.dart';

class TrinhdoDaotaoCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const TrinhdoDaotaoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Tính tổng số người lớn nhất để scale chiều rộng thanh
    final maxTotal = data.map((e) => (e['Nam'] ?? 0) + (e['Nu'] ?? 0)).reduce((a, b) => a > b ? a : b).toDouble();
    if (maxTotal == 0) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trình độ Đào tạo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Chú thích (legend)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.blue, label: 'Nam'),
                const SizedBox(width: 24),
                _LegendItem(color: Colors.amber, label: 'Nữ'),
              ],
            ),
            const SizedBox(height: 16),
            // Danh sách các thanh ngang
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = data[index];
                final title = item['TrinhDo'] as String;
                final nam = (item['Nam'] ?? 0).toDouble();
                final nu = (item['Nu'] ?? 0).toDouble();
                final total = nam + nu;
                final namWidth = (nam / maxTotal) * 100;
                final nuWidth = (nu / maxTotal) * 100;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        return Stack(
                          children: [
                            // Nền xám
                            Container(
                              height: 24,
                              width: maxWidth,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // Phần nam (xanh)
                            if (nam > 0)
                              Container(
                                height: 24,
                                width: (namWidth / 100) * maxWidth,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                              ),
                            // Phần nữ (vàng) – đặt bên cạnh nam
                            if (nu > 0)
                              Positioned(
                                left: (namWidth / 100) * maxWidth,
                                child: Container(
                                  height: 24,
                                  width: (nuWidth / 100) * maxWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(nuWidth > 0 ? 4 : 0),
                                      bottomRight: Radius.circular(nuWidth > 0 ? 4 : 0),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng: ${total.toInt()}', style: const TextStyle(fontSize: 12)),
                        Text('Nam: ${nam.toInt()}  Nữ: ${nu.toInt()}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}