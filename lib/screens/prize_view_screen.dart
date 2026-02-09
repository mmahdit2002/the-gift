import 'dart:io';
import 'dart:ui'; // REQUIRED for ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:audioplayers/audioplayers.dart';
import 'package:my_love/widgets/toast_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:animate_do/animate_do.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart'; // <--- NEW LIBRARY

// Assuming these exist in your project
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/all_neccessery_widgets.dart';

// --- HELPER: SAVE TO GALLERY (FIXED) ---
Future<void> _saveAssetToGallery(BuildContext context, String assetPath, bool isVideo) async {
  try {
    // 1. Check Access
    bool hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      hasAccess = await Gal.requestAccess();
    }

    if (!hasAccess) {
      if (context.mounted) {
        ToastManager().showToast(context: context, message: "دسترسی به گالری داده نشد.", icon: Icons.lock_outline, backgroundColor: Colors.orange);
      }
      return;
    }

    // 2. Save
    if (isVideo) {
      // Load video bytes and write to temp file first
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/temp_video.mp4').create();
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Save using Gal
      await Gal.putVideo(file.path);
    } else {
      // Load image bytes
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      // Save using Gal
      await Gal.putImageBytes(bytes);
    }

    // 3. Success Feedback
    if (context.mounted) {
      ToastManager().showToast(context: context, message: "با موفقیت در گالری ذخیره شد!", icon: Icons.check_circle_outline, backgroundColor: Colors.green);
    }
  } catch (e) {
    debugPrint("Error saving: $e");
    if (context.mounted) {
      ToastManager().showToast(context: context, message: "خطا در ذخیره‌سازی", icon: Icons.error_outline, backgroundColor: Colors.red);
    }
  }
}

// --- MAIN SCREEN ---
class PrizeViewScreen extends StatelessWidget {
  final DayModel day;

  const PrizeViewScreen({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPink,
      body: Stack(
        children: [
          // 1. Dynamic Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.backgroundPink, Color(0xFFFFE6EE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),

          // 2. Animated Blob (Top Right)
          Positioned(
            top: -50,
            right: -50,
            child: SpinPerfect(
              duration: const Duration(seconds: 25),
              infinite: true,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.15), blurRadius: 60, spreadRadius: 10)],
                ),
              ),
            ),
          ),

          // 3. Animated Blob (Bottom Left)
          Positioned(
            bottom: 50,
            left: -30,
            child: FadeInUp(
              duration: const Duration(seconds: 4),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.1), blurRadius: 40, spreadRadius: 5)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeuButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 6.0),
                          child: Icon(Icons.arrow_back_ios, color: AppTheme.deepPink, size: 20),
                        ),
                      ),
                      Text(
                        "جایزه ی ${day.jalaliDate}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(width: 40), // Spacer
                    ],
                  ),
                ),

                // --- CONTENT ---
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ZoomIn(duration: const Duration(milliseconds: 600), child: _buildContent(day.prizeType, day.prizeContent)),
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

  Widget _buildContent(PrizeType type, String contentPath) {
    switch (type) {
      case PrizeType.voice:
        return VoiceMessagePlayer(assetPath: contentPath);
      case PrizeType.video:
        return VideoMessagePlayer(assetPath: contentPath);
      case PrizeType.image:
      case PrizeType.letter:
        return PhotoPrizeViewer(assetPath: contentPath);
    }
  }
}

// --- 1. GLASS VOICE PLAYER (Unchanged) ---
class VoiceMessagePlayer extends StatefulWidget {
  final String assetPath;
  const VoiceMessagePlayer({Key? key, required this.assetPath}) : super(key: key);

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  late AnimationController _spinController;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _player.setSource(AssetSource(widget.assetPath.replaceFirst('assets/', '')));

