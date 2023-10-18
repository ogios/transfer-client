import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transfer_client/main.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';

import 'main/page.dart';
import 'config/page.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    GlobalFtoast.init(navigatorKey.currentContext!);
    return Scaffold(
      body: PageView(
        children: [
          MessagePage(),
          ConfigPage(),
        ],
      ),
    );
  }
}