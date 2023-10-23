import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transfer_client/api/dtserv.dart';
import 'package:transfer_client/page/home/download/downlaod_item.dart';

import 'dfile.dart';

class DownloadList {
  DownloadList() {
    scan();
  }
  final String base = "/transfer_client";
  final List<DFile> dlist = [];
  Function callback = () {};

  void registerCallback(Function call) {
    this.callback = call;
  }

  void clearCallback() {
    this.callback = () {};
  }

  bool contains(String filename) {
    for (var d in dlist) {
      if (d.filename == filename) return true;
    }
    return false;
  }

  Future<Directory> getDir() async {
    Directory? ddir = await getDownloadsDirectory();
    if (ddir == null) {
      throw Exception("Download dir not found!");
    }
    Directory dir = Directory(ddir.absolute.path + base);
    if (!dir.existsSync()) dir.createSync();
    return dir;
  }

  void scan() async {
    Directory directory = await getDir();
    List<FileSystemEntity> list = directory.listSync();
    for (FileSystemEntity f in list) {
      FileStat fs = f.statSync();
      String name = f.path.replaceFirst(directory.path, "");
      DFile d = DFile();
      d.filename = name;
      d.size = fs.size;
      d.current = fs.size;
      d.done = true;
      dlist.add(d);
    }
    this.callback();
  }

  void NewDownload(String id) {
    DFile d = DFile();
    DTServ.downloadFile(id, d);
    this.callback();
  }
}

final DownloadList GlobalDownloadList = DownloadList();

class DownloadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DownloadPage();
}

class _DownloadPage extends State<DownloadPage> {

  @override
  void dispose() {
    GlobalDownloadList.clearCallback();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    GlobalDownloadList.registerCallback(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: GlobalDownloadList.dlist.length,
      itemBuilder: (context, index) {
        DFile df = GlobalDownloadList.dlist[index];
        return DownloadItem(dFile: df);
      },
    );
  }
}
