import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'data/datasources/openalex_remote_data_source.dart';
import 'data/repositories/publication_repository_impl.dart';
import 'domain/repositories/publication_repository.dart';
import 'domain/usecases/get_analytics_summary.dart';
import 'domain/usecases/get_publications_trend.dart';
import 'domain/usecases/search_publications.dart';
import 'presentation/bloc/analysis/analysis_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/bloc/detail/detail_bloc.dart';
import 'presentation/bloc/search/search_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Blocs ---
  sl.registerFactory(() => SearchBloc(searchPublications: sl()));
  sl.registerFactory(() => DetailBloc());
  sl.registerFactory(() => AnalysisBloc(getPublicationsTrend: sl()));
  sl.registerFactory(() => DashboardBloc(getAnalyticsSummary: sl()));

  // --- Use Cases ---
  sl.registerLazySingleton(() => SearchPublications(sl()));
  sl.registerLazySingleton(() => GetPublicationsTrend(sl()));
  sl.registerLazySingleton(() => GetAnalyticsSummary(sl()));

  // --- Repositories ---
  sl.registerLazySingleton<PublicationRepository>(
    () => PublicationRepositoryImpl(
      remoteDataSource: sl(),
      apiClient: sl(),
    ),
  );

  // --- Data Sources ---
  sl.registerLazySingleton<OpenAlexRemoteDataSource>(
    () => OpenAlexRemoteDataSourceImpl(apiClient: sl()),
  );

  // --- Core / External ---
  final apiClient = await ApiClient.create();
  sl.registerLazySingleton(() => apiClient);
}
