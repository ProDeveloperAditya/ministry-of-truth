import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final XFile mediaFile;
  final bool isVideo;

  const AnalyzingScreen({
    super.key,
    required this.mediaFile,
    this.isVideo = false,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _currentStep = 'Uploading to Server...';
  
  // Simulated steps for UI feedback while waiting for API
  final List<String> _analysisSteps = [
    'Layer 1: Checking Cryptographic Provenance (C2PA)...',
    'Layer 2: Extracting Deep Learning Fingerprints...',
    'Layer 3: Performing Spectral FFT Analysis...',
    'Layer 4: Running Physics & ELA Sensor Analysis...',
    'Layer 5: YCbCr Chrominance Disconnect Scan...',
    'Aggregating 5-Layer Results via Reasoning Engine...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _startAnalysis();
    _cycleStatusMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cycleStatusMessages() async {
    for (String step in _analysisSteps) {
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _currentStep = step;
        });
      }
    }
  }

  Future<void> _startAnalysis() async {
    try {
      final ApiService apiService = ApiService();
      final result = await apiService.analyzeMedia(widget.mediaFile);
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imageFile: widget.mediaFile,
            resultData: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis Failed: $e'),
          backgroundColor: AppTheme.americanRed,
          duration: const Duration(seconds: 5),
        ),
      );
      Navigator.pop(context); // Go back to Home
    }
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
              AppTheme.americanWhite,
              const Color(0xFFF1F5F9),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'upload_button',
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _controller.value * 2 * 3.14159,
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.baseBlue.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Material(
                              color: AppTheme.baseBlue,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: const Icon(
                                  Icons.sync_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Analyzing Metadata\n& Pixel Forensics',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.baseBlue,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.baseBlue),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _currentStep,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
