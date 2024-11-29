// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;
// import 'package:onnxruntime/onnxruntime.dart';
// import 'package:flutter/material.dart';
// import 'package:photos/data/ImageEmbedding.dart';
// import 'package:photos/data/ImageEmbeddingDatabase.dart';
// import 'package:photos/data/ImageEmbeddingRepository.dart';
// import 'package:photos/Utils/ImageUtil.dart';
// import 'package:photos/service/imageservice.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:photos/Utils/VectorUtil.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:ui' as ui;
// import 'dart:developer' as developer;

// class ORTImageViewModel extends ChangeNotifier {
//   late OrtSession session;
//   late ImageEmbeddingRepository repository;
//   late List<AssetEntity> images;
//   List<int> idxList = [];
//   List<List<double>> embeddingsList = [];
//   late List<AssetEntity> _images;
//   ValueNotifier<double> progress = ValueNotifier(0.0);
//   List<AssetEntity> get imageList => _images;

//   ORTImageViewModel() {
//     OrtEnv.instance.init();
//     _initializeSession().then((_) => loadSavedIndexesFromDatabase());
//   }

//   Future<void> loadSavedIndexesFromDatabase() async {
//     final allEmbeddings = await repository.getAllEmbeddings();
//     idxList = allEmbeddings.map((e) => e.id).toList();
//     embeddingsList = allEmbeddings.map((e) => e.embedding).toList();
//   }

//   Future<void> _initializeSession() async {
//     try {
//       final modelID = 'assets/nomic-1.5-vision-model-quant.onnx';
//       final byteData = await rootBundle.load(modelID);
//       final modelBytes = byteData.buffer.asUint8List();
//       final sessionOptions = OrtSessionOptions();
//       session = OrtSession.fromBuffer(modelBytes, sessionOptions);
//       final imageEmbeddingDatabase = ImageEmbeddingDatabase();
//       final imageEmbeddingDao = await imageEmbeddingDatabase.database.then((db) => imageEmbeddingDatabase.imageEmbeddingDao);
//       repository = ImageEmbeddingRepository(imageEmbeddingDao);
//     } catch (e) {
//       print('Error initializing session: $e');
//     }
//   }

//   // Future<void> generateIndex(AssetEntity image) async {
//   //   try {
//   //     if (idxList.contains(int.parse(image.id))) return;

//   //     final imageDetails = image;
//   //     final id = int.parse(imageDetails.id);
//   //     final date = imageDetails.createDateTime;

//   //     if (imageDetails.type == AssetType.image) {
//   //       try {
//   //         final record = await repository.getRecord(id);
//   //         if (record != null) {
//   //           // idxList.add(record.id);
//   //           // embeddingsList.add(record.embedding);
//   //           return;
//   //         } else {
//   //           final newId = await processImage(imageDetails, id, date);
//   //           if (newId != null) {
//   //             idxList.add(newId);
//   //           }
//   //         }
//   //       } catch (e) {
//   //         print('Error processing id $id: $e');
//   //       }
//   //     }

//   //     notifyListeners();
//   //   } catch (e) {
//   //     print('Error in generateIndex: $e');
//   //   }
//   // }

//   Future<void> generateIndex(AssetEntity image) async {
//     if (idxList.contains(int.parse(image.id))) return;

//     try {
//       final imageDetails = image;
//       final id = int.parse(imageDetails.id);
//       final date = imageDetails.createDateTime;

//       if (imageDetails.type == AssetType.image) {
//         final record = await repository.getRecord(id);
//         if (record != null) {
//           return;
//         } else {
//           // Move processing to an isolate for concurrent processing.
//           final newId =
//               await compute(_processImageInIsolate, [imageDetails, id, date]);
//           if (newId != null) {
//             idxList.add(newId);
//           }
//         }
//       }

//       notifyListeners();
//     } catch (e) {
//       print('Error in generateIndex: $e');
//     }
//   }

//   Future<int?> _processImageInIsolate(List<dynamic> params) async {
//     final AssetEntity imageDetails = params[0];
//     final int id = params[1];
//     final DateTime date = params[2];

//     return await processImage(imageDetails, id, date);
//   }

//   Future<int?> processImage(
//       AssetEntity imageDetails, int id, DateTime date) async {
//     try {
//       final file = await imageDetails.file;
//       if (file == null) {
//         developer.log('File is null for id $id');
//         return null;
//       }

//       final filePath = file.path;
//       developer.log('Processing file: $filePath');

//       if (!await File(filePath).exists()) {
//         developer.log('File does not exist for id $id: $filePath');
//         return null;
//       }

//       final bytes = await File(filePath).readAsBytes();
//       developer.log('Bytes length: ${bytes.length}');

//       ui.Image? decodedImage;
//       try {
//         decodedImage = await decodeImageFromList(bytes);
//         developer.log('Decoded image: ${decodedImage.width}x${decodedImage.height}');
//       } catch (e) {
//         developer.log('Failed to decode image for id $id: $e',
//         error: e, stackTrace: StackTrace.current);
//         return null;
//       }

//       if (decodedImage == null) {
//         developer.log('Failed to decode image for id $id: decodedImage is null');
//         return null;
//       }

//       final imgImage = await _convertUiImageToImgImage(decodedImage);
//       developer.log('Img image: ${imgImage.width}x${imgImage.height}');

//       ui.Image? rawBitmap;
//       try {
//         rawBitmap = await centerCrop(imgImage, 224);
//         developer.log('Raw bitmap: ${rawBitmap.width}x${rawBitmap.height}');
//       } catch (e) {
//         developer.log('Error in centerCrop for id $id: $e',
//         error: e, stackTrace: StackTrace.current);
//         return null;
//       }

//       if (rawBitmap == null) {
//         developer.log('Failed to center crop image for id $id: rawBitmap is null');
//         return null;
//       }

//       final imgData = await preProcess(rawBitmap);
//       developer.log('Img data length: ${imgData.length}');

//       final inputShape = [1, 3, 224, 224];
//       final inputTensor = OrtValueTensor.createTensorWithDataList(imgData, inputShape);
//       final runOptions = OrtRunOptions();
//       final output = await session.runAsync(runOptions, {session.inputNames.first: inputTensor});
//       final rawOutput =(output?.first?.value as List<List<List<double>>>).first.first;

//       final normalizedOutput = normalizeL2(rawOutput);

//       final dateTimestamp = date.millisecondsSinceEpoch;
//       await repository.addImageEmbedding(ImageEmbedding(id: id, embedding: normalizedOutput, date: dateTimestamp));
//       embeddingsList.add(normalizedOutput);

//       print('Processed image for id $id');
//       return id;
//     } catch (e) {
//       developer.log('Error in processImage for id $id: $e',
//       error: e, stackTrace: StackTrace.current);
//       return null;
//     }
//   }

//   Future<img.Image> _convertUiImageToImgImage(ui.Image uiImage) async {
//     final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
//     return img.Image.fromBytes(
//       width: uiImage.width,
//       height: uiImage.height,
//       bytes: byteData!.buffer,
//       numChannels: 4,
//     );
//   }

//   Future<void> loadImages() async {
//     _images = await ImageService.getAssetsFromSelectedDirectories();
//     notifyListeners();
//   }
// }
