import 'ImageEmbedding.dart';
import 'ImageEmbeddingDao.dart';

class ImageEmbeddingRepository {
  final ImageEmbeddingDao _imageEmbeddingDao;

  ImageEmbeddingRepository(this._imageEmbeddingDao);

  /// Add a new image embedding to the database.
  Future<void> addImageEmbedding(ImageEmbedding imageEmbedding) async {
    await _imageEmbeddingDao.insertImageEmbedding(imageEmbedding);
  }

  /// Retrieve a list of all image embeddings from the database.
  Future<List<ImageEmbedding>> getAllEmbeddings() async {
    return await _imageEmbeddingDao.getAllEmbeddings();
  }

  /// Get a single image embedding by its ID.
  Future<ImageEmbedding?> getRecord(int id) async {
    final record = await _imageEmbeddingDao.getImageEmbeddingById(id);
    if (record == null) {
      return null;
      // throw Exception('No record found for id $id');
    }
    return record;
  }

  /// Update an existing image embedding.
  Future<void> updateImageEmbedding(ImageEmbedding imageEmbedding) async {
    await _imageEmbeddingDao.updateImageEmbedding(imageEmbedding);
  }

  /// Delete an image embedding by its ID.
  Future<void> deleteImageEmbedding(int id) async {
    await _imageEmbeddingDao.deleteImageEmbedding(id);
  }
  
}
