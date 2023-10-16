

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ogios_sutils/in.dart';
import 'package:ogios_sutils/out.dart';
import 'package:transfer_client/page/home/config/page.dart';

class UTServ {
  static Future<String> uploadText(String content) async {
    SocketOut sout = SocketOut();
    sout.addBytes(Uint8List.fromList("text".codeUnits));
    sout.addBytes(Uint8List.fromList(utf8.encode(content)));
    Socket socket = await _getConn();
    try {
      sout.writeTo(socket);
      SocketIn sin = SocketIn(conn: socket);
      Uint8List sec = await sin.getSec();
      String status = String.fromCharCodes(sec);
      if (status == "error") {
        String error_msg = String.fromCharCodes(await sin.getSec());
        throw Exception("remote error: $error_msg");
      } else if (status == "success") {
        return "Upload text success";
      } else {
        throw Exception("remote error: Unknow status: $status");
      }
    } catch (err) {
      socket.close();
      throw Exception("Upload text error: $err");
    }
  }


  static Future<Socket> _getConn() async {
    return await Socket.connect(GlobalConfig.host, GlobalConfig.port);
  }
}