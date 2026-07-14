import 'package:flutter/material.dart';

class TrinhdodaotaoData {
  final String label;
  final int nam;
  final int nu;
  TrinhdodaotaoData({required this.label, required this.nam, required this.nu});
}

class TrinhdodaotaoCard extends StatelessWidget {
  final List<TrinhdodaotaoData> dataList;
  final String title;

  const TrinhdodaotaoCard({
    super.key,
    required this.dataList,
    this.title = 'Trình độ Đào tạo',
  });

  @override
  Widget build(BuildContext context) {
    // Lọc bỏ dữ liệu có total = 0
    final filteredData = dataList.where((e) => e.nam + e.nu > 0).toList();
    if (filteredData.isEmpty) return const SizedBox.shrink();

    // Tính tổng số người lớn nhất để scale chiều rộng thanh
    final maxTotal = filteredData
        .map((e) => (e.nam + e.nu).toDouble())
        .reduce((a, b) => a > b ? a : b);
    if (maxTotal == 0) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              itemCount: filteredData.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredData[index];
                final title = item.label;
                final nam = item.nam.toDouble();
                final nu = item.nu.toDouble();
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