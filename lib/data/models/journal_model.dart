import '../../domain/entities/journal.dart';

class JournalModel extends Journal {
  const JournalModel({
    required super.id,
    required super.displayName,
    required super.publisher,
    required super.type,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    final sourceMap = json['source'] as Map<String, dynamic>? ?? json;
    
    return JournalModel(
      id: sourceMap['id']?.toString() ?? '',
      displayName: sourceMap['display_name']?.toString() ?? 'Unknown Source',
      publisher: sourceMap['publisher']?.toString() ?? 'Unknown Publisher',
      type: sourceMap['type']?.toString() ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'publisher': publisher,
      'type': type,
    };
  }
}
