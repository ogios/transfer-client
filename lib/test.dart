import 'package:flutter/material.dart';



class MyPage extends StatelessWidget {
  MyPage({super.key});

  Future<List<String>> fetchData() async {
    // 模拟网络请求获取数据
    await Future.delayed(Duration(seconds: 2));

    // 返回数据列表
    return ['Item 1', 'Item 2', 'Item 3'];
  }

  bool isDrawerOpen = false;
  double drawerHeight = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: FutureBuilder<List<String>>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  List<String> data = snapshot.data!;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(data[index]),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
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
          ),
          Expanded(
            flex: 10,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4, // 初始抽屉高度占整个屏幕高度的比例
              minChildSize: 0.4, // 抽屉最小高度占整个屏幕高度的比例
              maxChildSize: 1.0, // 抽屉最大高度占整个屏幕高度的比例
              builder: (context, controller) {
                return Container(
                  color: Colors.grey[200],
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: TextField(
                        minLines: 10,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Enter your text',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}