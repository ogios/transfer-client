import 'dart:io';

import 'package:transfer_client/page/home/config/page.dart';

class SocketRequest {
  Socket conn;

  SocketRequest({required this.conn});
}

Future<SocketRequest> request() async {
  while (!GlobalConfig.done) {
    await Future.delayed(Duration(seconds: 1));
  }
  Socket c = await Socket.connect(GlobalConfig.host, GlobalConfig.port);
  return SocketRequest(conn: c);
}