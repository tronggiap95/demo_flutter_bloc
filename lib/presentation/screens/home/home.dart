import 'package:flutter/material.dart';
import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';
import 'package:octo360/presentation/widgets/button/fill_button/fill_button.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButtonApp(
              label: "SIGN OUT",
              onPressed: () {
                FactoryManager.provideGlobalRepo().handleSignOut(context);
                NavigationApp.replaceWith(context, Routes.welcomeScreenRoute);
              },
            ),
          ),
        ],
      ),
    );
  }
}
