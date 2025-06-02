import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_record.dart';
import '../services/storage_service.dart';

/// 記録管理プロバイダー
class RecordsNotifier extends StateNotifier<List<ActivityRecord>> {
  RecordsNotifier() : super([]) {
    _loadRecords();
  }

  final _storageService = StorageService.instance;

  /// 記録を読み込み
  Future<void> _loadRecords() async {
    final records = await _storageService.loadRecords();
    state = records;
  }

  /// 記録を追加
  Future<void> addRecord(ActivityRecord record) async {
    final success = await _storageService.addRecord(record);
    if (success) {
      state = [record, ...state];
    }
  }

  /// 記録を削除
  Future<void> deleteRecord(String recordId) async {
    final success = await _storageService.deleteRecord(recordId);
    if (success) {
      state = state.where((record) => record.id != recordId).toList();
    }
  }

  /// 今日の記録を取得
  List<ActivityRecord> getTodaysRecords() {
    final today = DateTime.now();
    return state.where((record) {
      return record.startTime.year == today.year &&
          record.startTime.month == today.month &&
          record.startTime.day == today.day;
    }).toList();
  }

  /// 今日の合計時間を取得（秒）
  int getTodaysTotalDuration() {
    final todaysRecords = getTodaysRecords();
    return todaysRecords.fold(0, (total, record) => total + record.duration);
  }

  /// カテゴリ別の合計時間を取得
  Map<String, int> getCategoryTotals() {
    final categoryTotals = <String, int>{};
    for (final record in state) {
      categoryTotals[record.category] = 
          (categoryTotals[record.category] ?? 0) + record.duration;
    }
    return categoryTotals;
  }

  /// タグ別の合計時間を取得
  Map<String, int> getTagTotals() {
    final tagTotals = <String, int>{};
    for (final record in state) {
      for (final tag in record.tags) {
        tagTotals[tag] = (tagTotals[tag] ?? 0) + record.duration;
      }
    }
    return tagTotals;
  }

  /// 記録を更新
  void refresh() {
    _loadRecords();
  }
}

/// 記録プロバイダーのインスタンス
final recordsProvider = StateNotifierProvider<RecordsNotifier, List<ActivityRecord>>(
  (ref) => RecordsNotifier(),
);

/// 今日の記録を取得するプロバイダー
final todaysRecordsProvider = Provider<List<ActivityRecord>>((ref) {
  final records = ref.watch(recordsProvider);
  final today = DateTime.now();
  return records.where((record) {
    return record.startTime.year == today.year &&
        record.startTime.month == today.month &&
        record.startTime.day == today.day;
  }).toList();
});

/// 今日の合計時間を取得するプロバイダー
final todaysTotalDurationProvider = Provider<int>((ref) {
  final todaysRecords = ref.watch(todaysRecordsProvider);
  return todaysRecords.fold(0, (total, record) => total + record.duration);
}); 