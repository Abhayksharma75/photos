import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:developer' as developer;

// Constants
const int dimBatchSize = 1;
const int dimPixelSize = 3;
const int imageSizeX = 224;
const int imageSizeY = 224;

// Function for pre-processing the image
Future<dynamic> preProcess(ui.Image bitmap) async {
  print("preprocess starting");
  final imgData = Float32List(dimBatchSize * dimPixelSize * imageSizeX * imageSizeY);
  final stride = imageSizeX * imageSizeY;
  
  final byteData = await bitmap.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) {
    throw ArgumentError('Bitmap byte data is null.');
  }

  for (int i = 0; i < imageSizeX; i++) {
    for (int j = 0; j < imageSizeY; j++) {
      final idx = imageSizeY * i + j;
      final pixelIndex = (idx * 4);
      final red = byteData.getUint8(pixelIndex);
      final green = byteData.getUint8(pixelIndex + 1);
      final blue = byteData.getUint8(pixelIndex + 2);
      
      imgData[idx] = ((red / 255.0 - 0.48145467) / 0.26862955);
      imgData[idx + stride] = ((green / 255.0 - 0.4578275) / 0.2613026);
      imgData[idx + stride * 2] = ((blue / 255.0 - 0.40821072) / 0.2757771);
    }
  }
  
  return imgData;
}

// Function for center cropping the image
Future<ui.Image> centerCrop(img.Image bitmap, int imageSize) async {
  try {
    final cropX = bitmap.width >= bitmap.height ? (bitmap.width - bitmap.height) ~/ 2 : 0;
    final cropY = bitmap.height > bitmap.width ? (bitmap.height - bitmap.width) ~/ 2 : 0;
    final cropSize = bitmap.width >= bitmap.height ? bitmap.height : bitmap.width;

    developer.log('Original image size: ${bitmap.width}x${bitmap.height}');
    developer.log('Crop parameters: x=$cropX, y=$cropY, size=$cropSize');

    final croppedImage = img.copyCrop(bitmap, x: cropX, y: cropY, width: cropSize, height: cropSize);
    final resizedImage = img.copyResize(croppedImage, width: imageSize, height: imageSize);

    developer.log('Resized image size: ${resizedImage.width}x${resizedImage.height}');

    final bytes = resizedImage.getBytes();
    developer.log('Resized image bytes length: ${bytes.length}');

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      Uint8List.fromList(bytes),
      resizedImage.width,
      resizedImage.height,
      ui.PixelFormat.rgba8888,
      (ui.Image result) {
        completer.complete(result);
      },
    );
    
    return completer.future;
  } catch (e) {
    developer.log('Error in centerCrop: $e', error: e, stackTrace: StackTrace.current);
    rethrow;
  }
}