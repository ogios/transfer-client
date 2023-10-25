import 'package:flutter/material.dart';
import 'package:transfer_client/page/home/custom_component.dart';
import 'package:transfer_client/page/home/homepage.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';
import 'package:transfer_client/page/home/upload/page.dart';
import 'package:transfer_client/page/home/upload/uprogress.dart';

class UploadItem extends StatefulWidget {
  UploadItem({required this.up});

  final UProgress up;

  @override
  State<StatefulWidget> createState() => _UploadItem();
}

class _UploadItem extends State<UploadItem> {
  String getTitle() {
    var up = this.widget.up;
    switch (up.state) {
      case STATE_ERROR:
        return "ERROR: ${up.errText}";
      case STATE_INIT:
        return "Waiting for check...";
      case STATE_PROCESS:
      case STATE_SUCCESS:
        return up.raw!;
      default:
        return "Unknown state: ${up.state}";
    }
  }

  Widget getProgress() {
    var up = this.widget.up;
    switch (up.state) {
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
          value: up.current / up.size,
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
    var up = this.widget.up;
    switch (up.state) {
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
    var up = this.widget.up;
    up.clearCallback();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var up = this.widget.up;
    up.onInit = callback();
    up.onProcess = callback();
    up.onSuccess = callback();
    up.onError = callback();
  }

  Widget checkDelete(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete upload record"),
      titlePadding:
          const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 10),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      backgroundColor: actionColor,
      content: Text("Sure?", style: Theme.of(context).textTheme.labelMedium,),
      contentPadding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 14),
      actionsPadding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      actions: <Widget>[
        TextButton(
          child: const Text("delete"),
          onPressed: () {
            GlobalUploadlist.delete(this.widget.up.raw!);
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

  Widget checkReUpload(BuildContext context) {
    return AlertDialog(
      title: const Text("ReUpload"),
      titlePadding:
          const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 10),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      backgroundColor: actionColor,
      content: Text("Sure?", style: Theme.of(context).textTheme.labelMedium,),
      contentPadding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 14),
      actionsPadding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      actions: <Widget>[
        TextButton(
          child: const Text("upload"),
          onPressed: () {
            GlobalUploadlist.reUpload(this.widget.up);
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
          await showDialog(
              context: context,
              builder: (BuildContext context) => checkReUpload(context));
        } catch (err) {
          GlobalFtoast.error("ReUpload ERROR: $err", context);
        }
      },
      child: Column(
        children: [
          CustomCard(ListTile(
            title: Text(getTitle(), style: Theme.of(context).textTheme.titleMedium,),
            subtitle: getProgress(),
            leading: getIcon(),
          )),
        ],
      ),
    );
  }
}
