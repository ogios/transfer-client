import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ogios_sutils/in.dart';
import 'package:ogios_sutils/out.dart';
import 'package:transfer_client/api/subscribe.dart';
import 'package:transfer_client/page/home/config/page.dart';

import '../page/home/main/message_list.dart';

const int TYPE_TEXT = 1;
const int TYPE_BYTE = 2;
const DeepCollectionEquality deepcheck = DeepCollectionEquality();
final AsyncFetcher GlobalFetcher = AsyncFetcher();

typedef FetchCallback = Function(List<Message>, Object?);

class AsyncFetcher {
  bool running = false;
  late Timer _timer;
  List<Message> _messages = [];
  Object? _err;
  int total = 10;
  FetchCallback _defultCallback = (List<Message> msg, Object? err) {};
  FetchCallback callback = (List<Message> msg, Object? err) {};
  MsgSubcribe sub = MsgSubcribe();

  void registerCallback(Function(List<Message>, Object?) call) {
    this.callback = call;
    this.callback(_messages, _err);
  }

  void clearCallback() {
    this.callback = _defultCallback;
  }

  Future<void> syncData(Timer? t) async {
    try {
      log("syncing...");
      await _syncData();
    } catch (err) {
      Fluttertoast.showToast(msg: 'Err in fetch: ${err}');
      log("Error in async fetch!! ", error: err);
    }
  }

  void startSync() {
    log("start sync");
    if (running) return;
    running = true;
    syncData(null);
    _timer = Timer.periodic(const Duration(seconds: 20), syncData);
    sub.setCallback((){syncData(null);});
    sub.startSub();
  }

  void stopSync() {
    sub.clearCallback();
    sub.stopSub();
    log("stop sync");
    running = false;
    _timer.cancel();
  }

  void _changeMessage(List<Message> msgs) {
    log("change fetched messages");
    this._err = null;
    _messages = msgs;
    this.callback(this._messages, this._err);
  }

  Future _syncData() async {
    try {
      String rawData = await fetchDataFromBackend();
      List<Message> msgs = await this.processFetched(rawData);
      if (this._err != null || msgs.length != _messages.length) {
        /// check
        _changeMessage(msgs);
        return;
      } else {
        /// compare
        for (Message msg in msgs) {
          bool flag = false;
          for (Message oldmsg in _messages) {
            if (oldmsg.id == msg.id) {
              flag = true;
              break;
            }
          }
          if (!flag) {
            _changeMessage(msgs);
            return;
          }
        }
      }
    } catch (e) {
      this._err = e;
      this.callback(this._messages, this._err);
    }
  }

  SocketOut _getSo() {
    SocketOut so = SocketOut();
    so.addBytes(Uint8List.fromList("fetch".codeUnits));
    so.addBytes(SocketOut.getLength(0));
    so.addBytes(SocketOut.getLength(total));
    return so;
  }

  Future<String> fetchDataFromBackend() async {
    Socket socket;
    try {
      socket = await Socket.connect(GlobalConfig.host, GlobalConfig.port,
          timeout: Duration(seconds: 5));
    } catch (err) {
      log("Socket connection error: $err; Config: $GlobalConfig");
      throw err;
    }
    try {
      SocketOut so = this._getSo();
      await so.writeTo(socket);
      SocketIn sin = SocketIn(conn: socket);
      Uint8List status = await sin.getSec();
      if (status[0] == 200) {
        Uint8List data = await sin.getSec();
        return utf8.decode(data);
      } else {
        if (String.fromCharCodes(status) == "error") {
          throw Exception(utf8.decode(await sin.getSec()));
        } else {
          throw Exception("Unknow status: $status");
        }
      }
    } catch (err) {
      log("transmit err: $err");
      socket.close();
      throw err;
    }
  }

  Future<List<Message>> processFetched(String content) async {
    Map<String, dynamic> response = json.decode(content);
    if (response.isEmpty) throw Exception("No data received");
    if (!response.containsKey("total") || !response.containsKey("data")) {
      throw Exception("No total/id/data messages provided: $response");
    }
    int rec_total = (response["total"]) as int;
    if (rec_total > total) {
      this.syncData(null);
    }
    this.total = rec_total;
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

  static String formatTime(int time) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(time); // 将时间戳转换为DateTime对象
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss'); // 创建日期格式化对象
    return dateFormat.format(dateTime); // 格式化日期时间
  }

  static String formatSize(double size) {
    int index = 0;
    List<String> l = <String>[
      "B",
      "KB",
      "MB",
      "GB",
      "TB",
      "PB",
      "EB",
      "ZB",
      "YB"
    ];
    while (size > 1024 && index < l.length - 1) {
      size = size / 1024;
      index++;
    }
    return '${size.toStringAsFixed(2)}${l[index]}';
  }
}
