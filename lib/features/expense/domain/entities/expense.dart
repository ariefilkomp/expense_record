import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String uid;
  final String title;
  final double amount;
  final DateTime timestamp;
  final String category;

  Expense({
    required this.id,
    required this.uid,
    required this.title,
    required this.amount,
    required this.timestamp,
    required this.category,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      uid: json['uid'],
      title: json['title'],
      amount: json['amount'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'category': category,
    };
  }
}
