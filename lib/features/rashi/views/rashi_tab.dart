import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/rashi_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../ui/controls.dart';
import '../../../ui/glass.dart';
import '../../../ui/motion.dart';
import '../../../ui/pal.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tab_page.dart';
import '../../../ui/tokens.dart';
import '../../../ui/zone_sky.dart';

/// Rashi Bhavishya: free 5D for every Moon sign — yesterday, today, tomorrow.
class RashiTab extends StatelessWidget {
  const RashiTab({super.key});

  @override
  Widget build(BuildContext context) {
    final rashi = Get.find<RashiController>();
    return TabPage(
      onRefresh: () async => rashi.retry(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RASHI BHAVISHYA', style: T.eyebrow),
            const SizedBox(height: 8),
            Text('Turn the wheel to your sign', style: T.h1),
            const SizedBox(height: 8),
            Text('Not sure of your rashi? Match the first letter of your name.', style: T.muted),
          ],
        ),
        const RashiWheel(),
        const RashiDaySwitch(),
        const RashiReadingCard(),
        Text(
          'Rashi Bhavishya is general — it applies to everyone born under the same Moon sign. '
          'Your CK Planner is calculated for you personally.',
          style: T.small,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Horizontal list of the 12 signs, with the name letters for each.
class RashiPicker extends StatefulWidget {
  const RashiPicker({super.key});
  @override
  State<RashiPicker> createState() => _RashiPickerState();
}

class _RashiPickerState extends State<RashiPicker> {
  final _scroll = ScrollController();
  static const _w = 92.0, _gap = 10.0;
  late final Worker _w1;
  final c = Get.find<RashiController>();

  @override
  void initState() {
    super.initState();
    _w1 = ever<int>(c.selected, (i) => _center(i));
    WidgetsBinding.instance.addPostFrameCallback((_) => _center(c.selected.value, animate: false));
  }

  void _center(int i, {bool animate = true}) {
    if (!_scroll.hasClients) return;
    final vw = _scroll.position.viewportDimension;
    final target = (i * (_w + _gap) - (vw - _w) / 2).clamp(0.0, _scroll.position.maxScrollExtent);
    if (animate) {
      _scroll.animateTo(target, duration: const Duration(milliseconds: 500), curve: kEase);
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  void dispose() {
    _w1.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: kRashis.length,
        separatorBuilder: (_, __) => const SizedBox(width: _gap),
        itemBuilder: (_, i) => Obx(() {
          final sel = c.selected.value == i;
          final r = kRashis[i];
          return Pressable(
            onTap: () => c.selectRashi(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: kEase,
              width: _w,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: sel ? AppColors.red : Colors.white,
                border: Border.all(color: sel ? AppColors.red : AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: sel ? AppColors.red.withValues(alpha: 0.28) : Colors.black.withValues(alpha: 0.04),
                    blurRadius: sel ? 18 : 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StrokeIcon(r.icon, color: sel ? Colors.white : AppColors.red, size: 26, strokeWidth: 1.7),
                  const SizedBox(height: 8),
                  Text(r.name,
                      style: T.strong.copyWith(fontSize: 13.5, color: sel ? Colors.white : AppColors.tx)),
                  const SizedBox(height: 2),
                  Text(r.letters,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: T.small.copyWith(
                          fontSize: 10.5, color: sel ? Colors.white.withValues(alpha: 0.85) : AppColors.tx3)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class RashiDaySwitch extends StatelessWidget {
  const RashiDaySwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RashiController>();
    return Obx(() => Segmented(
          labels: const ['Yesterday', 'Today', 'Tomorrow'],
          index: c.offset.value + 1,
          onChanged: (i) => c.setOffset(i - 1),
        ));
  }
}

/// Navy card with the selected rashi's 5D for the selected day, as a
/// simple bar graph.
class RashiReadingCard extends StatelessWidget {
  final bool compact;
  const RashiReadingCard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RashiController>();
    return Obx(() {
      final r = c.rashi;
      final res = c.current;
      final day = c.offset.value == 0 ? 'Today' : c.offset.value < 0 ? 'Yesterday' : 'Tomorrow';
      return Glass(
        dark: true,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Builder(builder: (context) {
          final p = Pal.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('$day · 5D'.toUpperCase(), style: T.cap.copyWith(color: AppColors.orange))),
                  Text('${r.name} · general', style: T.small.copyWith(color: p.tx2)),
                ],
              ),
              const SizedBox(height: 16),
              ResultSwitch(
                result: res,
                onRetry: c.retry,
                loading: Skeleton(height: compact ? 170 : 210, radius: 16),
                builder: (ok) => FiveDColumns(ok.data!, height: compact ? 120 : 150),
              ),
              if (!compact) ...[
                const SizedBox(height: 12),
                Text(fmtDayLong(c.date), style: T.small.copyWith(color: p.tx3), textAlign: TextAlign.center),
              ],
            ],
          );
        }),
      );
    });
  }
}

/// The 12 signs on a wheel. Tap one and the wheel turns to bring it to the
/// top, under the pointer; the centre shows its name and name letters.
class RashiWheel extends StatefulWidget {
  const RashiWheel({super.key});
  @override
  State<RashiWheel> createState() => _RashiWheelState();
}

class _RashiWheelState extends State<RashiWheel> {
  final c = Get.find<RashiController>();
  late final Worker _w;

  /// Wheel rotation in sign-steps; follows the shortest way round.
  late double _turn = -c.selected.value.toDouble();

  @override
  void initState() {
    super.initState();
    _w = ever<int>(c.selected, (i) {
      final cur = -_turn;
      var delta = (i - cur) % 12;
      if (delta > 6) delta -= 12;
      setState(() => _turn = -(cur + delta));
    });
  }

  @override
  void dispose() {
    _w.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final size = math.min(box.maxWidth, 350.0);
      final ctr = size / 2;
      final ring = size * 0.4;
      return Center(
        child: SizedBox(
          width: size,
          height: size + 14,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: _turn),
            duration: const Duration(milliseconds: 650),
            curve: kEase,
            builder: (context, turn, _) {
              final sel = c.selected.value;
              final r = kRashis[sel];
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: size * 0.05,
                    top: 14 + size * 0.05,
                    width: size * 0.9,
                    height: size * 0.9,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.orange.withValues(alpha: 0.28), width: 1.4),
                        ),
                      ),
                    ),
                  ),
                  for (var i = 0; i < 12; i++)
                    Builder(builder: (_) {
                      final on = i == sel;
                      final s = on ? 64.0 : 52.0;
                      final a = ((i + turn) * 30 - 90) * math.pi / 180;
                      return Positioned(
                        left: ctr + ring * math.cos(a) - s / 2,
                        top: 14 + ctr + ring * math.sin(a) - s / 2,
                        width: s,
                        height: s,
                        child: _SignButton(index: i, selected: on),
                      );
                    }),
                  // Centre disc: the selected sign.
                  Positioned(
                    left: ctr - size * 0.215,
                    top: 14 + ctr - size * 0.215,
                    width: size * 0.43,
                    height: size * 0.43,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          center: Alignment(-0.3, -0.4),
                          colors: [Colors.white, AppColors.redSoft, Color(0xFFFFE3DE)],
                          stops: [0, 0.6, 1],
                        ),
                        border: Border.all(color: const Color(0xFFF3D3CE)),
                        boxShadow: [BoxShadow(color: AppColors.red.withValues(alpha: 0.14), blurRadius: 40, offset: const Offset(0, 18))],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey(sel),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(r.name, style: T.h2.copyWith(fontSize: 22)),
                            const SizedBox(height: 2),
                            Text(r.english, style: T.small.copyWith(color: AppColors.tx2)),
                            const SizedBox(height: 4),
                            Text(r.letters,
                                style: T.small.copyWith(fontSize: 11, color: AppColors.red, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Pointer above the top sign, in front of it.
                  Positioned(
                    left: ctr - 12,
                    top: 14 + ctr - ring - 32 - 14,
                    child: const IgnorePointer(child: CustomPaint(size: Size(24, 12), painter: _Pointer())),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}

class _Pointer extends CustomPainter {
  const _Pointer();
  @override
  void paint(Canvas canvas, Size s) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(s.width, 0)
      ..lineTo(s.width / 2, s.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SignButton extends StatelessWidget {
  final int index;
  final bool selected;
  const _SignButton({required this.index, required this.selected});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RashiController>();
    final r = kRashis[index];
    return Semantics(
      button: true,
      selected: selected,
      label: '${r.name} (${r.english}), letters ${r.letters}',
      child: Pressable(
        onTap: () {
          HapticFeedback.selectionClick();
          c.selectRashi(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: kEase,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.red : Colors.white,
            border: selected ? null : Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: selected ? AppColors.red.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.06),
                blurRadius: selected ? 24 : 12,
                offset: Offset(0, selected ? 10 : 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StrokeIcon(r.icon, color: selected ? Colors.white : AppColors.red, size: 22, strokeWidth: 1.8),
              const SizedBox(height: 1),
              Text(r.name,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: T.small.copyWith(
                      fontSize: selected ? 10.5 : 9,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.tx)),
            ],
          ),
        ),
      ),
    );
  }
}
