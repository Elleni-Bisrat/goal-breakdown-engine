import 'package:goal_breakdown_engine_app/core/settings/app_settings_cubit.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_state.dart';

/// Resolves visible name/email: local overrides win, then authenticated user data.
class UserDisplay {
  UserDisplay._();

  static String name(AppSettingsState settings, AuthState auth) {
    final o = settings.nameOverride;
    if (o != null && o.trim().isNotEmpty) return o.trim();
    if (auth is AuthAuthenticated) {
      final n = auth.displayName;
      if (n != null && n.trim().isNotEmpty) return n.trim();
      final e = auth.email;
      if (e != null && e.trim().isNotEmpty) {
        return e.split('@').first;
      }
    }
    return '';
  }

  static String email(AppSettingsState settings, AuthState auth) {
    final o = settings.emailOverride;
    if (o != null && o.trim().isNotEmpty) return o.trim();
    if (auth is AuthAuthenticated) {
      final e = auth.email;
      if (e != null && e.trim().isNotEmpty) return e.trim();
    }
    return '';
  }
}
