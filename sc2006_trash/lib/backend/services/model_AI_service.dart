// Purpose: Handles fetching tensor flow model from assets folder

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ModelAIService {
  static late Interpreter interpreter;
  static List<String> labels = [];

  static Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/model/model.tflite');
      labels = await _loadLabels('assets/model/labels.txt');
    } catch (e) {
      interpreter = throw Exception("Model failed to load");
    }
  }

  static Future<List<String>> _loadLabels(String path) async {
    final raw = await rootBundle.loadString(path);
    return LineSplitter.split(raw).toList();
  }
}
