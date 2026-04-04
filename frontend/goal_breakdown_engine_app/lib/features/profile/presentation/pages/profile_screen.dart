import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.goalCard,
              child: Icon(Icons.person, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Judith Smith',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'judith@example.com',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutPressed());
              },
              child: Text(
                'Log out',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
