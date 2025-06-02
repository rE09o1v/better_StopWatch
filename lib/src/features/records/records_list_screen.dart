import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/models/activity_record.dart';
import '../../shared/providers/records_provider.dart';

/// 記録一覧画面
/// 要件定義書「3.5. 記録一覧表示機能」に対応
class RecordsListScreen extends ConsumerWidget {
  const RecordsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordsProvider);
    final todaysTotalDuration = ref.watch(todaysTotalDurationProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          '記録一覧',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 今日の合計時間表示
          _buildTodaysTotalCard(todaysTotalDuration),
          
          // 記録リスト
          Expanded(
            child: records.isEmpty
                ? _buildEmptyState()
                : _buildRecordsList(records, ref),
          ),
        ],
      ),
    );
  }

  /// 今日の合計時間カード
  Widget _buildTodaysTotalCard(int totalDuration) {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final seconds = totalDuration % 60;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '今日の合計時間',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// 空の状態
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 64,
            color: AppColors.textGray,
          ),
          SizedBox(height: 16),
          Text(
            '記録がありません',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'タイマーを使って活動を記録してみましょう',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  /// 記録リスト
  Widget _buildRecordsList(List<ActivityRecord> records, WidgetRef ref) {
    // 日付でグループ化
    final groupedRecords = <String, List<ActivityRecord>>{};
    for (final record in records) {
      final dateKey = _formatDate(record.startTime);
      groupedRecords[dateKey] ??= [];
      groupedRecords[dateKey]!.add(record);
    }

    final sortedDates = groupedRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 新しい日付順

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayRecords = groupedRecords[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日付ヘッダー
            _buildDateHeader(date, dayRecords),
            
            // その日の記録
            ...dayRecords.map((record) => _buildRecordCard(record, ref)),
            
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// 日付ヘッダー
  Widget _buildDateHeader(String date, List<ActivityRecord> dayRecords) {
    final totalDuration = dayRecords.fold(0, (sum, record) => sum + record.duration);
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final seconds = totalDuration % 60;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDateDisplay(date),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          Text(
            '合計 ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  /// 記録カード
  Widget _buildRecordCard(ActivityRecord record, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue,
          child: Text(
            record.category.substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          record.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record.category} • ${_formatTime(record.startTime)}',
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
              ),
            ),
            if (record.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: record.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              record.formattedDuration,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.errorRed,
                size: 20,
              ),
              onPressed: () => _showDeleteDialog(record, ref),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// 削除確認ダイアログ
  void _showDeleteDialog(ActivityRecord record, WidgetRef ref) {
    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: const Text('記録を削除'),
        content: Text('「${record.name}」の記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(recordsProvider.notifier).deleteRecord(record.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('記録を削除しました'),
                  backgroundColor: AppColors.errorRed,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  /// 日付フォーマット（内部キー用）
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 日付フォーマット（表示用）
  String _formatDateDisplay(String dateKey) {
    final now = DateTime.now();
    final date = DateTime.parse(dateKey);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '今日';
    } else if (targetDate == yesterday) {
      return '昨日';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  /// 時刻フォーマット
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
} 