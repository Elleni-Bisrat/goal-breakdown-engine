import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_event.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  GoalsBloc({required GoalRepository goalRepository})
    : _goalRepository = goalRepository,
      super(const GoalsInitial()) {
    on<GoalsLoadRequested>(_onLoad);
    on<GoalCreateRequested>(_onCreate);
    on<GoalDeleteRequested>(_onDelete);
  }

  final GoalRepository _goalRepository;

  Future<void> _onLoad(
    GoalsLoadRequested event,
    Emitter<GoalsState> emit,
  ) async {
    emit(const GoalsLoading());
    try {
      final goals = await _goalRepository.fetchGoals();
      emit(GoalsLoaded(goals));
    } on DioException catch (e) {
      emit(GoalsFailure(_dioMsg(e)));
    } catch (e) {
      emit(GoalsFailure(e.toString()));
    }
  }

  Future<void> _onCreate(
    GoalCreateRequested event,
    Emitter<GoalsState> emit,
  ) async {
    final List<GoalEntity> prev = state is GoalsLoaded
        ? (state as GoalsLoaded).goals
        : <GoalEntity>[];
    emit(const GoalsLoading());
    try {
      final duration = _durationForPriority(event.priorityLabel);
      final description =
          'Priority: ${event.priorityLabel}. ${event.title.trim()}';
      await _goalRepository.createGoal(
        title: event.title.trim(),
        description: description,
        duration: duration,
      );
      final goals = await _goalRepository.fetchGoals();
      emit(GoalsLoaded(goals));
    } on DioException catch (e) {
      emit(GoalsFailure(_dioMsg(e)));
      if (prev.isNotEmpty) emit(GoalsLoaded(List.of(prev)));
    } catch (e) {
      emit(GoalsFailure(e.toString()));
      if (prev.isNotEmpty) emit(GoalsLoaded(List.of(prev)));
    }
  }

  Future<void> _onDelete(
    GoalDeleteRequested event,
    Emitter<GoalsState> emit,
  ) async {
    try {
      await _goalRepository.deleteGoal(event.goalId);
      add(const GoalsLoadRequested());
    } on DioException catch (e) {
      emit(GoalsFailure(_dioMsg(e)));
    } catch (e) {
      emit(GoalsFailure(e.toString()));
    }
  }

  static int _durationForPriority(String label) {
    final l = label.toLowerCase();
    if (l.contains('high')) return 90;
    if (l.contains('low')) return 30;
    return 60;
  }

  static String _dioMsg(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null)
      return data['message'].toString();
    return e.message ?? 'Request failed';
  }
}
