import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.title,
    super.description,
    required super.startDate,
    required super.endDate,
    super.priority,
    super.status,
    super.totalTasks,
    super.totalMilestones,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    // Extract the goal object from the response (API returns {goal: {...}, tasks: [...], summary: {...}})
    final goalData = json['goal'] as Map<String, dynamic>? ?? json;

    return GoalModel(
      id: goalData['_id']?.toString() ?? '',
      title: goalData['title']?.toString() ?? '',
      description: goalData['description']?.toString(),
      startDate: _parseDate(goalData['startDate']),
      endDate: _parseDate(goalData['endDate']),
      priority: goalData['priority']?.toString() ?? 'medium',
      status: goalData['status']?.toString() ?? 'active',
      totalTasks: (goalData['totalTasks'] as num?)?.toInt() ?? 0,
      totalMilestones: (goalData['totalMilestones'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('Error parsing date: $dateValue');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null && description!.isNotEmpty)
      'description': description,
    'startDate': _formatDate(startDate),
    'endDate': _formatDate(endDate),
    'priority': priority,
  };

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
