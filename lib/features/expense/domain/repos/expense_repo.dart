import 'package:expense_record/features/expense/domain/entities/expense.dart';

abstract class ExpenseRepo {
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(Expense expense);
  Stream<List<Expense>> getExpenses();
}
