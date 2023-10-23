import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfer_client/api/fetch.dart';
import 'package:transfer_client/page/home/config/c_host.dart';
import 'package:transfer_client/page/home/config/c_port.dart';
import 'package:transfer_client/page/home/config/page.dart';
import 'package:transfer_client/page/home/homepage.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:transfer_client/receive_share.dart';


const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initConfig() async {
  print("Gobalconfig: ${GlobalConfig.toString()}");
  var prefs = await SharedPreferences.getInstance();
  CHost.initConfig(GlobalConfig, prefs);
  CPort.initConfig(GlobalConfig, prefs);
  GlobalConfig.done = true;
  GlobalFetcher.startSync();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initReceiver();
  runApp(MaterialApp(
    builder: FToastBuilder(),
    navigatorKey: navigatorKey,
    theme: ThemeData(
      // primaryColor: primaryColor,
      // canvasColor: canvasColor,
      // scaffoldBackgroundColor: scaffoldBackgroundColor,
      // textTheme: const TextTheme(
      //   headlineSmall: TextStyle(
      //     color: Colors.white,
      //     fontSize: 46,
      //     fontWeight: FontWeight.w800,
      //   ),
      // ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    // home: HomePage(),
    home: FutureBuilder(
      future: initConfig(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return HomePage();
        } else {
          return const CircularProgressIndicator();
        }
      },
    ),
  ));
}