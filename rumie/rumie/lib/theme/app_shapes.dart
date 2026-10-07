import 'package:flutter/material.dart';

/// Corner radii and the superellipse ("squircle") shapes used everywhere.
/// Continuous curvature reads as native on iOS and softer than circular arcs.
class AppShapes {
  AppShapes._();

  static const double card = 28;
  static const double photo = 24;
  static const double tile = 20;
  static const double button = 18;
  static const double input = 16;
  static const double small = 12;

  static RoundedSuperellipseBorder shape(double radius, {BorderSide side = BorderSide.none}) =>
      RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(radius), side: side);

  static BorderRadius radius(double r) => BorderRadius.circular(r);
}
