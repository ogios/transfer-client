import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transfer_client/api/fetch.dart';
import 'package:transfer_client/page/home/main/message_list.dart';
import 'package:transfer_client/api/dtserv.dart';

class MessageItem extends StatefulWidget {
  MessageItem({required this.message});
  Message message;

  @override
  State<StatefulWidget> createState() => _MessageItem();
}

class _MessageItem extends State<MessageItem> {
  void _tservWrapper(Function function) async {
    String msg = "";
    try {
      msg = await function(this.widget.message);
    } catch (err) {
      Fluttertoast.showToast(msg: "TServ Error: $err");
    }
    Fluttertoast.showToast(msg: msg);
  }

  Widget _dialogTitle() {
    List<Widget> title = [Icon(this.widget.message.icon), SizedBox(width: 5)];
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
    title.add(Text(title_text,
        style: TextStyle(
            fontSize: 20,
            color: Color(0xFF2D2D2D),
            decoration: TextDecoration.none)));
    return Row(
      children: title,
    );
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
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: content,
    );
  }

  Widget _dialogFooter(BuildContext context) {
    List<Widget> footer = [];
    switch (this.widget.message.type) {
      case TYPE_TEXT:
        footer.add(TextButton(onPressed: () {}, child: Text("Delete")));
        footer.add(TextButton(
            onPressed: () {
              this._tservWrapper(DTServ.copyText);
            },
            child: Text("Copy")));
        break;
      case TYPE_BYTE:
        footer.add(TextButton(onPressed: () {}, child: Text("Delete")));
        footer.add(TextButton(
            onPressed: () {
              this._tservWrapper((Message message){
                return DTServ.downloadFile(
                    message, (){setState(() {});}
                );
              });
            },
            child: Text("Download")));
        break;
    }
    footer.add(TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Close")));

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
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dialogTitle(),
                SizedBox(height: 20),
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

  Widget getProgress() {
    if (this.widget.message.type == TYPE_BYTE) {
      if (DTServ.DProgress.containsKey(
          this.widget.message.raw.data_file!.filename)) {
        DownProgress? temp = DTServ
            .DProgress[this.widget.message.raw.data_file!.filename];
        if (temp!.total != null) {
          return LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(Colors.blue),
            value: temp.current / temp.total!,
          );
        }
      }
    }
    return Row();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openDialog,
      child: () {
        if (this.widget.message.error) {
          return ListTile(
              leading: Icon(
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
              Padding(padding: EdgeInsets.only(left: 10, right: 10),child: getProgress(),),
              Divider(),
            ],
          );
        }
      }(),
    );
  }
}
