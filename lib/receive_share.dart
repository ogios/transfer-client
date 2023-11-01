import 'dart:async';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transfer_client/page/home/upload/page.dart';
import 'package:uri_to_file/uri_to_file.dart';

StreamSubscription? _intentDataStreamSubscription;

void stopReceiver() {
  if (_intentDataStreamSubscription != null) {
    _intentDataStreamSubscription!.cancel();
  }
}

void initReceiver() {
  if (!(Platform.isAndroid || Platform.isIOS)) return;
  if (_intentDataStreamSubscription != null) return;

  // For sharing images coming from outside the app while the app is in the memory
  _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream().listen(
      (List<SharedMediaFile> value) {
    Fluttertoast.showToast(msg: "Received media stream.");
    if (value.length > 0) {
      GlobalUploadlist.newUploadFile(value[0].path);
      print("Shared: $value");
    }
  }, onError: (err) {
    print("getIntentDataStream error: $err");
  });

  // For sharing images coming from outside the app while the app is closed
  ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
    // print("Shared:" + (value.map((f) => f.path).join(",") ?? ""));
    if (value.length > 0) {
      GlobalUploadlist.newUploadFile(value[0].path);
      print("Shared: $value");
    }
  });

  // For sharing or opening urls/text coming from outside the app while the app is in the memory
  _intentDataStreamSubscription =
      ReceiveSharingIntent.getTextStream().listen((String value) async {
    Fluttertoast.showToast(msg: "Received text stream.");
    try {
      await toFile(value);
      Fluttertoast.showToast(msg: "Text deemed as uri, sharing file...");
      GlobalUploadlist.newUploadFile(value);
    } catch (err) {
      Fluttertoast.showToast(msg: "Uploading shared text");
      GlobalUploadlist.newUploadText(value);
    }
  }, onError: (err) {
    print("getLinkStream error: $err");
  });

  // For sharing or opening urls/text coming from outside the app while the app is closed
  ReceiveSharingIntent.getInitialText().then((String? value) async {
    if (value != null) {
      Fluttertoast.showToast(msg: "Uploading shared text");
      GlobalUploadlist.newUploadText(value);
    }
  });
}