    _player.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (_isPlaying) {
          _spinController.repeat();
        } else {
          _spinController.stop();
        }
      });
    });

    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
  }

  @override
  void dispose() {
    _player.dispose();
    _spinController.dispose();
    super.dispose();
  }

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final Color topShadow = Colors.white;
    final Color bottomShadow = AppTheme.deepPink.withOpacity(0.15);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _spinController,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.backgroundPink,
                    boxShadow: [
                      BoxShadow(color: topShadow, offset: const Offset(-4, -4), blurRadius: 8),
                      BoxShadow(color: bottomShadow, offset: const Offset(4, 4), blurRadius: 8),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [AppTheme.primaryPink, AppTheme.deepPink]),
                      ),
                      child: const Icon(Icons.music_note_rounded, size: 50, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "A Special Note For You",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textDark),
              ),
              const SizedBox(height: 5),
              Text("Listen carefully...", style: TextStyle(color: AppTheme.textDark.withOpacity(0.6))),
              const SizedBox(height: 20),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: AppTheme.deepPink,
                  inactiveTrackColor: AppTheme.deepPink.withOpacity(0.2),
                  thumbColor: AppTheme.deepPink,
                ),
                child: Slider(
                  min: 0,
                  max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                  value: _position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    await _player.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatTime(_position), style: TextStyle(color: AppTheme.textDark.withOpacity(0.8))),
                    NeuButton(
                      onPressed: () {
                        _isPlaying ? _player.pause() : _player.resume();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.backgroundPink,
                          boxShadow: [
                            BoxShadow(color: topShadow, offset: const Offset(-2, -2), blurRadius: 4),
                            BoxShadow(color: bottomShadow, offset: const Offset(2, 2), blurRadius: 4),
                          ],
                        ),
                        child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppTheme.deepPink, size: 30),
                      ),
                    ),
                    Text(_formatTime(_duration), style: TextStyle(color: AppTheme.textDark.withOpacity(0.8))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. GLASS VIDEO PLAYER FRAME ---
class VideoMessagePlayer extends StatefulWidget {
  final String assetPath;
  const VideoMessagePlayer({Key? key, required this.assetPath}) : super(key: key);

  @override
  State<VideoMessagePlayer> createState() => _VideoMessagePlayerState();
}

class _VideoMessagePlayerState extends State<VideoMessagePlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullScreen() {
    _controller.pause();
    Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenVideoPage(assetPath: widget.assetPath))).then((_) => _controller.play());
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.deepPink));
    }

    // GLASS FRAME
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller),
                      _ControlsOverlay(controller: _controller),
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(playedColor: AppTheme.deepPink, backgroundColor: Colors.white24),
                        padding: const EdgeInsets.only(top: 10),
                      ),
                    ],
                  ),
                ),
              ),
              // --- TOOLBAR ---
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.fullscreen_rounded, color: AppTheme.deepPink, size: 30),
                      onPressed: _openFullScreen,
                      tooltip: "تمام صفحه",
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, color: AppTheme.deepPink, size: 28),
                      onPressed: () => _saveAssetToGallery(context, widget.assetPath, true),
                      tooltip: "ذخیره در گالری",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Stack(
        children: <Widget>[
          Container(color: Colors.transparent),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 50),
            reverseDuration: const Duration(milliseconds: 200),
            child: controller.value.isPlaying
                ? const SizedBox.shrink()
                : Container(
                    color: Colors.black26,
                    child: const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 80.0)),
                  ),
          ),
        ],
      ),
    );
  }
}

// --- 3. GLASS PHOTO VIEWER FRAME ---
class PhotoPrizeViewer extends StatelessWidget {
  final String assetPath;
  const PhotoPrizeViewer({Key? key, required this.assetPath}) : super(key: key);

  void _openFullScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenPhotoPage(assetPath: assetPath)));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3), // Glass Frame
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The Photo with Stack for Expansion
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: PhotoView(
                        imageProvider: AssetImage(assetPath),
                        backgroundDecoration: const BoxDecoration(color: Colors.white),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                      ),
                    ),
                    // Expand Button
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.fullscreen, color: AppTheme.deepPink),
                          onPressed: () => _openFullScreen(context),
                        ),
                      ),
                    ),
                    // Save Button
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.download, color: AppTheme.deepPink),
                          onPressed: () => _saveAssetToGallery(context, assetPath, false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Handwriting Font Text
              Text(
                "Captured Moment",
                style: TextStyle(fontFamily: 'Cursive', fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark.withOpacity(0.8)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 4. FULL SCREEN VIDEO PAGE ---
class FullScreenVideoPage extends StatefulWidget {
  final String assetPath;
  const FullScreenVideoPage({Key? key, required this.assetPath}) : super(key: key);

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: _controller.value.isInitialized ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)) : const CircularProgressIndicator(color: Colors.white),
          ),
          // Close Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Save Button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.white, size: 30),
              onPressed: () => _saveAssetToGallery(context, widget.assetPath, true),
            ),
          ),
          // Controls
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _controller.value.isInitialized
                ? VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(playedColor: AppTheme.deepPink, backgroundColor: Colors.white24),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.deepPink.withOpacity(0.8),
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
      ),
    );
  }
}

// --- 5. FULL SCREEN PHOTO PAGE ---
class FullScreenPhotoPage extends StatelessWidget {
  final String assetPath;
  const FullScreenPhotoPage({Key? key, required this.assetPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: AssetImage(assetPath),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            heroAttributes: PhotoViewHeroAttributes(tag: assetPath),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                onPressed: () => _saveAssetToGallery(context, assetPath, false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
