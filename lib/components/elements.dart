import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  const CircleButton(
      {required this.onPressed,
      required this.child,
      this.size = 35,
      this.color = Colors.blue,
      super.key});

  final void Function()? onPressed;
  final Widget child;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: ClipOval(
        child: Material(
            color: color,
            child: InkWell(
                canRequestFocus: false, onTap: onPressed, child: child)),
      ),
    );
  }
}
