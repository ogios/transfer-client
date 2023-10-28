import 'package:flutter/material.dart';
import 'package:transfer_client/page/home/custom_component.dart';
import 'package:transfer_client/page/home/homepage.dart';

import 'c_host.dart';
import 'c_port.dart';

class TservConfig extends StatelessWidget {
  List<Widget> getTservConfig() {
    List<Widget> b = [];
    var temp = <Widget>[
      CHost(),
      CPort(),
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
        "Tserv",
        Column(
          children: getTservConfig(),
        ));
  }
}
