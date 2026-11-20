import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/network/api_repository.dart';
import '../core/utils/dates.dart';
import '../models/load_result.dart';
import '../ui/tabler_icons.dart';

class Rashi {
  /// Exact value GenralPredction expects.
  final String apiName;

  /// Name shown in the app (as on cosmoguru.net).
  final String name;
  final String english;

  /// Name letters for this Moon sign — helps people who don't know their
  /// rashi pick it from the first letter of their name.
  final String letters;

  /// Line icon of the sign (not an emoji).
  final String icon;
  const Rashi(this.apiName, this.name, this.english, this.letters, this.icon);
}

const List<Rashi> kRashis = [
  Rashi('Mesh', 'Mesh', 'Aries', 'A, L, E, I, O', TablerIcons.zodiacAries),
  Rashi('Vrishbha', 'Vrishabh', 'Taurus', 'B, V, U, W', TablerIcons.zodiacTaurus),
  Rashi('Mithun', 'Mithun', 'Gemini', 'K, Chh, Gh, Q, C', TablerIcons.zodiacGemini),
  Rashi('Kark', 'Kark', 'Cancer', 'D, H', TablerIcons.zodiacCancer),
  Rashi('Simha', 'Simha', 'Leo', 'M, T', TablerIcons.zodiacLeo),
  Rashi('Kanya', 'Kanya', 'Virgo', 'P, Th', TablerIcons.zodiacVirgo),
  Rashi('Tula', 'Tula', 'Libra', 'R, T', TablerIcons.zodiacLibra),
  Rashi('Vrishchik', 'Vrishchik', 'Scorpio', 'N, Y', TablerIcons.zodiacScorpio),
  Rashi('Dhanu', 'Dhanu', 'Sagittarius', 'Bh, F, Dh', TablerIcons.zodiacSagittarius),
  Rashi('Makar', 'Makar', 'Capricorn', 'Kh, J', TablerIcons.zodiacCapricorn),
  Rashi('Kumbh', 'Kumbh', 'Aquarius', 'G, S, Sh', TablerIcons.zodiacAquarius),
  Rashi('Meen', 'Meen', 'Pisces', 'D, Ch, Z, Th', TablerIcons.zodiacPisces),
];

/// General (rashi) 5D prediction for yesterday, today and tomorrow.
class RashiController extends GetxController with WidgetsBindingObserver {
  final ApiRepository _repo = ApiRepository();
  static const _prefKey = 'selectedRashi';

  final selected = 0.obs;

  /// -1 yesterday, 0 today, 1 tomorrow.
  final offset = 0.obs;

  final results = <String, FiveDResult>{}.obs;
  final _inflight = <String>{};

  Rashi get rashi => kRashis[selected.value];
  DateTime get date => addDays(today(), offset.value);

  String _key(int rashiIdx, DateTime d) => '${kRashis[rashiIdx].apiName}|${apiDate(d)}';

  FiveDResult? get current => results[_key(selected.value, date)];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _restore();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// The app may sit in the background past midnight; "today" then moves on,
  /// so load the new day's readings when the app comes back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadAllDays();
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    final i = p.getInt(_prefKey) ?? 0;
    selected.value = i.clamp(0, kRashis.length - 1);
    _loadAllDays();
  }

  Future<void> selectRashi(int i) async {
    if (i == selected.value) return;
    selected.value = i;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefKey, i);
    _loadAllDays();
  }

  void setOffset(int o) {
    offset.value = o;
    _load(selected.value, date);
  }

  /// Fetch the visible day first, then its neighbours so switching is instant.
  void _loadAllDays() {
    final idx = selected.value;
    _load(idx, date).then((_) {
      for (final o in const [-1, 0, 1]) {
        _load(idx, addDays(today(), o));
      }
    });
  }

  void retry() => _load(selected.value, date, force: true);

  Future<void> _load(int idx, DateTime d, {bool force = false}) async {
    final key = _key(idx, d);
    final existing = results[key];
    if (!force && existing != null && existing.status != LoadStatus.error) return;
    if (_inflight.contains(key)) return;
    _inflight.add(key);
    results[key] = const FiveDResult.loading();
    try {
      final r = await _repo.getGeneralPrediction({
        'rashi': kRashis[idx].apiName,
        'date': apiDate(d),
      });
      results[key] = FiveDResult.fromApi(r);
    } catch (e) {
      results[key] = FiveDResult.error(friendlyError(e));
    } finally {
      _inflight.remove(key);
    }
  }
}
