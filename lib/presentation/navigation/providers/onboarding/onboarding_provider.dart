import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octo360/domain/bloc/onboarding/splash_screen_bloc.dart';
import 'package:octo360/domain/bloc/onboarding/welcome_bloc.dart';
import 'package:octo360/presentation/screens/launch/splash_screen.dart';
import 'package:octo360/presentation/screens/onboarding/welcome_screen.dart';

final splashProvider = BlocProvider(
  create: (_) => SplashScreenBloc(),
  child: const SplashScreen(),
);

final welcomeProvider = BlocProvider(
  create: (_) => WelcomeBloc(),
  child: const WelcomeScreen(),
);
