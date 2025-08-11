import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class CircularTimerWidget extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onTimerComplete;
  final Color progressColor;
  final Color backgroundColor;
  final double size;

  const CircularTimerWidget({
    super.key,
    required this.durationSeconds,
    required this.onTimerComplete,
    this.progressColor = const Color(0xFF40E0D0),
    this.backgroundColor = Colors.white,
    this.size = 43.0,
  });

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _timer;
  int _currentSeconds = 0;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.durationSeconds;
    _animationController = AnimationController(
      duration: Duration(seconds: widget.durationSeconds),
      vsync: this,
    );
    _startTimer();
  }

  void _startTimer() {
    _currentSeconds = widget.durationSeconds;
    _animationController.reset();
    _animationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentSeconds--;
      });

      if (_currentSeconds <= 0) {
        timer.cancel();
        widget.onTimerComplete();
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor,
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: CircularTimerPainter(
                  progress: _animationController.value,
                  progressColor: widget.progressColor,
                  backgroundColor: Colors.grey.shade300,
                ),
              );
            },
          ),
          Text(
            '$_currentSeconds',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  CircularTimerPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 3, backgroundPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 3),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    final separatorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    const separatorCount = 10;
    for (int i = 0; i < separatorCount; i++) {
      final angle = (2 * math.pi * i) / separatorCount - math.pi / 2;
      final startRadius = radius - 9;
      final endRadius = radius + 3;
      
      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        separatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
