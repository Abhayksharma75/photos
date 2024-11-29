package com.example.photos.model

import com.example.photos.R
import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import android.annotation.SuppressLint
import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.photos.util.centerCrop
import com.example.photos.data.ImageEmbedding
import com.example.photos.data.ImageEmbeddingDatabase
import com.example.photos.data.ImageEmbeddingRepository
import com.example.photos.util.normalizeL2
import com.example.photos.util.preProcess
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.nio.FloatBuffer
import java.util.*
import kotlin.collections.ArrayList


class ORTImageViewModel(applicationcontext : Context) : ViewModel() {
    @SuppressLint("StaticFieldLeak")
    var context: Context = applicationcontext
    private var ortEnv: OrtEnvironment = OrtEnvironment.getEnvironment()
    private lateinit var repository: ImageEmbeddingRepository
    private lateinit var contentResolver: ContentResolver
    private var idxList: ArrayList<Long> = arrayListOf()
    private var embeddingsList: ArrayList<FloatArray> = arrayListOf()
    var progress: MutableLiveData<Double> = MutableLiveData(0.0)

    fun init(flutterEngine: FlutterEngine) {
        val imageEmbeddingDao = ImageEmbeddingDatabase.getDatabase(context).imageEmbeddingDao()
        repository = ImageEmbeddingRepository(imageEmbeddingDao)
        contentResolver = context.contentResolver

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ort_image_channel"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "generateIndex" -> {
                    val directories = call.argument<List<String>>("directories")
                    if (directories != null) {
                        generateIndex(directories) { currentProgress ->
                            MethodChannel(
                                flutterEngine.dartExecutor.binaryMessenger,
                                "ort_image_channel"
                            ).invokeMethod("progressUpdate", currentProgress)
                        }
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Invalid arguments", null)
                    }
                }

                "getIdxList" -> {
                    result.success(idxList)
                }

                "getEmbeddingsList" -> {
                    result.success(embeddingsList)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun generateIndex(directories: List<String>, progressCallback: (Double) -> Unit) {
        val modelID = R.raw.visual_quant
        val resources = context.resources
        val model = resources?.openRawResource(modelID)?.readBytes()
        val session = ortEnv.createSession(model)

        viewModelScope.launch(Dispatchers.Main) {
            progress.value = 0.0

            val totalImages = getTotalImages(directories)
            var processedImages = 0

            for (directory in directories) {
                val uri: Uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                val projection = arrayOf(
                    MediaStore.Images.Media._ID,
                    MediaStore.Images.Media.DATE_MODIFIED,
                    MediaStore.Images.Media.BUCKET_DISPLAY_NAME
                )
                val selection = "${MediaStore.Images.Media.BUCKET_DISPLAY_NAME} = ?"
                val selectionArgs = arrayOf(directory)
                val sortOrder = "${MediaStore.Images.Media._ID} ASC"

                val cursor: Cursor? = contentResolver.query(
                    uri,
                    projection,
                    selection,
                    selectionArgs,
                    sortOrder
                )

                cursor?.use {
                    val idColumn: Int = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
                    val dateColumn: Int =it.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_MODIFIED)
                    val bucketColumn: Int =it.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)
                    while (it.moveToNext()) {
                        val id: Long = it.getLong(idColumn)
                        val date: Long = it.getLong(dateColumn)
                        val bucket: String = it.getString(bucketColumn)

                        val record = repository.getRecord(id) as ImageEmbedding?
                        if (record != null) {
                            idxList.add(record.id)
                            embeddingsList.add(record.embedding)
                        } else {
                            val imageUri: Uri = Uri.withAppendedPath(uri, id.toString())
                            val inputStream = contentResolver.openInputStream(imageUri)
                            val bytes = inputStream?.readBytes()
                            inputStream?.close()

                            // Can fail to create the image decoder if its not implemented for the image type
                            val bitmap: Bitmap? =
                                BitmapFactory.decodeByteArray(bytes, 0, bytes?.size ?: 0)
                            bitmap?.let {
                                val rawBitmap = centerCrop(bitmap, 224)
                                val inputShape = longArrayOf(1, 3, 224, 224)
                                val inputName = session.inputNames.first()
                                val imgData = preProcess(rawBitmap)
                                val inputTensor =OnnxTensor.createTensor(ortEnv, FloatBuffer.wrap(imgData), inputShape)

                                inputTensor.use {
                                    val output =session?.run(Collections.singletonMap(inputName, inputTensor))
                                    output.use {
                                        var rawOutput = ((output?.get(0)?.value) as Array<Array<FloatArray>>)[0][0]
                                        rawOutput = normalizeL2(rawOutput)
                                        repository.addImageEmbedding(
                                            ImageEmbedding(
                                                id, date, rawOutput
                                            )
                                        )


                                        idxList.add(id)
                                        embeddingsList.add(rawOutput)

                                    }
                                }
                            }
                        }
                        // Record created/loaded, update progress
                        processedImages++
                        val currentProgress = processedImages.toDouble() / totalImages.toDouble()
                        progress.value = currentProgress
                        progressCallback(currentProgress)
                    }
                }
                cursor?.close()
            }

            session.close()
            progress.value = 1.0
            progressCallback(1.0)
        }
    }

    private fun getTotalImages(directories: List<String>): Int {
        var totalImages = 0
        for (directory in directories) {
            val uri: Uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            val projection = arrayOf(
                MediaStore.Images.Media._ID
            )
            val selection = "${MediaStore.Images.Media.BUCKET_DISPLAY_NAME} = ?"
            val selectionArgs = arrayOf(directory)
            val sortOrder = "${MediaStore.Images.Media._ID} ASC"

            val cursor: Cursor? = contentResolver.query(
                uri,
                projection,
                selection,
                selectionArgs,
                sortOrder
            )
            totalImages += cursor?.count ?: 0
            cursor?.close()
        }
        return totalImages
    }
}