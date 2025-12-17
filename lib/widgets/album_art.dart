import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/constants.dart';

class AlbumArt extends StatelessWidget {
  final String? albumArtPath;
  final double size;
  final double borderRadius;
  final BoxFit fit;
  final Widget? placeholder;

  const AlbumArt({
    super.key,
    this.albumArtPath,
    this.size = 200,
    this.borderRadius = AppSizes.albumArtRadius,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (albumArtPath == null || albumArtPath!.isEmpty) {
      return _buildPlaceholder();
    }

    if (albumArtPath!.startsWith('assets/')) {
      return Image.asset(
        albumArtPath!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (albumArtPath!.startsWith('http://') || 
               albumArtPath!.startsWith('https://')) {
      return Image.network(
        albumArtPath!,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingIndicator();
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      final file = File(albumArtPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } else {
        return _buildPlaceholder();
      }
    }
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          color: AppColors.cardBackground,
          child: Center(
            child: Icon(
              Icons.music_note,
              size: size * 0.4,
              color: AppColors.grey,
            ),
          ),
        );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: AppColors.cardBackground,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class CircularAlbumArt extends StatelessWidget {
  final String? albumArtPath;
  final double size;
  final Widget? placeholder;

  const CircularAlbumArt({
    super.key,
    this.albumArtPath,
    this.size = 200,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (albumArtPath == null || albumArtPath!.isEmpty) {
      return _buildPlaceholder();
    }

    if (albumArtPath!.startsWith('assets/')) {
      return Image.asset(
        albumArtPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (albumArtPath!.startsWith('http://') || 
               albumArtPath!.startsWith('https://')) {
      return Image.network(
        albumArtPath!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingIndicator();
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      final file = File(albumArtPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } else {
        return _buildPlaceholder();
      }
    }
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          color: AppColors.cardBackground,
          child: Center(
            child: Icon(
              Icons.music_note,
              size: size * 0.4,
              color: AppColors.grey,
            ),
          ),
        );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: AppColors.cardBackground,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class AlbumArtWithOverlay extends StatelessWidget {
  final String? albumArtPath;
  final double size;
  final Widget? overlayChild;
  final VoidCallback? onTap;

  const AlbumArtWithOverlay({
    super.key,
    this.albumArtPath,
    this.size = 200,
    this.overlayChild,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AlbumArt(
            albumArtPath: albumArtPath,
            size: size,
          ),
          if (overlayChild != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(AppSizes.albumArtRadius),
                ),
                child: Center(child: overlayChild),
              ),
            ),
        ],
      ),
    );
  }
}

class RotatingAlbumArt extends StatefulWidget {
  final String? albumArtPath;
  final double size;
  final bool isPlaying;

  const RotatingAlbumArt({
    super.key,
    this.albumArtPath,
    this.size = 200,
    this.isPlaying = false,
  });

  @override
  State<RotatingAlbumArt> createState() => _RotatingAlbumArtState();
}

class _RotatingAlbumArtState extends State<RotatingAlbumArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RotatingAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CircularAlbumArt(
        albumArtPath: widget.albumArtPath,
        size: widget.size,
      ),
    );
  }
}