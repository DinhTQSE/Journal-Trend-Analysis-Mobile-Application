import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_publications_trend.dart';
import '../../../domain/usecases/get_top_keywords.dart';
import '../../../domain/usecases/get_top_authors.dart';
import 'analysis_event.dart';
import 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final GetPublicationsTrend getPublicationsTrend;
  final GetTopKeywords getTopKeywords;
  final GetTopAuthors getTopAuthors;

  AnalysisBloc({
    required this.getPublicationsTrend,
    required this.getTopKeywords,
    required this.getTopAuthors,
  }) : super(AnalysisInitial()) {
    on<FetchAnalysisEvent>((event, emit) async {
      if (event.keyword.trim().isEmpty) {
        emit(AnalysisInitial());
        return;
      }

      emit(AnalysisLoading());

      try {
        // Run all three aggregation queries concurrently
        final results = await Future.wait([
          getPublicationsTrend(event.keyword),
          getTopKeywords(event.keyword),
          getTopAuthors(event.keyword),
        ]);

        final trendData = results[0] as Map<int, int>;
        final topKeywords = results[1] as List<Map<String, dynamic>>;
        final topAuthors = results[2] as List<Map<String, dynamic>>;

        emit(AnalysisSuccess(
          trendData: trendData,
          topKeywords: topKeywords,
          topAuthors: topAuthors,
          keyword: event.keyword,
        ));
      } catch (e) {
        emit(AnalysisFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
