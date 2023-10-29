import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfer_client/desktop.dart';
import 'package:transfer_client/mobile.dart';
import 'package:transfer_client/page/home/config/proxy/p_enable.dart';
import 'package:transfer_client/page/home/config/proxy/p_host.dart';
import 'package:transfer_client/page/home/config/proxy/p_port.dart';
import 'package:transfer_client/page/home/config/tserv/c_host.dart';
import 'package:transfer_client/page/home/config/tserv/c_port.dart';
import 'package:transfer_client/page/home/config/page.dart';
import 'package:transfer_client/page/home/config/udp/u_host.dart';
import 'package:transfer_client/page/home/config/udp/u_port.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';
import 'package:transfer_client/receive_share.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initConfig() async {
  print("Gobalconfig: ${GlobalConfig.toString()}");
  var prefs = await SharedPreferences.getInstance();
  CHost.initConfig(GlobalConfig, prefs);
  CPort.initConfig(GlobalConfig, prefs);
  UHost.initConfig(GlobalConfig, prefs);
  UPort.initConfig(GlobalConfig, prefs);
  PHost.initConfig(GlobalConfig, prefs);
  PPort.initConfig(GlobalConfig, prefs);
  PEnable.initConfig(GlobalConfig, prefs);
  GlobalConfig.done = true;
}

Future<void>? init() async {
  await initConfig();
  initReceiver();
  GlobalFtoast.init(navigatorKey.currentContext!);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isIOS || Platform.isAndroid) {
  //   runApp(Mobile());
  // } else {
  //   runApp(Desktop());
  // }
  runApp(Desktop());
}

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MaterialApp(
//     builder: FToastBuilder(),
//     navigatorKey: navigatorKey,
//     theme: ThemeData(
//       colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       useMaterial3: true,
//     ),
//     // home: HomePage(),
//     home: FutureBuilder(
//       future: init(),
//       builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return HomePage(controller: null);
//         } else {
//           return const CircularProgressIndicator();
//         }
//       },
//     ),
//   ));
// }
