import 'package:get/get.dart';
import 'package:skypec/Controller/Account/ChangePassViewModel.dart';
import 'package:skypec/Controller/Account/LoginViewModel.dart';
import 'package:skypec/Controller/Account/MenuViewModel.dart';
import 'package:skypec/Controller/Account/NotifyViewModel.dart';
import 'package:skypec/Controller/Account/SplashViewModel.dart';
import 'package:skypec/Controller/BCSL/CurrentOutputViewModel.dart';
import 'package:skypec/Controller/BCSL/OutputReportViewModel.dart';
import 'package:skypec/Controller/Home/HomeViewModel.dart';
import 'package:skypec/Controller/QTTC/CUTNViewModel.dart';
import 'package:skypec/Controller/QTTC/ChangeCostViewModel.dart';
import 'package:skypec/Controller/QTTC/FinancePlanViewModel.dart';
import 'package:skypec/Controller/QTTC/FixCostViewModel.dart';
import 'package:skypec/Controller/QTTC/FuelProfitViewModel.dart';
import 'package:skypec/Controller/QTTC/RevenueDetailViewModel.dart';
import 'package:skypec/Controller/QTTT/ForecastJETViewModel.dart';
import 'package:skypec/Controller/QTTT/InventoryViewModel.dart';
import 'package:skypec/Controller/QTTT/JETDetailViewModel.dart';
import 'package:skypec/Controller/QTTT/QtttViewModel.dart';
import 'package:skypec/Controller/QTTT/RateDetailViewModel.dart';

import 'package:skypec/Controller/TCNL/PhatTrienNhanLucViewModel.dart';
import 'package:skypec/Controller/TCNL/CongTacDangViewModel.dart';
import 'package:skypec/Controller/TCNL/TienluongchinhsachViewModel.dart';
import 'package:skypec/Controller/TCNL/TcnlViewModel.dart';
//TTBSP
import 'package:skypec/Controller/TTBSP/TtbspDoanhthuViewModel.dart';
import 'package:skypec/Controller/TTBSP/TtbspBaocaosanluongtheongayViewModel.dart';
import 'package:skypec/Controller/TTBSP/TtbspBaocaosanluongtheothangViewModel.dart';
import 'package:skypec/Controller/TTBSP/TtbspViewModel.dart';
//KT
import 'package:skypec/Controller/KT/KTViewModel.dart';
import 'package:skypec/Controller/KT/ThongtinchungViewModel.dart';
import 'package:skypec/Controller/KT/DulieukythuatViewModel.dart';
import 'package:skypec/Controller/KT/PhantichchiphiViewModel.dart';
import 'package:skypec/Controller/KT/BaoCaoKyThuatViewModel.dart';

//KT-Dulieukythuat
import 'package:skypec/Controller/KT/Dulieukythuat/XeTranapDetailViewModel.dart';
import 'package:skypec/Controller/KT/Dulieukythuat/XeVanchuyenDetailViewModel.dart';
import 'package:skypec/Controller/KT/Dulieukythuat/BechuaDetailViewModel.dart';
import 'package:skypec/Controller/KT/Dulieukythuat/BaulocDetailViewModel.dart';
import 'package:skypec/Controller/KT/Dulieukythuat/MaybomDetailViewModel.dart';
import 'package:skypec/Controller/KT/Dulieukythuat/DonghoDetailViewModel.dart';

//KT-BaoCao
import 'package:skypec/Controller/KT/BaoCao/KT_QT70ViewModel.dart';
//KT-BaoCao-QT70
import 'package:skypec/Controller/KT/BaoCao/QT70/QT70_PhuongtienViewModel.dart';
//KT-BaoCao-QT70-Phuongtien
import 'package:skypec/Controller/KT/BaoCao/QT70/Phuongtien/HSSS_Tuan_XTNViewModel.dart';
import 'package:skypec/Controller/KT/BaoCao/QT70/Phuongtien/HSSS_Thang_XTNViewModel.dart';
import 'package:skypec/Controller/KT/BaoCao/QT70/Phuongtien/HSSS_Tuan_XVTViewModel.dart';
import 'package:skypec/Controller/KT/BaoCao/QT70/Phuongtien/HSSS_Thang_XVTViewModel.dart';


//CNKV
import 'package:skypec/Controller/CNKV/Kythuat/Dulieukythuat/BaulocDetailCNKVViewModel.dart';
import 'package:skypec/Controller/CNKV/Kythuat/Dulieukythuat/BechuaDetailCNKVViewModel.dart';
import 'package:skypec/Controller/CNKV/Kythuat/Dulieukythuat/DonghoDetailCNKVViewModel.dart';
import 'package:skypec/Controller/CNKV/Kythuat/Dulieukythuat/XeTranapDetailCNKVViewModel.dart';
import 'package:skypec/Controller/CNKV/Kythuat/Dulieukythuat/XeVanchuyenDetailCNKVViewModel.dart';
import 'package:skypec/Controller/CNKV/Kythuat/Dulieukythuat/MaybomDetailCNKVViewModel.dart';

