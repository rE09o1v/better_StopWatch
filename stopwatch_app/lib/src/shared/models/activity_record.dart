import 'package:equatable/equatable.dart';

/// 活動記録を表すモデル
/// 要件定義書「1.4. 用語定義」の「記録」に対応
class ActivityRecord extends Equatable {
  const ActivityRecord({
    required this.id,
    required this.name,
    required this.duration,
    required this.category,
    required this.startTime,
    this.tags = const [],
  });

  /// 記録の一意識別子
  final String id;

  /// タイマー名（記録名）
  final String name;

  /// 計測時間（秒）
  final int duration;

  /// カテゴリ
  final String category;

  /// 開始日時
  final DateTime startTime;

  /// タグリスト（最大3つ）
  final List<String> tags;

  /// 終了日時を計算
  DateTime get endTime => startTime.add(Duration(seconds: duration));

  /// 時間を HH:MM:SS 形式で表示
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 分秒表示 (MM:SS)
  String get shortFormattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// JSONからActivityRecordを作成
  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      duration: json['duration'] as int,
      category: json['category'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      tags: List<String>.from(json['tags'] as List),
    );
  }

  /// ActivityRecordをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'category': category,
      'startTime': startTime.millisecondsSinceEpoch,
      'tags': tags,
    };
  }

  /// 記録をコピー（一部フィールドを変更）
  ActivityRecord copyWith({
    String? id,
    String? name,
    int? duration,
    String? category,
    DateTime? startTime,
    List<String>? tags,
  }) {
    return ActivityRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [id, name, duration, category, startTime, tags];
} 