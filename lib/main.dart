import 'dart:async';
import 'dart:ui' as ui;
import 'dart:core';

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.indigo.shade900,
        body: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PercentageSlider(),
              Countdown(),
            ],
          ),
        ),
      ),
    ),
  );
}

class PercentageSlider extends StatefulWidget {
  const PercentageSlider({super.key});

  @override
  State<PercentageSlider> createState() => _PercentageSliderState();
}

class _PercentageSliderState extends State<PercentageSlider> {
  int _value = 50;

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

    final sliderPath = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(
        size.width / 2,
        size.height * value / 100 - bezierYLength,
      )
      ..cubicTo(
        size.width / 2,
        size.height * value / 100 - bezierYLength / 2,
        size.width / 2 - bezierXLength,
        size.height * value / 100 - bezierYLength / 2,
        size.width / 2 - bezierXLength,
        size.height * value / 100,
      )
      ..cubicTo(
        size.width / 2 - bezierXLength,
        size.height * value / 100 + bezierYLength / 2,
        size.width / 2,
        size.height * value / 100 + bezierYLength / 2,
        size.width / 2,
        size.height * value / 100 + bezierYLength,
      )
      ..lineTo(
        size.width / 2,
        size.height,
      );

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
      final step = pathMetric.length.ceil() / 99;

      for (double t = 0.0, i = 1; t <= pathMetric.length; t += step, i++) {
        ui.Tangent? tangent = pathMetric.getTangentForOffset(t);
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

class Countdown extends StatefulWidget {
  const Countdown({super.key});

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  int _counter = 99;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _counter--);
    });
  }

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
            ...(_counter.abs()).toString().split('').map(
                  (d) => CountdownDigit(value: int.parse(d)),
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

class CountdownDigit extends StatelessWidget {
  const CountdownDigit({
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
