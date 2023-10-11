import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'message_list.dart';

const int TYPE_TEXT = 1;
const int TYPE_BYTE = 2;

class AsyncFetcher {
  AsyncFetcher({required this.callback});
  late Timer _timer;
  List<Message> _messages = [];
  Function callback;

  void startSync() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      try {
        _syncData();
      } catch (err) {
        Fluttertoast.showToast(msg: 'Err in fetch: ${err}');
        log("Error in async fetch!! ", error: err);
      }
    });
  }

  void stopSync() {
    _timer.cancel();
  }

  void _syncData() async {
    String rawData = await fetchDataFromBackend();
    List<Message> msgs = await this.processFetched(rawData);
    if (!listEquals(_messages, msgs)) {
      _messages = msgs;
      this.callback(msgs);
    }
  }

  Future<String> fetchDataFromBackend() async {
    await Future.delayed(const Duration(seconds: 1));
    return "";
  }

  Future<List<Message>> processFetched(String content) async {
    List<Map<String, dynamic>> metas = json.decode(content);
    if (metas.isEmpty) throw Exception("No data received");
    List<Message> messages = [];
    for (Map<String, dynamic> meta in metas) {
      if (!meta.containsKey("type")) {
        messages.add(Message(
            title: "Unknow type", content: meta.toString(), error: true));
      } else {
        switch (meta["type"] as int) {
          case TYPE_TEXT:
            messages.add(Message(title: meta["time"], content: meta["data"]));
            break;
          case TYPE_BYTE:
            messages.add(Message(
                title: meta["data"]["filename"],
                content:
                    '${formatSize(meta["data"]["size"])} - ${this.formatTime(meta["time"])}'));
            break;
          default:
            messages.add(Message(
                title: "Unknow type", content: meta.toString(), error: true));
        }
      }
    }
    return messages;
  }

  String formatTime(int time) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(time * 1000); // 将时间戳转换为DateTime对象
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss'); // 创建日期格式化对象
    return dateFormat.format(dateTime); // 格式化日期时间
  }

  String formatSize(double size) {
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
    }
    return '${size}${l[index]}';
  }
}
