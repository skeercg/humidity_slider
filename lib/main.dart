import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:humidity_slider/custom_slider.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _value = 0;

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
              CustomSlider(
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
