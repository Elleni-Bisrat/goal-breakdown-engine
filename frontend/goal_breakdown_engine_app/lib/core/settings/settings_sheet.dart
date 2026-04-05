import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/settings/app_settings_cubit.dart';
import 'package:goal_breakdown_engine_app/core/settings/user_display.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_state.dart';

Future<void> showAppSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const _SettingsSheetBody(),
  );
}

class _SettingsSheetBody extends StatefulWidget {
  const _SettingsSheetBody();

  @override
  State<_SettingsSheetBody> createState() => _SettingsSheetBodyState();
}

class _SettingsSheetBodyState extends State<_SettingsSheetBody> {
  late final TextEditingController _name;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppSettingsCubit>().state;
    final auth = context.read<AuthBloc>().state;
    _name = TextEditingController(text: UserDisplay.name(settings, auth));
    _email = TextEditingController(text: UserDisplay.email(settings, auth));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const avatars = ['👤', '🙂', '😎', '🧑‍💻', '👩‍🎓', '🦁', '⭐', '🎯'];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: BlocConsumer<AppSettingsCubit, AppSettingsState>(
        listenWhen: (p, c) =>
            p.nameOverride != c.nameOverride ||
            p.emailOverride != c.emailOverride ||
            p.avatarEmoji != c.avatarEmoji,
        listener: (context, settings) {
          final auth = context.read<AuthBloc>().state;
          _name.text = UserDisplay.name(settings, auth);
          _email.text = UserDisplay.email(settings, auth);
        },
        builder: (context, settings) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, auth) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        settings.themeMode == ThemeMode.dark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                      ),
                      title: const Text('Dark mode'),
                      trailing: Switch(
                        value: settings.themeMode == ThemeMode.dark,
                        onChanged: (_) {
                          context.read<AppSettingsCubit>().toggleLightDark();
                        },
                      ),
                    ),
                    const Divider(),
                    Text(
                      'Profile (this device)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shown on Home and Profile. Reset uses your sign-in name/email.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Avatar',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: avatars
                          .map(
                            (e) => Material(
                              color: e == settings.avatarEmoji
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () => context
                                    .read<AppSettingsCubit>()
                                    .setProfileOverrides(avatarEmoji: e),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(e, style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email (display only)',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context.read<AppSettingsCubit>().setProfileOverrides(
                              name: _name.text.trim(),
                              email: _email.text.trim(),
                            );
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AppSettingsCubit>().setProfileOverrides(
                              clearName: true,
                              clearEmail: true,
                            );
                        Navigator.pop(context);
                      },
                      child: const Text('Reset to sign-in defaults'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
