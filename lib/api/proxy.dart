import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:ogios_sutils/in.dart';
import 'package:ogios_sutils/out.dart';

import '../page/home/config/page.dart';

class ProxyServ {
  bool running = false;
  late Timer _timer;

  Future<void> runProxy(Timer? t) async {
    try {
      log("syncing...");
      await _runProxy();
    } catch (err) {
      Fluttertoast.showToast(msg: 'Err in fetch: ${err}');
      log("Error in async fetch!! ", error: err);
    }
  }

  Future<void> _runProxy() async {
    String raw = await getServerData();
    processServerData(raw);
  }

  SocketOut _getSo() {
    SocketOut so = SocketOut();
    so.addBytes(Uint8List.fromList("cli".codeUnits));
    return so;
  }

  Future<void> processServerData(String raw) async {
    Map<String, dynamic> response = json.decode(raw);
    if (response.isEmpty) throw Exception("No data received");
    List<dynamic> metas = response["data"] as List<dynamic>;
    List<Message> processed = [];
    for (Map<String, dynamic> meta in metas) {
      if (!meta.containsKey("type") || !meta.containsKey("id")) {
        processed.add(Message(
            title: "Unknow type or id",
            content: meta.toString(),
            error: true,
            icon: Icons.error,
            type: TYPE_TEXT,
            raw_map: meta,
            id: "-1"));
      } else {
        switch (meta["type"] as int) {
          case TYPE_TEXT:
            processed.add(Message(
                raw_map: meta,
                id: meta["id"],
                type: TYPE_TEXT,
                title: formatTime(meta["time"]),
                content: meta["data"],
                icon: Icons.textsms));
            break;
          case TYPE_BYTE:
            processed.add(Message(
                raw_map: meta,
                id: meta["id"],
                type: TYPE_BYTE,
                icon: Icons.file_present_rounded,
                title: meta["data"]["filename"],
                content:
                '${formatSize((meta["data"]["size"] as int).toDouble())} - ${formatTime(meta["time"])}'));
            break;
          default:
            processed.add(Message(
                raw_map: meta,
                id: "-1",
                title: "Unknow type",
                content: meta.toString(),
                type: TYPE_TEXT,
                icon: Icons.error,
                error: true));
        }
      }
    }
    return processed;
  }

  Future<String> getServerData() async {
    Socket socket;
    try {
      socket = await Socket.connect(GlobalConfig.p_host, GlobalConfig.p_port,
          timeout: const Duration(seconds: 5));
    } catch (err) {
      log("Socket connection error: $err; Config: $GlobalConfig");
      rethrow;
    }
    try {
      SocketOut so = this._getSo();
      await so.writeTo(socket);
      SocketIn sin = SocketIn(conn: socket);
      Uint8List status = await sin.getSec();
      if (String.fromCharCodes(status) == "success") {
        Uint8List data = await sin.getSec();
        return utf8.decode(data);
      } else if (String.fromCharCodes(status) == "error") {
        throw Exception(utf8.decode(await sin.getSec()));
      } else {
        throw Exception("Unknow status: $status");
      }
    } catch (err) {
      log("transmit err: $err");
      socket.close();
      rethrow;
    }
  }

  void startProxy() {
    log("start proxy");
    if (running) return;
    running = true;
    runProxy(null);
    _timer = Timer.periodic(const Duration(seconds: 20), runProxy);
  }

  void stopProxy() {
    log("stop proxy");
    running = false;
    _timer.cancel();
  }
}
