import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../models/five_d.dart';
import '../models/zone.dart';
import 'motion.dart';
import 'stroke_icon.dart';
import 'zone_icon.dart';

/// Zone Sky: one shared 0–100 sky split into the 7 zones at their true
/// ranges, with the five dimensions as planets at their altitude.
///
/// Position on one common scale is the most precisely read form of chart,
/// the layer a planet sits in is its zone, and every dimension has the same
/// size and weight. Drawn on a navy panel.
class ZoneSky extends StatelessWidget {
  final FiveD data;
  final double height;
  const ZoneSky(this.data, {super.key, this.height = 300});

  static const double _axis = 76;
  static const double _planet = 34;

  @override
  Widget build(BuildContext context) {
    final label = [
      for (final d in kDims) '${d.label} ${data.of(d.key).round()} percent, ${Zone.of(data.of(d.key)).label}'
    ].join('; ');
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            LayoutBuilder(builder: (context, c) {
              final w = c.maxWidth;
              final col = (w - _axis) / kDims.length;
              return SizedBox(
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final z in Zone.values) _band(z),
                    for (var i = 0; i < kDims.length; i++)
                      _planetAt(i, col, data.of(kDims[i].key)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: _axis),
                for (final d in kDims)
                  Expanded(
                    child: Column(
                      children: [
                        Text(d.label,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFF5F5F7))),
                        const SizedBox(height: 1),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          style: GoogleFonts.inter(
                              fontSize: 10.5, fontWeight: FontWeight.w700, color: Zone.of(data.of(d.key)).color),
                          child: Text(Zone.of(data.of(d.key)).label),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Zone boundaries on the continuous 0–100 scale (Critical ends at 15,
  /// Severe at 35 …), so a band's height is its real share of the scale.
  static double _top(Zone z) => z.to.toDouble();
  static double _bottom(Zone z) => z == Zone.critical ? 0 : (z.from - 1).toDouble();

  Widget _band(Zone z) {
    final top = height * (1 - _top(z) / 100);
    final h = height * (_top(z) - _bottom(z)) / 100;
    return Positioned(
      left: 0,
      right: 0,
      top: top,
      height: h,
      child: Container(
        decoration: BoxDecoration(
          color: z.color.withValues(alpha: 0.14),
          border: Border(top: BorderSide(color: z.color.withValues(alpha: 0.25))),
        ),
        padding: const EdgeInsets.only(left: 8),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            ZoneIcon(z, size: 17, glow: false),
            const SizedBox(width: 6),
            Text('${z == Zone.critical ? 0 : z.from}–${z.to}',
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFFB9BBD6))),
          ],
        ),
      ),
    );
  }

  Widget _planetAt(int i, double col, double v) {
    final cx = _axis + col * (i + 0.5);
    final cy = height * (1 - v.clamp(0, 100) / 100);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: kEase,
      left: cx - _planet / 2,
      top: cy - _planet / 2,
      width: _planet,
      height: _planet,
      child: Planet(value: v, size: _planet),
    );
  }
}

/// A soft matte sphere in the zone's colour with the value inside.
class Planet extends StatelessWidget {
  final double value;
  final double size;
  const Planet({super.key, required this.value, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final z = Zone.of(value);
    final c = z.color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.24, -0.36),
          radius: 0.9,
          colors: [Color.lerp(c, Colors.white, 0.22)!, c, Color.lerp(c, AppColors.navy, 0.3)!],
          stops: const [0, 0.55, 1],
        ),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.25), blurRadius: 14)],
      ),
      alignment: Alignment.center,
      child: Text(
        '${value.round()}',
        style: GoogleFonts.sora(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          color: (z == Zone.strong || z == Zone.critical) ? Colors.white : const Color(0xFF1C1F4A),
        ),
      ),
    );
  }
}

/// "What to do": the dimensions grouped by the CK report's zone advice,
/// best zone first.
class ZoneActions extends StatelessWidget {
  final FiveD data;
  final String caption;
  const ZoneActions(this.data, {super.key, required this.caption});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (final z in Zone.values.reversed) {
      final who = [for (final d in kDims) if (Zone.of(data.of(d.key)) == z) d.label];
      if (who.isEmpty) continue;
      rows.add(Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: z.color)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: z.advice,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: z.color)),
                  TextSpan(
                      text: '   ${who.join(', ')}',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFF5F5F7))),
                ]),
              ),
            ),
          ],
        ),
      ));
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caption.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: const Color(0xFF9A9CC0))),
          ...rows,
        ],
      ),
    );
  }
}

/// Simple vertical bar graph of the five dimensions (general rashi reading):
/// value on top, name below, bar coloured by zone.
class FiveDColumns extends StatelessWidget {
  final FiveD data;
  final double height;
  const FiveDColumns(this.data, {super.key, this.height = 150});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: [for (final d in kDims) '${d.label} ${data.of(d.key).round()} percent'].join('; '),
      child: ExcludeSemantics(
        child: Column(
          children: [
            Container(
              height: height + 28,
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x24FFFFFF)))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < kDims.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${data.of(kDims[i].key).round()}%',
                                style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFF5F5F7))),
                            const SizedBox(height: 6),
                            TweenAnimationBuilder<double>(
                              tween: Tween(end: data.of(kDims[i].key).clamp(0, 100) / 100),
                              duration: Duration(milliseconds: 700 + 60 * i),
                              curve: kEase,
                              builder: (_, t, __) => Container(
                                height: height * t,
                                constraints: const BoxConstraints(maxWidth: 36),
                                decoration: BoxDecoration(
                                  color: Zone.of(data.of(kDims[i].key)).color.withValues(alpha: 0.92),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(3)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final d in kDims)
                  Expanded(
                    child: Center(
                      child: Text(d.label,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFF5F5F7))),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact five-icon summary: each dimension's icon with its % below,
/// the % in its zone colour.
class FiveDIcons extends StatelessWidget {
  final FiveD data;
  const FiveDIcons(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final d in kDims)
          Expanded(
            child: Semantics(
              label: '${d.label} ${data.of(d.key).round()} percent',
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)),
                      alignment: Alignment.center,
                      child: StrokeIcon(d.icon, color: const Color(0xFFE7E8F5), size: 22),
                    ),
                    const SizedBox(height: 7),
                    Text('${data.of(d.key).round()}%',
                        style: GoogleFonts.sora(
                            fontSize: 16, fontWeight: FontWeight.w600, color: Zone.of(data.of(d.key)).color)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
