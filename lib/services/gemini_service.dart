import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:skin_sense_ai/models/analysis_result.dart';

class GeminiService {
  //get key from .env
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static late GenerativeModel _model;

  static void initialize() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  static Future<Map<String, dynamic>> generateMedicalContent({
    required String diseaseType,
    required double confidence,
    required String severity,
  }) async {
    try {
      final prompt = _buildMedicalPrompt(diseaseType, confidence, severity);

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText != null) {
        // Parse the JSON response
        final cleanedResponse = _cleanJsonResponse(responseText);
        final Map<String, dynamic> content = jsonDecode(cleanedResponse);

        log('Gemini Response: $content');
        return content;
      } else {
        throw Exception('No response from Gemini API');
      }
    } catch (e) {
      log('Error generating medical content: $e');
      return _getFallbackContent(diseaseType, severity);
    }
  }

  static String _buildMedicalPrompt(
    String diseaseType,
    double confidence,
    String severity,
  ) {
    return '''
You are a knowledgeable dermatology AI assistant. Based on the following skin condition analysis, provide comprehensive medical guidance in JSON format.

ANALYSIS DETAILS:
- Detected Condition: $diseaseType
- Confidence Level: ${confidence.toStringAsFixed(1)}%
- Severity Assessment: $severity

INSTRUCTIONS:
1. Provide accurate, evidence-based medical information
2. Always emphasize the importance of professional medical consultation
3. Focus on general care and lifestyle recommendations
4. Do not provide specific medication dosages or prescriptions
5. Be empathetic and supportive while being medically accurate
6. Do not use emojis or special characters that may not render properly in PDFs

Please respond with a JSON object containing the following fields:

{
  "recommendations": [
    "List of 3-4 specific recommendations for this condition and keep it concise 1-2 lines each",
    "Include both general skincare and condition-specific advice",
    "Focus on evidence-based practices",
    "Include when to seek professional help"
  ],
  "treatmentTips": [
    "List of 3-4 practical treatment and care tips and keep it concise 1-2 lines each",
    "Include daily care routines",
    "Mention lifestyle modifications",
    "Include environmental considerations"
  ],
  "additionalInfo": {
    "aboutCondition": "Brief explanation of the detected condition (2-3 sentences)",
    "whenToSeekHelp": "Clear guidelines on when immediate medical attention is needed",
    "lifestyleFactors": "Key lifestyle factors that may affect this condition",
    "prognosis": "General outlook and what to expect with proper care"
  },
  "disclaimer": "Important medical disclaimer emphasizing this is not a substitute for professional medical advice"
}

Ensure all content is medically accurate, compassionate, and emphasizes the importance of professional dermatological care. Do not include any emojis or special Unicode characters.
''';
  }

  static String _cleanJsonResponse(String response) {
    // Remove markdown code blocks if present
    String cleaned = response.replaceAll('```json', '').replaceAll('```', '');

    // Find the JSON object
    int startIndex = cleaned.indexOf('{');
    int endIndex = cleaned.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return cleaned.substring(startIndex, endIndex + 1);
    }

    return cleaned.trim();
  }

  static Map<String, dynamic> _getFallbackContent(
    String diseaseType,
    String severity,
  ) {
    return {
      "recommendations": [
        "Keep the affected area clean and dry",
        "Use gentle, fragrance-free skincare products",
        "Avoid harsh soaps and detergents",
        "Apply moisturizer regularly to prevent dryness",
        "Protect skin from excessive sun exposure",
        "Consult a dermatologist for proper diagnosis and treatment",
        "Monitor the condition and track any changes",
        "Follow a healthy diet rich in vitamins and omega-3 fatty acids",
      ],
      "treatmentTips": [
        "Apply moisturizer while skin is still damp after bathing",
        "Take lukewarm baths or showers instead of hot ones",
        "Use soft, breathable fabrics like cotton",
        "Maintain good hygiene without over-washing",
        "Stay hydrated by drinking plenty of water",
        "Avoid picking or scratching affected areas",
        "Consider using a humidifier in dry environments",
        "Follow any prescribed treatment regimen consistently",
      ],
      "additionalInfo": {
        "aboutCondition":
            "The detected condition appears to be $diseaseType with $severity severity. This skin condition may require professional medical evaluation for proper diagnosis and treatment.",
        "whenToSeekHelp":
            "Seek immediate medical attention if symptoms worsen, spread rapidly, or if you experience fever, severe pain, or signs of infection.",
        "lifestyleFactors":
            "Stress, diet, environmental factors, and skincare routine can all impact skin condition. Maintaining a healthy lifestyle may help manage symptoms.",
        "prognosis":
            "With proper care and medical guidance, most skin conditions can be effectively managed. Early intervention often leads to better outcomes.",
      },
      "disclaimer":
          "This analysis is for informational purposes only and should not replace professional medical advice. Always consult with a qualified dermatologist for proper diagnosis and treatment.",
    };
  }

  static Future<String> generateChatResponse({
    required String message,
    AnalysisResult? currentAnalysis,
  }) async {
    try {
      String prompt =
          '''
You are a knowledgeable AI assistant specializing in dermatology and skin health. 
Provide helpful, accurate information while always emphasizing the importance of professional medical consultation. Give in short points and concise responses for better understanding.
User message: $message
''';

      if (currentAnalysis != null) {
        prompt +=
            '''

Current analysis context:
- Detected condition: ${currentAnalysis.diseaseType}
- Confidence: ${currentAnalysis.getConfidencePercentage()} 
- Severity: ${currentAnalysis.severity}
''';
      }

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          'I\'m sorry, I couldn\'t generate a response. Please try again.';
    } catch (e) {
      log('Error generating chat response: $e');
      return 'I\'m having trouble processing your request. Please try again.';
    }
  }
}
