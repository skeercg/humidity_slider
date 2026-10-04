import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:core';

import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _value = 1;

  void _onChangeEnd(int value) {
    setState(() => _value = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PercentageSlider(
                initialValue: _value,
                onChangeEnd: _onChangeEnd,
              ),
              SizedBox(
                width: 200,
                child: Display(value: _value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PercentageSlider extends StatefulWidget {
  const PercentageSlider({
    super.key,
    required this.initialValue,
    required this.onChangeEnd,
  });

  final int initialValue;
  final void Function(int) onChangeEnd;

  @override
  State<PercentageSlider> createState() => _PercentageSliderState();
}

class _PercentageSliderState extends State<PercentageSlider> {
  int _value = 1;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final curValue = (details.localPosition.dy / 600 * 100).toInt();

        if (curValue > 100 || curValue < 0) {
          return;
        }

        setState(() => _value = curValue);
      },
      onVerticalDragEnd: (_) => widget.onChangeEnd(_value),
      child: CustomPaint(
        size: const Size(300, 600),
        painter: PercentageSliderPainter(value: _value),
      ),
    );
  }
}

class PercentageSliderPainter extends CustomPainter {
  final int value;

  const PercentageSliderPainter({
    super.repaint,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintSlider(canvas, size);

    _paintButton(canvas, size);
  }

  void _paintSlider(Canvas canvas, Size size) {
    final p1 = Offset(size.width / 2, 0);
    final p2 = Offset(size.width / 2, size.height);

    final sliderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = ui.Gradient.linear(
        p1,
        p2,
        [Colors.red, Colors.blue, Colors.red],
        [0.25, 0.45, 1.0],
      );

    const bezierYLength = 60;
    const bezierXLength = 30;

    double bumpX(double dy) {
      if (dy.abs() >= bezierYLength) return 0;
      return bezierXLength * (1 + math.cos(math.pi * dy / bezierYLength)) / 2;
    }

    final cx = size.width / 2;
    final y = size.height * value / 100;

    final bumpTop = math.max(0.0, y - bezierYLength);
    final bumpBottom = math.min(size.height, y + bezierYLength);

    final sliderPath = Path()..moveTo(cx - bumpX(-y), 0);

    for (var py = bumpTop; py < bumpBottom; py++) {
      sliderPath.lineTo(cx - bumpX(py - y), py);
    }

    sliderPath.lineTo(cx - bumpX(bumpBottom - y), bumpBottom);

    if (bumpBottom < size.height) {
      sliderPath.lineTo(cx, size.height);
    }

    canvas.drawPath(sliderPath, sliderPaint);

    final delimiterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const delimiterSLength = 8.0;
    const delimiterMLength = 16.0;

    // Gap between slider and each delimiter
    const delimiterGapWidth = 8;

    for (ui.PathMetric pathMetric in sliderPath.computeMetrics()) {
      final step = pathMetric.length / 100;

      for (int i = 0; i <= 100; i++) {
        ui.Tangent? tangent = pathMetric.getTangentForOffset(i * step);
        if (tangent != null) {
          final position = tangent.position;
          Offset p1 = Offset(position.dx - delimiterGapWidth, position.dy);
          Offset p2 = Offset(position.dx - delimiterGapWidth, position.dy);

          if (i % 10 == 0) {
            p1 -= const Offset(delimiterMLength, 0);
          } else {
            p1 -= const Offset(delimiterSLength, 0);
          }

          canvas.drawLine(p1, p2, delimiterPaint);

          if (i % 10 == 0 || i == value) {
            TextStyle percentageTextStyle = switch (i == value) {
              true => const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),
              false => const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
            };

            if (i != value && (-4 <= i - value && i - value <= 5)) {
              continue;
            }

            final textSpan = TextSpan(
              text: '$i%  ',
              style: percentageTextStyle,
            );

            final tp = TextPainter(
              text: textSpan,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr,
            )..layout();

            final textOffset = Offset(size.width / 2 - 100, position.dy);

            tp.paint(
              canvas,
              textOffset - Offset(tp.width / 2, tp.height / 2),
            );
          }
        }
      }
    }
  }

  void _paintButton(Canvas canvas, Size size) {
    final buttonPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final buttonOffset = Offset(size.width / 2, size.height * value / 100);

    canvas.drawCircle(
      buttonOffset,
      20,
      buttonPaint,
    );

    final iconUp = String.fromCharCode(Icons.arrow_drop_up.codePoint);
    final iconDown = String.fromCharCode(Icons.arrow_drop_down.codePoint);
    final iconFontFamily = Icons.arrow_drop_up.fontFamily;

    final textSpan = TextSpan(
      text: '$iconUp\n$iconDown',
      style: TextStyle(
        fontSize: 28,
        color: Colors.black,
        height: 0.5,
        fontFamily: iconFontFamily,
      ),
    );

    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
    )..layout();

    tp.paint(
      canvas,
      buttonOffset - Offset(tp.width / 2, tp.height / 4),
    );
  }

  @override
  bool shouldRepaint(PercentageSliderPainter oldDelegate) {
    return value != oldDelegate.value;
  }
}

class Display extends StatelessWidget {
  const Display({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current humidity',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...(value.abs()).toString().split('').map(
                  (d) => DisplayDigit(value: int.parse(d)),
                ),
            const Text(
              '%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 64,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DisplayDigit extends StatelessWidget {
  const DisplayDigit({
    super.key,
    required this.value,
    this.previousValue,
  });

  final int value;
  final int? previousValue;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 900),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        if (child.key == ValueKey(value)) {
          final slideIn = Tween<Offset>(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation);

          return SlideTransition(
            position: slideIn,
            child: FadeTransition(opacity: animation, child: child),
          );
        } else {
          final slideOut = Tween<Offset>(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(animation);

          return SlideTransition(
            position: slideOut,
            child: FadeTransition(opacity: animation, child: child),
          );
        }
      },
      child: Text(
        '$value',
        key: ValueKey<int>(value),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 64,
        ),
      ),
    );
  }
}
