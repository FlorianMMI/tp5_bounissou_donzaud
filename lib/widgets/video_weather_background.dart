import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Fond vidéo qui change en fonction de la météo et de l'heure
class VideoWeatherBackground extends StatefulWidget {
  final Widget child;
  final int cloudCover; // Couverture nuageuse (0-100%)
  final double precipitation; // Précipitations en mm
  final double temperature; // Température en °C
  final DateTime? localTime; // Heure locale de la ville

  const VideoWeatherBackground({
    super.key,
    required this.child,
    this.cloudCover = 50,
    this.precipitation = 0,
    this.temperature = 15,
    this.localTime,
  });

  @override
  State<VideoWeatherBackground> createState() => _VideoWeatherBackgroundState();
}

class _VideoWeatherBackgroundState extends State<VideoWeatherBackground> {
  VideoPlayerController? _controller;
  String _currentVideo = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoWeatherBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Change de vidéo si les conditions météo ont changé
    if (oldWidget.cloudCover != widget.cloudCover ||
        oldWidget.precipitation != widget.precipitation ||
        oldWidget.temperature != widget.temperature ||
        oldWidget.localTime != widget.localTime) {
      _initializeVideo();
    }
  }

  /// Sélectionne la bonne vidéo en fonction de la météo et de l'heure
  String _getVideoPath() {
    // Utiliser l'heure locale de la ville si disponible, sinon l'heure locale de l'appareil
    final hour = widget.localTime?.hour ?? DateTime.now().hour;

    // Nuit (20h - 6h)
    if (hour >= 20 || hour < 6) {
      return 'assets/night.mp4';
    }

    // S'il neige (température < 2°C et précipitations)
    if (widget.temperature < 2 && widget.precipitation > 0) {
      return 'assets/snow.mp4';
    }

    // S'il pleut
    if (widget.precipitation > 0) {
      return 'assets/rain.mp4';
    }

    // Brouillard/Nuageux (couverture > 70%)
    if (widget.cloudCover > 70) {
      return 'assets/fog.mp4';
    }

    // Ensoleillé par défaut
    return 'assets/sunny.mp4';
  }

  /// Initialise ou change la vidéo
  void _initializeVideo() async {
    final newVideo = _getVideoPath();

    // Ne change pas si c'est déjà la bonne vidéo
    if (newVideo == _currentVideo && _controller?.value.isInitialized == true) return;

    // Dispose de l'ancien contrôleur avant d'en créer un nouveau
    if (_currentVideo.isNotEmpty) {
      _controller?.pause();
      _controller?.dispose();
    }

    _currentVideo = newVideo;

    try {
      // Crée un nouveau contrôleur avec options optimisées
      _controller = VideoPlayerController.asset(
        newVideo,
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: false,
        ),
      )..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller?.play();
            _controller?.setLooping(true);
            _controller?.setVolume(0);
          }
        });
    } catch (error) {
      debugPrint('Erreur chargement vidéo: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Vidéo en fond fixe
        if (_controller?.value.isInitialized == true)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          )
        else
          // Fond noir pendant le chargement
          Container(color: Colors.black),

        // Overlay sombre pour améliorer la lisibilité
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
        ),

        // Contenu par-dessus
        widget.child,
      ],
    );
  }
}
