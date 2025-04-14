import 'package:expense_record/app.dart';
import 'package:expense_record/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  runApp(MyApp());
}
