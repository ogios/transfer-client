import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:transfer_client/page/home/config/page.dart';

class MsgSubcribe {
  bool running = false;
  Timer? _timer;
  bool subed = false;
  RawDatagramSocket? socket;
  Function callback = () {};

  void setCallback(Function call) {
    this.callback = call;
  }

  void clearCallback() {
    this.callback = () {};
  }

  void onMsgCallback(Uint8List data) {
    log("receiev from udps: $data");
    if (data.length == 1) {
      if (data[0] == 2) {
        log("received notify");
        callback();
      } else if (data[0] == 1) {
        this.socket!.send(
            [1], InternetAddress(GlobalConfig.u_host), GlobalConfig.u_port);
      }
    } else if (String.fromCharCodes(data) == "ok") {
      subed = true;
    }
  }

  void startSub() {
    if (this.running) return;
    () async {
      var socket = await RawDatagramSocket.bind(InternetAddress("0.0.0.0"), 15012);
      this.running = true;
      this.socket = socket;
      socket.listen((e) async {
        if (e == RawSocketEvent.read) {
          Uint8List data = socket.receive()!.data;
          onMsgCallback(data);
        }
      });
      await sub(null);
      _timer = Timer.periodic(const Duration(seconds: 30), sub);
    }();
  }

  void stopSub() {
    if (this._timer != null) {
      this._timer!.cancel();
    }
    this.running = false;
  }

  Future<void> sub(Timer? t) async {
    this.subed = false;
    while (!this.subed && this.running) {
      this.socket!.send("sub".codeUnits, InternetAddress(GlobalConfig.u_host),
          GlobalConfig.u_port);
      await Future.delayed(Duration(seconds: 3));
    }
  }
}
