import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfer_client/main.dart';
import 'package:transfer_client/page/home/config/page.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';

class PHost extends StatelessWidget implements ConfigWiget {
  PHost({super.key}) {
    textEditingController.text = GlobalConfig.p_host;
  }

  Config global = GlobalConfig;
  static final String PrefKey = "config.p_host";

  static void setConfig(Config global, String val) {
    global.p_host = val;
  }

  TextEditingController textEditingController =TextEditingController();
  Timer timer = Timer(const Duration(microseconds: 0), () {});

  void onHostCommit(String host) async {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 1), () async {
      setConfig(global, host);
      (await SharedPreferences.getInstance()).setString(PrefKey, host);
      GlobalFtoast.success("Host Saved", null, immediate: true);
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
      // subtitle: TypeAheadField(),
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
