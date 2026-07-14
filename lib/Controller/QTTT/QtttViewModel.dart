import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skypec/Components/Qttt/MarketFilterSheet.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';
import 'package:intl/intl.dart';

class KpiItem {
  int id;
  String title;
  String leftLabel;
  String leftValue;
  String? rightLabel;
  String? rightValue;
  String? subtitle; // ví dụ: "Tỉ giá ngày 07/08/2025"
  KpiItem({
    required this.id,
    required this.title,
    required this.leftLabel,
    required this.leftValue,
    this.rightLabel,
    this.rightValue,
    this.subtitle,
  });
}

// ----- Mức độ tin -----
enum Importance { low, normal, high, critical }

extension ImportanceX on Importance {
  String get label => switch (this) {
    Importance.low => 'Ít quan trọng',
    Importance.normal => 'Quan trọng',
    Importance.high => 'Rất quan trọng',
    Importance.critical => 'Khẩn cấp',
  };
  Color get color => switch (this) {
    Importance.low => const Color(0xFF2563EB), // xanh dương
    Importance.normal => const Color(0xFFF59E0B), // vàng
    Importance.high => const Color(0xFFEF4444), // đỏ
    Importance.critical => const Color(0xFF111827),
  };
}

class ImportanceTag {
  final String label;
  final Color color;
  const ImportanceTag(this.label, this.color);

  /// Map từ MucDo ở API
  static ImportanceTag fromCode(int? code) {
    switch (code) {
      case 3:
        return const ImportanceTag('Rất quan trọng', Color(0xFFEF4444)); // đỏ
      case 2:
        return const ImportanceTag('Ít quan trọng', Color(0xFF2563EB)); // xanh
      case 1:
      default:
        return const ImportanceTag('Quan trọng', Color(0xFFF59E0B)); // cam
    }
  }
}

class MarketNews {
  final int id;
  final DateTime date;
  final int loaiThongTin; // LoaiThongTin từ API
  final int mucDo; // MucDo từ API
  final String title;
  final String summary;
  final String path;

  MarketNews({
    required this.id,
    required this.date,
    required this.loaiThongTin,
    required this.mucDo,
    required this.title,
    required this.summary,
    required this.path,
  });

  factory MarketNews.fromJson(Map<String, dynamic> j) {
    return MarketNews(
      id: (j['Id'] ?? 0) as int,
      date: DateTime.tryParse(j['Ngay']?.toString() ?? '') ?? DateTime.now(),
      loaiThongTin: (j['LoaiThongTin'] ?? 0) as int,
      mucDo: (j['MucDo'] ?? 0) as int,
      title: (j['TieuDe'] ?? '').toString(),
      summary: (j['NoiDungChiTiet'] ?? '').toString(),
      path: (j['DuongDan'] ?? '').toString(),
    );
  }

  // ======= Helpers cho UI =======
  String get dateText => DateFormat('dd/MM/yyyy').format(date);

  /// Map MucDo -> label (dùng trong VM: selectedLevelLabel)
  static String levelLabelFromCode(int? code) {
    switch (code) {
      case 1:
        return 'Quan trọng';
      case 2:
        return 'Ít quan trọng';
      case 3:
        return 'Rất quan trọng';
      default:
        return ''; // trả '' để UI không hiện chip khi không chọn
    }
  }

  /// Map LoaiThongTin -> label (dùng trong VM: selectedTypeLabel)
  static String typeLabelFromCode(int? code) {
    switch (code) {
      case 1:
        return 'Thị trường';
      case 2:
        return 'Chính trị';
      case 3:
        return 'Kinh tế';
      case 4:
        return 'Xã hội';
      case 5:
        return 'Liên quan đến SKYPEC';
      case 6:
        return 'Hàng không Việt Nam';
      case 7:
        return 'Ngành hàng không';
      default:
        return ''; // hoặc: 'Loại $code'
    }
  }

  /// (Tuỳ chọn) màu theo MucDo để dùng cho card/tag
  static Color levelColorFromCode(int? code) {
    switch (code) {
      case 3:
        return const Color(0xFFEF4444); // đỏ: Rất quan trọng
      case 2:
        return const Color(0xFF2563EB); // xanh: Ít quan trọng
      case 1:
        return const Color(0xFFF59E0B); // cam: Quan trọng
      default:
        return const Color(0xFF6B7280); // xám: khác/không chọn
    }
  }

