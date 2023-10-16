import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:mutex/mutex.dart';
import 'package:ogios_sutils/in.dart';
import 'package:ogios_sutils/out.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transfer_client/api/fetch.dart';
import 'package:transfer_client/page/home/config/page.dart';
import 'package:transfer_client/page/home/main/message_list.dart';
import 'dart:io';

class DownProgress {
  DownProgress({required this.filename});
  final String filename;
  int? total;
  int current = 0;
  bool done = false;
  bool error = false;
  String errText = "";
}

class DTServ {
  static String base_path = "/transfer_client";
  static int buffer_size = 1024 * 64;
  static Map<String, DownProgress> DProgress = {};
  static Mutex mutex = Mutex();

  static Future<String> copyText(Message message) async {
    if (message.type != TYPE_TEXT) {
      throw Exception("fail to copy not TYPE_TEXT message");
    }
    Clipboard.setData(ClipboardData(text: message.content));
    return "Text Copied";
  }

  static Future<String> downloadFile(Message message, Function callback) async {
    mutex.acquire();
    try {
      if (DProgress.containsKey(message.raw.data_file!.filename)) {
        throw Exception("File task exist already");
      }
      Socket socket =
          await Socket.connect(GlobalConfig.host, GlobalConfig.port);
      SocketOut sout = SocketOut();
      sout.addBytes(Uint8List.fromList("fetch_byte".codeUnits));
      sout.addBytes(
          Uint8List.fromList(message.raw.data_file!.filename.codeUnits));
      sout.writeTo(socket);
      SocketIn sin = SocketIn(conn: socket);
      Uint8List sec = (await sin.getSec());
      String status = String.fromCharCodes(sec);
      if (status == "error") {
        Uint8List error_msg = await sin.getSec();
        socket.close();
        throw Exception(
            "Status error in file `${message.raw.data_file!.filename}`: ${String.fromCharCodes(error_msg)}");
      } else if (status == "success") {
        DownProgress dp =
            DownProgress(filename: message.raw.data_file!.filename);
        _saveFile(sin, dp, callback);
        DProgress[message.raw.data_file!.filename] = dp;
        mutex.release();
        return "File start downloading: ${message.raw.data_file!.filename}";
      } else {
        socket.close();
        throw Exception("Unknow status: $status");
      }
    } catch (err) {
      mutex.release();
      throw err;
    }
  }

  static Future<File> _getFile(String filename) async {
    Directory? ddir = await getDownloadsDirectory();
    if (ddir == null) {
      throw Exception("Download dir not found!");
    }
    Directory dir = Directory(ddir.absolute.path + base_path);
    if (!dir.existsSync()) dir.createSync();
    File file = File(ddir.absolute.path + base_path + "/$filename");
    if (!file.existsSync()) file.createSync();
    return file;
  }

  static Future<void> _saveFile(SocketIn sin, DownProgress dp, Function callback) async {
    try {
      log("start downloading file");
      await sin.getSec();
      int total = await sin.next();
      dp.total = total;
      callback();
      if (total <= buffer_size) {
        log("getting buffer all at once");
        Uint8List temp = await sin.getSec();
        dp.current += temp.length;
        log("getting file");
        File f = await _getFile(dp.filename);
        IOSink writer = f.openWrite();
        writer.add(temp);
        writer.close();
      } else {
        Uint8List buffer = Uint8List(buffer_size);
        File f = await _getFile(dp.filename);
        IOSink writer = f.openWrite();
        int read;
        while (dp.current < dp.total!) {
          read = await sin.read(buffer);
          dp.current += read;
          writer.add(buffer.sublist(0, read));
          callback();
        }
        writer.close();
      }
      callback();
      log("done _saveFile");
    } catch (err) {
      log("Error in _saveFile: $err");
      dp.error = true;
      dp.errText = "$err";
      dp.done = true;
      throw Exception("Error in _saveFile: $err");
    }
  }
}
