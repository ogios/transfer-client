import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transfer_client/page/home/homepage.dart';
import 'package:transfer_client/page/home/main/file.dart';
import 'package:transfer_client/page/home/upload/page.dart';

// class MessageTextarea extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _MessageTextarea();
// }
//
// class _MessageTextarea extends State<MessageTextarea> {
class MessageTextarea extends StatelessWidget {
  MessageTextarea({required this.textEditingController, super.key});

  final TextEditingController textEditingController;

  void _tservWrapper(Function function) async {
    String? msg;
    try {
      msg = await function();
      if (msg != null) Fluttertoast.showToast(msg: msg);
    } catch (err) {
      Fluttertoast.showToast(msg: "TServ Error: $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DraggableScrollableSheet(
      initialChildSize: 0.4, // 初始抽屉高度占整个屏幕高度的比例
      minChildSize: 0.1, // 抽屉最小高度占整个屏幕高度的比例
      maxChildSize: 1.0, // 抽屉最大高度占整个屏幕高度的比例
      builder: (context, controller) {
        return Container(
          color: actionColor,
          child: SingleChildScrollView(
            controller: controller,
            child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: textEditingController,
                      minLines: 10,
                      maxLines: null,
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                          hintText: 'Enter your text',
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BtnUploadFile(),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            _tservWrapper(() async {
                              return GlobalUploadlist.newUploadText(
                                textEditingController.value.text,
                              );
                            });
                          },
                          child: const Text('Upload text'),
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        );
      },
    );
  }
}
