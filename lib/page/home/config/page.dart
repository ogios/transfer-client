import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfer_client/desktop.dart';
import 'package:transfer_client/page/home/config/c_host.dart';
import 'package:transfer_client/page/home/config/c_port.dart';
import 'package:transfer_client/page/home/custom_component.dart';

import '../homepage.dart';

class Config {
  bool done = false;
  String host = "";
  int port = 0;

  @override
  String toString() {
    // TODO: implement toString
    return "${done} - ${host} - ${port}";
  }
}

Config GlobalConfig = Config();

interface class ConfigWiget extends Widget {
  static Future<void> initConfig(
      Config global, SharedPreferences prefs) async {}

  @override
  Element createElement() {
    // TODO: implement createElement
    throw UnimplementedError();
  }
}

class ConfigPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConfigPage();
}

class _ConfigPage extends State<ConfigPage> {
  late final SharedPreferences prefs;
  List<Widget> ConfigViews = [];

  @override
  void initState() {
    super.initState();
    initViews();
  }

  void initViews() async {
    print("Gobalconfig: ${GlobalConfig.toString()}");
    var temp = <ConfigWiget>[
      CHost(global: GlobalConfig),
      CPort(global: GlobalConfig),
    ];
    for (ConfigWiget a in temp) {
      ConfigViews.add(Card(color: actionColor, child: SizedBox.expand(child: a)));
      // ConfigViews.add(const Divider());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomBar(
          const Text("Config"),
          null
        ),
        body: ListWheelScrollView(
          itemExtent: 100,
          children: ConfigViews,
        ));
  }
}
