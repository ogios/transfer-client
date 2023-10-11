import 'package:flutter/material.dart';

class Message {
  Message({required this.title, required this.content, this.error=false, this.icon=Icons.abc});
  final String title;
  final String content;
  final IconData icon;
  final bool error;
}

// class MessageList extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _MessageList();
// }

// class _MessageList extends State<MessageList> {
class MessageList extends StatelessWidget {
  const MessageList({required this.messages, required this.error, super.key});
  final List<Message> messages;
  final String error;

  Widget _getComponent() {
    if (this.error != "") {
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
