import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transfer_client/api/utserv.dart';
import 'package:transfer_client/page/home/main/ftoast.dart';
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

  Future<void> clearDel() async {
    String msg = "";
    try {
      msg = await UTServ.clearDelete(onError: (String err) {
        GlobalFtoast.error(err, context);
      }, onSuccess: () {
        GlobalFtoast.success("Clear delete success", context);
      });
      Fluttertoast.showToast(msg: msg);
    } catch (err) {
      Fluttertoast.showToast(msg: "TServ Error: $err");
    }
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
        title: const Text("Message"),
        actions: [
          IconButton(
              onPressed: clearDel, icon: const Icon(Icons.delete_forever))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleVisible,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: <Widget>[
          MessageList(),
          SizeTransition(
            sizeFactor: animation,
            child: MessageTextarea(
              textEditingController: textEditingController,
            ),
          )
        ],
      ),
    );
  }
}
