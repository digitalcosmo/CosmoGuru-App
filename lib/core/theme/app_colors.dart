import 'package:flutter/material.dart';

/// CosmoGuru palette, taken from cosmoguru.net's CSS variables.
///
/// Field names are shared with the MyAcharyaji codebase so widgets port
/// across: `sun` is the brand accent (CosmoGuru red here), `teal` the
/// positive colour, `rose` the warning colour.
class AppColors {
  AppColors._();

  // Page
  static const bg = Color(0xFFF5F5F7); // --page
  static const bg2 = Color(0xFFFFFFFF);

  // Cards on the light page
  static const card = Color(0xFFFFFFFF);
  static const card2 = Color(0xFFF5F5F7);
  static const line = Color(0xFFE8E8ED); // --line-soft
  static const lineStrong = Color(0xFFD2D2D7); // --line

  // Text
  static const tx = Color(0xFF1D1D1F); // --ink
  static const tx2 = Color(0xFF6E6E73); // --muted
  static const tx3 = Color(0xFF8E8E93); // --deco

  // Brand
  static const red = Color(0xFFE31E24); // --red
  static const redDeep = Color(0xFFC8161D); // --red-deep
  static const redSoft = Color(0xFFFFF4F3); // --red-soft
  static const orange = Color(0xFFF28C28); // --orange
  static const orangeDeep = Color(0xFFA8530A);
  static const green = Color(0xFF1A7A43); // --green
  static const greenSoft = Color(0xFFEEF8F1);
  static const navy = Color(0xFF16183A); // --night
  static const navy2 = Color(0xFF242868);
  static const whatsapp = Color(0xFF1FA855);

  // Aliases used by shared widgets
  static const sun = red;
  static const sun2 = redDeep;
  static const teal = green;
  static const vio = Color(0xFF5856D6);
  static const rose = red;
}
