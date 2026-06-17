import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_publications_trend.dart';
import 'analysis_event.dart';
import 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final GetPublicationsTrend getPublicationsTrend;

  AnalysisBloc({required this.getPublicationsTrend}) : super(AnalysisInitial()) {
    on<FetchAnalysisEvent>((event, emit) async {
      if (event.keyword.trim().isEmpty) {
        emit(AnalysisInitial());
        return;
      }

      emit(AnalysisLoading());

      try {
        final trendData = await getPublicationsTrend(event.keyword);
        emit(AnalysisSuccess(trendData: trendData, keyword: event.keyword));
      } catch (e) {
        emit(AnalysisFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
