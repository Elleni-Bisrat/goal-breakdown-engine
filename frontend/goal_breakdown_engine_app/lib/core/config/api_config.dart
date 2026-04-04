/// Override at build time: `--dart-define=API_BASE_URL=http://10.0.2.2:5000`
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5000',
  );

  static const String apiPrefix = '/api';
}
