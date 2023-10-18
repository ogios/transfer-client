import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GlobalFtoast {
  static late FToast fToast;
  static bool _inited = false;

  static void init(BuildContext context) {
    if (_inited) return;
    fToast = FToast();
    fToast.init(context);
    _inited = true;
  }

  static void success(String content, BuildContext context) {
    if (!_inited) {
      throw Exception("ftoast not inited");
    }
    fToast.showToast(
        child: newSuccess(content, context), gravity: ToastGravity.TOP_RIGHT);
  }

  static void error(String content, BuildContext context) {
    if (!_inited) {
      throw Exception("ftoast not inited");
    }
    fToast.showToast(
        child: newError(content, context),
        gravity: ToastGravity.TOP_RIGHT,
        toastDuration: Duration(seconds: 5));
  }

  static Widget newSuccess(String content, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(content),
        ],
      ),
    );
  }

  static Widget newError(String content, BuildContext context) {
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
}
