import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/network/api_repository.dart';
import '../core/storage/user_data.dart';
import '../routes/app_routes.dart';

class ProfileController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final isLoading = false.obs;
  final firstName = ''.obs;
  final surname = ''.obs;
  final mobile = ''.obs;
  final gender = ''.obs;
  final dob = ''.obs;
  final profileImage = ''.obs;

  final fNameController = TextEditingController();
  final surNameController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final currentGender = 'male'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final userId = await UserData.getUserId();
      final result = await _repo.getProfile(userId);
      isLoading.value = false;

      if (result['status'] == true) {
        firstName.value = result['first_name'] ?? '';
        surname.value = result['surname'] ?? '';
        mobile.value = result['mobile'] ?? '';
        gender.value = result['Gender'] ?? '';
        dob.value = result['dob'] ?? '';
        profileImage.value = result['image'] ?? '';

        // Fill edit form
        fNameController.text = firstName.value;
        surNameController.text = surname.value;
        phoneController.text = mobile.value.replaceFirst('+91', '');
        dobController.text = dob.value;
        currentGender.value = gender.value.isNotEmpty ? gender.value : 'male';
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Profile load error: $e');
    }
  }

  /// Saves the profile. During sign-up ([registration]) it continues into
  /// the app; from Edit profile it goes back.
  Future<void> updateProfile({bool registration = false}) async {
    if (fNameController.text.trim().isEmpty) {
      _toast('Add your name', 'Please enter your first name.', error: true);
      return;
    }
    try {
      isLoading.value = true;
      final userId = await UserData.getUserId();
      final data = {
        'uID': userId,
        'first_name': fNameController.text,
        'surname': surNameController.text,
        'Gender': currentGender.value,
        'dob': dobController.text,
      };
      final result = await _repo.updateProfile(data);
      isLoading.value = false;

      if (result['status'] == true) {
        await loadProfile();
        if (registration) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.back();
          _toast('Saved', 'Your profile is updated.');
        }
      } else {
        _toast('Couldn\'t save', '${result['msg'] ?? 'Please try again.'}', error: true);
      }
    } catch (e) {
      isLoading.value = false;
      _toast('No connection', 'Check your internet and try again.', error: true);
    }
  }

  void _toast(String title, String msg, {bool error = false}) {
    final accent = error ? const Color(0xFFE31E24) : const Color(0xFF1A7A43);
    Get.snackbar(title, msg,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF1D1D1F),
        borderColor: accent.withValues(alpha: 0.6),
        borderWidth: 1,
        borderRadius: 18,
        icon: Icon(error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: accent),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24));
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1992, 3, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  String get displayName => '${firstName.value} ${surname.value}'.trim();

  @override
  void onClose() {
    fNameController.dispose();
    surNameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