  /// (Tuỳ chọn) getter tiện dụng nếu card cần nhãn + màu
  String get levelLabel => levelLabelFromCode(mucDo);
  String get typeLabel => typeLabelFromCode(loaiThongTin);
  Color get levelColor => levelColorFromCode(mucDo);
}

class ShareSegment {
  final String label;
  double value;
  final String unit;
  final Color color;
  ShareSegment({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
}

class ShareCardData {
  final String title; // ví dụ: "Sản lượng"
  final String unitTopRight; // ví dụ: "tấn" / "chuyến"
  List<ShareSegment> segments; // 2 mẩu: Skypec, Khác
  ShareCardData({
    required this.title,
    required this.unitTopRight,
    required this.segments,
  });

  double get total =>
      ((segments.fold<double>(0.0, (a, s) => a + s.value) * 100)
              .roundToDouble() /
          100);
  double percent(int i) => segments[i].value / (total == 0 ? 1 : total);
}

class QtttViewModel extends GetxController {
  final overview =
      <KpiItem>[
        KpiItem(
          id: 1,
          title: 'Tỉ giá',
          subtitle: 'Tỉ giá ngày 07/08/2025',
          leftLabel: 'Mua',
          leftValue: '0',
          rightLabel: 'Bán',
          rightValue: '0',
        ),
        KpiItem(
          id: 2,
          title: 'Sản lượng tháng 8 (Tấn)',
          leftLabel: 'Thực tế',
          leftValue: '0',
          rightLabel: 'Kế hoạch',
          rightValue: '0',
        ),
        KpiItem(
          id: 3,
          title: 'Giá JET A1 tháng 8',
          subtitle: 'Giá JET A1 tháng 8 (06/08/2025)',
          leftLabel: 'Hàng ngày',
          leftValue: '0',
          rightLabel: 'Trung bình tháng',
          rightValue: '0',
        ),
        KpiItem(
          id: 4,
          title: 'Lợi nhuận tháng 8',
          leftLabel: '',
          leftValue: '82,4 Tỷ',
        ),
      ].obs;

  final shareCards =
      <ShareCardData>[
        ShareCardData(
          title: 'Sản lượng',
          unitTopRight: 'tấn',
          segments: [
            ShareSegment(
              label: 'Skypec',
              value: 0,
              unit: 'Tấn',
              color: const Color(0xFF2D8CFF),
            ),
            ShareSegment(
              label: 'Khác',
              value: 0,
              unit: 'Tấn',
              color: const Color(0xFF35C189),
            ),
          ],
        ),
        ShareCardData(
          title: 'Chuyến bay',
          unitTopRight: 'chuyến',
          segments: [
            ShareSegment(
              label: 'Skypec',
              value: 0,
              unit: 'chuyến',
              color: const Color(0xFF2D8CFF),
            ),
            ShareSegment(
              label: 'Khác',
              value: 0,
              unit: 'chuyến',
              color: const Color(0xFF35C189),
            ),
          ],
        ),
      ].obs;

  // ====== MARKET TAB (Thông tin thị trường) ======
  final all = <MarketNews>[].obs;

  /// Danh sách sau khi áp keyword + filter + phân trang -> bind cho UI
  final filteredMarket = <MarketNews>[].obs;

  /// Tìm kiếm theo tiêu đề/nội dung
  final keyword = ''.obs;

  final selectedLevelCode = RxnInt(); // MucDo: 1/2/3, null = tất cả
  final selectedTypeCode = RxnInt(); // LoaiThongTin: 5/6/7..., null = tất cả

  final marketLevel =
      'Tất cả'
          .obs; // "Tất cả" | "Quan trọng" | "Ít quan trọng" | "Rất quan trọng"
  final marketInfoType =
      'Tất cả'
          .obs; // "Tất cả" | "Thị trường" | "Kinh tế/Doanh nghiệp" | "Hàng không"

  // Label hiển thị chip
  String get selectedLevelLabel =>
      MarketNews.levelLabelFromCode(selectedLevelCode.value);
  String get selectedTypeLabel =>
      MarketNews.typeLabelFromCode(selectedTypeCode.value);

  final selectedFilters = <String>[].obs;

  // ===== Phân trang client =====
  final pageSize = 10.obs;
  final page = 1.obs;
  int get totalPages =>
      (_filteredNoPaging.length / pageSize.value).ceil().clamp(1, 1 << 31);

  List<String> levelOptions = [
    'Tất cả',
    'Quan trọng',
    'Rất quan trọng',
    'Ít quan trọng',
  ];
  List<String> infoTypeOptions = [
    'Tất cả',
    'Thị trường',
    'Báo cáo quản trị',
    'Chính trị',
    'Kinh tế',
    'Xã hội',
    'Tin liên quan đến Skypec',
    'Tin liên quan đến hàng không',
    'Tin liên quan đến cảng hàng không Việt Nam',
  ];

  // Mapping MucDo
  Map<int, String> mucDoMap = {
    1: "Quan trọng",
    2: "Ít quan trọng",
    3: "Rất quan trọng",
  };

  // Mapping LoaiThongTin
  Map<int, String> loaiThongTinMap = {
    1: "Thị trường",
    2: "Chính trị",
    3: "Kinh tế",
    4: "Xã hội",
    5: "Tin liên quan đến SKYPEC",
    6: "Tin liên quan đến Tổng công ty hàng không Việt Nam",
    7: "Tin khác liên quan đến ngành hàng không",
  };

  int? _levelCodeFromLabel(String label) {
    final v = label.trim();
    if (v.isEmpty || v == 'Tất cả') return null;
    for (final e in mucDoMap.entries) {
      if (e.value.toLowerCase() == v.toLowerCase()) return e.key;
    }
    return null; // không khớp -> coi như "Tất cả"
  }

  String _levelLabelFromCode(int? code) {
    if (code == null) return 'Tất cả';
    return mucDoMap[code] ?? 'Tất cả';
  }

  int? _typeCodeFromLabel(String label) {
    final v = label.trim();
    if (v.isEmpty || v == 'Tất cả') return null;
    for (final e in loaiThongTinMap.entries) {
      if (e.value.toLowerCase() == v.toLowerCase()) return e.key;
    }
    return null;
  }

  String _typeLabelFromCode(int? code) {
    if (code == null) return 'Tất cả';
    return loaiThongTinMap[code] ?? 'Tất cả';
  }

  // ====== SHARE TAB (Thị phần) ======
  final RxString shareAirport = 'Tất cả'.obs; // Sân bay
  final RxString shareFlight = 'Tất cả'.obs; // Chuyến bay

  List<String> airportOptions = [
    'Tất cả',
    'BMV',
    'CRX',
    'DLI',
    'HPP',
    'HUI',
    'QUC',
    'PXU',
    'TBB',
    'THD',
  ];
  final List<String> flightOptions = const ['Tất cả', 'Nội địa', 'Quốc tế'];

  RxString currentDate = ''.obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    initializeDateFormatting('vi', null);
    getSumaryInfo();
    getAirportFilter();
    getMarketFilter();
    loadMarketNews();
    currentDate.value = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  // Popup bộ lọc (hook)
  // void openFilter() {
  //   Get.bottomSheet(
  //     SafeArea(
  //       child: Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: const BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //         ),
  //         child: const Text('Popup bộ lọc (TODO)'),
  //       ),
  //     ),
  //     isScrollControlled: true,
  //   );
  // }

  // void clearFilters() {
  //   selectedFilters.clear(); // chỉ hiển thị – tuỳ bạn reset thêm state khác
  //   update(); // nếu bạn không dùng Obx cho selectedFilters, còn dùng Obx thì không cần
  // }

  // //for popup
  // MarketFilterSheet gọi vào đây:
  void resetMarketFilter() {
    // reset UI (string)
    marketLevel.value = 'Tất cả';
    marketInfoType.value = 'Tất cả';

    // đồng bộ code (VM lọc)
    selectedLevelCode.value = null;
    selectedTypeCode.value = null;

    _applyFiltersAndPaginate(goFirst: true);
  }

  void applyMarketFilter() {
    // từ label (UI) -> code
    selectedLevelCode.value = _levelCodeFromLabel(marketLevel.value);
    selectedTypeCode.value = _typeCodeFromLabel(marketInfoType.value);
    _applyFiltersAndPaginate(goFirst: true);
  }

  Future<void> openMarketFilter(BuildContext ctx) async {
    await Get.bottomSheet(
      MarketFilterSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void applyShareFilter() {
    // TODO: lọc dữ liệu biểu đồ theo shareAirport/shareFlight
    getMarketShareInfo();
    update();
  }

  void resetShareFilter() {
    shareAirport.value = 'Tất cả';
    shareFlight.value = 'Tất cả';
  }

  Future<void> openShareFilter(BuildContext ctx) async {
    await Get.bottomSheet(
      ShareFilterSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> getSumaryInfo() async {
    try {
      try {
        var response = await APICaller.getInstance().get(
          'QuanTriThongTin/ChiSo',
        );
        if (response != null) {
          final data = jsonDecode(response) as Map<String, dynamic>;
          overview[0].leftValue = formatNumber(data["TiGiaBuy"]);
          overview[0].rightValue = formatNumber(data["TiGiaSell"]);
          overview[1].leftValue = formatNumber(data["SL_TT"]);
          overview[1].rightValue = formatNumber(data["SLLK"]);
          overview[2].leftValue = data["PlatNgay"];
          overview[2].rightValue = data["PlatTBT"];
          overview[3].leftValue = '${formatNumber(data["Lnt"] ?? 0.0)} Tỷ';

          var month = DateTime.now().month.toString();
          var date = DateFormat('dd/MM/yyyy').format(DateTime.now());

          overview[0].subtitle = "Tỉ giá ngày $date";
          overview[1].subtitle = "Sản lượng tháng $month (Tấn)";
          overview[2].subtitle = "Giá JET A1 tháng $month ($date) ";
          overview[3].subtitle = "Lợi nhuận tháng $month";

          overview.refresh();
        } else {
          //backLogin(true);
        }
      } catch (e) {
        Utils.showSnackBar(title: 'Thông báo', message: '$e');
      }
    } finally {
      //isSubmitting.value = false;
    }
  }

  String formatNumber(double value) {
    final formatter = NumberFormat("#,##0.###", "vi_VN");
    return formatter.format(value);
  }

  double roundTo2(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  Future<void> getMarketShareInfo() async {
    String airport =
        shareAirport.value == 'Tất cả' ? 'All' : shareAirport.value;
    String type = 'All';
    if (shareFlight.value == "Quốc tế") {
      type = "quocte";
    } else if (shareFlight.value == "Nội địa") {
      type = "noidia";
    }

    try {
      String url =
          "QuanTriThongTin/ThiPhan?sanbayfilter=$airport&loaithiphan=$type";
      var response = await APICaller.getInstance().get(url);
      if (response != null) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        var SLSKY = roundTo2(data['ThiPhanSanLuong']['Skypec']);
        var SLOTH = roundTo2(data['ThiPhanSanLuong']['Other']);
        shareCards[0].segments[0].value = SLSKY;
        shareCards[0].segments[1].value = SLOTH;

        var CBSKY = roundTo2(data['ThiPhanChuyenBay']['Skypec']);
        var CBOTH = roundTo2(data['ThiPhanChuyenBay']['Other']);
        shareCards[1].segments[0].value = CBSKY;
        shareCards[1].segments[1].value = CBOTH;

        shareCards.refresh();
      } else {
        //backLogin(true);
      }
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }

  Future<void> getAirportFilter() async {
    try {
      try {
        var response = await APICaller.getInstance().get("Helper/FilterSanbay");
        if (response != null) {
          airportOptions.clear();
          List<dynamic> decoded = jsonDecode(response);
          airportOptions = decoded.cast<String>();
          airportOptions.insert(0, 'Tất cả');
        }
      } catch (e) {
        Utils.showSnackBar(title: 'Thông báo', message: '$e');
      }
    } finally {
      //isSubmitting.value = false;
    }
  }

  Future<void> getMarketFilter() async {
    try {
      var response = await APICaller.getInstance().get(
        "QuanTriThongTin/FilterThongTinThiTruong",
      );
      if (response != null) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        List<int> mucDoIds = List<int>.from(data["MucDo"]);
        List<int> loaiThongTinIds = List<int>.from(data["LoaiThongTin"]);

        levelOptions.clear();
        infoTypeOptions.clear();
        // Map id sang text
        levelOptions = [
          "Tất cả",
          ...mucDoIds.map((id) => mucDoMap[id]!).toList(),
        ];
        infoTypeOptions = [
          "Tất cả",
          ...loaiThongTinIds.map((id) => loaiThongTinMap[id]!).toList(),
        ];
        print(levelOptions);
        print(infoTypeOptions);
      }
    } catch (e) {
      Utils.showSnackBar(title: 'Thông báo', message: '$e');
    }
  }

  Future<void> loadMarketNews({int? levelCode, int? typeCode}) async {
    try {
      try {
        var response = await APICaller.getInstance().get(
          "QuanTriThongTin/ThongTinThiTruong?MucDo=0&LoaiThongTin=0",
        );
        if (response != null) {
          final body = jsonDecode(response);
          final parsed = <MarketNews>[];
          if (body is List) {
            for (final e in body) {
              if (e is Map) {
                parsed.add(MarketNews.fromJson(Map<String, dynamic>.from(e)));
              }
            }
          } else {
            throw Exception('Payload không phải mảng JSON.');
          }

          all.assignAll(parsed);

          // nếu có truyền filter lên server, đồng bộ lại state client
          selectedLevelCode.value = levelCode;
          selectedTypeCode.value = typeCode;

          _applyFiltersAndPaginate(goFirst: true);
        }
      } catch (e) {
        Utils.showSnackBar(title: 'Thông báo', message: '$e');
        all.clear();
        filteredMarket.clear();
        selectedFilters.clear();
      }
    } finally {
      //isSubmitting.value = false;
    }
  }

  void onSearchChanged(String v) {
    keyword.value = v.trim();
    _applyFiltersAndPaginate(goFirst: true);
  }

  void setLevelByCode(int? code) {
    selectedLevelCode.value = code; // null = tất cả
    _applyFiltersAndPaginate(goFirst: true);
  }

  void setTypeByCode(int? code) {
    selectedTypeCode.value = code; // null = tất cả
    _applyFiltersAndPaginate(goFirst: true);
  }

  /// Bỏ lọc (chỉ filter, KHÔNG xóa keyword – đúng yêu cầu trước đó)
  void clearFilters() {
    selectedLevelCode.value = null;
    selectedTypeCode.value = null;
    _applyFiltersAndPaginate(goFirst: true);
  }

  /// Bỏ hết (cả search)
  void clearAll() {
    keyword.value = '';
    clearFilters();
  }

  // ================== PAGINATION ==================
  void setPageSize(int size) {
    pageSize.value = size.clamp(1, 1000);
    _paginate();
  }

  void goPage(int p) {
    page.value = p.clamp(1, totalPages);
    _paginate();
  }

  void nextPage() => goPage(page.value + 1);
  void prevPage() => goPage(page.value - 1);

  // ================== PRIVATE ==================
  // Lọc theo keyword + code, KHÔNG phân trang (trả ra _filteredNoPaging)
  List<MarketNews> get _filteredNoPaging {
    final kw = keyword.value.toLowerCase();
    return all.where((n) {
      final okKw =
          kw.isEmpty ||
          n.title.toLowerCase().contains(kw) ||
          n.summary.toLowerCase().contains(kw);

      final okLevel =
          selectedLevelCode.value == null || n.mucDo == selectedLevelCode.value;

      final okType =
          selectedTypeCode.value == null ||
          n.loaiThongTin == selectedTypeCode.value;

      return okKw && okLevel && okType;
    }).toList();
  }

  void _applyFiltersAndPaginate({bool goFirst = false}) {
    _rebuildSelectedFilters();
    if (goFirst) page.value = 1;
    _paginate();
  }

  void _paginate() {
    final list = _filteredNoPaging;
    final total = (list.length / pageSize.value).ceil().clamp(1, 1 << 31);
    final cur = page.value.clamp(1, total);
    page.value = cur;

    if (list.isEmpty) {
      filteredMarket.clear();
      return;
    }
    final start = (cur - 1) * pageSize.value;
    final end = (start + pageSize.value).clamp(0, list.length);
    filteredMarket.assignAll(list.sublist(start, end));
  }

  void _rebuildSelectedFilters() {
    final out = <String>[];

    final lvl = _levelLabelFromCode(selectedLevelCode.value);
    final typ = _typeLabelFromCode(selectedTypeCode.value);
    if (lvl.isNotEmpty && lvl != 'Tất cả') out.add(lvl);
    if (typ.isNotEmpty && typ != 'Tất cả') out.add(typ);

    selectedFilters.assignAll(out);

    // đồng bộ lại label cho popup cũ (để mở lại thấy đúng)
    marketLevel.value = lvl;
    marketInfoType.value = typ;
  }
}
