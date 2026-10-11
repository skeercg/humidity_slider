import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _buttonRadius = 20.0;

class CustomSlider extends StatefulWidget {
  const CustomSlider({
    super.key,
    required this.initialValue,
    required this.onChangeEnd,
  });

  final int initialValue;
  final ValueChanged<int> onChangeEnd;

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late int _value = widget.initialValue;

  void _handlePointerMove(PointerMoveEvent event) {
    final trackLength = context.size!.height - _buttonRadius * 2;
    if (trackLength <= 0) return;

    final percentage =
        (event.localPosition.dy - _buttonRadius) / trackLength * 100;
    setState(() => _value = percentage.clamp(0, 100).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _handlePointerMove,
      onPointerUp: (event) => widget.onChangeEnd(_value),
      onPointerCancel: (event) => widget.onChangeEnd(_value),
      child: SizedBox(
        width: 300,
        height: 600 + _buttonRadius * 2,
        child: _CustomSliderRenderObjectWidget(
          value: _value,
          button: RepaintBoundary(
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {},
                customBorder: const CircleBorder(),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      heightFactor: 0.5,
                      child: Icon(
                        Icons.arrow_drop_up,
                        size: 28,
                        color: Colors.black,
                      ),
                    ),
                    Align(
                      heightFactor: 0.5,
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 28,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomSliderRenderObjectWidget extends SingleChildRenderObjectWidget {
  const _CustomSliderRenderObjectWidget({
    required this.value,
    required Widget button,
  }) : super(child: button);

  final int value;

  @override
  _RenderCustomSlider createRenderObject(BuildContext context) {
    return _RenderCustomSlider(value: value);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCustomSlider renderObject,
  ) {
    renderObject.value = value;
  }
}

class _RenderCustomSlider extends RenderShiftedBox {
  _RenderCustomSlider({required int value})
      : _value = value,
        super(null);

  static const _bumpExtent = 60.0;
  static const _bumpDepth = 30.0;

  static const _delimiterGap = 8.0;
  static const _delimiterLength = 8.0;
  static const _majorDelimiterLength = 16.0;

  int get value => _value;
  int _value;
  set value(int value) {
    if (_value == value) return;
    _value = value;
    markNeedsLayout();
  }

  Rect get _track => Rect.fromLTRB(
        0,
        _buttonRadius,
        size.width,
        size.height - _buttonRadius,
      );

  Offset get _buttonCenter {
    final track = _track;
    return Offset(track.center.dx, track.top + track.height * _value / 100);
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    size = constraints.biggest;

    final child = this.child!;
    child.layout(BoxConstraints.tight(const Size.square(_buttonRadius * 2)));
    (child.parentData! as BoxParentData).offset =
        _buttonCenter - const Offset(_buttonRadius, _buttonRadius);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final line = _buildLine();

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    _paintLine(canvas, line);
    _paintScale(canvas, line);
    canvas.restore();

    super.paint(context, offset);
  }

  Path _buildLine() {
    final track = _track;
    final button = _buttonCenter;

    Offset pointAt(double y) {
      final dy = y - button.dy;
      final bump = dy.abs() < _bumpExtent
          ? _bumpDepth * (1 + math.cos(math.pi * dy / _bumpExtent)) / 2
          : 0.0;
      return Offset(button.dx - bump, y);
    }

    return Path()
      ..addPolygon(
        [
          for (var y = track.top; y < track.bottom; y++) pointAt(y),
          pointAt(track.bottom),
        ],
        false,
      );
  }

  void _paintLine(Canvas canvas, Path line) {
    final track = _track;

    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..shader = ui.Gradient.linear(
          track.topCenter,
          track.bottomCenter,
          [Colors.blue.shade100, Colors.blue.shade700],
        ),
    );
  }

  void _paintScale(Canvas canvas, Path line) {
    final metric = line.computeMetrics().firstOrNull;
    if (metric == null) return;

    final delimiterPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    final step = metric.length / 100;

    for (var i = 0; i <= 100; i++) {
      final position = metric.getTangentForOffset(i * step)?.position;
      if (position == null) continue;

      final isMajor = i % 10 == 0;
      final end = position - const Offset(_delimiterGap, 0);
      final length = isMajor ? _majorDelimiterLength : _delimiterLength;
      canvas.drawLine(end - Offset(length, 0), end, delimiterPaint);

      final isCurrent = i == _value;
      final isNearCurrent = -4 <= i - _value && i - _value <= 5;
      if (isCurrent || (isMajor && !isNearCurrent)) {
        _paintLabel(canvas, i, position.dy);
      }
    }
  }

  void _paintLabel(Canvas canvas, int percentage, double y) {
    final label = TextPainter(
      text: TextSpan(
        text: '$percentage%  ',
        style: percentage == _value
            ? const TextStyle(color: Colors.blue, fontSize: 18)
            : const TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    label.paint(
      canvas,
      Offset(size.width / 2 - 100, y) - label.size.center(Offset.zero),
    );
    label.dispose();
  }
}
