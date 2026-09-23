// controllers/chitietsucosuviec_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skypec/Service/APICaller.dart';
import 'package:skypec/Utils/Utils.dart';

class ChitietsucosuviecModel {
  final int maBaoCao;
  final String nguoiThucHien;
  final DateTime ngayBaoCao;
  final String gioBaoCao;
  final String coSuKienMatAnToan;
  final DateTime thoiGianXacNhan;
  final String gioXacNhan;
  final DateTime ngayLapSuViec;
  final String suViec;
  final String noiDungSuViec;
  final String noiDungXacNhan;
  final bool xacNhanNoiDung;

  ChitietsucosuviecModel({
    required this.maBaoCao,
    required this.nguoiThucHien,
    required this.ngayBaoCao,
    required this.gioBaoCao,
    required this.coSuKienMatAnToan,
    required this.thoiGianXacNhan,
    required this.gioXacNhan,
    required this.ngayLapSuViec,
    required this.suViec,
    required this.noiDungSuViec,
    required this.noiDungXacNhan,
    required this.xacNhanNoiDung,
  });

  factory ChitietsucosuviecModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return ChitietsucosuviecModel(
      maBaoCao: (map['MaBaoCao'] as num?)?.toInt() ?? 0,
      nguoiThucHien: map['NguoiThucHien']?.toString() ?? '',
      ngayBaoCao: parseDate(map['NgayBaoCao']),
      gioBaoCao: map['GioBaoCao']?.toString() ?? '',
      coSuKienMatAnToan: map['CoSuKienMatAnToan']?.toString() ?? 'Không có',
      thoiGianXacNhan: parseDate(map['ThoiGianXacNhan']),
      gioXacNhan: map['GioXacNhan']?.toString() ?? '',
      ngayLapSuViec: parseDate(map['NgayLapSuViec']),
      suViec: map['SuViec']?.toString() ?? '',
      noiDungSuViec: map['NoiDungSuViec']?.toString() ?? '',
      noiDungXacNhan: map['NoiDungXacNhan']?.toString() ?? '',
      xacNhanNoiDung: map['XacNhanNoiDung'] == true,
    );
  }
}

class ChitietsucosuviecViewModel extends GetxController {
  final loading = false.obs;
  final error = ''.obs;

  final chiTiet = Rxn<ChitietsucosuviecModel>();

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    final maBaoCao = args is Map ? args['MaBaoCao'] as int? : null;
    if (maBaoCao != null) {
      loadData(maBaoCao);
    }
  }

  Future<void> loadData(int maBaoCao) async {
    loading.value = true;
    error.value = '';
    try {
      final response = await APICaller.getInstance().post(
        "Atcl/Chitietsucosuviec",
        {"MaBaoCao": maBaoCao},
      );

      if (response != null && response is String) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        final list = data['Chitietsucosuviec'] as List? ?? [];
        if (list.isNotEmpty) {
          chiTiet.value = ChitietsucosuviecModel.fromMap(
            list.first as Map<String, dynamic>,
          );
        } else {
          error.value = 'Không tìm thấy chi tiết sự cố';
        }
      } else {
        error.value = 'Không nhận được dữ liệu từ server';
        Utils.showSnackBar(title: 'Lỗi', message: 'Không nhận được dữ liệu từ server');
      }
    } catch (e) {
      error.value = e.toString();
      Utils.showSnackBar(title: 'Lỗi', message: e.toString());
    } finally {
      loading.value = false;
    }
  }

  String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  String formatTime(String time) {
    if (time.isEmpty) return '--';
    // Nếu là "11:01:02 AM" -> parse
    try {
      final parsed = DateFormat('hh:mm:ss a').parse(time);
      return DateFormat('HH:mm:ss').format(parsed);
    } catch (e) {
      return time;
    }
  }

  // Màu cho sự kiện
  Color getColorForSuKien(String suKien) {
    switch (suKien) {
      case 'Sự kiện mất an toàn':
        return Colors.red;
      case 'Vụ việc kỹ thuật':
        return Colors.orange;
      case 'Không có':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Icon cho sự kiện
  IconData getIconForSuKien(String suKien) {
    switch (suKien) {
      case 'Sự kiện mất an toàn':
        return Icons.warning_amber_rounded;
      case 'Vụ việc kỹ thuật':
        return Icons.build_circle_outlined;
      case 'Không có':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  // Màu cho nội dung xác nhận
  Color getColorForNoiDungXacNhan(String value) {
    switch (value) {
      case 'Đóng':
        return Colors.green;
      case 'Báo cáo sơ bộ':
        return Colors.blue;
      case 'Báo cáo chi tiết':
        return Colors.purple;
      case 'Yêu cầu bổ sung':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}