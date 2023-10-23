import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';
import 'package:octo360/presentation/widgets/app_bar/custom_app_bar/custom_app_bar.dart';
import 'package:octo360/presentation/widgets/button/fill_button/fill_button.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _renderAppBar(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: MarginApp.m16, vertical: PaddingApp.p24),
        decoration: BoxDecoration(
          color: ColorsApp.primaryBase,
          image: DecorationImage(
              image: AssetImage(ImagesApp.welcomeBackground), fit: BoxFit.fill),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _renderContent(),
            _renderButton(),
          ],
        ),
      ),
    );
  }

  CustomAppBar _renderAppBar() {
    return const CustomAppBar(
      height: SizeApp.s0,
    );
  }

  Widget _renderContent() {
    return Column(
      children: [
        const SizedBox(height: MarginApp.m100),
        SvgPicture.asset(
          height: 100,
          ImagesApp.logoSplashScreen,
          colorFilter: ColorFilter.mode(ColorsApp.primaryBase, BlendMode.srcIn),
          fit: BoxFit.cover,
        ),
        const SizedBox(height: MarginApp.m48),
        Text(
          StringsApp.trackingHealthPhysicAndLife,
          textAlign: TextAlign.center,
          style: TextStylesApp.medium(
              color: ColorsApp.coalDark, fontSize: FontSizeApp.s24),
        ),
      ],
    );
  }

  Widget _renderButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: MarginApp.m16),
      child: SizedBox(
          width: double.infinity,
          child: FilledButtonApp(
              label: StringsApp.start,
              onPressed: () {
                NavigationApp.routeTo(context, Routes.logInScreenRoute);
              })),
    );
  }
}
