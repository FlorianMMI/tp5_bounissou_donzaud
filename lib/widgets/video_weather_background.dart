import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Fond vidéo qui change en fonction de la météo et de l'heure
/// La vidéo est en haut et laisse place à un gradient en scrollant
class VideoWeatherBackground extends StatefulWidget {
  final Widget child;
  final int cloudCover; // Couverture nuageuse (0-100%)
  final double precipitation; // Précipitations en mm
  final double temperature; // Température en °C
  final ScrollController? scrollController;

  const VideoWeatherBackground({
    super.key,
    required this.child,
    this.cloudCover = 50,
    this.precipitation = 0,
    this.temperature = 15,
    this.scrollController,
  });

  @override
  State<VideoWeatherBackground> createState() => _VideoWeatherBackgroundState();
}

class _VideoWeatherBackgroundState extends State<VideoWeatherBackground> {
  late VideoPlayerController _controller;
  String _currentVideo = '';
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(VideoWeatherBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Change de vidéo si les conditions météo ont changé
    if (oldWidget.cloudCover != widget.cloudCover ||
        oldWidget.precipitation != widget.precipitation ||
        oldWidget.temperature != widget.temperature) {
      _initializeVideo();
    }
    
    // Met à jour le listener si le controller change
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  /// Écoute le scroll pour ajuster l'opacité du gradient
  void _onScroll() {
    if (widget.scrollController != null) {
      setState(() {
        _scrollOffset = widget.scrollController!.offset;
      });
    }
  }

  /// Sélectionne la bonne vidéo en fonction de la météo et de l'heure
  String _getVideoPath() {
    final hour = DateTime.now().hour;

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
  void _initializeVideo() {
    final newVideo = _getVideoPath();

    // Ne change pas si c'est déjà la bonne vidéo
    if (newVideo == _currentVideo && _controller.value.isInitialized) return;

    // Dispose de l'ancien contrôleur avant d'en créer un nouveau
    if (_currentVideo.isNotEmpty) {
      _controller.pause();
      _controller.dispose();
    }

    _currentVideo = newVideo;

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
          _controller.play();
          _controller.setLooping(true);
          _controller.setVolume(0);
        }
      }).catchError((error) {
        debugPrint('Erreur chargement vidéo: $error');
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Vidéo en fond fixe
        if (_controller.value.isInitialized)
          Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
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
