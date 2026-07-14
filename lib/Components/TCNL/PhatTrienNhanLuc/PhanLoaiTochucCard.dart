import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

// Model dữ liệu
class PhanLoaiTochucData {
  final String name;
  final double count;
  PhanLoaiTochucData({required this.name, required this.count});
}

// Component
class PhanLoaiTochucCard extends StatelessWidget {
  final List<PhanLoaiTochucData> dataList;
  final double height;
  final String title;

  const PhanLoaiTochucCard({
    super.key,
    this.dataList = const [],          // ✅ không required, mặc định rỗng
    this.height = 600,                 // ✅ mặc định 400
    this.title = 'PHÂN LOẠI TỔ CHỨC TRỰC THUỘC CQ - ĐV', // ✅ mặc định tiêu đề
  });

  // Dữ liệu mặc định (giữ nguyên)
  factory PhanLoaiTochucCard.withDefaultData() {
    return PhanLoaiTochucCard(
      dataList: [
        PhanLoaiTochucData(name: 'Chi nhánh Skypec khu vực Miền Bắc', count: 5),
        PhanLoaiTochucData(name: 'Chi nhánh Skypec khu vực Miền Nam', count: 3),
        PhanLoaiTochucData(name: 'Chi nhánh Skypec Sân bay Buôn Ma Thuột', count: 11),
        PhanLoaiTochucData(name: 'Chi nhánh Skypec Sân bay Cần Thơ', count: 12),
        PhanLoaiTochucData(name: 'Chi nhánh Skypec Sân bay Cát Bi', count: 15),
        PhanLoaiTochucData(name: 'Chi nhánh Skypec Sân bay Đồng Hới', count: 10),
        PhanLoaiTochucData(name: 'Chi nhánh Skypec Sân bay Liên Khương', count: 15),
        PhanLoaiTochucData(name: 'Chi nhánh Skypec Sân bay Phú Quốc', count: 23),
        PhanLoaiTochucData(name: 'Chi nhánh Skypec Sân bay Thọ Xuân', count: 15),
        PhanLoaiTochucData(name: 'Chi nhánh Skypec Sân bay Vân Đồn', count: 7),
        PhanLoaiTochucData(name: 'Chi nhánh Skypec Sân bay Vinh', count: 25),
        PhanLoaiTochucData(name: 'Đội kho xăng dầu sân bay Nội bài', count: 39),
        PhanLoaiTochucData(name: 'Đội kho xăng dầu sân bay Tân Sơn Nhất', count: 32),
      ],
    );
  }

  double get totalCount => dataList.fold(0, (sum, item) => sum + item.count);

  @override
  Widget build(BuildContext context) {
    final total = totalCount;
    // Nếu không có dữ liệu, có thể hiển thị thông báo hoặc ẩn
    if (dataList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (Tổng: ${total.toInt()})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: SfTreemap(
                dataCount: dataList.length,
                weightValueMapper: (int index) => dataList[index].count,
                levels: [
                  TreemapLevel(
                    groupMapper: (int index) => dataList[index].name,
                    labelBuilder: (context, tile) {
                      final name = tile.group;
                      final weight = tile.weight;
                      final percent = (weight / total * 100).toStringAsFixed(1);
                      String shortName = name;
                      if (shortName.length > 25) {
                        shortName = '${shortName.substring(0, 22)}...';
                      }
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          '$shortName\n$percent%',
                          style: const TextStyle(color: Colors.black, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}