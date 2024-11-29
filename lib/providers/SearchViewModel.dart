import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'dart:math' as math;

class SearchViewModel extends ChangeNotifier {
  List<int> _searchResults = [];

  List<int> get searchResults => _searchResults;

  set searchResults(List<int> value) {
    _searchResults = value;
    developer
        .log('SearchResults updated. New length: ${_searchResults.length}');
    notifyListeners();
  }

  void sortByCosineDistance(Float32List textEmbedding,
      List<List<double>> embeddingsList, List<int> idxList) {
    if (embeddingsList.isEmpty || idxList.isEmpty) {
      developer.log('Error: embeddingsList or idxList is empty');
      notifyListeners();
      return;
    }

    List<MapEntry<int, double>> distances = [];
    for (int i = 0; i < embeddingsList.length; i++) {
      final embedding = embeddingsList[i];
      // Check if dimensions match
      if (embedding.length != textEmbedding.length) {
        developer.log(
            'Dimension mismatch: textEmbedding length is ${textEmbedding.length}, '
            'but embedding ${i} length is ${embedding.length}');
        continue; // Skip this embedding if dimensions don’t match
      }

      double distance =
          cosineSimilarity(textEmbedding, Float32List.fromList(embedding));
      distances.add(MapEntry(idxList[i], distance));
    }

    distances.sort((a, b) => b.value.compareTo(a.value));
    _searchResults = distances.map((e) => e.key).toList();
    developer
        .log('Sorted search results. New length: ${_searchResults.length}');
    notifyListeners();
  }

  double cosineSimilarity(Float32List a, Float32List b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have the same dimension');
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }
}
