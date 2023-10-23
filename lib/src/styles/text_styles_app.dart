import 'package:flutter/material.dart';
import 'package:octo360/src/fonts/font_manager.dart';

class TextStylesApp {
  ///weight: 300
  static TextStyle light({
    double fontSize = 14.0,
    required Color color,
    String fontFamily = FontFamilyApp.fontFamilyInter,
    double? lineHeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeightApp.light,
      color: color,
      height: lineHeight != null ? lineHeight / fontSize : null,
    );
  }

  ///weight: 300
  static TextStyle regular({
    double fontSize = 16.0,
    required Color color,
    String fontFamily = FontFamilyApp.fontFamilyInter,
    double? lineHeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeightApp.regular,
      color: color,
      height: lineHeight != null ? lineHeight / fontSize : null,
    );
  }

  ///weight: 500
  static TextStyle medium({
    double fontSize = 16.0,
    required Color color,
    String fontFamily = FontFamilyApp.fontFamilyInter,
    double? lineHeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeightApp.medium,
      color: color,
      height: lineHeight != null ? lineHeight / fontSize : null,
    );
  }

  ///weight: 600
  static TextStyle semiBold({
    double fontSize = 18.0,
    required Color color,
    String fontFamily = FontFamilyApp.fontFamilyInter,
    double? lineHeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeightApp.semibold,
      color: color,
      height: lineHeight != null ? lineHeight / fontSize : null,
    );
  }

  ///weight: 700
  static TextStyle bold({
    double fontSize = 18.0,
    required Color color,
    String fontFamily = FontFamilyApp.fontFamilyInter,
    double? lineHeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeightApp.bold,
      color: color,
      height: lineHeight != null ? lineHeight / fontSize : null,
    );
  }
}
