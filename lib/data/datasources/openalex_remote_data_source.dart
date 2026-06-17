import '../../core/network/api_client.dart';
import '../models/publication_model.dart';

abstract class OpenAlexRemoteDataSource {
  Future<List<PublicationModel>> searchPublications(String keyword);
  Future<Map<int, int>> getPublicationsTrend(String keyword);
}

class OpenAlexRemoteDataSourceImpl implements OpenAlexRemoteDataSource {
  final ApiClient apiClient;

  OpenAlexRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PublicationModel>> searchPublications(String keyword) async {
    final response = await apiClient.get(
      '/works',
      queryParameters: {
        'filter': 'title_and_abstract.search:$keyword',
        'sort': 'cited_by_count:desc',
        'per_page': 50,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = response.data['results'] as List<dynamic>? ?? [];
      return results
          .map((json) => PublicationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to search publications');
    }
  }

  @override
  Future<Map<int, int>> getPublicationsTrend(String keyword) async {
    final response = await apiClient.get(
      '/works',
      queryParameters: {
        'filter': 'title_and_abstract.search:$keyword',
        'group_by': 'publication_year',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> groups = response.data['group_by'] as List<dynamic>? ?? [];
      final Map<int, int> trends = {};
      for (var group in groups) {
        final yearStr = group['key']?.toString();
        final count = group['count'] as int?;
        if (yearStr != null && count != null) {
          final year = int.tryParse(yearStr);
          if (year != null) {
            trends[year] = count;
          }
        }
      }
      return trends;
    } else {
      throw Exception('Failed to get publication trends');
    }
  }
}
