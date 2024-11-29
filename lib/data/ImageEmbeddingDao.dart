import 'package:sqflite/sqflite.dart';
import 'ImageEmbedding.dart';

class ImageEmbeddingDao {
  final Database db;

  ImageEmbeddingDao(this.db);

  // Insert new image embedding
  Future<int> insertImageEmbedding(ImageEmbedding embedding) async {
    try {
      return await db.insert(
        'image_embedding',
        embedding.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert image embedding: $e');
    }
  }

  // Get all image embeddings
  Future<List<ImageEmbedding>> getAllEmbeddings() async {
    try {
      final List<Map<String, dynamic>> maps = await db.query('image_embedding');
      return List.generate(maps.length, (i) {
        return ImageEmbedding.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to fetch image embeddings: $e');
    }
  }

  // Get a single embedding by ID
  Future<ImageEmbedding?> getImageEmbeddingById(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'image_embedding',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ImageEmbedding.fromMap(maps.first);
    }
    return null;
  }

  // Update an existing image embedding
  Future<void> updateImageEmbedding(ImageEmbedding embedding) async {
    try {
      await db.update(
        'image_embedding',
        embedding.toMap(),
        where: 'id = ?',
        whereArgs: [embedding.id],
      );
    } catch (e) {
      throw Exception('Failed to update image embedding: $e');
    }
  }

  // Delete an image embedding by ID
  Future<void> deleteImageEmbedding(int id) async {
    try {
      await db.delete(
        'image_embedding',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete image embedding: $e');
    }
  }
}
