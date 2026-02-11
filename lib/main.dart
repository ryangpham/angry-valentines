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

class _ValentineHomeState extends State<ValentineHome>
    with TickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';
  late final AnimationController _sparkleController;
  final List<_FallingCow> _fallingCows = [];

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    for (final cow in _fallingCows) {
      cow.controller.dispose();
    }
    super.dispose();
  }

  void _triggerLoveTime() {
    final rng = Random();
    for (int i = 0; i < 10; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!mounted) return;
        final controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 2000 + rng.nextInt(1000)),
        );
        final cow = _FallingCow(
          controller: controller,
          x: rng.nextDouble(),
          rotation: (rng.nextDouble() - 0.5) * 0.8,
          size: 50.0 + rng.nextDouble() * 40,
        );
        setState(() => _fallingCows.add(cow));
        controller.forward().then((_) {
          if (!mounted) return;
          setState(() => _fallingCows.remove(cow));
          controller.dispose();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: const AssetImage('assets/images/cupid.jpg'),
          ),
        ),
        title: const Text('Cupid\'s Canvas'),
      ),
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
          // Scattered asset images for whimsy
          Positioned(
            top: 30,
            left: 10,
            child: Transform.rotate(
              angle: -0.2,
              child: Opacity(
                opacity: 0.85,
                child: Image.asset(
                  'assets/images/owl.jpg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 10,
            child: Transform.rotate(
              angle: 0.15,
              child: Opacity(
                opacity: 0.85,
                child: Image.asset(
                  'assets/images/frog.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            left: 20,
            child: Transform.rotate(
              angle: 0.1,
              child: Opacity(
                opacity: 0.85,
                child: Image.asset(
                  'assets/images/ladybug.webp',
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            right: 15,
            child: Transform.rotate(
              angle: -0.12,
              child: Opacity(
                opacity: 0.85,
                child: Image.asset(
                  'assets/images/monkey.png',
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: 0.05,
                child: Opacity(
                  opacity: 0.80,
                  child: Image.asset(
                    'assets/images/cows_kissing.jpg',
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          if (selectedEmoji == 'Party Heart')
            Positioned.fill(
              child: CustomPaint(painter: ConfettiPainter(seed: 42)),
            ),
          // Falling cows from Love Time button
          ..._fallingCows.map((cow) {
            return AnimatedBuilder(
              animation: cow.controller,
              builder: (context, child) {
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;
                final top =
                    -cow.size +
                    cow.controller.value * (screenHeight + cow.size * 2);
                final left = cow.x * (screenWidth - cow.size);
                return Positioned(
                  top: top,
                  left: left,
                  child: Transform.rotate(
                    angle: cow.rotation,
                    child: Image.asset(
                      'assets/images/cows_kissing.jpg',
                      width: cow.size,
                      height: cow.size * 0.7,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }),
          Column(
            children: [
              const SizedBox(height: 16),
              // Dropdown flanked by smiling hearts
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/smiling_heart.webp',
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedEmoji,
                    dropdownColor: const Color(0xFFFCE4EC),
                    items: emojiOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedEmoji = value ?? selectedEmoji),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    'assets/images/smiling_heart.webp',
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _triggerLoveTime,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Love Time'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Heart area with heart1.png accent
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // heart1.png decorative overlay
                        Positioned(
                          top: -15,
                          right: -15,
                          child: Opacity(
                            opacity: 0.35,
                            child: Image.asset(
                              'assets/images/heart1.png',
                              width: 70,
                              height: 70,
                            ),
                          ),
                        ),
                        // Love trail aura (behind heart)
                        CustomPaint(
                          size: const Size(300, 300),
                          painter: AuraPainter(type: selectedEmoji),
                        ),
                        // Main heart emoji
                        CustomPaint(
                          size: const Size(300, 300),
                          painter: HeartEmojiPainter(type: selectedEmoji),
                        ),
                        // Animated sparkles (in front of heart)
                        AnimatedBuilder(
                          animation: _sparkleController,
                          builder: (context, child) => CustomPaint(
                            size: const Size(300, 300),
                            painter: SparklesPainter(
                              progress: _sparkleController.value,
                              seed: 99,
                            ),
                          ),
                        ),
                      ],
                    ),
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

/// Builds the heart [Path] centered at [center]. Shared by multiple painters.
Path buildHeartPath(Offset center) {
  return Path()
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
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final heartPath = buildHeartPath(center);

    // Add shadow for depth
    canvas.drawShadow(
      heartPath,
      Colors.red.shade900.withValues(alpha: 0.4),
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

/// Draws concentric heart outlines behind the main heart for a glowing aura.
class AuraPainter extends CustomPainter {
  AuraPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = buildHeartPath(center);

    final baseColor = type == 'Party Heart'
        ? const Color(0xFFF48FB1)
        : const Color(0xFFE91E63);

    // Draw 4 layers outward: thicker stroke, lower opacity.
    const layers = [
      (strokeWidth: 8.0, opacity: 0.18),
      (strokeWidth: 16.0, opacity: 0.12),
      (strokeWidth: 24.0, opacity: 0.07),
      (strokeWidth: 32.0, opacity: 0.03),
    ];

    for (final layer in layers) {
      final paint = Paint()
        ..color = baseColor.withValues(alpha: layer.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = layer.strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AuraPainter oldDelegate) =>
      oldDelegate.type != type;
}

/// Draws twinkling star-burst sparkles around the heart.
class SparklesPainter extends CustomPainter {
  SparklesPainter({required this.progress, required this.seed});
  final double progress;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rng = Random(seed);
    const sparkleCount = 14;

    for (int i = 0; i < sparkleCount; i++) {
      // Fixed position on a ring around the heart.
      final baseAngle = (2 * pi / sparkleCount) * i + rng.nextDouble() * 0.5;
      final radius = 100.0 + rng.nextDouble() * 60;
      final x = center.dx + cos(baseAngle) * radius;
      final y = center.dy + sin(baseAngle) * radius - 20;

      // Twinkle: each sparkle has its own phase so they don't all pulse together.
      final phase = rng.nextDouble();
      final twinkle = (sin((progress + phase) * 2 * pi) + 1) / 2; // 0..1
      final opacity = 0.2 + twinkle * 0.8;
      final sparkleSize = 3.0 + twinkle * 5.0;

      final color = i.isEven
          ? Color(0xFFFFFFFF).withValues(alpha: opacity)
          : Color(0xFFFFD54F).withValues(alpha: opacity);

      final paint = Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw 4 short lines radiating from center (star burst).
      for (int r = 0; r < 4; r++) {
        final rayAngle = (pi / 4) * r;
        final dx = cos(rayAngle) * sparkleSize;
        final dy = sin(rayAngle) * sparkleSize;
        canvas.drawLine(Offset(x - dx, y - dy), Offset(x + dx, y + dy), paint);
      }

      // Center dot.
      canvas.drawCircle(
        Offset(x, y),
        1.5 + twinkle,
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SparklesPainter oldDelegate) =>
      oldDelegate.progress != progress;
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
                const Color(0xFFF8BBD0).withValues(alpha: opacity + 0.1),
                const Color(0xFFE91E63).withValues(alpha: opacity),
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

class _FallingCow {
  _FallingCow({
    required this.controller,
    required this.x,
    required this.rotation,
    required this.size,
  });

  final AnimationController controller;
  final double x;
  final double rotation;
  final double size;
}
