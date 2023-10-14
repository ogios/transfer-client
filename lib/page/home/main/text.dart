import 'package:flutter/material.dart';

// class MessageTextarea extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _MessageTextarea();
// }
//
// class _MessageTextarea extends State<MessageTextarea> {
class MessageTextarea extends StatelessWidget {
  MessageTextarea({required this.textEditingController, super.key});
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DraggableScrollableSheet(
        initialChildSize: 0.4, // 初始抽屉高度占整个屏幕高度的比例
        minChildSize: 0.1, // 抽屉最小高度占整个屏幕高度的比例
        maxChildSize: 1.0, // 抽屉最大高度占整个屏幕高度的比例
        builder: (context, controller) {
          return Container(
            color: Colors.grey[200],
            child: SingleChildScrollView(
              controller: controller,
              child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: textEditingController,
                        minLines: 10,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Enter your text',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 左侧按钮
                          ElevatedButton(
                            onPressed: () {
                              // 处理按钮点击事件
                            },
                            child: Text('Button 1'),
                          ),
                          SizedBox(width: 16), // 两个按钮之间的间距
                          // 右侧按钮
                          ElevatedButton(
                            onPressed: () {
                              // 处理按钮点击事件
                            },
                            child: Text('Button 2'),
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
