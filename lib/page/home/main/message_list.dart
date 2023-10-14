import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transfer_client/fetch.dart';

import '../../../main.dart';

class Message {
  Message({required this.title, required this.content, required this.id, this.error=false, this.icon=Icons.abc});
  final String title;
  final String content;
  final IconData icon;
  final bool error;
  final String id;
}

class MessageList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _MessageList();
}

class _MessageList extends State<MessageList> {
  _MessageList(){
    fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
  }
// class MessageList extends StatelessWidget {
  List<Message> messages = [];
  Object? error;
  final AsyncFetcher fetcher = AsyncFetcher();
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
          Flexible(child: Text(
            content, style: TextStyle(color: Colors.white, ),
          ),)
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
        fToast.showToast(child: newToast(this.error.toString()), gravity: ToastGravity.TOP_RIGHT);
      }
    });
  }

  @override
  void dispose() {
    fetcher.stopSync();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetcher.startSync();
    fetcher.registerCallback(refresh);
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
          if (m.error) {
            return ListTile(leading: Icon(Icons.error, color: Colors.red,), subtitle: Text(m.content));
          } else{
            return ListTile(
              title: Text(messages[index].title),
              subtitle: Text(messages[index].content),
              leading: Icon(messages[index].icon),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: this._getComponent()
          ),
      ],
    );
  }
}
