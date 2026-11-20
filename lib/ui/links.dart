import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/api_constants.dart';
import '../core/theme/app_colors.dart';

/// Opens a link outside the app; tells the user if nothing can open it.
Future<void> openLink(Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    Get.snackbar('Couldn\'t open', 'No app on this phone can open that.',
        backgroundColor: Colors.white,
        colorText: AppColors.tx,
        borderColor: AppColors.red.withValues(alpha: 0.5),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100));
  }
}

Future<void> openWhatsApp([String text = '']) => openLink(Uri.parse(
    'https://wa.me/${Brand.whatsapp}${text.isEmpty ? '' : '?text=${Uri.encodeComponent(text)}'}'));

Future<void> callCosmoGuru() => openLink(Uri(scheme: 'tel', path: Brand.phone));

Future<void> emailCosmoGuru([String subject = '']) =>
    openLink(Uri(scheme: 'mailto', path: Brand.email, queryParameters: subject.isEmpty ? null : {'subject': subject}));

Future<void> openWebsite([String url = Brand.website]) => openLink(Uri.parse(url));

/// Apple doesn't allow iOS apps to send people to an outside checkout for
/// digital goods (reports, recorded courses). On iPhone the app shows the
/// information but no prices or buy links; Android shows both.
bool get showPurchaseLinks => kIsWeb || defaultTargetPlatform != TargetPlatform.iOS;
