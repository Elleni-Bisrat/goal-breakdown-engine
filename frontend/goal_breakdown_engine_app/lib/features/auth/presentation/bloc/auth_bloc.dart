import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:goal_breakdown_engine_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthSignUpSubmitted>(_onSignUp);
    on<AuthLogoutPressed>(_onLogout);
  }

  final AuthRepository _authRepository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final token = await _authRepository.readToken();
    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated(token: token));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final session = await _authRepository.login(
        email: event.email.trim(),
        password: event.password,
      );
      emit(
        AuthAuthenticated(
          token: session.token,
          displayName: session.displayName,
          email: session.email ?? event.email.trim(),
        ),
      );
    } on DioException catch (e) {
      emit(AuthFailure(_messageFromDio(e)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final session = await _authRepository.signUp(
        name: event.name.trim(),
        email: event.email.trim(),
        password: event.password,
      );
      emit(
        AuthAuthenticated(
          token: session.token,
          displayName: session.displayName ?? event.name.trim(),
          email: session.email ?? event.email.trim(),
        ),
      );
    } on DioException catch (e) {
      emit(AuthFailure(_messageFromDio(e)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  static String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? 'Network error';
  }
}
