import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/providers/timer_provider.dart';
import '../../shared/providers/records_provider.dart';
import '../../shared/models/timer_state.dart';

/// タイマー画面
/// 要件定義書「3.1. タイマー機能」に対応
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final todaysTotalDuration = ref.watch(todaysTotalDurationProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'タイマー',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 今日の累計時間表示
            _buildTodaysTotalCard(todaysTotalDuration),
            const SizedBox(height: 24),
            
            // タイマー名入力
            _buildTimerNameInput(timerState),
            const SizedBox(height: 32),
            
            // タイマー表示
            _buildTimerDisplay(timerState),
            const SizedBox(height: 48),
            
            // コントロールボタン
            _buildControlButtons(timerState),
          ],
        ),
      ),
    );
  }

  /// 今日の累計時間カード
  Widget _buildTodaysTotalCard(int totalDuration) {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    
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
            '今日の累計時間',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// タイマー名入力フィールド
  Widget _buildTimerNameInput(TimerState timerState) {
    if (timerState.isRunning) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightBlue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          timerState.name.isEmpty ? 'タイマー' : timerState.name,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textGray,
          ),
        ),
      );
    }

    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'タイマー名',
        hintText: AppConstants.defaultTimerNamePlaceholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
      onChanged: (value) {
        ref.read(timerProvider.notifier).updateName(value);
      },
    );
  }

  /// タイマー表示
  Widget _buildTimerDisplay(TimerState timerState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        timerState.formattedDuration,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// コントロールボタン
  Widget _buildControlButtons(TimerState timerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 開始/一時停止ボタン
        _buildPrimaryButton(
          onPressed: () {
            if (timerState.isRunning) {
              ref.read(timerProvider.notifier).pause();
            } else {
              final name = _nameController.text.isEmpty 
                  ? 'タイマー' 
                  : _nameController.text;
              ref.read(timerProvider.notifier).start(name);
            }
          },
          label: timerState.isRunning ? '一時停止' : '開始',
          color: timerState.isRunning ? AppColors.warningAmber : AppColors.primaryBlue,
        ),
        
        // 停止ボタン
        if (!timerState.isInitial)
          _buildSecondaryButton(
            onPressed: () {
              ref.read(timerProvider.notifier).stop();
            },
            label: '停止',
          ),
        
        // リセットボタン
        if (!timerState.isInitial)
          _buildSecondaryButton(
            onPressed: () {
              ref.read(timerProvider.notifier).reset();
              _nameController.clear();
            },
            label: 'リセット',
          ),
      ],
    );
  }

  /// プライマリボタン
  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
    Color? color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// セカンダリボタン
  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        side: const BorderSide(color: AppColors.primaryBlue),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 