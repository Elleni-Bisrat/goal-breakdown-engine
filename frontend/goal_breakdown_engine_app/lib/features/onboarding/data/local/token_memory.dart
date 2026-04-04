/// Holds the JWT in memory for synchronous Dio interceptor access.
class TokenMemory {
  String? _token;

  String? get token => _token;

  void setToken(String? value) => _token = value;
}
