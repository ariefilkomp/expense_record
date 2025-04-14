import 'package:expense_record/features/expense/domain/entities/expense.dart';
import 'package:expense_record/features/expense/domain/repos/expense_repo.dart';
import 'package:expense_record/features/expense/presentation/cubits/expense_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseCubit extends Cubit<ExpenseStates> {
  final ExpenseRepo expenseRepo;
  final int limit;

  List<Expense> _expenses = [];
  bool _isFetching = false;

  ExpenseCubit({required this.expenseRepo, this.limit = 10})
    : super(ExpenseInitial());

  void addExpense(Expense expense) {
    try {
      expenseRepo.addExpense(expense);
      addExpenseOptimistically(expense);
    } catch (e) {
      print(e);
      emit(ExpenseError(message: e.toString()));
    }
  }

  get expenses => _expenses;

  void fetchExpenses({bool isFirstFetch = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (isFirstFetch) {
      expenseRepo.resetPagination();
      _expenses = [];
    }

    if (state is ExpenseInitial || state is ExpenseLoading) {
      emit(ExpenseLoading());
    }

    try {
      final newExpenses = await expenseRepo.fetchExpenses(limit: limit);
      final allExpenses = [..._expenses, ...newExpenses];

      _expenses = allExpenses;

      emit(
        ExpenseLoaded(
          expenses: allExpenses,
          hasReachedEnd: newExpenses.length < limit,
        ),
      );
    } catch (e) {
      emit(ExpenseError(message: 'Gagal mengambil data'));
    } finally {
      _isFetching = false;
    }
  }

  void addExpenseOptimistically(Expense expense) {
    if (state is ExpenseLoaded) {
      final currentExpenses = List<Expense>.from(
        (state as ExpenseLoaded).expenses,
      );
      currentExpenses.insert(0, expense); // masukkan ke atas

      emit(ExpenseLoaded(expenses: currentExpenses, hasReachedEnd: false));
    }
  }
}
