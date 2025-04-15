abstract class SummaryRepo {
  Future<Map<String, double>?> fetchSummary(String summaryId);
}
