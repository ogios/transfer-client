import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfer_client/main.dart';
import 'package:transfer_client/page/home/config/page.dart';

class UHost extends StatelessWidget implements ConfigWiget {
  UHost({super.key}) {
    textEditingController = TextEditingController();
    textEditingController.text = GlobalConfig.u_host;
    fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
  }

  Config global = GlobalConfig;
  static final String PrefKey = "config.u_host";
  late FToast fToast;

  static void setConfig(Config global, String val) {
    global.u_host = val;
  }

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(0.0),
      color: Colors.greenAccent,
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check),
        SizedBox(
          width: 12.0,
        ),
        Text("Host saved"),
      ],
    ),
  );

  late TextEditingController textEditingController;
  Timer timer = Timer(const Duration(microseconds: 0), () {});

  void onHostCommit(String host) async {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 1), () async {
      setConfig(global, host);
      (await SharedPreferences.getInstance()).setString(PrefKey, host);
      fToast.showToast(child: toast, gravity: ToastGravity.TOP_RIGHT);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      leading: const Icon(
        Icons.home,
        size: 40,
        color: Colors.white,
      ),
      title: const Text("Host"),
      subtitle: TextField(
        controller: textEditingController,
        onSubmitted: onHostCommit,
        onChanged: onHostCommit,
        cursorColor: Colors.white,
        decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white))),
      ),
    );
  }

  @override
  static Future<void> initConfig(Config global, SharedPreferences prefs) async {
    String a;
    try {
      a = prefs.getString(PrefKey)!;
    } catch (err) {
      a = "127.0.0.1";
    }
    setConfig(global, a);
  }
}
