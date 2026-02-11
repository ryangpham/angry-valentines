import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome> {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8BBD0), // soft pink
                    Color(0xFFE91E63), // passionate red
                  ],
                ),
              ),
            ),
          ),
          // Layered heart shapes for depth
          Positioned.fill(
            child: CustomPaint(painter: BackgroundHeartsPainter()),
          ),
          if (selectedEmoji == 'Party Heart')
            Positioned.fill(
              child: CustomPaint(painter: ConfettiPainter(seed: 42)),
            ),
          Column(
            children: [
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedEmoji,
                items: emojiOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedEmoji = value ?? selectedEmoji),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: HeartEmojiPainter(type: selectedEmoji),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(
        center.dx + 110,
        center.dy - 10,
        center.dx + 60,
        center.dy - 120,
        center.dx,
        center.dy - 40,
      )
      ..cubicTo(
        center.dx - 60,
        center.dy - 120,
        center.dx - 110,
        center.dy - 10,
        center.dx,
        center.dy + 60,
      )
      ..close();

    // Add shadow for depth
    canvas.drawShadow(
      heartPath,
      Colors.red.shade900.withOpacity(0.4),
      12,
      true,
    );

    // Gradient fill for heart
    final Rect heartBounds = Rect.fromCenter(
      center: center,
      width: 220,
      height: 200,
    );
    final Gradient heartGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        type == 'Party Heart'
            ? const Color(0xFFF8BBD0)
            : const Color(0xFFF06292),
        type == 'Party Heart'
            ? const Color(0xFFF06292)
            : const Color(0xFFD50000),
      ],
    );
    final Paint gradientPaint = Paint()
      ..shader = heartGradient.createShader(heartBounds)
      ..style = PaintingStyle.fill;
    canvas.drawPath(heartPath, gradientPaint);

    // Face features (starter)
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0,
      3.14,
      false,
      mouthPaint,
    );

    // Party hat placeholder (expand for confetti)
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type;
}

// Painter for background hearts (depth & passion)
class BackgroundHeartsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hearts = [
      // (x, y, scale, opacity)
      [0.2, 0.3, 0.7, 0.18],
      [0.7, 0.2, 0.5, 0.13],
      [0.5, 0.7, 1.1, 0.10],
      [0.8, 0.8, 0.4, 0.15],
      [0.3, 0.8, 0.6, 0.12],
    ];
    for (final h in hearts) {
      final dx = size.width * h[0];
      final dy = size.height * h[1];
      final scale = h[2];
      final opacity = h[3];
      final path = Path()
        ..moveTo(dx, dy + 60 * scale)
        ..cubicTo(
          dx + 110 * scale,
          dy - 10 * scale,
          dx + 60 * scale,
          dy - 120 * scale,
          dx,
          dy - 40 * scale,
        )
        ..cubicTo(
          dx - 60 * scale,
          dy - 120 * scale,
          dx - 110 * scale,
          dy - 10 * scale,
          dx,
          dy + 60 * scale,
        )
        ..close();
      final paint = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF8BBD0).withOpacity(opacity + 0.1),
                const Color(0xFFE91E63).withOpacity(opacity),
              ],
            ).createShader(
              Rect.fromCenter(
                center: Offset(dx, dy),
                width: 220 * scale,
                height: 200 * scale,
              ),
            )
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ConfettiPainter extends CustomPainter {
  ConfettiPainter({required this.seed});
  final int seed;

  static const _colors = [
    Color(0xFFE91E63), // pink-red
    Color(0xFFF48FB1), // light pink
    Color(0xFFFFD54F), // gold
    Color(0xFFFF5252), // red accent
    Color(0xFFFF80AB), // pink accent
    Color(0xFFFFFFFF), // white
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;
    const count = 40;

    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final w = 6.0 + rng.nextDouble() * 14;
      final h = 4.0 + rng.nextDouble() * 10;
      final angle = rng.nextDouble() * 2 * pi;
      paint.color = _colors[rng.nextInt(_colors.length)];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
