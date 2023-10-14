import 'package:flutter/material.dart';
import 'package:transfer_client/page/home/main/message_list.dart';
import 'package:transfer_client/page/home/main/text.dart';

class MessagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MessagePage();
}

class _MessagePage extends State<MessagePage>
    with SingleTickerProviderStateMixin {
  TextEditingController textEditingController = TextEditingController();
  late AnimationController controller = AnimationController(
    duration: Duration(milliseconds: 300),
    vsync: this,
  );
  late Animation<double> animation =
      CurvedAnimation(parent: controller, curve: Curves.easeInOut);
  bool text_enable = false;

  void toggleVisible() {
    setState(() {
      this.text_enable = !this.text_enable;
      if (text_enable) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (text_enable) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    this.controller.dispose();
    this.textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message Page"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleVisible,
      ),
      body: Stack(
        children: <Widget>[
          MessageList(),
          SizeTransition(
            sizeFactor: animation, //这里定义animation
            child: MessageTextarea(
              textEditingController: textEditingController,
            ),
          )
        ],
      ),
    );
  }
}
