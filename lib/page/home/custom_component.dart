import 'package:flutter/material.dart';

import 'homepage.dart';

PreferredSizeWidget CustomBar(Widget title, List<Widget>? actions) {
  return AppBar(
    backgroundColor: canvasColor,
    title: title,
    actions: actions,
  );
}

Widget CustomCard(Widget child) {
  return Card(color: actionColor, child: child);
}

Widget CustomConfigSec(BuildContext context, String title, Widget child) {
  return Container(
    padding: const EdgeInsets.all(5),
    child: Container(
      // padding: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(left: 5,right: 5, top: 10, bottom: 10),
      color: accentCanvasColor,
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium)
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    ),
  );
}
