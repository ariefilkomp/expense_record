/*

Auth repository - Outlines the possible auth operations for this app

*/

import 'package:expense_record/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<void> logOut();
  Future<AppUser?> getCurrentUser();
  Future<AppUser?> loginAnonymously();
  Future<AppUser?> loginWithGoogle();
  Future<AppUser?> linkAnonymousWithGoogle();
}
