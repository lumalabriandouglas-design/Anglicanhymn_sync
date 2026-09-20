import 'package:flutter/material.dart';

import 'breakpoints.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    super.fullscreenDialog,
  }) : super(
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return appPageTransition(
              context: context,
              animation: animation,
              child: child,
              fullscreenDialog: fullscreenDialog,
            );
          },
        );
}

Widget appPageTransition({
  required BuildContext context,
  required Animation<double> animation,
  required Widget child,
  bool fullscreenDialog = false,
}) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  final wide = Breakpoints.useRail(context);
  final Offset begin;
  if (fullscreenDialog) {
    begin = Offset(0, wide ? 0.04 : 0.08);
  } else if (wide) {
    begin = const Offset(0, 0.025);
  } else {
    begin = const Offset(0.045, 0);
  }

  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
      child: child,
    ),
  );
}

class AppFadeSlideTransitionsBuilder extends PageTransitionsBuilder {
  const AppFadeSlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return appPageTransition(
      context: context,
      animation: animation,
      child: child,
      fullscreenDialog: route.fullscreenDialog,
    );
  }
}

class AppNav {
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(context).push<T>(
      AppPageRoute<T>(
        builder: (_) => page,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  static Future<T?> showSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    if (Breakpoints.useRail(context)) {
      return showGeneralDialog<T>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 460,
                  maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
                ),
                child: builder(ctx),
              ),
            ),
          );
        },
        transitionBuilder: (ctx, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }
}
