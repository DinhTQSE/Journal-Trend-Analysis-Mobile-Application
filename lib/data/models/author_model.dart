import '../../domain/entities/author.dart';

class AuthorModel extends Author {
  const AuthorModel({
    required super.id,
    required super.displayName,
    required super.orcid,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    // OpenAlex authorships structure returns map with 'author' key
    final authorMap = json['author'] as Map<String, dynamic>? ?? json;
    
    return AuthorModel(
      id: authorMap['id']?.toString() ?? '',
      displayName: authorMap['display_name']?.toString() ?? 'Unknown Author',
      orcid: authorMap['orcid']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'orcid': orcid,
    };
  }
}
