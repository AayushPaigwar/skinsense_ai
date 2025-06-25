import 'dart:convert';

class AnalysisResult {
  final String id;
  final String imagePath;
  final String diseaseType;
  final double confidence;
  final String severity;
  final List<String> recommendations;
  final DateTime timestamp;
  final List<String> treatmentTips;
  final Map<String, dynamic>? additionalInfo;
  final String? disclaimer;

  AnalysisResult({
    required this.id,
    required this.imagePath,
    required this.diseaseType,
    required this.confidence,
    required this.severity,
    required this.recommendations,
    required this.timestamp,
    required this.treatmentTips,
    this.additionalInfo,
    this.disclaimer,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'diseaseType': diseaseType,
      'confidence': confidence,
      'severity': severity,
      'recommendations': recommendations,
      'timestamp': timestamp.toIso8601String(),
      'treatmentTips': treatmentTips,
      'additionalInfo': additionalInfo,
      'disclaimer': disclaimer,
    };
  }

  // Create from JSON
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'],
      imagePath: json['imagePath'],
      diseaseType: json['diseaseType'],
      confidence: json['confidence'].toDouble(),
      severity: json['severity'],
      recommendations: List<String>.from(json['recommendations']),
      timestamp: DateTime.parse(json['timestamp']),
      treatmentTips: List<String>.from(json['treatmentTips']),
      additionalInfo: json['additionalInfo'],
      disclaimer: json['disclaimer'],
    );
  }

  // Convert to JSON string for shared_preferences
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  static AnalysisResult fromJsonString(String jsonString) {
    return AnalysisResult.fromJson(jsonDecode(jsonString));
  }

  // Get user-friendly confidence percentage
  String getConfidencePercentage() {
    return '${confidence.toStringAsFixed(1)}%';
  }
}
