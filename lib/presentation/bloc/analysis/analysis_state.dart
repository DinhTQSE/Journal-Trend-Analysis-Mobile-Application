import 'package:equatable/equatable.dart';

abstract class AnalysisState extends Equatable {
  const AnalysisState();

  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}

class AnalysisLoading extends AnalysisState {}

class AnalysisSuccess extends AnalysisState {
  final Map<int, int> trendData;
  final String keyword;

  const AnalysisSuccess({required this.trendData, required this.keyword});

  @override
  List<Object?> get props => [trendData, keyword];
}

class AnalysisFailure extends AnalysisState {
  final String errorMessage;

  const AnalysisFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
