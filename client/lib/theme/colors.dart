import 'package:flutter/material.dart';

class ThemeColors {
  static const MaterialColor primarySwatch = Colors.amber;
  static const Color orangeAccentColor = Colors.orangeAccent;
  static const Color blackColor = const Color(0xff19191b);
  static const Color whiteColor = Colors.white;
  static const Color whiteLightColor = Colors.white10;

  static const Color greyColor = const Color(0xff8f8f8f);
  static const Color userCircleBackground = const Color(0xff2b2b33);
  static const Color onlineDotColor = const Color(0xff46dc64);
  static const Color lightBlueColor = const Color(0xff0077d7);
  static const Color separatorColor = const Color(0xff272c35);

  static const Color gradientColorStart = const Color(0xff00b6f3);
  static const Color gradientColorEnd = const Color(0xff0184dc);

  static const Color senderColor = const Color(0xff2b343b);
  static const Color receiverColor = const Color(0xff1e2225);

  static const Gradient fabGradient = LinearGradient(
      colors: [gradientColorStart, gradientColorEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);
}
