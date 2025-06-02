import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// カテゴリ管理プロバイダー
class CategoriesNotifier extends StateNotifier<List<String>> {
  CategoriesNotifier() : super([]) {
    _loadCategories();
  }

  final _storageService = StorageService.instance;

  /// カテゴリを読み込み
  Future<void> _loadCategories() async {
    final categories = await _storageService.loadCategories();
    state = categories;
  }

  /// カテゴリを追加
  Future<void> addCategory(String category) async {
    if (!state.contains(category)) {
      final newCategories = [...state, category];
      final success = await _storageService.saveCategories(newCategories);
      if (success) {
        state = newCategories;
      }
    }
  }

  /// カテゴリを削除
  Future<void> removeCategory(String category) async {
    final newCategories = state.where((c) => c != category).toList();
    final success = await _storageService.saveCategories(newCategories);
    if (success) {
      state = newCategories;
    }
  }

  /// カテゴリを更新
  void refresh() {
    _loadCategories();
  }
}

/// カテゴリプロバイダーのインスタンス
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<String>>(
  (ref) => CategoriesNotifier(),
); 