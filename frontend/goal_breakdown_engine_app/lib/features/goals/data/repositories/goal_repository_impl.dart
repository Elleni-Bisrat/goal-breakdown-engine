import 'package:dio/dio.dart';
import 'package:goal_breakdown_engine_app/features/goals/data/models/goal_model.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<GoalEntity> createGoal({
    required String title,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    required String priority,
  }) async {
    try {
      final requestData = {
        'title': title,
        'description': description ?? '',
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),
        'priority': priority.toLowerCase(),
      };

      print('Creating goal with data: $requestData');

      final response = await _dio.post<Map<String, dynamic>>(
        '/goals',
        data: requestData,
      );

      print('Create goal response status: ${response.statusCode}');
      print('Create goal response data: ${response.data}');

      // The API returns {goal: {...}, tasks: [...], summary: {...}}
      // We need to extract the goal object
      if (response.data == null) {
        throw Exception('Response data is null');
      }

      return GoalModel.fromJson(response.data!);
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      print('Dio error status: ${e.response?.statusCode}');
      print('Dio error message: ${e.message}');
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _dio.delete<dynamic>('/goals/$id');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<GoalEntity> fetchGoal(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/goals/$id');

      print('Fetch goal response: ${response.data}');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      return GoalModel.fromJson(response.data!);
    } on DioException catch (e) {
      print('Fetch goal error: ${e.response?.data}');
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<List<GoalEntity>> fetchGoals() async {
    try {
      final response = await _dio.get<List<dynamic>>('/goals');

      print('Fetch goals response: ${response.data}');

      final list = response.data ?? [];
      return list
          .map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('Fetch goals error: ${e.response?.data}');
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<GoalEntity> updateGoal(String id, Map<String, dynamic> patch) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/goals/$id',
        data: patch,
      );
      return GoalModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
    }
    if (data is String) return data;
    return e.message ?? 'Request failed';
  }
}
