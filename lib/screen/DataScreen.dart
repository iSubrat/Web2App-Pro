import 'package:async/async.dart';
import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../component/DeepLinkWidget.dart';
import '../model/MainResponse.dart';
import '../screen/DashboardScreen.dart';
import '../screen/ErrorScreen.dart';
import '../screen/SplashScreen.dart';
import '../utils/bloc.dart';
import '../utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

class DataScreen extends StatefulWidget {
  final MainResponse? config;

  DataScreen({required this.config});
  static String tag = '/SplashScreen';

  @override
  DataScreenState createState() => DataScreenState();
}

class DataScreenState extends State<DataScreen> {
  bool isWasConnectionLoss = false;
  AsyncMemoizer<MainResponse> mainMemoizer = AsyncMemoizer<MainResponse>();

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.cardColor,
      body: Stack(
        children: [
          Provider<DeepLinkBloc>(
            create: (context) => DeepLinkBloc(),
            dispose: (context, bloc) => bloc.dispose(),
            child: DeepLinkWidget(),
          ),
          Builder(
            builder: (context) {
              if (widget.config == null) {
                return ErrorScreen(
                  error: appLocalization!.translate('msg_wrong_url'),
                );
              }

              if (widget.config!.toJson().isNotEmpty) {
                if (widget.config!.appconfiguration!.isSplashScreen == "true") {
                  return SplashScreen();
                } else {
                  return DashBoardScreen();
                }
              } else {
                if (PURCHASE_CODE.isNotEmpty) {
                  return ErrorScreen(
                    error: (appLocalization!.translate('msg_wrong_url')!) +
                        " " +
                        (appLocalization.translate('lbl_or')!) +
                        " " +
                        appLocalization.translate('msg_add_configuration')!,
                  );
                } else {
                  return ErrorScreen(
                    error: appLocalization!.translate('msg_wrong_url'),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
