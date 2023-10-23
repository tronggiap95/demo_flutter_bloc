import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octo360/data/local/bridge/octo_beat/handler/octo_beat_symtoms_trigger_handler.dart';
import 'package:octo360/data/remote/socketio/socket_manager.dart';
import 'package:octo360/domain/bloc/global_bloc.dart';
import 'package:octo360/domain/bloc/onboarding/splash_screen_bloc.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/values/values_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _subscribeOctoBeatSymptomsEvent(context);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

    context.read<SplashScreenBloc>().setUpAppConfiguration();
    context.read<GlobalBloc>().initForceGroundService();

    super.initState();
  }

  void _subscribeOctoBeatSymptomsEvent(BuildContext context) {
    OctoBeatSymtomsTriggerHandler.start(context);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: ColorsApp.primaryBase,
        elevation: ElevationApp.ev0,
        systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
      ),
      body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(color: ColorsApp.primaryBase),
          child: Container(
            margin: const EdgeInsets.only(bottom: kToolbarHeight),
            child: Center(child: SvgPicture.asset(ImagesApp.logoSplashScreen)),
          )),
    );
  }
}
