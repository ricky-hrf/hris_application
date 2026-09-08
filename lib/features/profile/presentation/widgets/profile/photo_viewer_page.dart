import 'package:flutter/material.dart';

class PhotoViewerPage extends StatelessWidget {
  final ImageProvider image;
  final String heroTag;

  const PhotoViewerPage({
    super.key,
    required this.image,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image(image: image, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Profile Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.35),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}