//CNMB
import 'package:skypec/Controller/CNMB/CNMBViewModel.dart';
import 'package:skypec/Controller/CNMB/Kythuat/CNMBKythuatViewModel.dart';
import 'package:skypec/Controller/CNMB/Khaithac/CNMBKhaithacViewModel.dart';
//CNMB-Kythuat
import 'package:skypec/Controller/CNMB/Kythuat/CNMBThongtinchungViewModel.dart';
import 'package:skypec/Controller/CNMB/Kythuat/CNMBPhantichchiphiViewModel.dart';
import 'package:skypec/Controller/CNMB/Kythuat/CNMBDulieukythuatViewModel.dart';
//CNMB-Khaithac
import 'package:skypec/Controller/CNMB/Khaithac/CNMBBaocaokhaithacngayViewModel.dart';


//CNMT
import 'package:skypec/Controller/CNMT/CNMTViewModel.dart';
import 'package:skypec/Controller/CNMT/Kythuat/CNMTKythuatViewModel.dart';
import 'package:skypec/Controller/CNMT/Khaithac/CNMTKhaithacViewModel.dart';
//CNMT-Kythuat
import 'package:skypec/Controller/CNMT/Kythuat/CNMTThongtinchungViewModel.dart';
import 'package:skypec/Controller/CNMT/Kythuat/CNMTPhantichchiphiViewModel.dart';
import 'package:skypec/Controller/CNMT/Kythuat/CNMTDulieukythuatViewModel.dart';
//CNMT-Khaithac
import 'package:skypec/Controller/CNMT/Khaithac/CNMTBaocaokhaithacngayViewModel.dart';

//CNMN
import 'package:skypec/Controller/CNMN/CNMNViewModel.dart';
import 'package:skypec/Controller/CNMN/Kythuat/CNMNKythuatViewModel.dart';
import 'package:skypec/Controller/CNMN/Khaithac/CNMNKhaithacViewModel.dart';
//CNMN-Kythuat
import 'package:skypec/Controller/CNMN/Kythuat/CNMNThongtinchungViewModel.dart';
import 'package:skypec/Controller/CNMN/Kythuat/CNMNPhantichchiphiViewModel.dart';
import 'package:skypec/Controller/CNMN/Kythuat/CNMNDulieukythuatViewModel.dart';
//CNMN-Khaithac
import 'package:skypec/Controller/CNMN/Khaithac/CNMNBaocaokhaithacngayViewModel.dart';

//CUDV
import 'package:skypec/Controller/CUDV/CUDVTheodoiDieuvanViewModel.dart';
import 'package:skypec/Controller/CUDV/CUDVBaocaoQuantriViewModel.dart';
import 'package:skypec/Controller/CUDV/CUDVViewModel.dart';
import 'package:skypec/Controller/CUDV/CUDVBcqtViewModel.dart';
import 'package:skypec/Controller/CUDV/CUDVBcqtDukienViewModel.dart';


//Atcl
import 'package:skypec/Controller/Atcl/AtclViewModel.dart';
//ATCL-Baocaongay
import 'package:skypec/Controller/Atcl/AtclBaocaongayViewModel.dart';
import 'package:skypec/Controller/Atcl/Baocaongay/BangbaocaongayViewModel.dart';
import 'package:skypec/Controller/Atcl/Baocaongay/DanhgiavapheduyetViewModel.dart';
import 'package:skypec/Controller/Atcl/Baocaongay/MohinhshellViewModel.dart';
import 'package:skypec/Controller/Atcl/Baocaongay/ChitietsucosuviecViewModel.dart';
//ATCL-Baocaotunguyen
import 'package:skypec/Controller/Atcl/AtclBaocaotunguyenViewModel.dart';

//AnNinh
import 'package:skypec/Controller/AnNinh/AnNinhViewModel.dart';
import 'package:skypec/Controller/AnNinh/ANSanluongchuyenbayViewModel.dart';
import 'package:skypec/Controller/AnNinh/ANNINHTheodoiXNTViewModel.dart';
import 'package:skypec/Controller/AnNinh/ANNINHTheodoiXNT_SBViewModel.dart';


