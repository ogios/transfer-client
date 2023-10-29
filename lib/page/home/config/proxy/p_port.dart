import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfer_client/main.dart';
import 'package:transfer_client/page/home/config/page.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';

class PPort extends StatelessWidget implements ConfigWiget{
  PPort({super.key}) {
    textEditingController.text = GlobalConfig.p_port.toString();
  }
  Config global = GlobalConfig;
  static final String PrefKey = "config.p_port";

  static void setConfig(Config global, int val) {
    global.p_port = val;
  }

  TextEditingController textEditingController = TextEditingController();
  Timer timer = Timer(const Duration(microseconds: 0), () {});
  void onHostCommit(String p) async {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 1), () async {
      int port = int.parse(p);
      setConfig(global, port);
      (await SharedPreferences.getInstance()).setInt(PrefKey, port);
      GlobalFtoast.success("Port Saved", null, immediate: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      leading: const Icon(
        Icons.lens_blur,
        size: 40,
        color: Colors.white,
      ),
      title: const Text("Port"),
      subtitle: TextField(
        keyboardType: TextInputType.number,
        controller: textEditingController,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
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
    int a;
    try {
      a = prefs.getInt(PrefKey)!;
    } catch (err) {
      a = 15003;
    }
    setConfig(global, a);
  }
}
