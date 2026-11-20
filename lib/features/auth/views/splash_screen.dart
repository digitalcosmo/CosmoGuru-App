import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/user_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../ui/brand.dart';
import '../../../ui/cosmic_background.dart';
import '../../../ui/motion.dart';
import '../../../ui/tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    final loggedIn = await UserData.getLoggedIn();
    final hasUser = (await UserData.getUserId()).isNotEmpty;
    Get.offAllNamed(loggedIn && hasUser ? AppRoutes.home : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CosmicBackground(),
          Center(
            child: FadeSlideIn(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(size: 110, vertical: true),
                  const SizedBox(height: 22),
                  Text('Know the timing of your life', style: T.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
