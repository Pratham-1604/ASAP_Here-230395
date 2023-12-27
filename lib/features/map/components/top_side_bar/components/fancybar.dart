
import 'package:flutter/material.dart';

class FancyBar extends StatelessWidget {
  const FancyBar(
      {super.key, required this.height, required this.child, required this.margin});

  final double height;
  final Widget child;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 46,
      margin: margin,
      decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              blurRadius: 30,
              color: Colors.white24,
            )
          ]),
      child: child,
    );
  }
}