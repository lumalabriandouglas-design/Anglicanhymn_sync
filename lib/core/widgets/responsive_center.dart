import 'package:flutter/material.dart';

import 'breakpoints.dart';

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double? maxContentWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = maxContentWidth ?? Breakpoints.contentWidth(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