// // //View
// // View
// View
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/View/Account/ChangePass.dart';
import 'package:skypec/View/Account/Login.dart';
import 'package:skypec/View/Account/Menu.dart';
import 'package:skypec/View/Account/Notify.dart';
import 'package:skypec/View/Account/Splash.dart';
import 'package:skypec/View/BCSL/CurrentOutput.dart';
import 'package:skypec/View/BCSL/OutputReport.dart';
import 'package:skypec/View/Home/Home.dart';
import 'package:skypec/View/QTTC/CUTN.dart';
import 'package:skypec/View/QTTC/ChangeCost.dart';
import 'package:skypec/View/QTTC/FinancePlan.dart';
import 'package:skypec/View/QTTC/FixCost.dart';
import 'package:skypec/View/QTTC/FuelProfit.dart';
import 'package:skypec/View/QTTC/RevenueDetail.dart';
import 'package:skypec/View/QTTT/ForecastJET.dart';
import 'package:skypec/View/QTTT/Inventory.dart';
import 'package:skypec/View/QTTT/JETDetail.dart';
import 'package:skypec/View/QTTT/QTTT.dart';
import 'package:skypec/View/QTTT/RateDetail.dart';
//TCNL
import 'package:skypec/View/TCNL/PhatTrienNhanLuc.dart';
import 'package:skypec/View/TCNL/CongTacDang.dart';
import 'package:skypec/View/TCNL/Tienluongchinhsach.dart';
import 'package:skypec/View/TCNL/TcnlMain.dart';
//TTBSP
import 'package:skypec/View/TTBSP/Doanhthu.dart';
import 'package:skypec/View/TTBSP/TtbspBaocaosanluongtheongay.dart';
import 'package:skypec/View/TTBSP/TtbspBaocaosanluongtheothang.dart';
import 'package:skypec/View/TTBSP/TtbspMain.dart';
//KT
import 'package:skypec/View/KT/KTMain.dart';
import 'package:skypec/View/KT/Thongtinchung.dart';
import 'package:skypec/View/KT/Dulieukythuat.dart';
import 'package:skypec/View/KT/Phantichchiphi.dart';
import 'package:skypec/View/KT/BaoCaoKyThuat.dart';

//KT-Dulieukythuat
import 'package:skypec/View/KT/Dulieukythuat/XeTranapDetail.dart';
import 'package:skypec/View/KT/Dulieukythuat/XeVanchuyenDetail.dart';
import 'package:skypec/View/KT/Dulieukythuat/BechuaDetail.dart';
import 'package:skypec/View/KT/Dulieukythuat/BaulocDetail.dart';
import 'package:skypec/View/KT/Dulieukythuat/MaybomDetail.dart';
import 'package:skypec/View/KT/Dulieukythuat/DonghoDetail.dart';

//KT-BaoCao
import 'package:skypec/View/KT/BaoCao/KT_QT70.dart';
//KT-BaoCao-QT70
import 'package:skypec/View/KT/BaoCao/QT70/QT70_Phuongtien.dart';
//KT-BaoCao-QT70-Phuongtien
import 'package:skypec/View/KT/BaoCao/QT70/Phuongtien/HSSS_Tuan_XTN.dart';
import 'package:skypec/View/KT/BaoCao/QT70/Phuongtien/HSSS_Thang_XTN.dart';
import 'package:skypec/View/KT/BaoCao/QT70/Phuongtien/HSSS_Tuan_XVT.dart';
import 'package:skypec/View/KT/BaoCao/QT70/Phuongtien/HSSS_Thang_XVT.dart';


//CNMB
import 'package:skypec/View/CNMB/CNMBMain.dart';
import 'package:skypec/View/CNMB/Khaithac/CNMBKhaithac.dart';
import 'package:skypec/View/CNMB/Kythuat/CNMBKythuat.dart';
//CNMB-Kythuat
import 'package:skypec/View/CNMB/Kythuat/CNMBThongtinchung.dart';
import 'package:skypec/View/CNMB/Kythuat/CNMBDulieukythuat.dart';
import 'package:skypec/View/CNMB/Kythuat/CNMBPhantichchiphi.dart';
//CNMB-Khaithac
import 'package:skypec/View/CNMB/Khaithac/CNMBBaocaokhaithacngay.dart';

//CNMB-Kythuat-Dulieukythuat
import 'package:skypec/View/CNKV/Kythuat/Dulieukythuat/XeTranapDetailCNKV.dart';
import 'package:skypec/View/CNKV/Kythuat/Dulieukythuat/XeVanchuyenDetailCNKV.dart';
import 'package:skypec/View/CNKV/Kythuat/Dulieukythuat/BechuaDetailCNKV.dart';
import 'package:skypec/View/CNKV/Kythuat/Dulieukythuat/BaulocDetailCNKV.dart';
import 'package:skypec/View/CNKV/Kythuat/Dulieukythuat/MaybomDetailCNKV.dart';
import 'package:skypec/View/CNKV/Kythuat/Dulieukythuat/DonghoDetailCNKV.dart';


