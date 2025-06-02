import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/models/activity_record.dart';
import '../../shared/models/timer_state.dart';
import '../../shared/providers/timer_provider.dart';
import '../../shared/providers/records_provider.dart';
import '../../shared/providers/categories_provider.dart';

/// 記録入力画面
/// 要件定義書「3.2. 記録入力機能」に対応
class RecordInputScreen extends ConsumerStatefulWidget {
  const RecordInputScreen({super.key});

  @override
  ConsumerState<RecordInputScreen> createState() => _RecordInputScreenState();
}

class _RecordInputScreenState extends ConsumerState<RecordInputScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagController = TextEditingController();
  
  String? _selectedCategory;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    // タイマーの情報を初期値として設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerState = ref.read(timerProvider);
      if (timerState.canSaveRecord) {
        _nameController.text = timerState.name;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final categories = ref.watch(categoriesProvider);

    if (!timerState.canSaveRecord) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('記録入力'),
          backgroundColor: AppColors.backgroundWhite,
        ),
        body: const Center(
          child: Text(
            '記録できるデータがありません。\nタイマーを実行してから記録してください。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textGray,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          '記録入力',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _discardRecord,
            child: const Text(
              '破棄',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 計測結果表示
            _buildResultCard(timerState),
            const SizedBox(height: 24),
            
            // タイマー名入力
            _buildNameInput(),
            const SizedBox(height: 16),
            
            // カテゴリ選択
            _buildCategorySelection(categories),
            const SizedBox(height: 16),
            
            // タグ入力
            _buildTagInput(),
            const SizedBox(height: 24),
            
            // タグ表示
            if (_tags.isNotEmpty) _buildTagList(),
            
            const Spacer(),
            
            // 保存ボタン
            _buildSaveButton(timerState),
          ],
        ),
      ),
    );
  }

  /// 計測結果カード
  Widget _buildResultCard(TimerState timerState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '計測時間',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timerState.formattedDuration,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// 名前入力フィールド
  Widget _buildNameInput() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'タイマー名 *',
        hintText: AppConstants.defaultTimerNamePlaceholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  /// カテゴリ選択
  Widget _buildCategorySelection(List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'カテゴリ *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
          items: [
            ...categories.map(
              (category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ),
            ),
            const DropdownMenuItem(
              value: '__new_category__',
              child: Text('新しいカテゴリを作成...'),
            ),
          ],
          onChanged: (value) {
            if (value == '__new_category__') {
              _showNewCategoryDialog();
            } else {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ],
    );
  }

  /// タグ入力
  Widget _buildTagInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _tagController,
            decoration: InputDecoration(
              labelText: 'タグを追加（任意）',
              hintText: '例：集中、難しい',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
            onSubmitted: _addTag,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _addTag(_tagController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('追加'),
        ),
      ],
    );
  }

  /// タグリスト
  Widget _buildTagList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'タグ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeTag(tag),
              backgroundColor: AppColors.lightBlue,
              labelStyle: const TextStyle(color: AppColors.primaryBlue),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// 保存ボタン
  Widget _buildSaveButton(TimerState timerState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canSave() ? () => _saveRecord(timerState) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '記録を保存',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// タグを追加
  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && 
        !_tags.contains(tag.trim()) && 
        _tags.length < AppConstants.maxTagsPerRecord) {
      setState(() {
        _tags.add(tag.trim());
        _tagController.clear();
      });
    }
  }

  /// タグを削除
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  /// 保存可能かチェック
  bool _canSave() {
    return _nameController.text.trim().isNotEmpty && 
           _selectedCategory != null;
  }

  /// 記録を保存
  void _saveRecord(TimerState timerState) async {
    if (!_canSave()) return;

    final record = ActivityRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      duration: timerState.duration,
      category: _selectedCategory!,
      startTime: timerState.startTime!,
      tags: _tags,
    );

    await ref.read(recordsProvider.notifier).addRecord(record);
    ref.read(timerProvider.notifier).reset();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('記録を保存しました'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  /// 記録を破棄
  void _discardRecord() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記録を破棄'),
        content: const Text('計測した記録を破棄しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(timerProvider.notifier).reset();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('破棄'),
          ),
        ],
      ),
    );
  }

  /// 新しいカテゴリダイアログ
  void _showNewCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいカテゴリ'),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'カテゴリ名',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final newCategory = _categoryController.text.trim();
              if (newCategory.isNotEmpty) {
                ref.read(categoriesProvider.notifier).addCategory(newCategory);
                setState(() {
                  _selectedCategory = newCategory;
                });
                _categoryController.clear();
              }
              Navigator.of(context).pop();
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
} 