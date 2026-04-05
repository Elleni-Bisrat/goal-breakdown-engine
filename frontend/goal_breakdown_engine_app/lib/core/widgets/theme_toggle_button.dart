import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/settings/app_settings_cubit.dart';

/// Theme toggle using [GestureDetector] only (no [IconButton] / ink splash).
/// That avoids GlobalKey conflicts when PageView or IndexedStack keeps multiple
/// overlapping subtrees alive.
class ThemeToggleIconButton extends StatelessWidget {
  const ThemeToggleIconButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        final dark = state.themeMode == ThemeMode.dark;
        return Tooltip(
          message: dark ? 'Light mode' : 'Dark mode',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                context.read<AppSettingsCubit>().toggleLightDark(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: iconColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}
