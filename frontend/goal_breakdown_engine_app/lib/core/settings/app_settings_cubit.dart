import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:goal_breakdown_engine_app/core/data/local/app_settings_storage.dart';

part 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._storage)
      : super(
          const AppSettingsState(
            themeMode: ThemeMode.light,
            nameOverride: null,
            emailOverride: null,
            avatarEmoji: '👤',
            hydrated: false,
          ),
        ) {
    _hydrate();
  }

  final AppSettingsStorage _storage;

  Future<void> _hydrate() async {
    final theme = await _storage.readThemeMode();
    final name = await _storage.readNameOverride();
    final email = await _storage.readEmailOverride();
    final avatar = await _storage.readAvatarEmoji();
    emit(
      AppSettingsState(
        themeMode: theme,
        nameOverride: name,
        emailOverride: email,
        avatarEmoji: avatar,
        hydrated: true,
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _storage.writeThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> toggleLightDark() async {
    final next = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(next);
  }

  Future<void> setProfileOverrides({
    String? name,
    String? email,
    String? avatarEmoji,
    bool clearName = false,
    bool clearEmail = false,
  }) async {
    if (clearName) {
      await _storage.writeNameOverride(null);
    } else if (name != null) {
      await _storage.writeNameOverride(name);
    }
    if (clearEmail) {
      await _storage.writeEmailOverride(null);
    } else if (email != null) {
      await _storage.writeEmailOverride(email);
    }
    if (avatarEmoji != null) {
      await _storage.writeAvatarEmoji(avatarEmoji);
    }

    final nameOut =
        clearName ? null : await _storage.readNameOverride();
    final emailOut =
        clearEmail ? null : await _storage.readEmailOverride();
    final avatarOut = await _storage.readAvatarEmoji();

    emit(
      AppSettingsState(
        themeMode: state.themeMode,
        nameOverride: nameOut,
        emailOverride: emailOut,
        avatarEmoji: avatarOut,
        hydrated: true,
      ),
    );
  }
}
