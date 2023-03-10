import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({
    required this.onPressed,
    required this.child,
    required this.tooltip,
    this.size = 35,
    super.key,
  });

  final void Function()? onPressed;
  final Widget child;
  final double size;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(seconds: 1),
      child: SizedBox(
        height: size,
        width: size,
        child: ClipOval(
          child: Material(
            color: Theme.of(context).colorScheme.primary,
            child: InkWell(
              canRequestFocus: false,
              onTap: onPressed,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
