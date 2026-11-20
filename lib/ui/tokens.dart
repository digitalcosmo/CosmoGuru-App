import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

/// Type scale from cosmoguru.net: Sora for headings, Inter for text.
///
/// Primary styles carry no colour, so they take the surface's text colour
/// (dark on white cards, light on navy panels). Secondary styles default to
/// the light-page greys; on navy panels pass `Pal.of(context).tx2/tx3`.
class T {
  T._();

  static TextStyle h1 = GoogleFonts.sora(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.8, height: 1.12);
  static TextStyle h2 = GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.4, height: 1.2);
  static TextStyle h3 = GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2);
  static TextStyle body = GoogleFonts.inter(fontSize: 15, height: 1.45);
  static TextStyle muted = GoogleFonts.inter(fontSize: 14, color: AppColors.tx2, height: 1.5);
  static TextStyle small = GoogleFonts.inter(fontSize: 12.5, color: AppColors.tx3, height: 1.4);
  static TextStyle label = GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500);
  static TextStyle strong = GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600);
  static TextStyle cap = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tx3, letterSpacing: 1.4);
  static TextStyle pct = GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600);

  /// Red uppercase eyebrow above section titles ("See the pattern…").
  static TextStyle eyebrow = GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.red, letterSpacing: 1.2);
}

const double kRadius = 24;
const EdgeInsets kPagePad = EdgeInsets.fromLTRB(20, 0, 20, 0);
