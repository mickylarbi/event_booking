import 'package:flutter/material.dart';

Size kScreenSize(context) => MediaQuery.of(context).size;
double kScreenHeight(context) => MediaQuery.of(context).size.height;
double kScreenWidth(context) => MediaQuery.of(context).size.width;

String kLogoTag = 'logoTag';

Color kBackgroundColor = const Color(0xFFF9F9F9);

Duration ktimeout = const Duration(seconds: 30);

ButtonStyle get translucentButtonStyle => TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: Colors.blue.withOpacity(.2));


ButtonStyle get elevatedButtonStyle => TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    )
    ;
