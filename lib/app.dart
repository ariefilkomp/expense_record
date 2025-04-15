import 'package:expense_record/features/auth/data/firebase_auth_repo.dart';
import 'package:expense_record/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:expense_record/features/auth/presentation/cubits/auth_states.dart';
import 'package:expense_record/features/auth/presentation/pages/login_page.dart';
import 'package:expense_record/features/expense/data/firebase_expense_repo.dart';
import 'package:expense_record/features/expense/presentation/cubits/expense_cubit.dart';
import 'package:expense_record/features/home/presentation/pages/home_page.dart';
import 'package:expense_record/features/summary/data/firebase_summary_repo.dart';
import 'package:expense_record/features/summary/presentation/cubits/summary_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepo = FirebaseAuthRepo();
  final firebaseExpenseRepo = FirebaseExpenseRepo();
  final firebaseSummaryRepo = FirebaseSummaryRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),

        BlocProvider(
          create: (context) => ExpenseCubit(expenseRepo: firebaseExpenseRepo),
        ),

        BlocProvider(
          create: (context) => SummaryCubit(summaryRepo: firebaseSummaryRepo),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocConsumer<AuthCubit, AuthStates>(
          builder: (context, state) {
            if (state is Unauthenticated) {
              return const LoginPage();
            }

            if (state is Authenticated) {
              return const HomePage();
            }

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
          listener: (context, state) => {},
        ),
      ),
    );
  }
}
