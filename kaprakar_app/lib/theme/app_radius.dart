import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const Radius small = Radius.circular(8.0);
  static const Radius medium = Radius.circular(12.0); // Standard
  static const Radius card = Radius.circular(20.0);   // Feature cards
  static const Radius input = Radius.circular(20.0);  // Inputs (16-20)
  static const Radius pill = Radius.circular(30.0);   // Buttons

  static BorderRadius smallRadius = const BorderRadius.all(small);
  static BorderRadius mediumRadius = const BorderRadius.all(medium);
  static BorderRadius cardRadius = const BorderRadius.all(card);
  static BorderRadius inputRadius = const BorderRadius.all(input);
  static BorderRadius pillRadius = const BorderRadius.all(pill);
}
