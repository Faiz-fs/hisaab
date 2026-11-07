import 'package:flutter/material.dart';

/// Design token colours for Hisaab.
/// All colours are defined as [Color] constants derived from the brand palette.
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0B0B10);
  static const Color card = Color(0xFF16161D);
  static const Color nested = Color(0xFF1E1E28);

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF262633);
  static const Color borderInteractive = Color(0xFF38384D);

  // ── Brand / Accent ────────────────────────────────────────────────────────
  /// Lime – primary action colour
  static const Color primary = Color(0xFFC6F432);
  static const Color onPrimary = Color(0xFF0B0B10);

  // ── Semantic ──────────────────────────────────────────────────────────────
  /// Mint – under-budget indicator
  static const Color mint = Color(0xFF2FD58A);
  static const Color amber = Color(0xFFFFB020);
  static const Color red = Color(0xFFFF4D5E);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E9F);
}
