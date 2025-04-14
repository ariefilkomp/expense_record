import 'package:expense_record/features/expense/domain/entities/expense.dart';
import 'package:expense_record/features/expense/domain/repos/expense_repo.dart';
import 'package:expense_record/features/expense/presentation/cubits/expense_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseCubit extends Cubit<ExpenseStates> {
  final ExpenseRepo expenseRepo;
  ExpenseCubit({required this.expenseRepo}) : super(ExpenseInitial());

  void addExpense(Expense expense) {
    try {
      emit(ExpenseLoading());
      expenseRepo.addExpense(expense).then((value) => emit(ExpenseAdded()));
    } catch (e) {
      print(e);
      emit(ExpenseError(message: e.toString()));
    }
  }
}
