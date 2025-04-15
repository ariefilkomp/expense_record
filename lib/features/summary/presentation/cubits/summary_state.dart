abstract class SummaryState {}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class SummaryLoaded extends SummaryState {
  final Map<String, double>? summaries;
  SummaryLoaded({required this.summaries});
}

class SummaryError extends SummaryState {
  final String message;
  SummaryError({required this.message});
}
