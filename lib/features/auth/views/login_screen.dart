import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/brand.dart';
import '../../../ui/controls.dart';
import '../../../ui/cosmic_background.dart';
import '../../../ui/motion.dart';
import '../../../ui/tokens.dart';

/// Sign in with your mobile number. Reports bought from CosmoGuru are
/// linked to this number — there is no Acharyaji code to enter.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CosmicBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: staggered(stepMs: 80, [
                  const SizedBox(height: 28),
                  const BrandMark(size: 44),
                  const SizedBox(height: 120),
                  Text('SEE THE PATTERN. THEN DECIDE.', style: T.eyebrow),
                  const SizedBox(height: 10),
                  Text('Know the timing\nof your life', style: T.h1.copyWith(fontSize: 36, height: 1.08)),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in with the mobile number you used to buy your CosmoGuru report. '
                    'Your planner and daily rashi are waiting.',
                    style: T.muted.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  Text('MOBILE NUMBER', style: T.cap),
                  const SizedBox(height: 10),
                  Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lineStrong),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 18),
                        Text('+91', style: GoogleFonts.inter(fontSize: 18, color: AppColors.tx2, fontWeight: FontWeight.w600)),
                        Container(width: 1, height: 28, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppColors.line),
                        Expanded(
                          child: TextField(
                            controller: c.phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            textAlignVertical: TextAlignVertical.center,
                            autofillHints: const [AutofillHints.telephoneNumberNational],
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => c.sendOtp(),
                            style: GoogleFonts.inter(fontSize: 18, color: AppColors.tx, letterSpacing: 0.5),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '98XXX XXXXX',
                              hintStyle: GoogleFonts.inter(fontSize: 18, color: AppColors.tx3.withValues(alpha: 0.6)),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isCollapsed: true,
                              filled: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Obx(() => c.isLoading.value
                      ? const SizedBox(
                          height: 52,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.red),
                            ),
                          ),
                        )
                      : PrimaryButton(label: 'Send OTP', onTap: () => c.sendOtp())),
                  const SizedBox(height: 18),
                  Center(
                    child: GestureDetector(
                      onTap: () => launchUrl(Uri.parse(Brand.termsUrl), mode: LaunchMode.externalApplication),
                      child: Text.rich(
                        TextSpan(style: T.small, children: const [
                          TextSpan(text: 'By continuing you agree to our '),
                          TextSpan(text: 'terms', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
