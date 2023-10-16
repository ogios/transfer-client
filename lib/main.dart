import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transfer_client/api/fetch.dart';
import 'package:transfer_client/page/home/homepage.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  GlobalFetcher.startSync();
  runApp(MaterialApp(
    builder: FToastBuilder(),
    navigatorKey: navigatorKey,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: HomePage(),
  ));
}