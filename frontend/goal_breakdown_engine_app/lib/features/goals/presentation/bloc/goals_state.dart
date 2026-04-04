import 'package:equatable/equatable.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';

sealed class GoalsState extends Equatable {
  const GoalsState();

  @override
  List<Object?> get props => [];
}

final class GoalsInitial extends GoalsState {
  const GoalsInitial();
}

final class GoalsLoading extends GoalsState {
  const GoalsLoading();
}

final class GoalsLoaded extends GoalsState {
  const GoalsLoaded(this.goals);

  final List<GoalEntity> goals;

  @override
  List<Object?> get props => [goals];
}

final class GoalsFailure extends GoalsState {
  const GoalsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
