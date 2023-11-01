import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ogios_sutils/in.dart';
import 'package:ogios_sutils/out.dart';
import 'package:path/path.dart';
import 'package:transfer_client/api/proxy.dart';
import 'package:transfer_client/page/home/config/page.dart';
import 'package:transfer_client/page/home/main/message_list.dart';
import 'package:transfer_client/page/home/upload/uprogress.dart';
import 'package:uri_to_file/uri_to_file.dart';

class UTServ {
  static Future<void> uploadText(UProgress up) async {
    Socket socket;
    SocketOut sout;
    try {
      sout = SocketOut();
      sout.addBytes(Uint8List.fromList("text".codeUnits));
      sout.addBytes(Uint8List.fromList(utf8.encode(up.raw!)));
      socket = await _getConn();
    } catch (err) {
      up.errText = "SocketOut or Conneciton error: $err";
      up.state = STATE_ERROR;
      return;
    }
    up.size = utf8.encode(up.raw!).length;
    up.state = STATE_PROCESS;
    try {
      await write(socket, sout);
      up.current = up.size;
      up.state = STATE_SUCCESS;
    } catch (err) {
      socket.close();
      String error_msg = "Upload text error: $err";
      up.errText = error_msg;
      up.state = STATE_ERROR;
      return;
    }
  }

  static Future<void> uploadFileWithPath(UProgress up) async {
    try {
      File f;
      try {
        f = await toFile(up.raw!);
      } catch(e) {
        f = File(up.raw!);
      }
      FileStat s = f.statSync();
      String name = basename(up.raw!);
      up.size = s.size;
      UTServ.uploadFile(f.openRead(), s.size, name, up);
    } catch (err)  {
      up.errText = "Upload File With Path ERROR: $err";
      up.error = true;
    }
  }

  static Future<void> uploadFile(Stream<List<int>> stream, int length, String name, UProgress up) async {
    Socket socket;
    SocketOut sout;
    try {
      sout = SocketOut();
      sout.addBytes(Uint8List.fromList("byte".codeUnits));
      sout.addBytes(Uint8List.fromList(utf8.encode(name)));
      sout.addReader(stream, length);
      socket = await _getConn();
    } catch (err) {
      up.errText = "SocketOut or Conneciton error: $err";
      up.state = STATE_ERROR;
      return;
    }
    up.state = STATE_PROCESS;
    try {
      await write(socket, sout);
      up.current = length;
      up.state = STATE_SUCCESS;
    } catch (err) {
      socket.close();
      String error_msg = "Upload file error: $err";
      up.errText = error_msg;
      up.state = STATE_ERROR;
      return;
    }
  }

  static Future<String> deleteByID(Message message, {Function(String err)? onError, Function()? onSuccess}) async {
    SocketOut sout = SocketOut();
    sout.addBytes(Uint8List.fromList("delete".codeUnits));
    sout.addBytes(Uint8List.fromList(utf8.encode(message.id)));
    Socket socket = await _getConn();
    try {
      return await write(socket, sout, onSuccess: onSuccess);
    } catch (err) {
      socket.close();
      String error_msg = "Delete ID:${message.id} error: $err";
      if (onError != null) onError(error_msg);
      throw Exception(error_msg);
    }
  }

  static Future<String> clearDelete({Function(String err)? onError, Function()? onSuccess}) async {
    SocketOut sout = SocketOut();
    sout.addBytes(Uint8List.fromList("clear_del".codeUnits));
    Socket socket = await _getConn();
    try {
      return await write(socket, sout, onSuccess: onSuccess);
    } catch (err) {
      socket.close();
      String error_msg = "Clear delete error: $err";
      if (onError != null) onError(error_msg);
      throw Exception(error_msg);
    }
  }

  static Future<String> write(Socket socket, SocketOut sout, {Function()? onSuccess}) async {
    sout.writeTo(socket);
    SocketIn sin = SocketIn(conn: socket);
    Uint8List sec = await sin.getSec();
    String status = utf8.decode(sec);
    if (status == "error") {
      String error_msg = utf8.decode(await sin.getSec());
      throw Exception("remote error: $error_msg");
    } else if (status == "success") {
      if (onSuccess != null) onSuccess();
      return "Upload success";
    } else {
      throw Exception("remote error: Unknow status: $status");
    }
  }


  static Future<Socket> _getConn() async {
    while (!GlobalConfig.done) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    List<dynamic> server = await getServer();
    Socket socket = await Socket.connect(server[0], server[1]);
    return socket;
  }
}
