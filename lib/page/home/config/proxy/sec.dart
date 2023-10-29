import 'package:flutter/material.dart';
import 'package:transfer_client/page/home/config/proxy/p_enable.dart';
import 'package:transfer_client/page/home/custom_component.dart';
import 'package:transfer_client/page/home/homepage.dart';

import 'p_host.dart';
import 'p_port.dart';

class ProxyConfig extends StatelessWidget {

  List<Widget> getProxyConfig() {
    List<Widget> b = [];
    var temp = <Widget>[
      PEnable(),
      PHost(),
      PPort(),
    ];
    for (Widget a in temp) {
      // b.add(Card(color: actionColor, child: SizedBox.expand(child: a)));
      b.add(Card(color: actionColor, child: a));
    }
    return b;
  }

  @override
  Widget build(BuildContext context) {
    return CustomConfigSec(
        context,
        "Proxy Server",
        Column(
          children: getProxyConfig(),
        ));
  }
}
