import 'package:flutter/material.dart';

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  const SkeletonBox.circle({
    super.key,
    required double diameter,
  })  : width = diameter,
        height = diameter,
        borderRadius = null,
        shape = BoxShape.circle;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _base = Color(0xFFE3E9E6);
  static const _highlight = Color(0xFFF2F5F4);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(_base, _highlight, _controller.value);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? (widget.borderRadius ?? BorderRadius.circular(8))
                : null,
          ),
        );
      },
    );
  }
}