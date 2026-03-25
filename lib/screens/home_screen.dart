import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import 'analyzing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  void _navigateToAnalysis(XFile media, bool isVideo) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyzingScreen(
          mediaFile: media,
          isVideo: isVideo,
        ),
      ),
    );
  }

  Future<void> _pickMedia(bool isVideo, ImageSource source) async {
    try {
      final XFile? media = isVideo 
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);
          
      if (media != null) {
        _navigateToAnalysis(media, isVideo);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking media: $e'),
          backgroundColor: AppTheme.americanRed,
        ),
      );
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: AppTheme.americanWhite.withOpacity(0.7),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Upload Media',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.baseBlue,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildModalAction(
                        icon: Icons.photo_library_rounded,
                        title: 'Choose Photo',
                        subtitle: 'From gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _pickMedia(false, ImageSource.gallery);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildModalAction(
                        icon: Icons.video_library_rounded,
                        title: 'Choose Video',
                        subtitle: 'From gallery (.mp4, .mov)',
                        onTap: () {
                          Navigator.pop(context);
                          _pickMedia(true, ImageSource.gallery);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildModalAction(
                        icon: Icons.camera_alt_rounded,
                        title: 'Take Photo',
                        subtitle: 'Use camera',
                        onTap: () {
                          Navigator.pop(context);
                          _pickMedia(false, ImageSource.camera);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalAction({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.baseBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.baseBlue, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: AppTheme.americanWhite.withOpacity(0.7),
            ),
          ),
        ),
        title: const Text('MINISTRY OF TRUTH'),
      ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.baseBlue.withOpacity(0.05),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    size: 100,
                    color: AppTheme.baseBlue,
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'Verify Digital\nAuthenticity',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Upload media to detect AI generation, deepfakes, and alterations using our Penta-Layer Forensic Defense Architecture.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textLight,
                    height: 1.6,
                  ),
                ),
                const Spacer(flex: 2),
                Center(
                  child: Hero(
                    tag: 'upload_button',
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.baseBlue.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Material(
                            color: AppTheme.baseBlue,
                            child: InkWell(
                              onTap: () => _showPickerOptions(context),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: const Icon(
                                  Icons.add_rounded,
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
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
