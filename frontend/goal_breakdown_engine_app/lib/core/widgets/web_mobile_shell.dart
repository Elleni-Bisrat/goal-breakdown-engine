import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// On web, centers the app in a ~375px-wide phone frame (Figma-style preview).
Widget wrapWebMobilePreview(BuildContext context, Widget? child) {
  if (child == null) return const SizedBox.shrink();
  if (!kIsWeb) return child;

  final mq = MediaQuery.of(context);
  final maxH = mq.size.height * 0.94;
  final h = math.max(480.0, math.min(812.0, maxH));

  return ColoredBox(
    color: const Color(0xFF2C2C2C),
    child: Center(
      child: Container(
        width: 375,
        height: h,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: const Color(0xFF0A0A0A), width: 10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 48,
              spreadRadius: 4,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    ),
  );
}
