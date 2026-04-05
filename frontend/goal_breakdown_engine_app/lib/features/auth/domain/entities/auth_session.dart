import 'package:equatable/equatable.dart';

/// Result of login/sign-up. Optional name/email are parsed when the API returns them.
class AuthSession extends Equatable {
  const AuthSession({
    required this.token,
    this.displayName,
    this.email,
  });

  final String token;
  final String? displayName;
  final String? email;

  @override
  List<Object?> get props => [token, displayName, email];
}
