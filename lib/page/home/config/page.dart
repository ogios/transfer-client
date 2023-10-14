import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfer_client/page/home/config/c_host.dart';
import 'package:transfer_client/page/home/config/c_port.dart';

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
  void initConfig(Config global, SharedPreferences prefs) async {}

  @override
  Element createElement() {
    // TODO: implement createElement
    throw UnimplementedError();
  }
}

class ConfigPage extends StatelessWidget {
  late final SharedPreferences prefs;
  List<Widget> ConfigViews = [];

  ConfigPage({super.key}) {
    initViews(config: true,view: true);
  }

  void initViews({bool config = false, bool view = false}) async {
    print("Gobalconfig: ${GlobalConfig.toString()}");
    prefs = await SharedPreferences.getInstance();
    var temp = <ConfigWiget>[
      CHost(global: GlobalConfig),
      CPort(global: GlobalConfig),
    ];
    for (ConfigWiget a in temp) {
      a.initConfig(GlobalConfig, prefs);
      ConfigViews.add(
          Card(child: SizedBox.expand(child: a)));
      // ConfigViews.add(const Divider());
    }
    GlobalConfig.done = true;
  }

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView(
      itemExtent: 100,
      children: ConfigViews,
    );
  }
}
