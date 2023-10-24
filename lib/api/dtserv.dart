import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:ogios_sutils/in.dart';
import 'package:ogios_sutils/out.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transfer_client/page/home/config/page.dart';
import 'dart:io';

import '../page/home/download/dfile.dart';

class DTServ {
  static String base_path = "/transfer_client";
  static int buffer_size = 1024 * 64;
  // static Map<String, DownProgress> DProgress = {};
  // static Mutex mutex = Mutex();

  static Future<String> downloadFile(
      String id, DFile df) async {
    // mutex.acquire();
    try {
      // if (DProgress.containsKey(message.raw.data_file!.filename)) {
      //   throw Exception("File task exist already");
      // }
      Socket socket =
          await Socket.connect(GlobalConfig.host, GlobalConfig.port);
      SocketOut sout = SocketOut();
      sout.addBytes(Uint8List.fromList("fetch_byte".codeUnits));
      sout.addBytes(Uint8List.fromList(utf8.encode(id)));
      sout.writeTo(socket);
      SocketIn sin = SocketIn(conn: socket);

      // status
      Uint8List sec = (await sin.getSec());
      String status = utf8.decode(sec);
      if (status == "error") {
        Uint8List error_msg = await sin.getSec();
        socket.close();
        throw Exception(
            "Status error in file `$id`: ${utf8.decode(error_msg)}");
      } else if (status == "success") {
        // filename
        sec = await sin.getSec();
        String filename = utf8.decode(sec);
        df.filename = filename;

        // bytes
        _saveFile(sin, df);
        // mutex.release();
        df.done = true;
        return "File start downloading: $filename";
      } else {
        socket.close();
        throw Exception("Unknow status: $status");
      }
    } catch (err) {
      // mutex.release();
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

  static Future<void> _saveFile(
      SocketIn sin, DFile df) async {
    // try {
      log("start downloading file");
      int total = await sin.next();
      df.size = total;
      if (total <= buffer_size) {
        log("getting buffer all at once");
        Uint8List temp = await sin.getSec();
        df.current += temp.length;
        log("getting file");
        File f = await _getFile(df.filename);
        IOSink writer = f.openWrite();
        writer.add(temp);
        writer.close();
      } else {
        Uint8List buffer = Uint8List(buffer_size);
        File f = await _getFile(df.filename);
        IOSink writer = f.openWrite();
        int read;
        while (df.current < df.size) {
          read = await sin.read(buffer);
          df.current += read;
          writer.add(buffer.sublist(0, read));
        }
        writer.close();
      }
      log("done _saveFile");
    // } catch (err) {
    //   log("Error in _saveFile: $err");
    //   df.errText = "$err";
    //   df.error = true;
    //   throw Exception("Error in _saveFile: $err");
    // }
  }
}
