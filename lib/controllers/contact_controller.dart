import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/network/api_repository.dart';
import 'profile_controller.dart';

/// "Write to us" form → cosmoguru.com/Cosmo_app_api/add_contact.
class ContactController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  final problemType = RxnString();

  final sending = false.obs;

  /// Field-level errors shown under the inputs.
  final errors = <String, String>{}.obs;

  @override
  void onReady() {
    super.onReady();
    // Prefill the name from the profile when we have it.
    final p = Get.find<ProfileController>();
    if (nameController.text.isEmpty) nameController.text = p.displayName;
  }

  bool _validate() {
    final e = <String, String>{};
    if (nameController.text.trim().isEmpty) e['name'] = 'Please enter your name.';
    final email = emailController.text.trim();
    if (email.isEmpty) {
      e['email'] = 'Please enter your email.';
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      e['email'] = 'That email doesn\'t look right.';
    }
    if (problemType.value == null) e['type'] = 'Choose what this is about.';
    if (messageController.text.trim().length < 5) e['message'] = 'Tell us a little more.';
    errors.assignAll(e);
    return e.isEmpty;
  }

  /// Returns null on success, or a message to show.
  Future<String?> send() async {
    if (!_validate()) return 'Please check the highlighted fields.';
    sending.value = true;
    try {
      final mobile = Get.find<ProfileController>().mobile.value;
      final r = await _repo.addContact({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile_no': mobile,
        'problem_type': problemType.value,
        'message': messageController.text.trim(),
      });
      sending.value = false;
      if (r['success'] == true || r['status'] == true) {
        messageController.clear();
        problemType.value = null;
        errors.clear();
        return null;
      }
      return '${r['message'] ?? r['msg'] ?? 'Could not send your message. Please try again.'}';
    } catch (e) {
      sending.value = false;
      return friendlyError(e);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
