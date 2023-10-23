import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octo360/application/enum/app_lifecycle_state_enum.dart';
import 'package:octo360/data/di/di.dart';
import 'package:octo360/data/local/bridge/scanner/ble_scanner_plugin.dart';
import 'package:octo360/data/local/notification/local_notification_services.dart';
import 'package:octo360/data/local/share_pref/shared_pref.dart';
import 'package:octo360/domain/bloc/global_bloc.dart';
import 'package:octo360/domain/model/global/global_state.dart';
import 'package:octo360/l10n/locale_enum.dart';
import 'package:octo360/l10n/support_locales.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/providers/root/root_provider.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';
import 'package:octo360/src/styles/theme_manager.dart';
import 'package:octo_beat_plugin/octo_beat_plugin.dart';

import 'presentation/navigation/observer/route_observer_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white),
  );

  initModule();
  LocalNotificationServices.init();
  OctoBeatPlugin.subscribeEvents();
  BleScannerPlugin.subscribeBluetoothStateEvents();
  runApp(rootProvider());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    SharedPref.setAppLifecycleState(AppLifecycleStateEnum.active);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        await SharedPref.setAppLifecycleState(AppLifecycleStateEnum.active);
        break;
      case AppLifecycleState.inactive:
        await SharedPref.setAppLifecycleState(AppLifecycleStateEnum.inactive);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GlobalBloc, GlobalState, LocaleEnum>(
      selector: (state) {
        return state.currentLocale;
      },
      builder: (context, currentLocale) {
        return MaterialApp(
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaleFactor: 1.0),
              child: child ?? const SizedBox.shrink(),
            );
          },
          key: ValueKey(currentLocale),
          localizationsDelegates: localeDelagates,
          supportedLocales: supportLocales,
          locale: currentLocale.getLocale,
          navigatorKey: NavigationApp.navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: ThemeApp.getTheme(),
          onGenerateRoute: NavigationApp.getRoutes,
          initialRoute: Routes.splashScreenRoute,
          navigatorObservers: RouteObserverManager.listRouteObserver,
        );
      },
    );
  }
}
