import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class ThemeApp {
  static ThemeData getTheme() {
    return ThemeData(
        // main colors
        colorScheme: ColorScheme.fromSwatch(
          errorColor: ColorsApp.systemErrorPrimary,
          accentColor: ColorsApp.primaryBase,
          backgroundColor: ColorsApp.white,
          cardColor: ColorsApp.white,
        ),
        primaryColorLight: ColorsApp.primaryBase,
        canvasColor: ColorsApp.white,
        disabledColor: ColorsApp.primaryLight,
        // ripple color
        splashColor: ColorsApp.primaryLight,
        //App bar
        appBarTheme: _appBarTheme(),
        pageTransitionsTheme: _pageTransitionsTheme(),
        textButtonTheme: _textButtonThemeData(),
        // Elevated Button
        elevatedButtonTheme: _elevatedButtonThemeData(),
        //Outline Button
        outlinedButtonTheme: _outlinedButtonTheme(),
        // Text theme
        // input decoration theme (text form field)
        inputDecorationTheme: _inputDecorationTheme());
  }

  static AppBarTheme _appBarTheme() {
    return AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: ColorsApp.primaryBase,
            statusBarBrightness: Brightness.dark, //For iOS
            statusBarIconBrightness: Brightness.light //For android
            ),
        centerTitle: true,
        color: ColorsApp.white,
        elevation: ElevationApp.ev4,
        titleTextStyle: TextStylesApp.bold(
            color: ColorsApp.coalDarker, fontSize: FontSizeApp.s26));
  }

  static PageTransitionsTheme _pageTransitionsTheme() {
    return const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    });
  }

  static TextButtonThemeData _textButtonThemeData() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorsApp.primaryBase,
        textStyle: TextStylesApp.bold(
            color: ColorsApp.primaryBase, fontSize: FontSizeApp.s14),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonThemeData() {
    return ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            elevation: ElevationApp.ev2,
            padding: const EdgeInsets.symmetric(horizontal: PaddingApp.p24),
            fixedSize: const Size(ButtonSizeApp.width, ButtonSizeApp.height),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BorderRadiusApp.r8)),
            backgroundColor: ColorsApp.primaryBase,
            disabledBackgroundColor: ColorsApp.primaryLight,
            textStyle: TextStylesApp.bold(
                color: ColorsApp.white, fontSize: FontSizeApp.s16)));
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: ColorsApp.fogBackground,
        foregroundColor: ColorsApp.coalDarkest,
        fixedSize: const Size.fromHeight(SizeApp.s44),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BorderRadiusApp.r8),
            side: BorderSide(
                color: ColorsApp.coalDarkest, width: BorderWidthApp.w2)),
        side: BorderSide(
          color: ColorsApp.coalDarkest,
          width: BorderWidthApp.w2,
        ),
        textStyle: TextStylesApp.bold(color: ColorsApp.coalDarkest),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: ColorsApp.fogBackground,
      contentPadding: const EdgeInsets.all(PaddingApp.p12),
      hintStyle: TextStylesApp.regular(
              color: ColorsApp.greenBase, fontSize: FontSizeApp.s16)
          .copyWith(letterSpacing: 0),
      labelStyle: TextStylesApp.medium(
          color: ColorsApp.greyScale, fontSize: FontSizeApp.s14),
      errorStyle: TextStylesApp.regular(
          color: Colors.transparent, fontSize: FontSizeApp.s14),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: ColorsApp.fogBackground, width: BorderWidthApp.w1),
          borderRadius:
              const BorderRadius.all(Radius.circular(BorderRadiusApp.r10))),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: ColorsApp.coalDarkest, width: BorderWidthApp.w1),
          borderRadius:
              const BorderRadius.all(Radius.circular(BorderRadiusApp.r10))),
      errorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: ColorsApp.redBase, width: BorderWidthApp.w1),
          borderRadius:
              const BorderRadius.all(Radius.circular(BorderRadiusApp.r10))),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: ColorsApp.coalDarkest, width: BorderWidthApp.w1),
          borderRadius:
              const BorderRadius.all(Radius.circular(BorderRadiusApp.r10))),
    );
  }
}
