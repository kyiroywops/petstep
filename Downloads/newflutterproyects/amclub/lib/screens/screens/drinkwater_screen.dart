import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:amclub/screens/providers/tomoagua_provider.dart'; // Importa el provider
import 'dart:math' as math;

class DrinkScreen extends ConsumerStatefulWidget {
  DrinkScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DrinkScreen> createState() => _DrinkScreenState();
}

class _DrinkScreenState extends ConsumerState<DrinkScreen> with SingleTickerProviderStateMixin {
  double _progress = 0.1; // Comienza con un 10% de progreso
  bool _completed = false;
  bool _isDragging = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _progress = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isNearIndicator(Offset localPosition, Size size) {
    final double radius = size.width / 4;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double sweepAngle = 2 * math.pi * _progress;
    final double indicatorX = center.dx + radius * math.cos(sweepAngle - math.pi / 2);
    final double indicatorY = center.dy + radius * math.sin(sweepAngle - math.pi / 2);
    final Offset indicatorPosition = Offset(indicatorX, indicatorY);

    return (localPosition - indicatorPosition).distance < 20; // Ajustar la tolerancia a 20 px
  }

  void _updateProgress(Offset localPosition, Size size) {
    if (!_isDragging) return;

    final double angle = math.atan2(
      localPosition.dy - size.height / 2,
      localPosition.dx - size.width / 2,
    );
    double newProgress = (angle + math.pi / 2) / (2 * math.pi);
    if (newProgress < 0) newProgress += 1;

    setState(() {
      if (_completed) return;

      if (newProgress >= 0.99) {
        newProgress = 1.0; // Avanza un poco más allá del 100%
        _completed = true;
        ref.read(tomoAguaProvider.notifier).tomarAgua();
      } else {
        _progress = newProgress;
      }
    });
  }

  void _resetProgress() {
    if (!_completed) {
      _animation = Tween<double>(begin: _progress, end: 0.1).animate(_controller)
        ..addListener(() {
          setState(() {
            _progress = _animation.value;
          });
        });
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDrunkWater = ref.watch(tomoAguaProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onPanStart: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localPosition = box.globalToLocal(details.globalPosition);
              if (_isNearIndicator(localPosition, box.size)) {
                _isDragging = true;
              }
            },
            onPanUpdate: (details) {
              if (_isDragging) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final Offset localPosition = box.globalToLocal(details.globalPosition);
                _updateProgress(localPosition, box.size);
              }
            },
            onPanEnd: (details) {
              if (_isDragging) {
                _resetProgress();
                _isDragging = false;
              }
            },
            child: CustomPaint(
              size: Size(150, 150), // Tamaño del círculo
              painter: CirclePainter(_progress, _completed),
              child: Center(
                child: Text(
                  _completed ? '¡Hecho!' : 'Toma Agua',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Ajusta el tamaño de la fuente
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double progress;
  final bool completed;

  CirclePainter(this.progress, this.completed);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint trackPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 50 // Borde más grande
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..color = completed ? Colors.lightBlueAccent.shade200 : Colors.lightBlue.shade200
      ..strokeWidth = 50 // Borde más grande
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint centerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final double radius = size.width / 4; // Reducir el radio a la mitad
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Dibuja el fondo negro del círculo
    canvas.drawCircle(center, radius, centerPaint);

    // Dibuja el borde del círculo
    canvas.drawCircle(center, radius, trackPaint);

    // Dibuja el progreso
    final double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweepAngle + 0.1, false, progressPaint); // Ajuste de inicio y fin para llenar el círculo

    // Indicador de progreso con icono de check
    final double indicatorX = center.dx + radius * math.cos(sweepAngle - math.pi / 2);
    final double indicatorY = center.dy + radius * math.sin(sweepAngle - math.pi / 2);
    final double indicatorRadius = 15; // Radio del indicador

    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      indicatorRadius, // Radio del indicador igual al borde
      Paint()..color = completed ? Colors.lightBlue.shade300 : Colors.lightBlue.shade200,
    );

    final TextPainter checkTextPainter = TextPainter(
      text: TextSpan(
        text: '\u2713', // Símbolo de check
        style: TextStyle(
          color: Colors.white,
          fontSize: 14, // Ajusta el tamaño del icono
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    checkTextPainter.layout();
    checkTextPainter.paint(canvas, Offset(indicatorX - 7, indicatorY - 7)); // Centra el texto dentro del indicador
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
