import 'dart:developer';

import '../models/analysis_result.dart';
import 'gemini_service.dart';

class ChatbotService {
  // Send message to chatbot and get response
  static Future<String> sendMessage(
    String message, {
    AnalysisResult? currentAnalysis,
  }) async {
    try {
      // Use Gemini for chatbot responses
      return await GeminiService.generateChatResponse(
        message: message,
        currentAnalysis: currentAnalysis,
      );
    } catch (e) {
      log('Error sending message to chatbot: $e');
      return 'I\'m having trouble processing your request. Please try again.';
    }
  }

  /* // Generate system prompt based on current analysis
  static String _getSystemPrompt(AnalysisResult? currentAnalysis) {
    String basePrompt = '''
You are a knowledgeable AI assistant specializing in dermatology and skin health. You provide helpful, accurate information about skin conditions, with a focus on psoriasis and other common skin diseases.

IMPORTANT GUIDELINES:
- Always emphasize that you are not a replacement for professional medical advice
- Encourage users to consult dermatologists for proper diagnosis and treatment
- Provide supportive, empathetic responses
- Focus on general skincare advice and lifestyle recommendations
- Never provide specific medication dosages or prescriptions
- Be encouraging and positive while being realistic about treatment expectations

You should help users understand:
- General information about skin conditions
- Skincare routines and best practices
- When to seek professional medical help
- Lifestyle factors that may affect skin health
- Treatment options that require medical supervision
''';

    if (currentAnalysis != null) {
      basePrompt +=
          '''

CURRENT ANALYSIS CONTEXT:
The user has just received an AI analysis of their skin image with the following results:
- Detected condition: ${currentAnalysis.diseaseType}
- Confidence level: ${currentAnalysis.getConfidencePercentage()}
- Severity assessment: ${currentAnalysis.severity}
- Analysis date: ${currentAnalysis.timestamp.toString().split(' ')[0]}

You can reference this analysis when answering questions and provide context-specific advice.
''';
    }

    return basePrompt;
  }*/
}
