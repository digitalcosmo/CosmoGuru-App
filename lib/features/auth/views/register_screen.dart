import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/brand.dart';
import '../../../ui/controls.dart';
import '../../../ui/cosmic_background.dart';
import '../../../ui/motion.dart';
import '../../../ui/tokens.dart';
import '../../profile/views/edit_profile_screen.dart';

/// First sign-in: the server asks for the person's details
/// (regstration_required = Yes) before showing the app.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    final fields = profileFormFields(context, c);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CosmicBackground(orbits: false),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: staggered(stepMs: 60, [
                const Align(alignment: Alignment.centerLeft, child: BrandMark(size: 40)),
                const SizedBox(height: 36),
                Text('WELCOME', style: T.eyebrow),
                const SizedBox(height: 8),
                Text('Tell us about you', style: T.h1),
                const SizedBox(height: 10),
                Text('Add your name and birth date so we can greet you and match your reports.',
                    style: T.muted),
                const SizedBox(height: 28),
                for (final f in fields) ...[f, const SizedBox(height: 16)],
                const SizedBox(height: 8),
                Obx(() => c.isLoading.value
                    ? const Center(child: CircularProgressIndicator(color: AppColors.red))
                    : PrimaryButton(label: 'Continue', onTap: () => c.updateProfile(registration: true))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
