package com.example.photos.data


import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.TypeConverters

@Entity(tableName = "image_embeddings")
@TypeConverters(Converters::class)
data class ImageEmbedding(
    @PrimaryKey(autoGenerate = false)
    val id: Long,
    val date: Long,
    val embedding: FloatArray
)