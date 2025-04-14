import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_record/features/expense/domain/entities/expense.dart';
import 'package:expense_record/features/expense/domain/repos/expense_repo.dart';

class FirebaseExpenseRepo implements ExpenseRepo {
  final firestore = FirebaseFirestore.instance;

  @override
  Future<void> addExpense(Expense expense) async {
    try {
      await firestore.collection('expenses').add(expense.toJson());
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      firestore.collection('expenses').doc(expense.id).update(expense.toJson());
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    try {
      firestore.collection('expenses').doc(expense.id).delete();
    } catch (e) {
      print(e);
    }
  }

  @override
  Stream<List<Expense>> getExpenses() {
    return firestore.collection('expenses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromJson(doc.data())).toList();
    });
  }
}
