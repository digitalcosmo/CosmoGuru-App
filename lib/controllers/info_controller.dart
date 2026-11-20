import 'package:get/get.dart';
import '../core/network/api_repository.dart';
import '../models/load_result.dart';

/// Guidelines and FAQ (shared CosmoKundli content).
class InfoController extends GetxController {
  final ApiRepository _repo = ApiRepository();

  final guidelineStatus = LoadStatus.loading.obs;
  final guidelineContent = ''.obs;

  final faqStatus = LoadStatus.loading.obs;
  final faqList = <Map<String, dynamic>>[].obs;

  String _s(dynamic v) => v == null ? '' : '$v'.trim();

  Future<void> loadGuidelines() async {
    guidelineStatus.value = LoadStatus.loading;
    try {
      final r = await _repo.getGuidelines();
      guidelineContent.value = _s(r['content'] ?? r['data'] ?? r['guideline']);
      guidelineStatus.value = LoadStatus.ok;
    } catch (e) {
      guidelineStatus.value = LoadStatus.error;
    }
  }

  Future<void> loadFAQs() async {
    faqStatus.value = LoadStatus.loading;
    try {
      final r = await _repo.getFaqs();
      final list = r['list'] ?? r['List'] ?? r['data'] ?? [];
      if (list is List) {
        faqList.assignAll(list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
      }
      faqStatus.value = LoadStatus.ok;
    } catch (e) {
      faqStatus.value = LoadStatus.error;
    }
  }
}
