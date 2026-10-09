import 'package:flutter/widgets.dart';

/// Motion tokens. Short durations because users are mid-task; exponential
/// ease-outs so movement settles instead of bouncing.
///
/// Route every duration through [AppMotion.of] so reduced-motion users get
/// instant state changes.
class AppMotion {
  AppMotion._();

  /// Press feedback, selection indicators.
  static const Duration fast = Duration(milliseconds: 130);

  /// Most state changes: hover, chips, tab fades.
  static const Duration base = Duration(milliseconds: 220);

  /// Layout-ish changes: nav capsule, card removal, routes.
  static const Duration slow = Duration(milliseconds: 360);

  /// Staggered entrances.
  static const Duration reveal = Duration(milliseconds: 480);

  /// The one celebratory moment (a connection).
  static const Duration celebrate = Duration(milliseconds: 560);

  static const Curve enter = Curves.easeOutQuint;
  static const Curve standard = Curves.easeOutQuart;
  static const Curve exit = Curves.easeOutCubic;
  static const Curve emphasized = Cubic(0.2, 0.9, 0.1, 1.0);

  static bool reduced(BuildContext context) => MediaQuery.disableAnimationsOf(context);

  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
