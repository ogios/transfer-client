import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transfer_client/api/utserv.dart';

import 'ftoast.dart';

class BtnUploadFile extends StatelessWidget {
  void _tservWrapper(Function function) async {
    String msg = "";
    try {
      msg = await function();
    } catch (err) {
      Fluttertoast.showToast(msg: "TServ Error: $err");
    }
    Fluttertoast.showToast(msg: msg);
  }

  void uploadFile(BuildContext context) async {
    _tservWrapper(() async {
      XFile? file = await openFile();
      if (file == null) throw Exception("No file selected");
      return await UTServ.uploadFile(
          file.openRead(), await file.length(), file.name,
          onError: (String err) {
        GlobalFtoast.error(err, context);
      }, onSuccess: () {
        GlobalFtoast.success("text upload success", context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ElevatedButton(
      onPressed: () {
        uploadFile(context);
      },
      child: Text('Upload file'),
    );
  }
}
