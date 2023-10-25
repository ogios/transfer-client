import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:transfer_client/api/dtserv.dart';
import 'package:transfer_client/page/home/download/downlaod_item.dart';
import 'package:transfer_client/page/home/custom_component.dart';

import 'dfile.dart';

class DownloadList {
  DownloadList() {
    scan();
  }

  final String base = "/transfer_client";
  final List<DFile> dlist = [];
  final Lock lock = Lock();
  Function callback = () {};

  void registerCallback(Function call) {
    this.callback = call;
  }

  void clearCallback() {
    this.callback = () {};
  }

  void DFileCallback() {
    this.callback();
  }

  void setDFileCallback(DFile d) {
    d.onError = DFileCallback;
    d.onProcess = DFileCallback;
    d.onSuccess = DFileCallback;
    d.onInit = DFileCallback;
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
    await lock.synchronized(() async {
      Directory directory = await getDir();
      List<FileSystemEntity> list = directory.listSync();
      for (FileSystemEntity f in list) {
        FileStat fs = f.statSync();
        String name = basename(f.path);
        // String name = f.path.replaceFirst(directory.path, "");
        DFile d = DFile();
        d.filename = name;
        d.size = fs.size;
        d.current = fs.size;
        d.done = true;
        dlist.add(d);
      }
      this.callback();
    });
  }

  void newDownload(String id) {
    lock.synchronized(() async {
      DFile d = DFile();
      this.setDFileCallback(d);
      this.dlist.add(d);
      DTServ.downloadFile(id, d);
      this.callback();
    });
  }

  void _delete(DFile d) async {
    if (d.state == STATE_SUCCESS) {
      String path = "${(await getDir()).path}/${d.filename}";
      File file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  void delete(DFile d) async {
    await lock.synchronized(() async {
      _delete(d);
      for (var i = 0; i < this.dlist.length; i++) {
        if (this.dlist[i].filename == d.filename) {
          this.dlist.removeAt(i);
          return;
        }
      }
    });
    this.callback();
  }

  void clear() async {
    await lock.synchronized(() async {
      for (var d in this.dlist) {
        this._delete(d);
      }
      this.dlist.clear();
    });
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
    return Scaffold(
        appBar: CustomBar(
          Text("Download", style: Theme.of(context).textTheme.titleLarge,),
          [
            IconButton(
                onPressed: GlobalDownloadList.clear,
                icon: const Icon(Icons.delete_forever, color: Colors.white,))
          ],
        ),
        body: ListView.builder(
          itemCount: GlobalDownloadList.dlist.length,
          itemBuilder: (context, index) {
            DFile df = GlobalDownloadList.dlist[index];
            return DownloadItem(dFile: df);
          },
        ));
  }
}
