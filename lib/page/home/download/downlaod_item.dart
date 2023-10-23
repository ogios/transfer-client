import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transfer_client/page/home/download/dfile.dart';
import 'package:transfer_client/page/home/download/page.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';

class DownloadItem extends StatefulWidget {
  DownloadItem({required this.dFile});
  final DFile dFile;

  @override
  State<StatefulWidget> createState() => _DownloadItem();
}

class _DownloadItem extends State<DownloadItem> {
  String getTitle() {
    var df = this.widget.dFile;
    switch (df.state) {
      case STATE_ERROR:
        return "ERROR: ${df.errText}";
      case STATE_INIT:
        return "Waiting for check...";
      case STATE_PROCESS:
      case STATE_SUCCESS:
        return df.filename;
      default:
        return "Unknown state: ${df.state}";
    }
  }

  Widget getProgress() {
    var df = this.widget.dFile;
    switch (df.state) {
      case STATE_ERROR:
        return LinearProgressIndicator(
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation(Colors.redAccent),
          value: 1,
        );
      case STATE_INIT:
        return const Row();
      case STATE_PROCESS:
      case STATE_SUCCESS:
        return LinearProgressIndicator(
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
          value: df.current / df.size,
        );
      default:
        return LinearProgressIndicator(
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation(Colors.redAccent),
          value: 1,
        );
    }
  }

  Widget getIcon() {
    var df = this.widget.dFile;
    switch (df.state) {
      case STATE_ERROR:
        return Icon(
          Icons.error,
          color: Colors.redAccent,
        );
      case STATE_INIT:
        return Icon(
          Icons.hourglass_empty,
          color: Colors.grey,
        );
      case STATE_PROCESS:
        return Icon(
          Icons.hourglass_bottom,
          color: Colors.blueAccent,
        );
      case STATE_SUCCESS:
        return Icon(
          Icons.check_circle,
          color: Colors.greenAccent,
        );
      default:
        return Icon(
          Icons.question_mark,
          color: Colors.redAccent,
        );
    }
  }

  Function callback() => () {
        setState(() {});
      };

  @override
  void dispose() {
    var df = this.widget.dFile;
    df.clearCallback();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var df = this.widget.dFile;
    df.onInit = callback();
    df.onProcess = callback();
    df.onSuccess = callback();
    df.onError = callback();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () async {
        try {
          Directory? sys_path = await getDownloadsDirectory();
          String path = "${sys_path!.path}${GlobalDownloadList.base}/${this.widget.dFile.filename}";
          await Share.shareFiles([path], text: "File from transfer-client");
        } catch (err) {
          GlobalFtoast.error("Share File ERROR: $err", context);
        }
      },
      child: Column(
        children: [
          ListTile(
            title: Text(getTitle()),
            subtitle: getProgress(),
            leading: getIcon(),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
