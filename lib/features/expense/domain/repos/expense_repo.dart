import 'package:expense_record/features/expense/domain/entities/expense.dart';

abstract class ExpenseRepo {
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(Expense expense);
  Future<List<Expense>> fetchExpenses({required int limit});
  void resetPagination();
  Future<void> fetchSummary(String summaryId);
}
