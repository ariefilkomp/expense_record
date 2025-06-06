import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_record/features/expense/domain/entities/expense.dart';
import 'package:expense_record/features/expense/domain/repos/expense_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:intl/intl.dart' show DateFormat;

class FirebaseExpenseRepo implements ExpenseRepo {
  final firestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;
  DocumentSnapshot? lastDoc;

  @override
  Future<void> addExpense(Expense expense) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final formattedMonth = DateFormat('yyyyMM').format(expense.timestamp);

      final expenseRef = firestore
          .collection('users')
          .doc(expense.uid)
          .collection('expenses')
          .doc(expense.id);

      final summaryRef = firestore
          .collection('users')
          .doc(expense.uid)
          .collection('summaries')
          .doc(formattedMonth);

      final snakeCaseCategory = expense.category
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(RegExp(r'\s+'), '_');

      await firestore.runTransaction((transaction) async {
        // Ambil summary bulan tersebut
        final summarySnapshot = await transaction.get(summaryRef);

        Map<String, dynamic> updatedSummary = {};

        if (summarySnapshot.exists) {
          final currentData = summarySnapshot.data() as Map<String, dynamic>;
          final currentValue = (currentData[snakeCaseCategory] ?? 0) as num;

          updatedSummary = {
            ...currentData,
            snakeCaseCategory: currentValue + expense.amount,
          };
        } else {
          updatedSummary = {snakeCaseCategory: expense.amount};
        }

        // Simpan expense baru
        transaction.set(expenseRef, expense.toJson());
        transaction.set(summaryRef, updatedSummary);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Gagal menambahkan expense: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      String formattedMonth = DateFormat('yyyyMM').format(expense.timestamp);
      String snakeCaseCategory = expense.category
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(RegExp(r'\s+'), '_');

      // read data lama
      DocumentSnapshot docOld =
          await firestore
              .collection('users')
              .doc(expense.uid)
              .collection('expenses')
              .doc(expense.id)
              .get();

      Expense expenseOld = Expense.fromJson(
        docOld.data() as Map<String, dynamic>,
      );

      // update summary
      DocumentSnapshot summaries =
          await firestore
              .collection('users')
              .doc(expense.uid)
              .collection('summaries')
              .doc(formattedMonth)
              .get();

      if (summaries.exists) {
        Map<String, dynamic> data = summaries.data() as Map<String, dynamic>;
        data[snakeCaseCategory] -= expenseOld.amount;
        data[snakeCaseCategory] += expense.amount;
        firestore
            .collection('users')
            .doc(expense.uid)
            .collection('summaries')
            .doc(formattedMonth)
            .update(data);
      }

      firestore
          .collection('users')
          .doc(expense.uid)
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toJson());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    try {
      // update summary
      String formattedMonth = DateFormat('yyyyMM').format(expense.timestamp);
      String snakeCaseCategory = expense.category
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(RegExp(r'\s+'), '_');

      DocumentSnapshot summaries =
          await firestore
              .collection('users')
              .doc(expense.uid)
              .collection('summaries')
              .doc(formattedMonth)
              .get();

      DocumentSnapshot docOld =
          await firestore
              .collection('users')
              .doc(expense.uid)
              .collection('expenses')
              .doc(expense.id)
              .get();

      Expense expenseOld = Expense.fromJson(
        docOld.data() as Map<String, dynamic>,
      );

      if (summaries.exists) {
        Map<String, dynamic> data = summaries.data() as Map<String, dynamic>;
        data[snakeCaseCategory] -= expenseOld.amount;
        firestore
            .collection('users')
            .doc(expense.uid)
            .collection('summaries')
            .doc(formattedMonth)
            .update(data);
      }

      firestore
          .collection('users')
          .doc(expense.uid)
          .collection('expenses')
          .doc(expense.id)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Future<List<Expense>> fetchExpenses({int limit = 10}) async {
    Query query = firestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('expenses')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc!);
    }

    QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
    }

    return snapshot.docs
        .map(
          (doc) =>
              Expense.fromFirestore(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  @override
  void resetPagination() {
    lastDoc = null;
  }
}
