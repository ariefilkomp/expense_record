import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_record/features/summary/domain/repos/summary_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseSummaryRepo implements SummaryRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Future<Map<String, double>?> fetchSummary(String summaryId) async {
    DocumentSnapshot snapshot =
        await firestore
            .collection('users')
            .doc(firebaseAuth.currentUser!.uid)
            .collection('summaries')
            .doc(summaryId)
            .get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<MapEntry<String, double>> entries =
          data.entries
              .map((e) => MapEntry(e.key, (e.value as num).toDouble()))
              .toList();
      Map<String, double> processedData = {
        for (var entry in entries) entry.key: entry.value,
      };

      return processedData;
    }

    return null;
  }
}
