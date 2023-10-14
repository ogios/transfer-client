import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main/page.dart';
import 'config/page.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
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