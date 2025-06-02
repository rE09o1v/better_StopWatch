import 'package:flutter/material.dart';

/// アプリケーションで使用するカラーパレット
/// UI/UX設計書「1.2 カラーパレット」に基づく
class AppColors {
  AppColors._();

  /// プライマリブルー: メインアクション
  static const Color primaryBlue = Color(0xFF2563EB);

  /// ライトブルー: 背景、非アクティブ状態
  static const Color lightBlue = Color(0xFFDBEAFE);

  /// アクセントグリーン: 成功、完了
  static const Color accentGreen = Color(0xFF10B981);

  /// グレー: テキスト、補助情報
  static const Color textGray = Color(0xFF6B7280);

  /// ホワイト: 背景
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  /// エラー色（追加）
  static const Color errorRed = Color(0xFFDC2626);

  /// 警告色（追加）
  static const Color warningAmber = Color(0xFFF59E0B);
} 