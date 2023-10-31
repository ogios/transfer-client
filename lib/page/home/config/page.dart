import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfer_client/page/home/config/proxy/sec.dart';
import 'package:transfer_client/page/home/config/tserv/sec.dart';
import 'package:transfer_client/page/home/config/udp/sec.dart';
import 'package:transfer_client/page/home/custom_component.dart';
import 'package:transfer_client/page/home/homepage.dart';

class Config {
  bool done = false;
  String host = "";
  int port = 0;
  int u_port = 0;
  String p_host = "";
  int p_port = 0;
  String p_key = "";
  bool p_enable = false;

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
  List<Widget> ConfigViews = [
    TservConfig(),
    UDPConfig(),
    ProxyConfig(),
  ];

  @override
  void initState() {
    super.initState();
    initViews();
  }

  void initViews() async {
    // print("Gobalconfig: ${GlobalConfig.toString()}");
    // var temp = <Widget>[
    //   TservConfig(),
    //   // CHost(),
    //   // CPort(),
    // ];
    // for (Widget a in temp) {
    //   ConfigViews.add(
    //       // Card(color: actionColor, child: SizedBox.expand(child: a)));
    //       // SizedBox.expand(child: a));
    //       Container(
    //         padding: const EdgeInsets.all(5), color: accentCanvasColor,
    //         child: a,
    //       ));
    //   // a);
    //   // ConfigViews.add(const Divider());
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomBar(
            Text(
              "Config",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            null),
        // body: ListWheelScrollView(
        //   itemExtent: 500,
        //   children: ConfigViews,
        // ));
        body: ListView(
          children: ConfigViews,
        ));
  }
}
