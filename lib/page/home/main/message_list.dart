import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transfer_client/api/fetch.dart';
import 'package:transfer_client/page/home/main/message_item.dart';

import '../../../main.dart';

class RawMessage {
  RawMessage(Map<String, dynamic> raw) {
    this.type = raw["type"];
    this.id = raw["id"];
    this.time = raw["time"];
    switch (this.type) {
      case TYPE_TEXT:
        this.data_file = null;
        this.data_text = raw["data"];
        break;
      case TYPE_BYTE:
        this.data_text = null;
        this.data_file = RawMessageFile(
            filename: raw["data"]["filename"], size: raw["data"]["size"]);
    }
  }

  late final int type;
  late final String id;
  late final int time;
  late final String? data_text;
  late final RawMessageFile? data_file;
}

class RawMessageFile {
  RawMessageFile({required this.filename, required this.size});
  final String filename;
  final int size;
}

class Message {
  Message(
      {required this.type,
      required this.title,
      required this.content,
      required this.id,
      required Map<String, dynamic> raw_map,
      this.error = false,
      this.icon = Icons.abc}) {
    if (this.error) return;
    this.raw = RawMessage(raw_map);
  }
  final String title;
  final String content;
  final IconData icon;
  final bool error;
  final String id;
  final int type;
  late final RawMessage raw;
}

class MessageList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MessageList();
}

class _MessageList extends State<MessageList> {
  _MessageList() {
    fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
  }
// class MessageList extends StatelessWidget {
  List<Message> messages = [];
  Object? error;
  late FToast fToast;

  Widget newToast(String content) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      width: mediaQuery.size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
        color: Colors.redAccent,
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.0,
          ),
          Icon(Icons.error, color: Colors.white),
          SizedBox(
            width: 12.0,
          ),
          Flexible(
            child: Text(
              content,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  void refresh(List<Message> messages, Object? error) {
    setState(() {
      this.messages = messages;
      this.error = error;
      if (this.error != null) {
        fToast.removeQueuedCustomToasts();
        fToast.showToast(
            child: newToast(this.error.toString()),
            gravity: ToastGravity.TOP_RIGHT);
      }
    });
  }

  @override
  void dispose() {
    GlobalFetcher.clearCallback();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    GlobalFetcher.registerCallback(refresh);
  }

  Widget _getComponent() {
    if (this.error != null) {
      return Center(
        child: Text('Error: ${this.error}'),
      );
    } else {
      return ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          Message m = messages[index];
          return MessageItem(message: m);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: this._getComponent()),
      ],
    );
  }
}
