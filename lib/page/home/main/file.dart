import 'dart:developer';

import 'package:file_picker/file_picker.dart';
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
      FilePickerResult? files = await FilePicker.platform.pickFiles(allowMultiple: false, withReadStream: true);
      if (files == null) throw Exception("No file selected");
      PlatformFile file = files.files[0];
      log("filename: ${file.name}");

      return await UTServ.uploadFile(
          file.readStream!, file.size, file.name,
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
      child: const Text('Upload file'),
    );
  }
}
