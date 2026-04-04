import 'package:flutter/material.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';

/// Bottom-sheet style dialog: goal title + priority (no separate create page).
Future<Map<String, String>?> showCreateGoalSheet(BuildContext context) {
  final titleCtrl = TextEditingController();
  String priority = 'Medium';

  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'New goal',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Describe your goal and set a priority. Your backend will break it down into milestones and tasks.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Goal',
                    hintText: 'e.g. Learn programming with Flutter',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 'High', child: Text('High')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => priority = v);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final t = titleCtrl.text.trim();
                    if (t.isEmpty) return;
                    Navigator.pop(ctx, {'title': t, 'priority': priority});
                  },
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
