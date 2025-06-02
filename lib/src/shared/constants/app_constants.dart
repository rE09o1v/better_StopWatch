/// アプリケーション全体で使用する定数
class AppConstants {
  AppConstants._();

  /// アプリケーション名
  static const String appName = 'ストップウォッチ';

  /// デフォルトのタイマー名プレースホルダー
  static const String defaultTimerNamePlaceholder = '例：数学の勉強';

  /// タグの最大数
  static const int maxTagsPerRecord = 3;

  /// デフォルトのカテゴリ
  static const List<String> defaultCategories = [
    '勉強',
    '運動',
    '読書',
    '仕事',
    '趣味',
  ];
}

/// ローカルストレージのキー
class StorageKeys {
  StorageKeys._();
  
  static const String records = 'stopwatch_records';
  static const String categories = 'stopwatch_categories';
  static const String appSettings = 'stopwatch_app_settings';
}

/// 時間フォーマット
class TimeFormat {
  TimeFormat._();
  
  static const String stopwatchDisplay = 'HH:mm:ss';
  static const String recordDisplay = 'MM:ss';
  static const String dateDisplay = 'yyyy/MM/dd';
  static const String timeDisplay = 'HH:mm';
} 