package com.example.photos.data

class ImageEmbeddingRepository(private val imageEmbeddingDao: ImageEmbeddingDao) {
    suspend fun addImageEmbedding(imageEmbedding: ImageEmbedding) {
        imageEmbeddingDao.addImageEmbedding(imageEmbedding)
    }

    suspend fun getRecord(id: Long): ImageEmbedding {
        return imageEmbeddingDao.getRecord(id)
    }
}
