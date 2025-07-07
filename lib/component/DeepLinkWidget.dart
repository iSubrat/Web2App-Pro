import 'package:flutter/material.dart';
import 'package:mightyweb/screen/WebScreen.dart';
import '../main.dart';
import '../utils/bloc.dart';
import 'package:provider/provider.dart';

class DeepLinkWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DeepLinkBloc _bloc = Provider.of<DeepLinkBloc>(context);
    return StreamBuilder<String>(
      stream: _bloc.state.asBroadcastStream(),
      builder: (context, snapshot) {
        print("is there data in snapshot ${snapshot.data}");
        if (!snapshot.hasData) {
          return SizedBox(height: 0);
        } else {
          if (snapshot.data!.isNotEmpty) {
            Future.microtask(
              () {
                print("Navigating to WebScreen with deep link: ${snapshot.data}");
                appStore.setDeepLinkURL(snapshot.data!.toString());
                print("AppStore Deep link:" + appStore.deepLinkURL.toString());
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebScreen(mInitialUrl: snapshot.data),
                  ),
                );
              },
            );
          }
          return SizedBox();
        }
      },
    );
  }
}
