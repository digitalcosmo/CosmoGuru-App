import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'pal.dart';
import 'tokens.dart';

/// Card. Light by default: white, hairline border and a soft shadow, like
/// cosmoguru.net's 28px cards. With [dark] it becomes a navy data panel
/// (the site's "night" cards) and everything inside switches to [Pal.navy].
///
/// (Named Glass so screens port 1:1 from MyAcharyaji.)
class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final bool dark;
  final bool shadow;

  const Glass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = kRadius,
    this.color,
    this.gradient,
    this.borderColor,
    this.dark = false,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: br,
        color: gradient != null
            ? null
            : (color ?? (dark ? AppColors.navy : AppColors.card)),
        gradient: gradient ??
            (dark && color == null
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1C1F4A), AppColors.navy],
                  )
                : null),
        border: Border.all(color: borderColor ?? (dark ? const Color(0x14FFFFFF) : AppColors.line)),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: (dark ? AppColors.navy : const Color(0xFF1D1D1F)).withValues(alpha: dark ? 0.22 : 0.06),
                  blurRadius: dark ? 28 : 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: child,
    );
    return dark ? Surface(pal: Pal.navy, child: box) : box;
  }
}

/// Small uppercase caption + optional right-hand note.
class CardHeader extends StatelessWidget {
  final String title;
  final String? note;
  final Widget? trailing;
  const CardHeader(this.title, {super.key, this.note, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(
      children: [
        Expanded(child: Text(title.toUpperCase(), style: T.cap.copyWith(color: p.dark ? AppColors.orange : p.tx3))),
        if (note != null) Text(note!, style: T.small.copyWith(color: p.tx3)),
        if (trailing != null) trailing!,
      ],
    );
  }
}
