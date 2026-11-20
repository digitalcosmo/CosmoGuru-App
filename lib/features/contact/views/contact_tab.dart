import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/contact_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../ui/brand.dart';
import '../../../ui/controls.dart';
import '../../../ui/fields.dart';
import '../../../ui/glass.dart';
import '../../../ui/links.dart';
import '../../../ui/motion.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tab_page.dart';
import '../../../ui/tokens.dart';

/// CosmoGuru: reach us (WhatsApp, call, email, website), write to us, and
/// the client's own account.
class ContactTab extends StatelessWidget {
  const ContactTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPage(
      gap: 20,
      children: [
        _Header(),
        _QuickActions(),
        _Details(),
        _WriteToUs(),
        _YouCard(),
        _Links(),
        _SignOut(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandMark(size: 52),
        const SizedBox(height: 22),
        Text('WE\'RE HERE TO HELP', style: T.eyebrow),
        const SizedBox(height: 8),
        Text('Talk to CosmoGuru', style: T.h1),
        const SizedBox(height: 8),
        Text('Questions about your report, the app, a consultation or a course — reach us the way you like.',
            style: T.muted),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    Widget action(String label, String icon, Color color, VoidCallback onTap) => Expanded(
          child: Pressable(
            onTap: onTap,
            child: Glass(
              padding: const EdgeInsets.symmetric(vertical: 16),
              radius: 20,
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.1)),
                    alignment: Alignment.center,
                    child: StrokeIcon(icon, color: color, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(label, style: T.small.copyWith(color: AppColors.tx, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
    return Row(
      children: [
        action('WhatsApp', Ic.whatsapp, AppColors.whatsapp, () => openWhatsApp('Hi CosmoGuru, ')),
        const SizedBox(width: 10),
        action('Call', Ic.phone, AppColors.red, callCosmoGuru),
        const SizedBox(width: 10),
        action('Email', Ic.mail, AppColors.orangeDeep, () => emailCosmoGuru('CosmoGuru app')),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details();

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Column(
        children: [
          _Row(icon: Ic.phone, label: 'Phone', value: Brand.phoneDisplay, onTap: callCosmoGuru),
          _Row(icon: Ic.mail, label: 'Email', value: Brand.email, onTap: () => emailCosmoGuru()),
          _Row(
            icon: 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM3 12h18M12 3c2.5 2.7 3.8 5.7 3.8 9s-1.3 6.3-3.8 9c-2.5-2.7-3.8-5.7-3.8-9S9.5 5.7 12 3z',
            label: 'Website',
            value: Brand.websiteDisplay,
            last: true,
            onTap: () => openWebsite(),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String icon, label, value;
  final bool last;
  final VoidCallback? onTap;
  final bool chevron;
  const _Row({required this.icon, required this.label, this.value = '', this.last = false, this.onTap, this.chevron = false});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            StrokeIcon(icon, color: AppColors.red, size: 18),
            const SizedBox(width: 12),
            Text(label, style: T.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: T.label.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            if (chevron) ...[
              const SizedBox(width: 6),
              const StrokeIcon(Ic.chevRight, color: AppColors.tx3, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

/// Contact form → cosmoguru.com add_contact.
class _WriteToUs extends StatelessWidget {
  const _WriteToUs();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ContactController>();
    return Glass(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        final e = c.errors;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('WRITE TO US', style: T.eyebrow),
            const SizedBox(height: 6),
            Text('We usually reply within a working day.', style: T.small),
            const SizedBox(height: 18),
            LabeledField(
              label: 'Your name',
              controller: c.nameController,
              capitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              error: e['name'],
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'Email',
              controller: c.emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              hint: 'you@example.com',
              error: e['email'],
            ),
            const SizedBox(height: 14),
            Text('ABOUT', style: T.cap),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in Brand.problemTypes)
                  Chip2(label: t, selected: c.problemType.value == t, onTap: () => c.problemType.value = t),
              ],
            ),
            if (e['type'] != null) ...[
              const SizedBox(height: 6),
              Text(e['type']!, style: T.small.copyWith(color: AppColors.red, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 14),
            LabeledField(
              label: 'Message',
              controller: c.messageController,
              maxLines: 5,
              hint: 'How can we help?',
              capitalization: TextCapitalization.sentences,
              error: e['message'],
            ),
            const SizedBox(height: 18),
            c.sending.value
                ? const SizedBox(
                    height: 52,
                    child: Center(child: CircularProgressIndicator(color: AppColors.red)),
                  )
                : PrimaryButton(
                    label: 'Send message',
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      final err = await c.send();
                      final ok = err == null;
                      Get.snackbar(
                        ok ? 'Message sent' : 'Not sent',
                        ok ? 'Thank you — CosmoGuru will get back to you soon.' : err,
                        backgroundColor: Colors.white,
                        colorText: AppColors.tx,
                        borderColor: (ok ? AppColors.green : AppColors.red).withValues(alpha: 0.5),
                        borderWidth: 1,
                        borderRadius: 18,
                        icon: Icon(ok ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                            color: ok ? AppColors.green : AppColors.red),
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      );
                    },
                  ),
          ],
        );
      }),
    );
  }
}

class _YouCard extends StatelessWidget {
  const _YouCard();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<ProfileController>();
    return Obx(() {
      final name = p.displayName;
      return Pressable(
        onTap: () => Get.toNamed(AppRoutes.profile),
        child: Glass(
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.redSoft),
                alignment: Alignment.center,
                child: name.isEmpty
                    ? const StrokeIcon(Ic.user, color: AppColors.red, size: 20)
                    : Text(name[0].toUpperCase(), style: T.h3.copyWith(color: AppColors.red)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOUR ACCOUNT', style: T.cap),
                    const SizedBox(height: 4),
                    Text(name.isEmpty ? 'Your profile' : name, style: T.strong),
                    if (p.mobile.value.isNotEmpty) Text(p.mobile.value, style: T.small),
                  ],
                ),
              ),
              const StrokeIcon(Ic.chevRight, color: AppColors.tx3, size: 18),
            ],
          ),
        ),
      );
    });
  }
}

class _Links extends StatelessWidget {
  const _Links();

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Column(
        children: [
          _Row(icon: Ic.book, label: 'How to read your planner', chevron: true, onTap: () => Get.toNamed(AppRoutes.guidelines)),
          _Row(icon: Ic.help, label: 'FAQ', chevron: true, onTap: () => Get.toNamed(AppRoutes.faq)),
          _Row(
            icon: Ic.shield,
            label: 'Terms & conditions',
            chevron: true,
            last: true,
            onTap: () => openWebsite(Brand.termsUrl),
          ),
        ],
      ),
    );
  }
}

class _SignOut extends StatelessWidget {
  const _SignOut();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Pressable(
        onTap: () => _confirm(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StrokeIcon(Ic.logout, color: AppColors.red, size: 17),
              const SizedBox(width: 8),
              Text('Sign out', style: T.strong.copyWith(color: AppColors.red, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    showGlassSheet(context, builder: (ctx) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sign out?', style: T.h2),
          const SizedBox(height: 8),
          Text('You\'ll need your mobile number and OTP to sign back in.', style: T.muted),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Sign out',
            onTap: () {
              Navigator.of(ctx).pop();
              Get.find<HomeController>().logout();
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: T.strong.copyWith(color: AppColors.tx2)),
            ),
          ),
        ],
      );
    });
  }
}
