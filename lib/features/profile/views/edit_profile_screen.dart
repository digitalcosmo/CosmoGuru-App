import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/controls.dart';
import '../../../ui/fields.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/sub_page.dart';
import '../../../ui/tokens.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    return SubPage(
      title: 'Edit profile',
      children: profileFormFields(context, c) +
          [
            const SizedBox(height: 8),
            Obx(() => c.isLoading.value
                ? const Center(child: CircularProgressIndicator(color: AppColors.red))
                : PrimaryButton(label: 'Save changes', onTap: () => c.updateProfile())),
          ],
    );
  }
}

/// Name, birth date and gender — shared by sign-up and Edit profile.
List<Widget> profileFormFields(BuildContext context, ProfileController c) => [
      LabeledField(
        label: 'First name',
        controller: c.fNameController,
        capitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.givenName],
      ),
      LabeledField(
        label: 'Surname',
        controller: c.surNameController,
        capitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.familyName],
      ),
      LabeledField(
        label: 'Date of birth',
        controller: c.dobController,
        readOnly: true,
        hint: 'Pick your birth date',
        trailing: Ic.calendar,
        onTap: () => c.selectDate(context),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GENDER', style: T.cap),
          const SizedBox(height: 8),
          Obx(() => Segmented(
                labels: const ['Male', 'Female', 'Other'],
                index: const ['male', 'female', 'other'].indexOf(c.currentGender.value).clamp(0, 2),
                onChanged: (i) => c.currentGender.value = const ['male', 'female', 'other'][i],
              )),
        ],
      ),
    ];
