import 'package:equatable/equatable.dart';

/// タイマーの状態を表す列挙型
enum TimerStatus {
  /// 初期状態（未開始）
  initial,
  /// 計測中
  running,
  /// 一時停止中
  paused,
  /// 停止済み（記録可能状態）
  stopped,
}

/// タイマーの状態を管理するモデル
class TimerState extends Equatable {
  const TimerState({
    required this.status,
    required this.duration,
    required this.name,
    this.startTime,
  });

  /// タイマーの現在ステータス
  final TimerStatus status;

  /// 現在の計測時間（秒）
  final int duration;

  /// タイマー名
  final String name;

  /// 計測開始時刻
  final DateTime? startTime;

  /// 初期状態のTimerState
  static const initial = TimerState(
    status: TimerStatus.initial,
    duration: 0,
    name: '',
  );

  /// 時間を HH:MM:SS 形式で表示
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// タイマーが動作中かどうか
  bool get isRunning => status == TimerStatus.running;

  /// タイマーが停止中かどうか
  bool get isStopped => status == TimerStatus.stopped;

  /// タイマーが初期状態かどうか
  bool get isInitial => status == TimerStatus.initial;

  /// 記録可能な状態かどうか（停止済みかつ時間が0より大きい）
  bool get canSaveRecord => status == TimerStatus.stopped && duration > 0;

  /// 状態をコピー（一部フィールドを変更）
  TimerState copyWith({
    TimerStatus? status,
    int? duration,
    String? name,
    DateTime? startTime,
  }) {
    return TimerState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  List<Object?> get props => [status, duration, name, startTime];
} 