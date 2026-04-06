import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only settings (theme + profile display). Does not replace backend auth.
class AppSettingsStorage {
  static const _kTheme = 'app_theme_mode';
  static const _kName = 'profile_display_name';
  static const _kEmail = 'profile_display_email';
  static const _kAvatar = 'profile_avatar_emoji';

  Future<ThemeMode> readThemeMode() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_kTheme);
    return switch (v) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  Future<void> writeThemeMode(ThemeMode mode) async {
    final p = await SharedPreferences.getInstance();
    final s = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      _ => 'light',
    };
    await p.setString(_kTheme, s);
  }

  Future<String?> readNameOverride() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kName);
  }

  Future<void> writeNameOverride(String? value) async {
    final p = await SharedPreferences.getInstance();
    if (value == null || value.trim().isEmpty) {
      await p.remove(_kName);
    } else {
      await p.setString(_kName, value.trim());
    }
  }

  Future<String?> readEmailOverride() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kEmail);
  }

  Future<void> writeEmailOverride(String? value) async {
    final p = await SharedPreferences.getInstance();
    if (value == null || value.trim().isEmpty) {
      await p.remove(_kEmail);
    } else {
      await p.setString(_kEmail, value.trim());
    }
  }

  Future<String> readAvatarEmoji() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kAvatar) ?? '👤';
  }

  Future<void> writeAvatarEmoji(String value) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAvatar, value.isEmpty ? '👤' : value);
  }
}