//CNMT
import 'package:skypec/View/CNMT/CNMTMain.dart';
import 'package:skypec/View/CNMT/Kythuat/CNMTKythuat.dart';
//CNMT-Kythuat
import 'package:skypec/View/CNMT/Kythuat/CNMTThongtinchung.dart';
import 'package:skypec/View/CNMT/Kythuat/CNMTDulieukythuat.dart';
import 'package:skypec/View/CNMT/Kythuat/CNMTPhantichchiphi.dart';

//CNMT
import 'package:skypec/View/CNMT/CNMTMain.dart';
import 'package:skypec/View/CNMT/Khaithac/CNMTKhaithac.dart';
import 'package:skypec/View/CNMT/Kythuat/CNMTKythuat.dart';
//CNMT-Kythuat
import 'package:skypec/View/CNMT/Kythuat/CNMTThongtinchung.dart';
import 'package:skypec/View/CNMT/Kythuat/CNMTDulieukythuat.dart';
import 'package:skypec/View/CNMT/Kythuat/CNMTPhantichchiphi.dart';
//CNMT-Khaithac
import 'package:skypec/View/CNMT/Khaithac/CNMTBaocaokhaithacngay.dart';

//CNMN
import 'package:skypec/View/CNMN/CNMNMain.dart';
import 'package:skypec/View/CNMN/Khaithac/CNMNKhaithac.dart';
import 'package:skypec/View/CNMN/Kythuat/CNMNKythuat.dart';
//CNMN-Kythuat
import 'package:skypec/View/CNMN/Kythuat/CNMNThongtinchung.dart';
import 'package:skypec/View/CNMN/Kythuat/CNMNDulieukythuat.dart';
import 'package:skypec/View/CNMN/Kythuat/CNMNPhantichchiphi.dart';
//CNMN-Khaithac
import 'package:skypec/View/CNMN/Khaithac/CNMNBaocaokhaithacngay.dart';







//CUDV
import 'package:skypec/View/CUDV/TheodoiDieuvan.dart';
import 'package:skypec/View/CUDV/CUDVBaocaoQuantri.dart';
import 'package:skypec/View/CUDV/CUDVMain.dart';
import 'package:skypec/View/CUDV/CUDVBcqt.dart';
import 'package:skypec/View/CUDV/CUDVBcqtDukien.dart';


//Atcl
import 'package:skypec/View/Atcl/AtclMain.dart';
//ATCL-Baocaongay
import 'package:skypec/View/Atcl/AtclBaocaongay.dart';
import 'package:skypec/View/Atcl/Baocaongay/Danhgiavapheduyet.dart';
import 'package:skypec/View/Atcl/Baocaongay/Mohinhshell.dart';
import 'package:skypec/View/Atcl/Baocaongay/Bangbaocaongay.dart';
import 'package:skypec/View/Atcl/Baocaongay/Chitietsucosuviec.dart';
//ATCL-Baocaotunguyen
import 'package:skypec/View/Atcl/AtclBaocaotunguyen.dart';

//AnNinh
import 'package:skypec/View/AnNinh/AnNinhMain.dart';
import 'package:skypec/View/AnNinh/ANSanluongchuyenbay.dart';
import 'package:skypec/View/AnNinh/ANNINHTheodoiXNT_SB.dart';
import 'package:skypec/View/AnNinh/ANNINHTheodoiXNT.dart';
import 'package:skypec/View/AnNinh/ANBangbaocaongay.dart';
import 'package:skypec/View/AnNinh/ANDulieukythuat.dart';


