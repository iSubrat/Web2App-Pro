// lib/main.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'AppTheme.dart';
import 'app_localizations.dart';
import 'model/LanguageModel.dart';
import 'screen/DataScreen.dart';
import 'utils/common.dart';
import 'utils/constant.dart';
import 'component/NoInternetConnection.dart';
import 'store/AppStore.dart';

AppStore appStore = AppStore();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = HttpOverridesSkipCertificate();
  runApp(AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({Key? key}) : super(key: key);

  Future<void> _initEverything() async {
    // your custom init (e.g. shared prefs, DB, etc.)
    await initialize();

    // set up MobX store
    appStore.setDarkMode(aIsDarkMode: getBoolAsync(isDarkModeOnPref));
    appStore.setLanguage(getStringAsync(APP_LANGUAGE, defaultValue: 'en'));

    // mobile-only services
    if (isMobile) {
      await MobileAds.instance.initialize();

      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.Debug.setAlertLevel(OSLogLevel.none);
      OneSignal.consentRequired(false);

      OneSignal.initialize(
        getStringAsync(ONESINGLE, defaultValue: mOneSignalID),
      );
      OneSignal.Notifications.requestPermission(true);
      OneSignal.Notifications.addForegroundWillDisplayListener(
        (event) {
          // display even when in foreground
          event.preventDefault();
          event.notification.display();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initEverything(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // while we’re waiting, show a simple splash
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: Scaffold(
              backgroundColor:
                  AppTheme.lightTheme.scaffoldBackgroundColor,
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        // once done, launch the real app
        return const MyApp();
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // status bar color
    setStatusBarColor(
      appStore.primaryColors,
      statusBarBrightness: Brightness.light,
    );

    // listen for connectivity changes
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      appStore.setConnectionState(result);
      if (result == ConnectivityResult.none) {
        log('No internet – showing offline screen');
        push(const NoInternetConnection());
      } else {
        log('Connected – popping offline screen');
        pop();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,

        // decide home based on network
        home: appStore.isNetworkAvailable
            ? const DataScreen()
            : const NoInternetConnection(),

        // localization
        supportedLocales: Language.languagesLocale(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, locales) => locale,
        locale: Locale(
          getStringAsync(APP_LANGUAGE, defaultValue: 'en'),
        ),

        // theming
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode:
            appStore.isDarkModeOn! ? ThemeMode.dark : ThemeMode.light,

        navigatorKey: navigatorKey,
        scrollBehavior: SBehavior(),
      );
    });
  }
}
