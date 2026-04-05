/// Override at build time: `--dart-define=API_BASE_URL=http://10.0.2.2:5000`
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://goal-breakdown-engine.onrender.com',
  );

  static const String apiPrefix = '/api';
}
