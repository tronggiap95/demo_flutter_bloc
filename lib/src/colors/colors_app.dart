import 'package:flutter/material.dart';

class ColorsApp {
  static Color white = HexColor.fromHex("#FFFFFF");

  static Color primaryBase = HexColor.fromHex("#2A56BD");
  static Color primaryLight = HexColor.fromHex("#6089DB");
  static Color primaryLighter = HexColor.fromHex("#ADC5F0");
  static Color primaryLightest = HexColor.fromHex("#E6EFFF");
  static Color primaryDark = HexColor.fromHex("#204292");

  static Color secondaryBase = HexColor.fromHex("#07A878");
  static Color secondaryLightest = HexColor.fromHex("#DEF5EE");

  static Color coalBase = HexColor.fromHex("#8E939E");
  static Color coalLight = HexColor.fromHex("#C0C5D1");
  static Color coalLighter = HexColor.fromHex("#D8DCE5");
  static Color coalLightest = HexColor.fromHex("#EBEEF5");
  static Color coalDark = HexColor.fromHex("#5A5D66");
  static Color coalDarker = HexColor.fromHex("#3A3D42");
  static Color coalDarkest = HexColor.fromHex("#282A2E");

  static Color fogBackground = HexColor.fromHex("#F5F6FA");

  static Color greenBase = HexColor.fromHex("#25B84C");
  static Color greenLighter = HexColor.fromHex("#DCFAE0");
  static Color greenLightest = HexColor.fromHex("#E5FFE9");

  static Color systemAttentionHover = HexColor.fromHex("#F29303");
  static Color systemAttentionTertiary = HexColor.fromHex("#FDEDD4");
  static Color systemErrorPrimary = HexColor.fromHex("#E12424");

  static Color orangeBase = HexColor.fromHex("#F59120");
  static Color orangeLighter = HexColor.fromHex("#FBEBDB");
  static Color orangeLightest = HexColor.fromHex("#FBEBDB");

  static Color redBase = HexColor.fromHex("#D62F2F");
  static Color redLightest = HexColor.fromHex("#FDE8E8");

  static Color blueLightest = HexColor.fromHex("#EBF8FF");

  static Color greyScale = HexColor.fromHex("##8492A6");

  static Color shadowColor = HexColor.fromHex("#E8EDF3");
}

extension HexColor on Color {
  static Color fromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = "FF$hex"; // 8 char with opacity 100%
    }
    return Color(int.parse(hex, radix: 16));
  }
}
