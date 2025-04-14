import 'package:expense_record/features/auth/domain/entities/app_user.dart';

abstract class AuthStates {}

class AuthInitial extends AuthStates {}

class AuthLoading extends AuthStates {}

class Authenticated extends AuthStates {
  final AppUser user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthStates {}

class AuthError extends AuthStates {
  final String message;
  AuthError(this.message);
}
