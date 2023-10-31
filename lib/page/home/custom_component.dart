import 'package:flutter/material.dart';
import 'package:transfer_client/api/proxy.dart';
import 'package:transfer_client/page/home/config/page.dart';

import 'homepage.dart';

PreferredSizeWidget CustomBar(Widget title, List<Widget>? actions) {
  if (GlobalConfig.p_enable) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: FutureBuilder(
        future: GlobalProxy.getServer(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AppBar(
              backgroundColor: canvasColor,
              title: title,
              actions: actions,
            );
          } else if (snapshot.hasError) {
            return Text(
              'Error: ${snapshot.error}',
              style: Theme.of(context).textTheme.titleLarge,
            );
          } else {
            String text = (title as Text).data!;
            List<dynamic> server = snapshot.data;
            return AppBar(
                backgroundColor: canvasColor,
                actions: actions,
                title: Flexible(
                    child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              color: actionColor,
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "$text(${server[0]}:${server[1]})",
                              ),
                            ),
                          );
                        });
                  },
                  child: Text(
                    "$text(${server[0]}:${server[1]})",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                )));
          }
        },
      ),
    );
  } else {
    return AppBar(
      backgroundColor: canvasColor,
      title: title,
      actions: actions,
    );
  }
}

Widget CustomCard(Widget child) {
  return Card(color: actionColor, child: child);
}

Widget CustomConfigSec(BuildContext context, String title, Widget child) {
  return Container(
    padding: const EdgeInsets.all(5),
    child: Container(
      // padding: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
      color: accentCanvasColor,
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleMedium))
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    ),
  );
}
