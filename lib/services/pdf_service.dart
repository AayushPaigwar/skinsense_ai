import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/analysis_result.dart';

class PDFService {
  // Professional color palette
  static const PdfColor primaryBlue = PdfColor.fromInt(0xFF2563EB);
  static const PdfColor accentTeal = PdfColor.fromInt(0xFF0891B2);
  static const PdfColor lightBlue = PdfColor.fromInt(0xFFDEF3FF);
  static const PdfColor successGreen = PdfColor.fromInt(0xFF16A34A);
  static const PdfColor warningAmber = PdfColor.fromInt(0xFFF59E0B);
  static const PdfColor dangerRed = PdfColor.fromInt(0xFFDC2626);
  static const PdfColor lightGray = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor mediumGray = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor darkGray = PdfColor.fromInt(0xFF64748B);
  static const PdfColor textBlack = PdfColor.fromInt(0xFF1E293B);

  // Generate single-page PDF report
  static Future<Uint8List> generateAnalysisReport(
    AnalysisResult analysis,
  ) async {
    final pdf = pw.Document(
      title: 'SkinSense AI - Skin Analysis Report',
      author: 'SkinSense AI',
      creator: 'SkinSense AI Application',
      subject: 'Dermatological Analysis Report',
      keywords: 'skin analysis, dermatology, ai, medical report',
    );

    // Load image from file path
    Uint8List? imageBytes;
    try {
      final imageFile = File(analysis.imagePath);
      if (await imageFile.exists()) {
        imageBytes = await imageFile.readAsBytes();
      }
    } catch (e) {
      print('Error loading image for PDF: $e');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(),

              pw.SizedBox(height: 15),

              // Report Information Bar
              _buildReportInfo(analysis),

              pw.SizedBox(height: 15),

              // Main Content Area
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Column - Image and Analysis Summary
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Image Section
                          if (imageBytes != null)
                            _buildImageSection(imageBytes),

                          pw.SizedBox(height: 12),

                          // Analysis Summary
                          _buildAnalysisSummary(analysis),
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 15),

                    // Right Column - Details and Recommendations
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Key Findings
                          _buildKeyFindings(analysis),

                          pw.SizedBox(height: 12),

                          // Recommendations
                          _buildRecommendations(analysis),

                          pw.SizedBox(height: 12),

                          // Treatment Tips
                          _buildTreatmentTips(analysis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // Footer with Disclaimer
              _buildFooterWithDisclaimer(analysis),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  // Professional header with clean design
  static pw.Widget _buildHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [primaryBlue, accentTeal],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SkinSense AI',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                'Advanced Dermatological Analysis',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              'ANALYSIS REPORT',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: primaryBlue,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Report information bar
  static pw.Widget _buildReportInfo(AnalysisResult analysis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: lightGray,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: mediumGray),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem(
            'Report Date',
            DateTime.now().toString().split(' ')[0],
          ),
          _buildInfoItem(
            'Analysis Date',
            analysis.timestamp.toString().split(' ')[0],
          ),
          _buildInfoItem(
            'Report ID',
            analysis.timestamp.millisecondsSinceEpoch.toString().substring(7),
          ),
          _buildInfoItem('Type', 'Skin Analysis'),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, color: darkGray)),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: textBlack,
          ),
        ),
      ],
    );
  }

  // Image section with professional styling
  static pw.Widget _buildImageSection(Uint8List imageBytes) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Analyzed Image',
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: textBlack,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 180,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: mediumGray),
          ),
          child: pw.ClipRRect(
            verticalRadius: 8,
            horizontalRadius: 8,
            child: pw.Image(pw.MemoryImage(imageBytes), fit: pw.BoxFit.cover),
          ),
        ),
      ],
    );
  }

  // Analysis summary with key metrics
  static pw.Widget _buildAnalysisSummary(AnalysisResult analysis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: lightBlue,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: accentTeal),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Analysis Summary',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: textBlack,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Condition:',
                    style: pw.TextStyle(fontSize: 9, color: darkGray),
                  ),
                  pw.Text(
                    analysis.diseaseType,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: textBlack,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Confidence:',
                    style: pw.TextStyle(fontSize: 9, color: darkGray),
                  ),
                  pw.Text(
                    analysis.getConfidencePercentage(),
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: successGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text(
                'Severity:',
                style: pw.TextStyle(fontSize: 9, color: darkGray),
              ),
              pw.SizedBox(width: 5),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: pw.BoxDecoration(
                  color: _getSeverityColor(analysis.severity),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  analysis.severity,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Key findings section
  static pw.Widget _buildKeyFindings(AnalysisResult analysis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: mediumGray),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Key Findings',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: textBlack,
            ),
          ),
          pw.SizedBox(height: 8),
          if (analysis.additionalInfo != null) ...[
            _buildFindingItem(
              'About Condition',
              analysis.additionalInfo!['aboutCondition'] ?? 'Not available',
            ),
            pw.SizedBox(height: 6),
            _buildFindingItem(
              'When to Seek Help',
              analysis.additionalInfo!['whenToSeekHelp'] ?? 'Not available',
            ),
          ] else ...[
            pw.Text(
              'Detailed analysis information not available.',
              style: pw.TextStyle(fontSize: 10, color: darkGray),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildFindingItem(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          content.length > 150 ? '${content.substring(0, 150)}...' : content,
          style: pw.TextStyle(fontSize: 9, color: textBlack, height: 1.3),
        ),
      ],
    );
  }

  // Recommendations section
  static pw.Widget _buildRecommendations(AnalysisResult analysis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF0FDF4),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: successGreen),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Recommendations',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: textBlack,
            ),
          ),
          pw.SizedBox(height: 8),
          ...analysis.recommendations
              .take(4)
              .map(
                (recommendation) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 4,
                        height: 4,
                        margin: const pw.EdgeInsets.only(top: 4, right: 6),
                        decoration: pw.BoxDecoration(
                          color: successGreen,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          recommendation,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: textBlack,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // Treatment tips section
  static pw.Widget _buildTreatmentTips(AnalysisResult analysis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFEF3C7),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: warningAmber),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Treatment & Care Tips',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: textBlack,
            ),
          ),
          pw.SizedBox(height: 8),
          ...analysis.treatmentTips
              .take(4)
              .map(
                (tip) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 4,
                        height: 4,
                        margin: const pw.EdgeInsets.only(top: 4, right: 6),
                        decoration: pw.BoxDecoration(
                          color: warningAmber,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          tip,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: textBlack,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // Footer with disclaimer
  static pw.Widget _buildFooterWithDisclaimer(AnalysisResult analysis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFEF2F2),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: dangerRed),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 20,
            height: 20,
            decoration: pw.BoxDecoration(
              color: dangerRed,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                '!',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Medical Disclaimer',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: dangerRed,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  analysis.disclaimer ??
                      'This analysis is for informational purposes only and should not replace professional medical advice. Consult a qualified dermatologist for proper diagnosis and treatment.',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: textBlack,
                    height: 1.3,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Generated by SkinSense AI',
                  style: pw.TextStyle(fontSize: 8, color: darkGray),
                ),
                pw.SizedBox(height: 4),
                pw.UrlLink(
                  destination: 'http://skinsense-ai.vercel.app/',
                  child: pw.Text(
                    'Visit SkinSense AI Website',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: primaryBlue,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to get severity color
  static PdfColor _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
      case 'mild':
        return successGreen;
      case 'medium':
      case 'moderate':
        return warningAmber;
      case 'high':
      case 'severe':
        return dangerRed;
      default:
        return darkGray;
    }
  }

  // Save and share PDF
  static Future<void> shareAnalysisReport(AnalysisResult analysis) async {
    try {
      final Uint8List pdfBytes = await generateAnalysisReport(analysis);

      final directory = await getTemporaryDirectory();
      final fileName =
          'SkinSense_Analysis_${analysis.diseaseType.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'SkinSense AI - Professional Skin Analysis Report for ${analysis.diseaseType}',
        subject: 'SkinSense AI - Skin Analysis Report',
      );
    } catch (e) {
      log('Error sharing PDF: $e');
      throw Exception('Failed to generate and share PDF report: $e');
    }
  }
}
