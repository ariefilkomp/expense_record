import 'package:expense_record/features/summary/domain/repos/summary_repo.dart';
import 'package:expense_record/features/summary/presentation/cubits/summary_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SummaryCubit extends Cubit<SummaryState> {
  final SummaryRepo summaryRepo;
  SummaryCubit({required this.summaryRepo}) : super(SummaryInitial());

  Future<void> fetchSummary(String summaryId) async {
    try {
      emit(SummaryLoading());
      final data = await summaryRepo.fetchSummary(summaryId);
      emit(SummaryLoaded(summaries: data));
    } catch (e) {
      emit(SummaryError(message: e.toString()));
    }
  }
}
