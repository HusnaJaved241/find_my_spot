import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final String heroTag;
  final VoidCallback onPressed;
  final Icon icon;

  const CustomFloatingActionButton({
    super.key,
    required this.heroTag,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: icon,
    );
  }
}
