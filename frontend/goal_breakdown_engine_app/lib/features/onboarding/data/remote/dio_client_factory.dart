import 'package:dio/dio.dart';
import 'package:goal_breakdown_engine_app/core/config/api_config.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/data/local/token_memory.dart';

class DioClientFactory {
  DioClientFactory({required TokenMemory tokenMemory})
    : _tokenMemory = tokenMemory;

  final TokenMemory _tokenMemory;

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final t = _tokenMemory.token;
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          }
          handler.next(options);
        },
      ),
    );

    return dio;
  }
}
