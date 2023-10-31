import 'package:flutter/material.dart';
import 'package:transfer_client/page/home/custom_component.dart';
import 'package:transfer_client/page/home/homepage.dart';

import 'u_port.dart';

class UDPConfig extends StatelessWidget {
  List<Widget> getTservConfig() {
    List<Widget> b = [];
    var temp = <Widget>[
      UPort(),
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
        "UDP Subcription",
        Column(
          children: getTservConfig(),
        ));
  }
}
