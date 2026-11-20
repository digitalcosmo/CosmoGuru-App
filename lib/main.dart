import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/contact_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/info_controller.dart';
import 'controllers/planner_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/rashi_controller.dart';
import 'controllers/report_controller.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFF5F5F7),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const CosmoGuruApp());
}

class CosmoGuruApp extends StatelessWidget {
  const CosmoGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CosmoGuru',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.put(HomeController(), permanent: true);
        Get.lazyPut(() => RashiController(), fenix: true);
        Get.lazyPut(() => ReportController(), fenix: true);
        Get.lazyPut(() => PlannerController(), fenix: true);
        Get.lazyPut(() => ProfileController(), fenix: true);
        Get.lazyPut(() => InfoController(), fenix: true);
        Get.lazyPut(() => ContactController(), fenix: true);
      }),
    );
  }
}
