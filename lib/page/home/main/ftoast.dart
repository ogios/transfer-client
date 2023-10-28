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

  static void success(String content, BuildContext? context,
      {bool immediate = false}) {
    if (!_inited) {
      throw Exception("ftoast not inited");
    }
    if (immediate) {
      fToast.removeQueuedCustomToasts();
    }
    fToast.showToast(
        child: newSuccess(content, context), gravity: ToastGravity.TOP_RIGHT);
  }

  static void error(String content, BuildContext? context,
      {bool immediate = false}) {
    if (!_inited) {
      throw Exception("ftoast not inited");
    }
    if (immediate) {
      fToast.removeQueuedCustomToasts();
    }
    fToast.showToast(
        child: newError(content, context),
        gravity: ToastGravity.TOP_RIGHT,
        toastDuration: const Duration(seconds: 5));
  }

  static Widget newSuccess(String content, BuildContext? context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check),
          const SizedBox(
            width: 12.0,
          ),
          Text(content),
        ],
      ),
    );
  }

  static Widget newError(String content, BuildContext? context) {
    double? width;
    if (context != null) {
      if (context.mounted) {
        try {
          width = MediaQuery.of(context).size.width;
        } catch (err) {}
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
        color: Colors.redAccent,
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12.0,
          ),
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(
            width: 12.0,
          ),
          Flexible(
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
