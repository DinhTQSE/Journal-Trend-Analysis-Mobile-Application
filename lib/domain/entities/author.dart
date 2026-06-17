import 'package:equatable/equatable.dart';

class Author extends Equatable {
  final String id;
  final String displayName;
  final String orcid;

  const Author({
    required this.id,
    required this.displayName,
    required this.orcid,
  });

  @override
  List<Object?> get props => [id, displayName, orcid];
}
