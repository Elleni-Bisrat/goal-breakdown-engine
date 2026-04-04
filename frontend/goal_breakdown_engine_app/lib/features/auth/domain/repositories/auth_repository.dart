abstract class AuthRepository {
  Future<String> login({required String email, required String password});

  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<String?> readToken();

  Future<void> persistToken(String token);
}
