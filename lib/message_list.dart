import 'package:flutter/material.dart';

class Message {
  Message({required this.title, required this.icon, required this.content});
  final String title;
  final String content;
  final IconData icon;
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
          return ListTile(
            title: Text(messages[index].title),
            subtitle: Text(messages[index].content),
            leading: Icon(messages[index].icon),
          );
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
