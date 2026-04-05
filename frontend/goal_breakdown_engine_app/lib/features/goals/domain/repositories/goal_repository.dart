import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';

abstract class GoalRepository {
  Future<List<GoalEntity>> fetchGoals();

  Future<GoalEntity> fetchGoal(String id);

  Future<GoalEntity> createGoal({
    required String title,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    required String priority,
  });

  Future<void> deleteGoal(String id);

  Future<GoalEntity> updateGoal(String id, Map<String, dynamic> patch);
}
