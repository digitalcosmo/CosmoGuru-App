import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Colours for whatever surface a widget is drawn on: the light page and
/// white cards, or the navy data panels (5D, planner, calendar) where the
/// zone colours stay readable. Read it with [Pal.of].
class Pal {
  final bool dark;
  final Color tx, tx2, tx3;
  final Color line;

  /// Fill for chips, cells and nested boxes on this surface.
  final Color fill;

  /// Bar / column track.
  final Color track;

  /// Selection colour on this surface, and text on top of it.
  final Color accent, onAccent;

  const Pal({
    required this.dark,
    required this.tx,
    required this.tx2,
    required this.tx3,
    required this.line,
    required this.fill,
    required this.track,
    required this.accent,
    required this.onAccent,
  });

  static const light = Pal(
    dark: false,
    tx: AppColors.tx,
    tx2: AppColors.tx2,
    tx3: AppColors.tx3,
    line: AppColors.line,
    fill: AppColors.card2,
    track: Color(0xFFEDEDF0),
    accent: AppColors.red,
    onAccent: Colors.white,
  );

  static const navy = Pal(
    dark: true,
    tx: Color(0xFFF5F5F7),
    tx2: Color(0xFFB9BBD6),
    tx3: Color(0xFF8C8FB3),
    line: Color(0x1FFFFFFF),
    fill: Color(0x12FFFFFF),
    track: Color(0x17FFFFFF),
    accent: AppColors.orange,
    onAccent: Color(0xFF1A1205),
  );

  static Pal of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PalScope>()?.pal ?? light;
}

class _PalScope extends InheritedWidget {
  final Pal pal;
  const _PalScope({required this.pal, required super.child});

  @override
  bool updateShouldNotify(_PalScope old) => old.pal != pal;
}

/// Puts [child] on a given palette: widgets below read [Pal.of] and plain
/// text inherits the palette's text colour.
class Surface extends StatelessWidget {
  final Pal pal;
  final Widget child;
  const Surface({super.key, required this.pal, required this.child});

  @override
  Widget build(BuildContext context) {
    return _PalScope(
      pal: pal,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: pal.tx),
        child: IconTheme.merge(data: IconThemeData(color: pal.tx), child: child),
      ),
    );
  }
}
