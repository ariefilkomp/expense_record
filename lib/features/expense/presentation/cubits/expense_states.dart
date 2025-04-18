import 'package:expense_record/features/expense/domain/entities/expense.dart';

abstract class ExpenseStates {}

class ExpenseLoading extends ExpenseStates {}

class ExpenseLoaded extends ExpenseStates {
  final List<Expense> expenses;
  final bool hasReachedEnd;
  ExpenseLoaded({required this.expenses, this.hasReachedEnd = false});
}

class ExpenseError extends ExpenseStates {
  final String message;
  ExpenseError({required this.message});
}

class ExpenseDeleted extends ExpenseStates {}

class ExpenseUpdated extends ExpenseStates {}

class ExpenseAdded extends ExpenseStates {}

class ExpenseInitial extends ExpenseStates {}
