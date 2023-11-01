import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:ogios_sutils/in.dart';
import 'package:ogios_sutils/out.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';

import '../page/home/config/page.dart';

class ServerInfo {
  List<String> v6 = [];
  List<String> v4 = [];
  int port = -1;
}

class ProxyServ {
  bool running = false;
  Object? err;
  late Timer _timer;
  String? host;
  int? port;

  Future<List<dynamic>> getServer() async {
    while ((host == null || port == null) && err == null) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (err != null) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: "Proxy server ERROR: $err");
      throw err!;
    } else {
      return [host, port];
    }
  }

  Future<void> runProxy(Timer? t) async {
    try {
      log("run proxy...");
      await _runProxy();
    } catch (err) {
      Fluttertoast.showToast(msg: 'runProxy ERROR: ${err}');
      log("runProxy ERROR!! ", error: err);
      this.err = err;
      await Future.delayed(const Duration(seconds: 3));
      runProxy(null);
    }
  }

  Future<void> _runProxy() async {
    String raw = await getServerData();
    ServerInfo si = await processServerData(raw);
    String? usable = await testInfo(si);
    if (usable == null) {
      GlobalFtoast.error("Test Proxy WARNING: Server test all fail", null);
      log("Test Proxy WARNING: Server test all fail");
      host = GlobalConfig.host;
      port = GlobalConfig.port;
    } else {
      GlobalFtoast.success("Proxy refreshed: $usable", null);
      log("Proxy refreshed: $usable");
      host = usable;
      port = si.port;
    }
  }

  Future<String?> testInfo(ServerInfo si) async {
    bool done = false;
    bool start = false;
    int count = 0;
    int done_count = 0;
    Future<String?> test(String host, int port) async {
      SocketOut so;
      try {
        while (!start) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        so = SocketOut();
        so.addBytes(Uint8List.fromList("fetch".codeUnits));
        so.addBytes(SocketOut.getLength(0));
        so.addBytes(SocketOut.getLength(0));
        try {
          Socket socket = await Socket.connect(host, port,
              timeout: const Duration(seconds: 3));
          so.writeTo(socket);
          SocketIn sin = SocketIn(conn: socket);
          Uint8List status = await sin.getSec();
          if (status[0] == 200) {
            Uint8List data = await sin.getSec();
            json.decode(utf8.decode(data));
            return host;
          }
        } catch (e) {}
      } catch (e) {
        log("TestInfo ERROR: $e");
      }
      done_count++;
      while (!done && done_count < count) {
        await Future.delayed(const Duration(seconds: 1));
      }
      return null;
    }

    List<Future<String?>> fs = [];
    for (String addr in si.v4) {
      fs.add(test(addr, si.port));
      count++;
    }
    for (String addr in si.v6) {
      fs.add(test(addr, si.port));
      count++;
    }
    start = true;

    String? res = await Future.any(fs);
    done = true;
    return res;
  }

  SocketOut _getSo() {
    SocketOut so = SocketOut();
    so.addBytes(Uint8List.fromList("client".codeUnits));
    so.addBytes(Uint8List.fromList(GlobalConfig.p_key.codeUnits));
    return so;
  }

  Future<ServerInfo> processServerData(String raw) async {
    Map<String, dynamic> response = json.decode(raw);
    if (response.isEmpty) throw Exception("No data received");

    ServerInfo si = ServerInfo();
    si.v6 = response["v6"].cast<String>();
    si.v4 = response["v4"].cast<String>();
    si.port = response["port"];
    return si;
  }

  Future<String> getServerData() async {
    Socket socket;
    try {
      String h = await parseDNS(GlobalConfig.p_host);
      socket = await Socket.connect(h, GlobalConfig.p_port,
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
        socket.close();
        return utf8.decode(data);
      } else if (String.fromCharCodes(status) == "error") {
        String error_msg = utf8.decode(await sin.getSec());
        throw Exception(error_msg);
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
    _timer = Timer.periodic(const Duration(minutes: 5), runProxy);
  }

  void stopProxy() {
    log("stop proxy");
    _timer.cancel();
    running = false;
  }
}

var GlobalProxy = ProxyServ();

Future<String> parseDNS(String host) async {
  if (GlobalConfig.d_enable) {
    List<InternetAddress> addrs =
        await InternetAddress.lookup(host, type: InternetAddressType.IPv6);
    return addrs[0].address;
  } else {
    List<InternetAddress> addrs =
        await InternetAddress.lookup(host, type: InternetAddressType.IPv4);
    return addrs[0].address;
  }
}

Future<List<dynamic>> getServer() async {
  List<dynamic> res;
  if (GlobalConfig.p_enable) {
    res = await GlobalProxy.getServer();
  } else {
    res = [GlobalConfig.host, GlobalConfig.port];
  }
  String host = res[0];
  if (!host.contains(":")) {
    final pattern = RegExp(r'[a-zA-Z]'); // 匹配小写和大写字母
    final hasLetters = pattern.hasMatch(host);
    if (hasLetters) {
      host = await parseDNS(res[0]);
    }
  }
  res[0] = host;
  return res;
}
