import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfer_client/api/proxy.dart';
import 'package:transfer_client/page/home/config/page.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';

class DEnable extends StatefulWidget implements ConfigWiget {
  DEnable({super.key});

  @override
  State<StatefulWidget> createState() => _DEnable();

  Config global = GlobalConfig;
  static final String PrefKey = "config.d_enable";

  static void setConfig(Config global, bool val) {
    global.d_enable = val;
  }

  @override
  static Future<void> initConfig(Config global, SharedPreferences prefs) async {
    bool a;
    try {
      a = prefs.getBool(PrefKey)!;
    } catch (err) {
      a = false;
    }
    setConfig(global, a);
  }
}

class _DEnable extends State<DEnable> {

  TextEditingController textEditingController = TextEditingController();
  Timer timer = Timer(const Duration(microseconds: 0), () {});

  void onCommit(bool p) async {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 1), () async {
      (await SharedPreferences.getInstance())
          .setBool(DEnable.PrefKey, getVal());
      GlobalFtoast.success("State Saved", null, immediate: true);
    });
    if (p) {
      GlobalProxy.startProxy();
    } else {
      GlobalProxy.stopProxy();
    }
  }

  String getDesc() {
    if (GlobalConfig.d_enable) {
      return "v6";
    } else {
      return "v4";
    }
  }

  bool getVal() {
    return GlobalConfig.d_enable;
  }
  void setVal(bool val) {
    GlobalConfig.d_enable = val;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 80,
        ),
        const Icon(
          Icons.network_ping,
          size: 40,
          color: Colors.white,
        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(
          child: Text(
            getDesc(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Switch(
          value: getVal(),
          onChanged: (val) {
            onCommit(val);
            setState(() {
              setVal(val);
            });
          },
        ),
        const SizedBox(
          width: 20,
          height: 80,
        ),
      ],
    );
  }
}
