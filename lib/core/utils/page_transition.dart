import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper function to create custom page transitions
CustomTransitionPage customPageTransition(
  BuildContext context,
  Widget child, {
  String? transitionType = 'fade', // Default transition is fade
}) {
  switch (transitionType) {
    case 'slide':
      return slideTransitionBuilder(context, child);
    case 'fade':
    default:
      return fadeTransitionBuilder(context, child);
  }
}

/// Fade Transition
CustomTransitionPage fadeTransitionBuilder(
  BuildContext context,
  Widget child,
) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Slide Transition
CustomTransitionPage slideTransitionBuilder(
  BuildContext context,
  Widget child,
) {
  const begin = Offset(1.0, 0.0); // Slide from the right
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
