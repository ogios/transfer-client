import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:transfer_client/main.dart';
import 'package:transfer_client/page/home/homepage.dart';

class Desktop extends StatelessWidget {
  Desktop({Key? key}) : super(key: key);

  final _controller = SidebarXController(selectedIndex: 0);

  Widget getHomePage() {
    return Scaffold(
      body: Row(
        children: [
          SidebarX(
            controller: _controller,
            theme: SidebarXTheme(
              // margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: canvasColor,
                // borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(color: Colors.white),
              selectedTextStyle: const TextStyle(color: Colors.white),
              itemTextPadding: const EdgeInsets.only(left: 30),
              selectedItemTextPadding: const EdgeInsets.only(left: 30),
              itemDecoration: BoxDecoration(
                border: Border.all(color: canvasColor),
              ),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: actionColor.withOpacity(0.37),
                ),
                // gradient: const LinearGradient(
                //   colors: [accentCanvasColor, canvasColor],
                // ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 30,
                  )
                ],
              ),
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 20,
              ),
            ),
            extendedTheme: const SidebarXTheme(
              width: 200,
              decoration: BoxDecoration(
                color: canvasColor,
              ),
              margin: EdgeInsets.only(right: 10),
            ),
            footerDivider: divider,
            // headerBuilder: (context, extended) {
            //   return SizedBox(
            //     height: 100,
            //     child: Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Image.asset('assets/images/avatar.png'),
            //     ),
            //   );
            // },
            items: HomePage.menu,
          ),
          Expanded(
            child: Center(
              child: HomePage(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget homeBuilder() {
    return FutureBuilder(
      future: init(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return getHomePage();
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FToastBuilder(),
      navigatorKey: navigatorKey,
      title: 'SidebarX Example',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   primaryColor: primaryColor,
      //   canvasColor: canvasColor,
      //   scaffoldBackgroundColor: scaffoldBackgroundColor,
      //   textTheme: const TextTheme(
      //     headlineSmall: TextStyle(
      //       color: Colors.white,
      //       fontSize: 46,
      //       fontWeight: FontWeight.w800,
      //     ),
      //   ),
      // ),
      theme: HomePage.theme,
      home: homeBuilder(),
    );
  }
}

