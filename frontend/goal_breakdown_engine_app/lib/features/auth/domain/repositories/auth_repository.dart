import 'package:goal_breakdown_engine_app/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<String?> readToken();

  Future<void> persistToken(String token);
}