class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: Routes.splash,
      page: () => Splash(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashViewModel>(() => SplashViewModel());
      }),
    ),
    GetPage(
      name: Routes.login,
      page: () => const Login(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginViewModel>(() => LoginViewModel());
      }),
    ),
    GetPage(
      name: Routes.home,
      page: () => const Home(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeViewModel>(() => HomeViewModel());
      }),
    ),
    GetPage(
      name: Routes.qttt,
      page: () => const Qttt(),
      binding: BindingsBuilder(() {
        Get.lazyPut<QtttViewModel>(() => QtttViewModel());
      }),
    ),
    GetPage(
      name: Routes.ratedetail,
      page: () => const RateDetail(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RateDetailViewModel>(() => RateDetailViewModel());
      }),
    ),
    GetPage(
      name: Routes.inventory,
      page: () => const Inventory(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InventoryViewModel>(() => InventoryViewModel());
      }),
    ),
    GetPage(
      name: Routes.forecastjet,
      page: () => ForecastJET(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ForecastJETViewModel>(() => ForecastJETViewModel());
      }),
    ),
    GetPage(
      name: Routes.jetdetail,
      page: () => const JETDetail(),
      binding: BindingsBuilder(() {
        Get.lazyPut<JETDetailViewModel>(() => JETDetailViewModel());
      }),
    ),
    GetPage(
      name: Routes.financeplan,
      page: () => const FinancePlan(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FinancePlanViewModel>(() => FinancePlanViewModel());
      }),
    ),
    GetPage(
      name: Routes.revenuedetail,
      page: () => const RevenueDetail(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RevenueDetailViewModel>(() => RevenueDetailViewModel());
      }),
    ),
    GetPage(
      name: Routes.fixcost,
      page: () => const FixCost(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FixCostViewModel>(() => FixCostViewModel());
      }),
    ),
    GetPage(
      name: Routes.changecost,
      page: () => const ChangeCost(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChangeCostViewModel>(() => ChangeCostViewModel());
      }),
    ),
    GetPage(
      name: Routes.cutn,
      page: () => const CUTN(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CUTNViewModel>(() => CUTNViewModel());
      }),
    ),
    GetPage(
      name: Routes.fuelprofit,
      page: () => const FuelProfit(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FuelProfitViewModel>(() => FuelProfitViewModel());
      }),
    ),
    GetPage(
      name: Routes.menu,
      page: () => const Menu(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MenuViewModel>(() => MenuViewModel());
      }),
    ),
    GetPage(
      name: Routes.changepass,
      page: () => ChangePass(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChangePassViewModel>(() => ChangePassViewModel());
      }),
    ),
    GetPage(
      name: Routes.outputreport,
      page: () => OutputReport(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OutputReportViewModel>(() => OutputReportViewModel());
      }),
    ),
    GetPage(
      name: Routes.currentoutput,
      page: () => CurrentOutput(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CurrentOutputViewModel>(() => CurrentOutputViewModel());
      }),
    ),
    GetPage(
      name: Routes.notify,
      page: () => Notify(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotifyViewModel>(() => NotifyViewModel());
      }),
    ),

    //tcnl;
    GetPage(
      name: Routes.tcnlMain,
      page: () => const TcnlMain(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TcnlViewModel>(() => TcnlViewModel());
      }),
    ),
    GetPage(
      name: Routes.tcnlPtnl,
      page: () => const PhatTrienNhanLuc(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PhatTrienNhanLucViewModel>(() => PhatTrienNhanLucViewModel());
      }),
    ),
    GetPage(
          name: Routes.tcnlCtd,
          page: () => const CongTacDang(),
          binding: BindingsBuilder(() {
            Get.lazyPut<CongTacDangViewModel>(() => CongTacDangViewModel());
          }),
        ),
      GetPage(
          name: Routes.tcnlTlcs,
          page: () => const Tienluongchinhsach(),
          binding: BindingsBuilder(() {
            Get.lazyPut<TienluongchinhsachViewModel>(() => TienluongchinhsachViewModel());
          }),
        ),

    //ttbsp
    GetPage(
      name: Routes.ttbspMain,
      page: () => const TtbspMain(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TtbspViewModel>(() => TtbspViewModel());
      }),
    ),
    GetPage(
      name: Routes.ttbspDt,
      page: () => const Doanhthu(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TtbspDoanhthuViewModel>(() => TtbspDoanhthuViewModel());
      }),
    ),
    GetPage(
      name: Routes.ttbspBaocaosanluongtheongay,
      page: () => const TtbspBaocaosanluongtheongay(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TtbspBaocaosanluongtheongayViewModel>(() => TtbspBaocaosanluongtheongayViewModel());
      }),
    ),
    GetPage(
      name: Routes.ttbspBaocaosanluongtheothang,
      page: () => const TtbspBaocaosanluongtheothang(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TtbspBaocaosanluongtheothangViewModel>(() => TtbspBaocaosanluongtheothangViewModel());
      }),
    ),


    //KT
    GetPage(
      name: Routes.ktMain,
      page: () => const KTMain(),
      binding: BindingsBuilder(() {
        Get.lazyPut<KtViewModel>(() => KtViewModel());
      }),
    ),
    //
    GetPage(
      name: Routes.ktThongtinchung,
      page: () => const Thongtinchung(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ThongtinchungViewModel>(() => ThongtinchungViewModel());
      }),
    ),
    GetPage(
      name: Routes.ktDulieukythuat,
      page: () => const Dulieukythuat(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DulieukythuatViewModel>(() => DulieukythuatViewModel());
      }),
    ),
    GetPage(
      name: Routes.ktPhantichchiphi,
      page: () => const Phantichchiphi(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PhantichchiphiViewModel>(() => PhantichchiphiViewModel());
      }),
    ),
    GetPage(
      name: Routes.ktBaoCaoKyThuat,
      page: () => const BaoCaoKyThuat(),
      binding: BindingsBuilder(() {
        Get.put(BaoCaoKyThuatViewModel());
      }),
  ),

    //KT-Dulieukythuat
    GetPage(
    name: Routes.xeTranapDetail,
    page: () => const XeTranapDetail(),
    binding: BindingsBuilder(() {
      Get.put(XeTranapDetailViewModel());
    }),
  ),
    GetPage(
    name: Routes.xeVanChuyenDetail,
    page: () => const XeVanchuyenDetail(),
    binding: BindingsBuilder(() {
      Get.put(XeVanchuyenDetailViewModel());
    }),
  ),
  GetPage(
    name: Routes.beChuaDetail,
    page: () => const BechuaDetail(),
    binding: BindingsBuilder(() {
      Get.put(BechuaDetailViewModel());
    }),
  ),
  GetPage(
    name: Routes.bauLocDetail,
    page: () => const BaulocDetail(),
    binding: BindingsBuilder(() {
      Get.put(BaulocDetailViewModel());
    }),
  ),
  GetPage(
    name: Routes.mayBomDetail,
    page: () => const MaybomDetail(),
    binding: BindingsBuilder(() {
      Get.put(MaybomDetailViewModel());
    }),
  ),
  GetPage(
    name: Routes.dongHoDetail,
    page: () => const DonghoDetail(),
    binding: BindingsBuilder(() {
      Get.put(DonghoDetailViewModel());
    }),
  ),
  



  
  //KT-BaoCao
  GetPage(
    name: Routes.ktQT70,
    page: () => const KT_QT70(),
    binding: BindingsBuilder(() {
      Get.put(KT_QT70ViewModel());
    }),
  ),
  //KT-BaoCao-QT70
  GetPage(
    name: Routes.ktQT70huongTien,
    page: () => const QT70_Phuongtien(),
    binding: BindingsBuilder(() {
      Get.put(QT70_PhuongtienViewModel());
    }),
  ),
  //KT-BaoCao-QT70-Phuongtien
  GetPage(
    name: Routes.hsssXeTraNapTuan,
    page: () => const HSSS_Tuan_XTN(),
    binding: BindingsBuilder(() {
      Get.put(HSSS_Tuan_XTNViewModel());
    }),
  ),
  GetPage(
    name: Routes.hsssXeTraNapThang,
    page: () => const HSSS_Thang_XTN(),
    binding: BindingsBuilder(() {
      Get.put(HSSS_Thang_XTNViewModel());
    }),
  ),
  GetPage(
    name: Routes.hsssXeVanCNVTTuan,
    page: () => const HSSS_Tuan_XVT(),
    binding: BindingsBuilder(() {
      Get.put(HSSS_Tuan_XVTViewModel());
    }),
  ),
  GetPage(
    name: Routes.hsssXeVanCNVTThang,
    page: () => const HSSS_Thang_XVT(),
    binding: BindingsBuilder(() {
      Get.put(HSSS_Thang_XVTViewModel());
    }),
  ),



