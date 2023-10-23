import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octo360/domain/bloc/global_bloc.dart';
import 'package:octo360/main.dart';

Widget rootProvider() {
  return MultiBlocProvider(
    providers: [
      BlocProvider<GlobalBloc>(
        create: (BuildContext context) => GlobalBloc(),
      ),
    ],
    child: const MyApp(),
  );
}
