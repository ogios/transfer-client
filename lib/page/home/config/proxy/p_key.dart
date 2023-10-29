import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfer_client/main.dart';
import 'package:transfer_client/page/home/config/page.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';

class PKey extends StatelessWidget implements ConfigWiget {
  PKey({super.key}) {
    textEditingController.text = GlobalConfig.p_key;
  }

  Config global = GlobalConfig;
  static final String PrefKey = "config.p_key";

  static void setConfig(Config global, String val) {
    global.p_key = val;
  }

  TextEditingController textEditingController =TextEditingController();
  Timer timer = Timer(const Duration(microseconds: 0), () {});

  void onHostCommit(String host) async {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 1), () async {
      setConfig(global, host);
      (await SharedPreferences.getInstance()).setString(PrefKey, host);
      GlobalFtoast.success("Key Saved", null, immediate: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      leading: const Icon(
        Icons.key,
        size: 40,
        color: Colors.white,
      ),
      title: const Text("Key"),
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
      a = "foobar";
    }
    setConfig(global, a);
  }
}
