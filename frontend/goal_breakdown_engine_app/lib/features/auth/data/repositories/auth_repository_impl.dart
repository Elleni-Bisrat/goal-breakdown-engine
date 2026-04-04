import 'package:dio/dio.dart';
import 'package:goal_breakdown_engine_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/data/local/token_memory.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/data/local/token_storage_prefs.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required Dio dio,
    required TokenStoragePrefs prefs,
    required TokenMemory memory,
  }) : _dio = dio,
       _prefs = prefs,
       _memory = memory;

  final Dio _dio;
  final TokenStoragePrefs _prefs;
  final TokenMemory _memory;

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data!;
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError(data['message']?.toString() ?? 'Login failed');
    }
    await persistToken(token);
    return token;
  }

  @override
  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/signup',
      data: {'name': name, 'email': email, 'password': password},
    );
    final data = res.data!;
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError(data['message']?.toString() ?? 'Sign up failed');
    }
    await persistToken(token);
    return token;
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<dynamic>('/auth/logout');
    } catch (_) {}
    _memory.setToken(null);
    await _prefs.clear();
  }

  @override
  Future<String?> readToken() async {
    final t = await _prefs.read();
    _memory.setToken(t);
    return t;
  }

  @override
  Future<void> persistToken(String token) async {
    _memory.setToken(token);
    await _prefs.write(token);
  }
}
