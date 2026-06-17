import 'package:equatable/equatable.dart';

class Journal extends Equatable {
  final String id;
  final String displayName;
  final String publisher;
  final String type;

  const Journal({
    required this.id,
    required this.displayName,
    required this.publisher,
    required this.type,
  });

  @override
  List<Object?> get props => [id, displayName, publisher, type];
}
