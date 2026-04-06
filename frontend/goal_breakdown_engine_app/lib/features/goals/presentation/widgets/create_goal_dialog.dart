import 'package:flutter/material.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';

Future<Map<String, dynamic>?> showCreateGoalSheet(BuildContext context) {
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  String priority = 'medium';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.28,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    'Create New Goal',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Define your goal with timeline and priority',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Goal Title *',
                      hintText: 'e.g., Learn Flutter Development',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionCtrl,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Describe your goal in detail...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: priority,
                    decoration: const InputDecoration(labelText: 'Priority *'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => priority = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => startDate = picked);
                        if (endDate.isBefore(startDate)) {
                          setModalState(
                            () => endDate = startDate.add(
                              const Duration(days: 30),
                            ),
                          );
                        }
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date *',
                      ),
                      child: Text(
                        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: startDate,
                        lastDate: startDate.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => endDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date *',
                      ),
                      child: Text(
                        '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please enter a goal title'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        return;
                      }
                      if (endDate.isBefore(startDate)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'End date must be after start date',
                            ),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(ctx, {
                        'title': title,
                        'description': descriptionCtrl.text.trim(),
                        'startDate': startDate,
                        'endDate': endDate,
                        'priority': priority,
                      });
                    },
                    child: const Text('Create Goal'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<Map<String, dynamic>?> showEditGoalSheet(
  BuildContext context, {
  required GoalEntity goal,
}) {
  final titleCtrl = TextEditingController(text: goal.title);
  final descriptionCtrl = TextEditingController(text: goal.description ?? '');
  String priority = goal.priority.toLowerCase();
  DateTime startDate = goal.startDate;
  DateTime endDate = goal.endDate;

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.28,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    'Edit Goal',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Goal Title *'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionCtrl,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: priority,
                    decoration: const InputDecoration(labelText: 'Priority *'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => priority = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => startDate = picked);
                        if (endDate.isBefore(startDate)) {
                          setModalState(
                            () => endDate = startDate.add(const Duration(days: 1)),
                          );
                        }
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Start Date *'),
                      child: Text(
                        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: startDate,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => endDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'End Date *'),
                      child: Text(
                        '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please enter a goal title'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        return;
                      }
                      if (endDate.isBefore(startDate)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'End date must be after start date',
                            ),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(ctx, {
                        'title': title,
                        'description': descriptionCtrl.text.trim(),
                        'startDate': startDate,
                        'endDate': endDate,
                        'priority': priority,
                      });
                    },
                    child: const Text('Save Changes'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
