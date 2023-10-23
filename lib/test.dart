import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ogios_sutils/in.dart';
import 'package:ogios_sutils/out.dart';

Future test4() async {
  Socket s = await Socket.connect("192.168.0.108", 15001);
  SocketOut so = SocketOut();
  so.addBytes(Uint8List.fromList("fetch_byte".codeUnits));
  so.addBytes(Uint8List.fromList(utf8.encode("pPGWp")));
  await so.writeTo(s);
  SocketIn si = SocketIn(conn: s);
  while (!si.raw.isDone()) {
    await Future.delayed(Duration(milliseconds: 500));
  }
  log("${si.raw}");
}

Future test3() async {
  Socket s = await Socket.connect("192.168.0.108", 15001);
  SocketOut so = SocketOut();
  so.addBytes(Uint8List.fromList("fetch_byte".codeUnits));
  so.addBytes(Uint8List.fromList(utf8.encode("pPGWp")));
  await so.writeTo(s);
  SocketIn si = SocketIn(conn: s);
  // status
  Uint8List sec = await si.getSec();
  String status = utf8.decode(sec);
  log("$status");
  // filename
  sec = await si.getSec();
  String filename = utf8.decode(sec);
  log("$filename");
  // file data
  List<int> final_bytes = [];
  int total = await si.next();
  int current = 0;
  var temp = Uint8List(1024*64);
  int read;
  while (current < total) {
    read = await si.read(temp);
    final_bytes.addAll(temp.sublist(0, read));
    current += read;
    log("added: ${read} | !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  }
  // print("sec: $sec");
  // print("sec to string: ${String.fromCharCodes(sec)}");
}