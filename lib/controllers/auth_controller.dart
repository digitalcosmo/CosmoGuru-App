import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/network/api_repository.dart';
import '../core/storage/user_data.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedCountryCode = '+91'.obs;
  final isTAndC = true.obs;

  String? registrationRequired;

  /// OTP length used by the CosmoKundli SMS.
  static const otpLength = 4;

  /// Inline message under the OTP boxes ("Wrong code…").
  final otpError = ''.obs;

  void _showSnackbar(String title, String message, {bool isError = true}) {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    final accent = isError ? const Color(0xFFE31E24) : const Color(0xFF1A7A43);
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.white,
      borderColor: accent.withValues(alpha: 0.6),
      borderWidth: 1,
      colorText: const Color(0xFF1D1D1F),
      icon: Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: accent),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 18,
      duration: const Duration(seconds: 3),
    );
  }

  String get _digits => phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

  // ───── Send OTP ─────
  /// Sends the OTP. From the login screen it opens the OTP screen; a resend
  /// ([navigate] = false) stays where it is.
  Future<bool> sendOtp({bool navigate = true}) async {
    if (_digits.length != 10) {
      _showSnackbar('Check your number', 'Enter your 10-digit mobile number.');
      return false;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = {'mobile': '${selectedCountryCode.value}$_digits'};
      final result = await _repo.sendOtp(data);
      isLoading.value = false;

      if (result['status'] == true) {
        otpController.clear();
        otpError.value = '';
        if (navigate) {
          Get.toNamed(AppRoutes.otp);
        } else {
          _showSnackbar('Code sent', 'A new code is on its way.', isError: false);
        }
        return true;
      } else {
        _showSnackbar('Couldn\'t send code', '${result['msg'] ?? 'Please try again.'}');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      debugPrint('SendOTP error: $e');
      _showSnackbar('No connection', 'Check your internet and try again.');
      return false;
    }
  }

  // ───── Verify OTP ─────
  /// Returns true when the code is accepted (and navigates on).
  Future<bool> verifyOtp() async {
    if (otpController.text.length < otpLength || isLoading.value) return false;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      otpError.value = '';
      final data = {
        'mobile': '${selectedCountryCode.value}$_digits',
        'otp': otpController.text,
        'deviceid': await UserData.getDeviceId(),
        'macid': 'flutter',
      };
      final result = await _repo.verifyOtp(data);
      isLoading.value = false;

      if (result['status'] == true) {
        await UserData.setUserId(result['uID'].toString());
        await UserData.setLoggedIn(true);
        registrationRequired = result['regstration_required']?.toString();
        // CosmoGuru buyers go straight in — no Acharyaji code. New users
        // first add their name and birth date.
        if ('$registrationRequired'.toLowerCase() == 'yes') {
          Get.offAllNamed(AppRoutes.register);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
        return true;
      } else {
        final msg = '${result['msg'] ?? ''}'.trim();
        otpError.value = msg.isEmpty ? 'That code isn\'t right. Try again.' : msg;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      debugPrint('VerifyOTP error: $e');
      otpError.value = 'No connection. Check your internet and try again.';
      return false;
    }
  }

  // ───── Logout ─────
  Future<void> logout() async {
    await UserData.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
