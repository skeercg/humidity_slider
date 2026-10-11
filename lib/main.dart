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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: const Interval(0.5, 1),
          switchOutCurve: const Interval(0.5, 1),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          child: Text(
            '$value%',
            key: ValueKey(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
            ),
          ),
        ),
      ],
    );
  }
}
