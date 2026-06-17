import '../entities/publication.dart';
import '../entities/analytics_summary.dart';

abstract class PublicationRepository {
  /// Searches for publications by a keyword topic.
  Future<List<Publication>> searchPublications(String keyword);

  /// Retrieves trend data of publication count per year for a keyword.
  Future<Map<int, int>> getPublicationsTrend(String keyword);

  /// Retrieves a summary dashboard analytics object for a keyword.
  Future<AnalyticsSummary> getAnalyticsSummary(String keyword);
}
