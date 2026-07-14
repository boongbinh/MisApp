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
  ];
}
