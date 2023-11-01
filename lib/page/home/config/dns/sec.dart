import 'package:flutter/material.dart';
import 'package:transfer_client/page/home/config/proxy/p_enable.dart';
import 'package:transfer_client/page/home/custom_component.dart';
import 'package:transfer_client/page/home/homepage.dart';

import 'd_enable.dart';


class DnsConfig extends StatelessWidget {

  List<Widget> getProxyConfig() {
    List<Widget> b = [];
    var temp = <Widget>[
      DEnable(),
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
        "DNS lookup",
        Column(
          children: getProxyConfig(),
        ));
  }
}
