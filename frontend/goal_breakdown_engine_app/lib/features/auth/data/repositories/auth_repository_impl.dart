import 'package:dio/dio.dart';
import 'package:goal_breakdown_engine_app/features/auth/domain/entities/auth_session.dart';
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

  static AuthSession _sessionFromData(Map<String, dynamic> data, String token) {
    final payload = data['data'];
    final nested = payload is Map<String, dynamic> ? payload : null;

    String? pickName() {
      final u = data['user'];
      if (u is Map) {
        final n = u['name'] ?? u['displayName'] ?? u['fullName'];
        if (n != null) return n.toString();
      }
      if (nested != null) {
        final n = nested['name'] ?? nested['displayName'] ?? nested['fullName'];
        if (n != null) return n.toString();
      }
      final n = data['name'] ?? data['displayName'] ?? data['fullName'];
      return n?.toString();
    }

    String? pickEmail() {
      final u = data['user'];
      if (u is Map) {
        final e = u['email'];
        if (e != null) return e.toString();
      }
      if (nested != null) {
        final e = nested['email'];
        if (e != null) return e.toString();
      }
      final e = data['email'];
      return e?.toString();
    }

    return AuthSession(
      token: token,
      displayName: pickName(),
      email: pickEmail(),
    );
  }

  @override
  Future<AuthSession> login({
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
    final session = _sessionFromData(data, token);
    await persistToken(session.token);
    return session;
  }

  @override
  Future<AuthSession> signUp({
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
    var session = _sessionFromData(data, token);
    session = AuthSession(
      token: session.token,
      displayName: session.displayName ?? name,
      email: session.email ?? email,
    );
    await persistToken(session.token);
    return session;
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
