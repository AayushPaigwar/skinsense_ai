import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/analysis_result.dart';
import 'gemini_service.dart';

class SkinAnalysisService {
  // Base URL for the skin analysis API from env
  static String get _baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get _apiUrl => '$_baseUrl/predict';
  static const String _historyKey = 'analysis_history';
  static const Uuid _uuid = Uuid();

  // Analyze skin image using the API
  static Future<AnalysisResult?> analyzeSkinImage(Uint8List imageBytes) async {
    try {
      // Save image locally first
      final String imagePath = await _saveImageLocally(imageBytes);

      // Prepare multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'skin_image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseData);

        // Parse API response and map disease type
        final String rawDiseaseType = jsonResponse['full_name'] ?? 'Unknown';
        final String diseaseType = rawDiseaseType;
        final double confidence = (jsonResponse['confidence'] ?? 0.0)
            .toDouble();

        log('API Response: $jsonResponse');
        log('Mapped Disease Type: $diseaseType');

        // Generate severity

        if (confidence > 85.0) {
          final String severity = _determineSeverity(confidence);

          // Generate content using Gemini AI
          final Map<String, dynamic> geminiContent =
              await GeminiService.generateMedicalContent(
                diseaseType: diseaseType,
                confidence: confidence,
                severity: severity,
              );

          // Extract content from Gemini response
          final List<String> recommendations = List<String>.from(
            geminiContent['recommendations'] ?? [],
          );
          final List<String> treatmentTips = List<String>.from(
            geminiContent['treatmentTips'] ?? [],
          );
          final Map<String, dynamic>? additionalInfo =
              geminiContent['additionalInfo'];
          final String? disclaimer = geminiContent['disclaimer'];

          // Create analysis result
          final analysisResult = AnalysisResult(
            id: _uuid.v4(),
            imagePath: imagePath,
            diseaseType: diseaseType,
            confidence: confidence,
            severity: severity,
            recommendations: recommendations,
            timestamp: DateTime.now(),
            treatmentTips: treatmentTips,
            additionalInfo: additionalInfo,
            disclaimer: disclaimer,
          );

          // Save to history
          await _saveToHistory(analysisResult);

          log('Analysis Result: ${analysisResult.toJsonString()}');

          return analysisResult;
        }
      } else {
        log('API Error: ${response.statusCode} - $responseData');
        return null;
      }
    } catch (e) {
      log('Error analyzing skin image: $e');
      return null;
    }
    return null;
  }

  // Save image locally
  static Future<String> _saveImageLocally(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/skin_images';
    final imageDir = Directory(imagePath);

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final fileName = 'skin_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('$imagePath/$fileName');
    await file.writeAsBytes(imageBytes);

    return file.path;
  }

  // Determine severity based on confidence
  static String _determineSeverity(double confidence) {
    if (confidence >= 0.8) {
      return 'Severe';
    } else if (confidence >= 0.6) {
      return 'Moderate';
    } else {
      return 'Mild';
    }
  }

  // Save analysis result to history
  static Future<void> _saveToHistory(AnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    // Add new result to beginning of list
    history.insert(0, result.toJsonString());

    // Limit history to 50 items
    if (history.length > 50) {
      history = history.sublist(0, 50);
    }

    await prefs.setStringList(_historyKey, history);
  }

  // Get analysis history
  static Future<List<AnalysisResult>> getAnalysisHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    return history
        .map((jsonString) => AnalysisResult.fromJsonString(jsonString))
        .toList();
  }

  // Delete analysis from history
  static Future<void> deleteAnalysis(String analysisId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    history.removeWhere((jsonString) {
      final result = AnalysisResult.fromJsonString(jsonString);
      return result.id == analysisId;
    });

    await prefs.setStringList(_historyKey, history);
  }

  // Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
