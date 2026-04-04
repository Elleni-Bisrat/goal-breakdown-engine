import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.title,
    super.description,
    required super.duration,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'];
    return GoalModel(
      id: rawId is String ? rawId : rawId.toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      duration: (json['duration'] is int)
          ? json['duration'] as int
          : int.tryParse('${json['duration']}') ?? 30,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    'duration': duration,
  };
}
