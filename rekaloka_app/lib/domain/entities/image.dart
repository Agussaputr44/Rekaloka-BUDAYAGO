import 'package:equatable/equatable.dart';

class Image extends Equatable {
  final String? id;
  final String? description;
  final String url;

  const Image({
    this.id,
    this.description,
    required this.url,
  });

  @override
  List<Object?> get props => [id, url, description];
}