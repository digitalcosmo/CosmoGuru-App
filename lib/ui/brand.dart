import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

/// CosmoGuru mark (red star with orbits) + wordmark, like the site header.
class BrandMark extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool vertical;
  const BrandMark({super.key, this.size = 36, this.showTagline = true, this.vertical = false});

  @override
  Widget build(BuildContext context) {
    final mark = Image.asset('assets/images/logo_mark.png', width: size, height: size, fit: BoxFit.contain);
    final words = Column(
      crossAxisAlignment: vertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('CosmoGuru',
            style: GoogleFonts.sora(
              fontSize: size * (vertical ? 0.42 : 0.5),
              fontWeight: FontWeight.w600,
              color: AppColors.red,
              letterSpacing: -0.3,
              height: 1.05,
            )),
        if (showTagline)
          Text('Guiding Life',
              style: GoogleFonts.inter(
                fontSize: size * (vertical ? 0.17 : 0.24),
                fontWeight: FontWeight.w500,
                color: AppColors.tx2,
                letterSpacing: 0.2,
              )),
      ],
    );
    if (vertical) {
      return Column(mainAxisSize: MainAxisSize.min, children: [mark, SizedBox(height: size * 0.16), words]);
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [mark, const SizedBox(width: 8), words]);
  }
}
