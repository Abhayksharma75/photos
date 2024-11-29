import 'dart:convert';
import 'dart:ffi';

class ImageEmbedding {
  final int id;
  final List<double> embedding;
  final int date;

  ImageEmbedding({required this.id, required this.embedding, required this.date});

  // Convert a model to a Map for insertion into the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'embedding': jsonEncode(embedding),
      'date': date,
    };
  }

  // Create a model from a Map (for reading from the database)
  static ImageEmbedding fromMap(Map<String, dynamic> map) {
    return ImageEmbedding(
      id: map['id'],
      embedding: (jsonDecode(map['embedding']) as List<dynamic>)
          .map((e) => e as double)
          .toList(),
      date: map['date'],
    );
  }
}
