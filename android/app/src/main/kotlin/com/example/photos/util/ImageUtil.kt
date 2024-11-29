package com.example.photos.util

import android.graphics.Bitmap
import androidx.annotation.WorkerThread

// Constants
private const val BATCH_SIZE = 1
private const val PIXEL_SIZE = 3
private const val IMAGE_SIZE_X = 224
private const val IMAGE_SIZE_Y = 224

// Function for pre-processing the image
@WorkerThread
fun preProcess(bitmap: Bitmap): FloatArray {
    val imageData = FloatArray(BATCH_SIZE * PIXEL_SIZE * IMAGE_SIZE_X * IMAGE_SIZE_Y)
    val stride = IMAGE_SIZE_X * IMAGE_SIZE_Y

    val pixels = IntArray(IMAGE_SIZE_X * IMAGE_SIZE_Y)
    bitmap.getPixels(pixels, 0, IMAGE_SIZE_X, 0, 0, IMAGE_SIZE_X, IMAGE_SIZE_Y)

    for (i in 0 until IMAGE_SIZE_X) {
        for (j in 0 until IMAGE_SIZE_Y) {
            val idx = IMAGE_SIZE_Y * i + j
            val pixel = pixels[idx]
            val red = (pixel shr 16) and 0xFF
            val green = (pixel shr 8) and 0xFF
            val blue = pixel and 0xFF

            imageData[idx] = ((red / 255.0f - 0.48145467f) / 0.26862955f)
            imageData[idx + stride] = ((green / 255.0f - 0.4578275f) / 0.2613026f)
            imageData[idx + stride * 2] = ((blue / 255.0f - 0.40821072f) / 0.2757771f)
        }
    }

    return imageData
}
fun centerCrop(bitmap: Bitmap, imageSize: Int): Bitmap {
    val cropX = if (bitmap.width >= bitmap.height) (bitmap.width - bitmap.height) / 2 else 0
    val cropY = if (bitmap.height > bitmap.width) (bitmap.height - bitmap.width) / 2 else 0
    val cropSize = if (bitmap.width >= bitmap.height) bitmap.height else bitmap.width

    val croppedBitmap = Bitmap.createBitmap(
        bitmap,
        cropX,
        cropY,
        cropSize,
        cropSize
    )

    return Bitmap.createScaledBitmap(croppedBitmap, imageSize, imageSize, true)
}