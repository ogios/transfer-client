import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transfer_client/api/fetch.dart';
import 'package:transfer_client/api/utserv.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';
import 'package:transfer_client/page/home/main/message_list.dart';
import 'package:transfer_client/page/home/download/page.dart';
// import 'package:transfer_client/test.dart';

class MessageItem extends StatefulWidget {
  MessageItem({required this.message});
  final Message message;

  @override
  State<StatefulWidget> createState() => _MessageItem();
}

class _MessageItem extends State<MessageItem> {
  void _tservWrapper(Function function) async {
    String msg = "";
    try {
      msg = await function(this.widget.message);
      Fluttertoast.showToast(msg: msg);
    } catch (err) {
      Fluttertoast.showToast(msg: "TServ Error: $err");
    }
  }

  void deleteMsg() {
    _tservWrapper((Message message) {
      return UTServ.deleteByID(message, onError: (String err) {
        GlobalFtoast.error(err, context);
      }, onSuccess: () {
        GlobalFtoast.success("delete id:${message.id} success", context);
      });
    });
  }

  Widget _dialogContent() {
    if (this.widget.message.error) {
      return Row(
        children: [
          Text(this.widget.message.title),
          Text(this.widget.message.content)
        ],
      );
    }
    List<Widget> content = [
      Text("Id: ${this.widget.message.raw.id}"),
      Text("Time: ${AsyncFetcher.formatTime(this.widget.message.raw.time)}")
    ];
    switch (this.widget.message.type) {
      case TYPE_TEXT:
        // content.add(ListView(children: [Text(this.widget.message.content)],));
        content.add(Container(
          height: 200,
          child: ListView(
            children: [Text(this.widget.message.content)],
          ),
        ));
        break;
      case TYPE_BYTE:
        content.add(Text(
            "Size: ${AsyncFetcher.formatSize((this.widget.message.raw.data_file!.size as int).toDouble())}"));
        content.add(Text("File name: ${this.widget.message.title}"));
    }
    var temp = <Widget>[];
    for (Widget c in content) {
      temp.add(c);
      temp.add(const SizedBox(height: 5));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: temp,
    );
  }

  Widget _dialogTitle() {
    List<Widget> title = [
      Icon(this.widget.message.icon),
      const SizedBox(width: 5)
    ];
    String title_text = "";
    switch (this.widget.message.type) {
      case TYPE_TEXT:
        title_text = "Text";
        break;
      case TYPE_BYTE:
        title_text = "File - ${this.widget.message.title}";
        break;
      default:
        title_text = "Error";
    }
    title.add(Flexible(
      child: Text(title_text,
          softWrap: true,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF2D2D2D),
          )),
    ));
    return Row(
      children: title,
    );
  }

  Widget _dialogFooter(BuildContext context) {
    List<Widget> footer = [];
    switch (this.widget.message.type) {
      case TYPE_TEXT:
        footer
            .add(TextButton(onPressed: deleteMsg, child: const Text("Delete")));
        footer.add(TextButton(
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: this.widget.message.content));
              Fluttertoast.showToast(msg: "Text copied");
              Navigator.pop(context);
            },
            child: const Text("Copy")));
        break;
      case TYPE_BYTE:
        footer
            .add(TextButton(onPressed: deleteMsg, child: const Text("Delete")));
        footer.add(TextButton(
            onPressed: () {
              _tservWrapper((Message message) {
                // test3();
                GlobalDownloadList.newDownload(message.id);
                return "Start Downloading...";
              });
            },
            child: const Text("Download")));
        break;
    }
    footer.add(TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Close")));

    return Center(
        child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: footer,
    ));
  }

  Widget dialogWidget(BuildContext context) {
    return Dialog(
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dialogTitle(),
                const SizedBox(height: 20),
                _dialogContent(),
                _dialogFooter(context),
              ],
            )));
  }

  void openDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => dialogWidget(context));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openDialog,
      onDoubleTap: (){
        try {
          if (this.widget.message.type == TYPE_TEXT) {
            Share.share(this.widget.message.content, subject: "transfer-client");
          }
        } catch (err) {
          GlobalFtoast.error("Share text ERROR: $err", context);
        }
      },
      child: () {
        if (this.widget.message.error) {
          return ListTile(
              leading: const Icon(
                Icons.error,
                color: Colors.red,
              ),
              subtitle: Text(this.widget.message.content));
        } else {
          return Column(
            children: [
              ListTile(
                title: Text(this.widget.message.title),
                subtitle: Text(this.widget.message.content),
                leading: Icon(this.widget.message.icon),
              ),
              const Divider(),
            ],
          );
        }
      }(),
    );
  }
}
