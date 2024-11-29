// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:math';
// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';
// import 'package:onnxruntime/onnxruntime.dart'; // for mapEquals
// import 'package:photos/tokenizer/ClipTokenizer.dart';
// import 'package:photos/Utils/VectorUtil.dart';


// class ORTTextViewModel extends ChangeNotifier {
//   late OrtSession session;
//   late Map<String, int> tokenizerVocab;
//   late Map<StringPair, int> tokenizerMerges;
//   final int tokenBOS = 49406; 
//   final int tokenEOS = 49407;
//   final RegExp queryFilter = RegExp(r'[^A-Za-z0-9 ]');
//   late ClipTokenizer tokenizer;
//   late Future<void> initialization;

//   ORTTextViewModel() {
//     initialization = _initializeSession();
//   }

//   Future<void> _initializeSession() async {
//     try {
//       final sessionOptions = OrtSessionOptions();
//       final byteData = await rootBundle.load('assets/nomic-1.5-text-model-quant.onnx');
//       final modelBytes = byteData.buffer.asUint8List();
//       session = await OrtSession.fromBuffer(modelBytes, sessionOptions);

//       tokenizerVocab = await _getVocab();
//       tokenizerMerges = await _getMerges();
      
//       tokenizer = ClipTokenizer(tokenizerVocab, tokenizerMerges);
//     } catch (e) {
//       print('Error initializing ORTTextViewModel: $e');
//       rethrow;
//     }
//   }

//   Future<Map<String, int>> _getVocab() async {
//     final String vocabData = await rootBundle.loadString('assets/vocab.json');
//     final Map<String, dynamic> jsonVocab = json.decode(vocabData);
//     return jsonVocab.map((key, value) => MapEntry(key.replaceAll("</w>", " "), value as int));
//   }

//   Future<Map<StringPair, int>> _getMerges() async {
//     final String mergesData = await rootBundle.loadString('assets/merges.txt');
//     final Map<StringPair, int> merges = {};
//     final lines = LineSplitter().convert(mergesData).skip(1);

//     for (var i = 0; i < lines.length; i++) {
//       final splitLine = lines.elementAt(i).split(' ');
//       final keyTuple = StringPair(splitLine[0], splitLine[1].replaceAll("</w>", " "));
//       merges[keyTuple] = i;
//     }
//     return merges;
//   }

//   Future<List<double>> getTextEmbedding(String text) async {
//   await initialization;

//   try {
//     // Clean and tokenize text
//     String textClean = text.replaceAll(queryFilter, "").toLowerCase();

//     // Encode text and adjust to 15 tokens (or the model's required input size)
//     List<int> tokens = tokenizer.encode(textClean);
//     tokens = (tokens + List.filled(15 - tokens.length, 0)).sublist(0, 15);

//     // Generate token_type_ids (same length as tokens) filled with zeros
//     List<int> tokenTypeIds = List.filled(15, 0);

//     // Convert to tensors with the expected input shape
//     final inputShape = [1, 15];
//     final inputIdsTensor = OrtValueTensor.createTensorWithDataList(Int64List.fromList(tokens), inputShape);
//     final tokenTypeIdsTensor = OrtValueTensor.createTensorWithDataList(Int64List.fromList(tokenTypeIds), inputShape);

//     // Prepare the input map with correct input names
//     final Map<String, OrtValue> inputMap = {
//       "input_ids": inputIdsTensor,
//       "token_type_ids": tokenTypeIdsTensor,
//     };

//     // Run session to get the embedding output
//     final runOptions = OrtRunOptions();
//     final output = session.run(runOptions, inputMap);
//     final rawOutput = (output.first?.value as List<List<List<double>>>).first.first;

//     final normalizedOutput = normalizeL2(rawOutput); 

//       return normalizedOutput;
//     } catch (e) {
//       print('Error in getTextEmbedding: $e');
//       // You might want to return a default embedding or rethrow the error
//       rethrow;
//     }
//   }

//   List<double> NormalizeL2(List<double> input) {
//     double sumSquares = input.fold(0.0, (sum, value) => sum + value * value);
//     double norm = sqrt(sumSquares);
//     return input.map((value) => value / norm).toList();
//   }
// }
