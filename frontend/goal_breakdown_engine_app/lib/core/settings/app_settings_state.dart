part of 'app_settings_cubit.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({
    required this.themeMode,
    required this.nameOverride,
    required this.emailOverride,
    required this.avatarEmoji,
    this.hydrated = false,
  });

  final ThemeMode themeMode;
  final String? nameOverride;
  final String? emailOverride;
  final String avatarEmoji;
  final bool hydrated;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    String? nameOverride,
    String? emailOverride,
    String? avatarEmoji,
    bool? hydrated,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      nameOverride: nameOverride ?? this.nameOverride,
      emailOverride: emailOverride ?? this.emailOverride,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      hydrated: hydrated ?? this.hydrated,
    );
  }

  @override
  List<Object?> get props =>
      [themeMode, nameOverride, emailOverride, avatarEmoji, hydrated];
}