//CNMB
    GetPage(
      name: Routes.cnmbMain,
      page: () => const CNMBMain(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMBViewModel>(() => CNMBViewModel());
      }),
    ),
    //
    GetPage(
      name: Routes.cnmbKythuat,
      page: () => const CNMBKythuat(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMBKythuatViewModel>(() => CNMBKythuatViewModel());
      }),
    ),
    GetPage(
      name: Routes.cnmbKhaithac,
      page: () => const CNMBKhaithac(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMBKhaithacViewModel>(() => CNMBKhaithacViewModel());
      }),
    ),
    //CNMB-Kythuat
    GetPage(
      name: Routes.cnmbThongtinchung,
      page: () => const CNMBThongtinchung(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMBThongtinchungViewModel>(() => CNMBThongtinchungViewModel());
      }),
    ),
    GetPage(
      name: Routes.cnmbDulieukythuat,
      page: () => const CNMBDulieukythuat(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMBDulieukythuatViewModel>(() => CNMBDulieukythuatViewModel());
      }),
    ),

    //CNMB-Kythuat-Dulieukythuat
    GetPage(
    name: Routes.xeTranapDetailCNKV,
    page: () => const XeTranapDetailCNKV(),
    binding: BindingsBuilder(() {
      Get.put(XeTranapDetailCNKVViewModel());
    }),
  ),
    GetPage(
    name: Routes.xeVanChuyenDetailCNKV,
    page: () => const XeVanchuyenDetailCNKV(),
    binding: BindingsBuilder(() {
      Get.put(XeVanchuyenDetailCNKVViewModel());
    }),
  ),
  GetPage(
    name: Routes.beChuaDetailCNKV,
    page: () => const BechuaDetailCNKV(),
    binding: BindingsBuilder(() {
      Get.put(BechuaDetailCNKVViewModel());
    }),
  ),
  GetPage(
    name: Routes.bauLocDetailCNKV,
    page: () => const BaulocDetailCNKV(),
    binding: BindingsBuilder(() {
      Get.put(BaulocDetailCNKVViewModel());
    }),
  ),
  GetPage(
    name: Routes.mayBomDetailCNKV,
    page: () => const MaybomDetailCNKV(),
    binding: BindingsBuilder(() {
      Get.put(MaybomDetailCNKVViewModel());
    }),
  ),
  GetPage(
    name: Routes.dongHoDetailCNKV,
    page: () => const DonghoDetailCNKV(),
    binding: BindingsBuilder(() {
      Get.put(DonghoDetailCNKVViewModel());
    }),
  ),
    GetPage(
      name: Routes.cnmbPhantichchiphi,
      page: () => const CNMBPhantichchiphi(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMBPhantichchiphiViewModel>(() => CNMBPhantichchiphiViewModel());
      }),
    ),

