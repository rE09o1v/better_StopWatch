import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timer_state.dart';

/// タイマープロバイダー
/// タイマーの状態とロジックを管理
class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(TimerState.initial);

  Timer? _timer;

  /// タイマーを開始
  void start(String timerName) {
    if (state.status == TimerStatus.initial) {
      // 初回開始
      state = state.copyWith(
        status: TimerStatus.running,
        name: timerName,
        startTime: DateTime.now(),
      );
    } else {
      // 一時停止から再開
      state = state.copyWith(status: TimerStatus.running);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(duration: state.duration + 1);
    });
  }

  /// タイマーを一時停止
  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// タイマーを停止（記録可能状態）
  void stop() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.stopped);
  }

  /// タイマーをリセット
  void reset() {
    _timer?.cancel();
    state = TimerState.initial;
  }

  /// タイマー名を更新
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// タイマープロバイダーのインスタンス
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>(
  (ref) => TimerNotifier(),
); 