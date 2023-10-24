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
        return const Icon(
          Icons.error,
          color: Colors.redAccent,
        );
      case STATE_INIT:
        return const Icon(
          Icons.hourglass_empty,
          color: Colors.grey,
        );
      case STATE_PROCESS:
        return const Icon(
          Icons.hourglass_bottom,
          color: Colors.blueAccent,
        );
      case STATE_SUCCESS:
        return const Icon(
          Icons.check_circle,
          color: Colors.greenAccent,
        );
      default:
        return const Icon(
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

  Widget checkDelete(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete downloaded file"),
      titlePadding:
      const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 10),
      titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
      content: const Text("Sure?"),
      contentPadding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 14),
      actionsPadding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      actions: <Widget>[
        TextButton(
          child: const Text("delete"),
          onPressed: () {
            GlobalDownloadList.delete(this.widget.dFile);
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: const Text("cancel"),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          await showDialog(
              context: context,
              builder: (BuildContext context) => checkDelete(context));
        } catch (err) {
          GlobalFtoast.error("Delete Upload ERROR: $err", context);
        }
      },
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
