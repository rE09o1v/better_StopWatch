import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_record.dart';
import '../constants/app_constants.dart';

/// ローカルストレージサービス
/// 要件定義書「4.3. セキュリティ」に基づくローカルデータ保存
class StorageService {
  StorageService._();
  static final StorageService _instance = StorageService._();
  static StorageService get instance => _instance;

  SharedPreferences? _prefs;

  /// 初期化
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 記録の保存
  Future<bool> saveRecords(List<ActivityRecord> records) async {
    try {
      await initialize();
      final recordsJson = records.map((record) => record.toJson()).toList();
      final recordsString = jsonEncode(recordsJson);
      return await _prefs!.setString(StorageKeys.records, recordsString);
    } catch (e) {
      print('記録の保存に失敗しました: $e');
      return false;
    }
  }

  /// 記録の読み込み
  Future<List<ActivityRecord>> loadRecords() async {
    try {
      await initialize();
      final recordsString = _prefs!.getString(StorageKeys.records);
      if (recordsString == null) {
        return [];
      }

      final recordsJson = jsonDecode(recordsString) as List;
      return recordsJson
          .map((json) => ActivityRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('記録の読み込みに失敗しました: $e');
      return [];
    }
  }

  /// カテゴリの保存
  Future<bool> saveCategories(List<String> categories) async {
    try {
      await initialize();
      return await _prefs!.setStringList(StorageKeys.categories, categories);
    } catch (e) {
      print('カテゴリの保存に失敗しました: $e');
      return false;
    }
  }

  /// カテゴリの読み込み
  Future<List<String>> loadCategories() async {
    try {
      await initialize();
      final categories = _prefs!.getStringList(StorageKeys.categories);
      if (categories == null || categories.isEmpty) {
        // デフォルトカテゴリを保存
        await saveCategories(AppConstants.defaultCategories);
        return AppConstants.defaultCategories;
      }
      return categories;
    } catch (e) {
      print('カテゴリの読み込みに失敗しました: $e');
      return AppConstants.defaultCategories;
    }
  }

  /// 単一記録の追加
  Future<bool> addRecord(ActivityRecord record) async {
    final records = await loadRecords();
    records.insert(0, record); // 新しい記録を先頭に追加
    return await saveRecords(records);
  }

  /// 記録の削除
  Future<bool> deleteRecord(String recordId) async {
    final records = await loadRecords();
    records.removeWhere((record) => record.id == recordId);
    return await saveRecords(records);
  }

  /// 今日の記録を取得
  Future<List<ActivityRecord>> getTodaysRecords() async {
    final records = await loadRecords();
    final today = DateTime.now();
    return records.where((record) {
      return record.startTime.year == today.year &&
          record.startTime.month == today.month &&
          record.startTime.day == today.day;
    }).toList();
  }

  /// 今日の合計時間を取得（秒）
  Future<int> getTodaysTotalDuration() async {
    final todaysRecords = await getTodaysRecords();
    return todaysRecords.fold<int>(0, (total, record) => total + record.duration);
  }

  /// すべてのデータをクリア（デバッグ用）
  Future<bool> clearAllData() async {
    try {
      await initialize();
      await _prefs!.remove(StorageKeys.records);
      await _prefs!.remove(StorageKeys.categories);
      await _prefs!.remove(StorageKeys.appSettings);
      return true;
    } catch (e) {
      print('データクリアに失敗しました: $e');
      return false;
    }
  }
} 