import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class VideoBackground extends StatefulWidget {
  final Widget child;
  final String? videoUrl; // Can be a local asset path or network URL

  const VideoBackground({
    Key? key,
    required this.child,
    this.videoUrl,
  }) : super(key: key);

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      if (widget.videoUrl!.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      } else {
        _controller = VideoPlayerController.asset(widget.videoUrl!);
      }

      _controller!.initialize().then((_) {
        _controller!.setLooping(true);
        _controller!.setVolume(0.0); // Muted background video
        _controller!.play();
        setState(() {
          _isVideoInitialized = true;
        });
      }).catchError((e) {
        print("Error initializing video: $e");
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fallback color
        Container(color: AppColors.background),
        
        // Video Layer
        if (_isVideoInitialized && _controller != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          )
        else
          // Placeholder for the "Diaexpressions" watermark if video fails or not provided
          Center(
            child: Opacity(
              opacity: 0.1,
              child: Text(
                'Blantons',
                style: TextStyle(
                    fontFamily: GoogleFonts.cormorantUpright().fontFamily,
                    fontSize: 80,
                    fontWeight: FontWeight.w100,
                    color: Colors.brown.shade200,
                 )
              ),
            ),
          ),
          
        // Content Layer
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}
