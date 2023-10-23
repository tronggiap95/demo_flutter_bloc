import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octo360/data/di/di.dart';
import 'package:octo360/domain/bloc/account/complete_profile_screen_bloc.dart';
import 'package:octo360/domain/bloc/account/log_in_screen_bloc.dart';
import 'package:octo360/domain/bloc/account/receive_otp_screen_bloc.dart';
import 'package:octo360/presentation/screens/accounts/complete_profile_screen.dart';
import 'package:octo360/presentation/screens/accounts/login_screen.dart';
import 'package:octo360/presentation/screens/accounts/receive_otp_screen.dart';

final loginScreenProvider = BlocProvider(
  create: (_) => LogInScreenBloc(instance()),
  child: const LoginScreen(),
);

final receiveOtpScreenProvider = BlocProvider(
  create: (_) => ReceiveOtpScreenBloc(instance()),
  child: const ReceiveOtpScreen(),
);

final completeProfileScreenProvider = BlocProvider(
  create: (_) => CompleteProfileScreenBloc(instance()),
  child: const CompleteProfileScreen(),
);
