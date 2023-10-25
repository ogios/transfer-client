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
