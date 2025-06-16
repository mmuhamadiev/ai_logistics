
import 'package:flutter/material.dart';

abstract class AppColors {
  static const  white = Color(0xffFEFEFE);
  static const  transparentGray = Color(0xff0E0F0C);
  static const  lightGray = Color(0xffF9FAFB);
  static const  grey = Color(0xffA8AAA6);
  static const  buttonGrey = Color(0xffcdeaff);
  static const  black = Color(0xff0E0F0C);
  static const  red = Color(0xffFF4C4B);
  static const  blue = Color(0xff205295);
  static const  lightBlue = Color(0xff2C74B3);
  static const  lightGreen = Color(0xffDCFCE7);
  static const  green = Color(0xff1DA54E);

  static const List<Color> linearLogin = [
    black,
    blue,
    lightBlue
  ];

  static final lineLoginGradient = LinearGradient(
    colors: linearLogin,
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static final lineGradient = LinearGradient(
    colors: [Color(0xffEDEDED), Color(0xffDAE3D7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}