/*

Auth cubit state management

*/

import 'package:expense_record/features/auth/domain/entities/app_user.dart';
import 'package:expense_record/features/auth/domain/repos/auth_repo.dart';
import 'package:expense_record/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthStates> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  // check user if already authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  //get current user
  AppUser? get currentUser => _currentUser;

  Future<void> logOut() async {
    await authRepo.logOut();
    emit(Unauthenticated());
  }

  Future<void> loginAnonymously() async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginAnonymously();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithGoogle();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> linkAnonymousWithGoogle() async {
    try {
      emit(AuthLoading());
      final user = await authRepo.linkAnonymousWithGoogle();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
}
