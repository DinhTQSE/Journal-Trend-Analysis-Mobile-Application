import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/publication.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/journal.dart';
import '../../domain/repositories/publication_repository.dart';
import '../datasources/openalex_remote_data_source.dart';
import '../models/publication_model.dart';
import '../../core/network/api_client.dart';

class PublicationRepositoryImpl implements PublicationRepository {
  final OpenAlexRemoteDataSource remoteDataSource;
  final ApiClient apiClient; // For direct meta count checks if needed

  PublicationRepositoryImpl({
    required this.remoteDataSource,
    required this.apiClient,
  });

  @override
  Future<List<Publication>> searchPublications(String keyword) async {
    try {
      final models = await remoteDataSource.searchPublications(keyword);
      return models;
    } catch (e) {
      throw Exception('Search publications failed: $e');
    }
  }

  @override
  Future<Map<int, int>> getPublicationsTrend(String keyword) async {
    try {
      return await remoteDataSource.getPublicationsTrend(keyword);
    } catch (e) {
      throw Exception('Get publication trends failed: $e');
    }
  }

  @override
  Future<AnalyticsSummary> getAnalyticsSummary(String keyword) async {
    try {
      // 1. Fetch works sorted by citations
      final response = await apiClient.get(
        '/works',
        queryParameters: {
          'filter': 'title_and_abstract.search:$keyword',
          'sort': 'cited_by_count:desc',
          'per_page': 50,
        },
      );

      int totalPublications = 0;
      List<PublicationModel> publications = [];

      if (response.statusCode == 200) {
        totalPublications = response.data['meta']?['count'] as int? ?? 0;
        final List<dynamic> results = response.data['results'] as List<dynamic>? ?? [];
        publications = results
            .map((json) => PublicationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // 2. Fetch trends to find peak publication year
      final trends = await remoteDataSource.getPublicationsTrend(keyword);
      int peakYear = 0;
      int maxCount = -1;
      trends.forEach((year, count) {
        if (count > maxCount) {
          maxCount = count;
          peakYear = year;
        }
      });

      if (publications.isEmpty) {
        return AnalyticsSummary(
          totalPublications: totalPublications,
          averageCitations: 0,
          peakYear: peakYear,
        );
      }

      // 3. Compute average citation count of the fetched publications
      double sumCitations = 0;
      for (var pub in publications) {
        sumCitations += pub.citedByCount;
      }
      final averageCitations = sumCitations / publications.length;

      // 4. Top Paper is the most cited one (first in the desc-sorted list)
      final topPaper = publications.first;

      // 5. Aggregate to find Top Author
      final Map<Author, int> authorCounts = {};
      for (var pub in publications) {
        for (var author in pub.authors) {
          authorCounts[author] = (authorCounts[author] ?? 0) + 1;
        }
      }
      Author? topAuthor;
      int maxAuthorCount = -1;
      authorCounts.forEach((author, count) {
        if (count > maxAuthorCount) {
          maxAuthorCount = count;
          topAuthor = author;
        }
      });

      // 6. Aggregate to find Top Journal
      final Map<Journal, int> journalCounts = {};
      for (var pub in publications) {
        if (pub.journal != null) {
          final journal = pub.journal!;
          journalCounts[journal] = (journalCounts[journal] ?? 0) + 1;
        }
      }
      Journal? topJournal;
      int maxJournalCount = -1;
      journalCounts.forEach((journal, count) {
        if (count > maxJournalCount) {
          maxJournalCount = count;
          topJournal = journal;
        }
      });

      return AnalyticsSummary(
        totalPublications: totalPublications,
        averageCitations: double.parse(averageCitations.toStringAsFixed(2)),
        peakYear: peakYear,
        topPaper: topPaper,
        topAuthor: topAuthor,
        topJournal: topJournal,
      );
    } catch (e) {
      throw Exception('Get analytics summary failed: $e');
    }
  }
}
