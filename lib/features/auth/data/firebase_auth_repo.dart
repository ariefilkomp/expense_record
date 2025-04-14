import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_record/features/auth/domain/entities/app_user.dart';
import 'package:expense_record/features/auth/domain/repos/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  Future<AppUser?> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      // fetch user document from firestore
      DocumentSnapshot userDoc =
          await firebaseFirestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
      // save user data in firestore
      return AppUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: getValue<String>(userDoc, 'name', ''),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    return null;
  }

  @override
  Future<AppUser?> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      // save user data in firestore
      await firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .set(user.toJson());

      return user;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    return null;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      isAnonymous: firebaseUser.isAnonymous,
    );
  }

  @override
  Future<void> logOut() async {
    await firebaseAuth.signOut();
  }

  T getValue<T>(DocumentSnapshot doc, String key, T defaultValue) {
    if (doc.data().toString().contains(key) && doc.get(key) != null) {
      var value = doc.get(key);
      if (T == DateTime && value is Timestamp) {
        return value.toDate() as T;
      }
      return value as T;
    }
    return defaultValue;
  }

  @override
  Future<AppUser?> loginAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      return AppUser(
        uid: userCredential.user!.uid,
        email: 'anonim@gmail.com',
        name: 'anonim',
        isAnonymous: true,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
    return null;
  }

  @override
  Future<AppUser?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      return AppUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName ?? '',
        photoUrl: userCredential.user!.photoURL ?? '',
        isAnonymous: userCredential.user!.isAnonymous,
      );
    } catch (e) {
      print('================== ERRORR ===================');
      print(e);
    }
    return null;
  }

  @override
  Future<AppUser?> linkAnonymousWithGoogle() async {
    try {
      // 1. Sign in with Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("Login Google dibatalkan oleh user.");
        return null;
      }

      // 2. Simpan data dari akun Google
      final String googleName = googleUser.displayName ?? '';
      final String googleEmail = googleUser.email;
      final String googlePhotoUrl = googleUser.photoUrl ?? '';

      // 3. Ambil authentication token
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Link akun anonymous dengan Google
      final UserCredential userCredential = await FirebaseAuth
          .instance
          .currentUser!
          .linkWithCredential(credential);

      // 5. Update profile Firebase user dengan info dari Google
      await userCredential.user!.updateDisplayName(googleName);
      await userCredential.user!.updatePhotoURL(googlePhotoUrl);

      // 6. Return AppUser dengan data lengkap
      return AppUser(
        uid: userCredential.user!.uid,
        email: googleEmail,
        name: googleName,
        photoUrl: googlePhotoUrl,
        isAnonymous: userCredential.user!.isAnonymous,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        print("Akun Google ini sudah digunakan di akun lain.");
      } else if (e.code == 'provider-already-linked') {
        print("Akun sudah terhubung dengan Google sebelumnya.");
      } else {
        print("Error saat link akun: ${e.message}");
      }
      return null;
    } catch (e) {
      print("Error umum: $e");
      return null;
    }
  }
}
