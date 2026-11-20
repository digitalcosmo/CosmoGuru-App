import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/rashi_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../models/five_d.dart';
import '../../../models/zone.dart';
import '../../../ui/controls.dart';
import '../../../ui/dim_bars.dart';
import '../../../ui/glass.dart';
import '../../../ui/motion.dart';
import '../../../ui/pal.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tab_page.dart';
import '../../../ui/tokens.dart';
import '../../../ui/zone_icon.dart';

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
            Text('Your rashi, today.', style: T.h1),
            const SizedBox(height: 8),
            Text('Pick your Moon sign and see your day across five areas of life.', style: T.muted),
          ],
        ),
        const RashiPicker(),
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

/// Navy card with the selected rashi's 5D for the selected day.
class RashiReadingCard extends StatelessWidget {
  /// Compact: no best/take-care boxes (used on Home).
  final bool compact;
  const RashiReadingCard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RashiController>();
    return Obx(() {
      final r = c.rashi;
      final res = c.current;
      return Glass(
        dark: true,
        padding: const EdgeInsets.all(20),
        child: Builder(builder: (context) {
          final p = Pal.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orange.withValues(alpha: 0.16),
                    ),
                    alignment: Alignment.center,
                    child: StrokeIcon(r.icon, color: AppColors.orange, size: 24, strokeWidth: 1.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.name} · ${r.english}', style: T.h3),
                        const SizedBox(height: 3),
                        Text(
                          '${c.offset.value == 0 ? 'Today' : c.offset.value < 0 ? 'Yesterday' : 'Tomorrow'} · ${fmtDayLong(c.date)}',
                          style: T.small.copyWith(color: p.tx3),
                        ),
                      ],
                    ),
                  ),
                  const ZoneInfoButton(),
                ],
              ),
              const SizedBox(height: 20),
              ResultSwitch(
                result: res,
                onRetry: c.retry,
                loading: Column(children: [
                  if (!compact) ...[
                    const Row(children: [
                      Expanded(child: Skeleton(height: 92, radius: 16)),
                      SizedBox(width: 10),
                      Expanded(child: Skeleton(height: 92, radius: 16)),
                    ]),
                    const SizedBox(height: 22),
                  ],
                  const DimBarsSkeleton(),
                ]),
                builder: (ok) => _Reading(
                  key: ValueKey('${r.apiName}${c.offset.value}'),
                  data: ok.data!,
                  compact: compact,
                ),
              ),
            ],
          );
        }),
      );
    });
  }
}

class _Reading extends StatelessWidget {
  final FiveD data;
  final bool compact;
  const _Reading({super.key, required this.data, this.compact = false});

  @override
  Widget build(BuildContext context) {
    // Highest and lowest dimension — something concrete to act on, without
    // collapsing five different measures into one meaningless average.
    final sorted = [...kDims]..sort((a, b) => data.of(b.key).compareTo(data.of(a.key)));
    final best = sorted.first, low = sorted.last;
    final flat = data.of(best.key).round() == data.of(low.key).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact && !flat) ...[
          Row(
            children: [
              Expanded(child: _Highlight(title: 'Best area', dim: best, value: data.of(best.key))),
              const SizedBox(width: 10),
              Expanded(child: _Highlight(title: 'Take care with', dim: low, value: data.of(low.key))),
            ],
          ),
          const SizedBox(height: 22),
        ],
        DimBars(data),
      ],
    );
  }
}

class _Highlight extends StatelessWidget {
  final String title;
  final Dim dim;
  final double value;
  const _Highlight({required this.title, required this.dim, required this.value});

  @override
  Widget build(BuildContext context) {
    final z = Zone.of(value);
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: z.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: z.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: T.cap.copyWith(fontSize: 10, letterSpacing: 1.2, color: p.tx3)),
          const SizedBox(height: 10),
          Row(
            children: [
              DimBadge(dim, size: 28),
              const SizedBox(width: 8),
              Expanded(child: Text(dim.label, style: T.strong.copyWith(fontSize: 14.5))),
              ZoneIcon(z, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(z.advice, style: T.small.copyWith(color: z.textOn(dark: p.dark), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
