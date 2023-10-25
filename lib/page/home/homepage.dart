import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:transfer_client/page/home/download/page.dart';
import 'package:transfer_client/page/home/upload/page.dart';

import 'config/page.dart';
import 'main/page.dart';

// class HomePage extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     GlobalFtoast.init(navigatorKey.currentContext!);
//     return Scaffold(
//       body: PageView(
//         children: [
//           MessagePage(),
//           UploadPage(),
//           DownloadPage(),
//           ConfigPage(),
//         ],
//       ),
//     );
//   }
// }

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
    required this.controller,
  }) : super(key: key);

  static var menu = const [
    SidebarXItem(
      icon: Icons.messenger,
      label: 'Message',
    ),
    SidebarXItem(
      icon: Icons.upload_file_rounded,
      label: 'Uploads',
    ),
    SidebarXItem(
      icon: Icons.download_for_offline,
      label: 'Downloads',
    ),
    SidebarXItem(
      icon: Icons.settings,
      label: 'Config',
    ),
  ];

  static ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      primaryColor: primaryColor,
      canvasColor: canvasColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textButtonTheme: TextButtonThemeData(style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(canvasColor),
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.focused) &&
                !states.contains(MaterialState.pressed)) {
              //获取焦点时的颜色
              return Colors.blue;
            } else if (states.contains(MaterialState.pressed)) {
              //按下时的颜色
              return Colors.deepPurple;
            }
            //默认状态使用灰色
            return Colors.white;
          },
        ),
      )),
      textTheme: const TextTheme(
        labelMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: 46,
          fontWeight: FontWeight.w800,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white));

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        switch (controller.selectedIndex) {
          case 0:
            return MessagePage();
          case 1:
            return UploadPage();
          case 2:
            return DownloadPage();
          case 3:
            return ConfigPage();
          default:
            return Text(
              'Not found page',
              style: theme.textTheme.headlineSmall,
            );
        }
      },
    );
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
const actionColor = Color(0xFF5F5FA7);

final divider = Divider(color: white.withOpacity(0.3), height: 1);
