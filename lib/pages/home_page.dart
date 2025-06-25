import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../image_upload.dart';
import '../models/analysis_result.dart';
import '../services/skin_analysis_service.dart';
import '../widgets/chatbot_widget.dart';
import 'analysis_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<AnalysisResult> recentAnalyses = [];
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade-in animation for the home page
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Load recent analyses and start the animation
    _loadRecentAnalyses();
    _animationController.forward(); // Start the fade-in animation
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Load recent analyses from history
  Future<void> _loadRecentAnalyses() async {
    final history = await SkinAnalysisService.getAnalysisHistory();
    setState(() {
      recentAnalyses = history.take(3).toList();
    });
  }

  // Handle image selection from camera or gallery
  Future<void> _handleImageSelection(bool fromCamera) async {
    setState(() {
      isLoading = true;
    });

    try {
      final Uint8List? imageBytes = fromCamera
          ? await ImageUploadHelper.captureImage()
          : await ImageUploadHelper.pickImageFromGallery();

      if (imageBytes != null) {
        // Validate image bytes before sending to API
        if (!ImageUploadHelper.isValidImageBytes(imageBytes)) {
          _showErrorSnackBar(
            'Invalid image format. Please select a valid image file.',
          );
          return;
        }

        // Check image size (should be reasonable for API)
        if (imageBytes.length > 10 * 1024 * 1024) {
          // 10MB limit
          _showErrorSnackBar(
            'Image file is too large. Please select a smaller image.',
          );
          return;
        }

        final AnalysisResult? result =
            await SkinAnalysisService.analyzeSkinImage(imageBytes);

        if (result != null && mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisPage(analysisResult: result),
            ),
          );
          _loadRecentAnalyses(); // Refresh recent analyses
        } else if (mounted) {
          _showErrorSnackBar(
            'Failed to analyze image. Please ensure the image shows skin clearly and try again.',
          );
        }
      } else {
        _showErrorSnackBar('No image selected. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error processing image: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Show error snackbar with message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show chatbot in a modal bottom sheet
  void _showChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatbotWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: _buildHeader(),
                  ),
                  const SizedBox(height: 22),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: _buildActionButtons(),
                  ),

                  // Recent Analyses Section
                  if (recentAnalyses.isNotEmpty) ...[
                    _buildRecentAnalysesSection(),
                    const SizedBox(height: 24),
                  ],

                  // Info Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: _buildInfoCards(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showChatbot,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        icon: const Icon(Icons.chat),
        label: const Text('Ask AI'),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Title and Subtitle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title and Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detect Psoriasis',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-Powered Skin Analysis',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),

            // History Button
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
              icon: Icon(
                Icons.history,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Analyzing your skin image...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  title: 'Take Photo',
                  subtitle: 'Use camera to capture',
                  icon: Icons.camera_alt,
                  onTap: () => _handleImageSelection(true),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  title: 'Upload Photo',
                  subtitle: 'Select from gallery',
                  icon: Icons.photo_library,
                  onTap: () => _handleImageSelection(false),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnalysesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Analyses',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPage(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentAnalyses.length,
            itemBuilder: (context, index) {
              final analysis = recentAnalyses[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: 12.0,
                  left: index == 0
                      ? 20.0
                      : 0.0, // Add left padding only for the first item
                ),
                child: InkWell(
                  radius: 12,

                  borderRadius: BorderRadius.circular(12),
                  splashColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  highlightColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  focusColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AnalysisPage(analysisResult: analysis),
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: analysis.severity == 'Severe'
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : analysis.severity == 'Moderate'
                                    ? Colors.orange.withValues(alpha: 0.1)
                                    : Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.medical_information,
                                size: 16,
                                color: analysis.severity == 'Severe'
                                    ? Colors.red
                                    : analysis.severity == 'Moderate'
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                analysis.diseaseType,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Confidence: ${analysis.getConfidencePercentage()}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${analysis.timestamp.day.toString().padLeft(2, '0')}-${analysis.timestamp.month.toString().padLeft(2, '0')}-${analysis.timestamp.year}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildInfoCard(
          title: 'AI-Powered Analysis',
          description:
              'Advanced machine learning algorithms analyze your skin images for accurate detection.',
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Expert AI Assistant',
          description:
              'Get personalized advice and answers to your skin health questions from our AI chatbot.',
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Detailed Reports',
          description:
              'Generate comprehensive PDF reports with analysis results and treatment recommendations.',
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