//CNMB-Khaithac
    GetPage(
      name: Routes.cnmbBaocaokhaithacngay,
      page: () => const CNMBBaocaokhaithacngay(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMBBaocaokhaithacngayViewModel>(() => CNMBBaocaokhaithacngayViewModel());
      }),
    ),

  //CNMT
    GetPage(
      name: Routes.cnmtMain,
      page: () => const CNMTMain(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMTViewModel>(() => CNMTViewModel());
      }),
    ),
    //
    GetPage(
      name: Routes.cnmtKythuat,
      page: () => const CNMTKythuat(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMTKythuatViewModel>(() => CNMTKythuatViewModel());
      }),
    ),
    GetPage(
      name: Routes.cnmtKhaithac,
      page: () => const CNMTKhaithac(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMTKhaithacViewModel>(() => CNMTKhaithacViewModel());
      }),
    ),
    //CNMT-Kythuat
    GetPage(
      name: Routes.cnmtThongtinchung,
      page: () => const CNMTThongtinchung(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMTThongtinchungViewModel>(
          () => CNMTThongtinchungViewModel(),
        );
      }),
    ),
    GetPage(
      name: Routes.cnmtDulieukythuat,
      page: () => const CNMTDulieukythuat(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMTDulieukythuatViewModel>(
          () => CNMTDulieukythuatViewModel(),
        );
      }),
    ),
    GetPage(
      name: Routes.cnmtPhantichchiphi,
      page: () => const CNMTPhantichchiphi(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMTPhantichchiphiViewModel>(
          () => CNMTPhantichchiphiViewModel(),
        );
      }),
    ),

    //CNMT-Khaithac
    GetPage(
      name: Routes.cnmtBaocaokhaithacngay,
      page: () => const CNMTBaocaokhaithacngay(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMTBaocaokhaithacngayViewModel>(
          () => CNMTBaocaokhaithacngayViewModel(),
        );
      }),
    ),

    //CNMN
    GetPage(
      name: Routes.cnmnMain,
      page: () => const CNMNMain(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMNViewModel>(() => CNMNViewModel());
      }),
    ),
    //
    GetPage(
      name: Routes.cnmnKythuat,
      page: () => const CNMNKythuat(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMNKythuatViewModel>(() => CNMNKythuatViewModel());
      }),
    ),
    GetPage(
      name: Routes.cnmnKhaithac,
      page: () => const CNMNKhaithac(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMNKhaithacViewModel>(() => CNMNKhaithacViewModel());
      }),
    ),
    //CNMN-Kythuat
    GetPage(
      name: Routes.cnmnThongtinchung,
      page: () => const CNMNThongtinchung(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMNThongtinchungViewModel>(
          () => CNMNThongtinchungViewModel(),
        );
      }),
    ),
    GetPage(
      name: Routes.cnmnDulieukythuat,
      page: () => const CNMNDulieukythuat(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMNDulieukythuatViewModel>(
          () => CNMNDulieukythuatViewModel(),
        );
      }),
    ),

    //CNMN-Kythuat-Dulieukythuat
    GetPage(
      name: Routes.cnmnPhantichchiphi,
      page: () => const CNMNPhantichchiphi(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMNPhantichchiphiViewModel>(
          () => CNMNPhantichchiphiViewModel(),
        );
      }),
    ),

    //CNMN-Khaithac
    GetPage(
      name: Routes.cnmnBaocaokhaithacngay,
      page: () => const CNMNBaocaokhaithacngay(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CNMNBaocaokhaithacngayViewModel>(
          () => CNMNBaocaokhaithacngayViewModel(),
        );
      }),
    ),











    //CUDV
    GetPage(
      name: Routes.cudvMain,
      page: () => const CUDVMain(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CUDVViewModel>(() => CUDVViewModel());
      }),
    ),
    GetPage(
      name: Routes.cudvKehoachnhaphang,
      page: () => CUDVBaocaoQuantri(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CUDVBaocaoQuantriViewModel>(() => CUDVBaocaoQuantriViewModel());
      }),
    ),
    GetPage(
      name: Routes.cudvTheodoidieuvan,
      page: () => Theodoidieuvan(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TheodoidieuvanViewModel>(() => TheodoidieuvanViewModel());
      }),
    ),
    GetPage(
      name: Routes.cudvBaocaoquantri,
      page: () => CUDVBcqt(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CUDVBcqtViewModel>(() => CUDVBcqtViewModel());
      }),
    ),
    GetPage(
      name: Routes.cudvBaocaoquantriDukien,
      page: () => CUDVBcqtDukien(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CUDVBcqtDukienViewModel>(() => CUDVBcqtDukienViewModel());
      }),
    ),


    
    //Atcl
    GetPage(
      name: Routes.atclMain,
      page: () => const AtclMain(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AtclViewModel>(() => AtclViewModel());
      }),
    ),
    //ATCL-Baocaongay
    GetPage(
      name: Routes.atclBaocaongay,
      page: () => const AtclBaocaongay(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AtclBaocaongayViewModel>(() => AtclBaocaongayViewModel());
      }),
    ),
    GetPage(
      name: Routes.atclBaocaongayBang,
      page: () => const Bangbaocaongay(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BangbaocaongayViewModel>(() => BangbaocaongayViewModel());
      }),
    ),
    GetPage(
      name: Routes.atclBaocaongayDanhgia,
      page: () => const Danhgiavapheduyet(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DanhgiavapheduyetViewModel>(() => DanhgiavapheduyetViewModel());
      }),
    ),
    GetPage(
      name: Routes.atclBaocaongayMohinhshell,
      page: () => const Mohinhshell(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MohinhshellViewModel>(() => MohinhshellViewModel());
      }),
    ),
    GetPage(
      name: Routes.atclBaocaongayMohinhshell,
      page: () => const Mohinhshell(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MohinhshellViewModel>(() => MohinhshellViewModel());
      }),
    ),
    GetPage(
      name: Routes.atclChitietsucosuviec,
      page: () => const Chitietsucosuviec(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChitietsucosuviecViewModel>(() => ChitietsucosuviecViewModel());
      }),
    ),
    
    //ATCL-Baocaotunguyen
    GetPage(
      name: Routes.atclBaocaotunguyen,
      page: () => const AtclBaocaotunguyen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AtclBaocaotunguyenViewModel>(() => AtclBaocaotunguyenViewModel());
      }),
    ),
    //AnNinh
  GetPage(
      name: Routes.anNinhMain,
      page: () => const AnNinhMain(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnNinhViewModel>(() => AnNinhViewModel());
      }),
    ),
  GetPage(
      name: Routes.anNinhSanluongchuyenbay,
      page: () => const ANSanluongchuyenbay(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ANSanluongchuyenbayViewModel>(() => ANSanluongchuyenbayViewModel());
      }),
    ),
  GetPage(
      name: Routes.anninhTheodoiXNT,
      page: () => const ANNINHTheodoiXNT(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ANNINHTheodoiXNTViewModel>(
          () => ANNINHTheodoiXNTViewModel(),
        );
      }),
    ),
    GetPage(
      name: Routes.anninhTheodoiXNT_SB,
      page: () => const ANNINHTheodoiXNT_SB(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ANNINHTheodoiXNT_SBViewModel>(
          () => ANNINHTheodoiXNT_SBViewModel(),
        );
      }),
    ),
    GetPage(
      name: Routes.anninhBaocaongay,
      page: () => const ANBangbaocaongay(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BangbaocaongayViewModel>(() => BangbaocaongayViewModel());
      }),
    ),
    GetPage(
      name: Routes.anninhDulieukythuat,
      page: () => const ANDulieukythuat(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DulieukythuatViewModel>(() => DulieukythuatViewModel());
      }),
    ),
  ];
}
