import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transfer_client/api/fetch.dart';
import 'package:transfer_client/api/utserv.dart';
import 'package:transfer_client/page/home/upload/upload_item.dart';
import 'package:transfer_client/page/home/upload/uprogress.dart';


class UploadList {
  final List<UProgress> ulist = [];
  Function callback = () {};

  void registerCallback(Function call) {
    this.callback = call;
  }

  void clearCallback() {
    this.callback = () {};
  }

  void UProgressCallback() {
    this.callback();
  }

  void setDFileCallback(UProgress u) {
    u.onError = UProgressCallback;
    u.onProcess = UProgressCallback;
    u.onSuccess = UProgressCallback;
    u.onInit = UProgressCallback;
  }

  bool contains(String raw) {
    for (var d in ulist) {
      if (d.raw == raw) return true;
    }
    return false;
  }

  void ReUpload(UProgress up) {
    () async {
      up.state = 0;
      this.callback();
      UTServ.uploadText(up);
      this.callback();
    }();
    return;
  }

  void delete(String raw) {
    for (var i =0; i< ulist.length; i++) {
      var u = ulist[i];
      if (u.raw == raw) {
        ulist.removeAt(i);
        this.callback();
        return;
      }
    }
  }

  void newUploadText(String content) {
    UProgress u = UProgress(type: TYPE_TEXT);
    this.setDFileCallback(u);
    u.raw = content;
    u.size = utf8.encode(content).length;
    this.ulist.add(u);
    UTServ.uploadText(u);
    this.callback();
  }

  void newUploadFile(String raw) {
    UProgress u = UProgress(type: TYPE_BYTE);
    this.setDFileCallback(u);
    u.raw = raw;
    this.ulist.add(u);
    UTServ.uploadFileWithPath(u);
    this.callback();
  }
}

final UploadList GlobalUploadlist = UploadList();

class UploadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UploadPage();
}

class _UploadPage extends State<UploadPage> {

  @override
  void dispose() {
    GlobalUploadlist.clearCallback();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    GlobalUploadlist.registerCallback(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: GlobalUploadlist.ulist.length,
      itemBuilder: (context, index) {
        UProgress up = GlobalUploadlist.ulist[index];
        return UploadItem(up: up);
      },
    );
  }
}
