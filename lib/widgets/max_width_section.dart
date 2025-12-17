// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class MaxWidthSection extends StatelessWidget {
  final Widget child;
  const MaxWidthSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: child,
        ),
      ),
    );
  }
}
