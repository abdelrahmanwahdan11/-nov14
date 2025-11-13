import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MiniSparkline extends StatefulWidget {
  const MiniSparkline({
    super.key,
    required this.values,
    required this.lineColor,
    required this.fillColor,
    this.strokeWidth = 2.4,
    this.animate = true,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;
  final bool animate;

  @override
  State<MiniSparkline> createState() => _MiniSparklineState();
}

class _MiniSparklineState extends State<MiniSparkline> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 820));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(MiniSparkline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.values, widget.values)) {
      if (widget.animate) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 1;
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _MiniSparklinePainter(
            values: widget.values,
            progress: _animation.value,
            lineColor: widget.lineColor,
            fillColor: widget.fillColor,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  const _MiniSparklinePainter({
    required this.values,
    required this.progress,
    required this.lineColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  final List<double> values;
  final double progress;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.isEmpty) return;
    final effectiveValues = values.length == 1 ? [values.first, values.first] : values;
    final minValue = effectiveValues.reduce(math.min);
    final maxValue = effectiveValues.reduce(math.max);
    final range = (maxValue - minValue).abs() < 0.001 ? 1.0 : maxValue - minValue;
    final totalSegments = effectiveValues.length - 1;
    final clipWidth = size.width * progress.clamp(0.0, 1.0);
    final stepX = totalSegments == 0 ? size.width : size.width / totalSegments;

    final path = Path();
    for (int i = 0; i < effectiveValues.length; i++) {
      final x = (stepX * i).clamp(0.0, size.width);
      final normalized = (effectiveValues[i] - minValue) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, clipWidth, size.height));

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [fillColor.withOpacity(0.35), fillColor.withOpacity(0.05)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = lineColor;
    canvas.drawPath(path, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.values.length != values.length ||
        !listEquals(oldDelegate.values, values) ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
