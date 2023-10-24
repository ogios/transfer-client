import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:transfer_client/page/home/upload/page.dart';

StreamSubscription? _intentDataStreamSubscription;

void stopReceiver() {
  if (_intentDataStreamSubscription != null) {
    _intentDataStreamSubscription!.cancel();
  }
}

void initReceiver() {
  if (_intentDataStreamSubscription != null) return;

  // For sharing images coming from outside the app while the app is in the memory
  _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream().listen(
      (List<SharedMediaFile> value) {
    Fluttertoast.showToast(msg: "Received media stream, can not proceed.");
  }, onError: (err) {
    print("getIntentDataStream error: $err");
  });

  // For sharing images coming from outside the app while the app is closed
  ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
    // print("Shared:" + (value.map((f) => f.path).join(",") ?? ""));
    GlobalUploadlist.newUploadFile(value[0].path);
    print("Shared: $value");
  });

  // For sharing or opening urls/text coming from outside the app while the app is in the memory
  _intentDataStreamSubscription =
      ReceiveSharingIntent.getTextStream().listen((String value) {
    Fluttertoast.showToast(msg: "Received text stream, can not proceed.");
  }, onError: (err) {
    print("getLinkStream error: $err");
  });

  // For sharing or opening urls/text coming from outside the app while the app is closed
  ReceiveSharingIntent.getInitialText().then((String? value) async {
    if (value != null) {
      Fluttertoast.showToast(msg: "Uploading shared text");
      GlobalUploadlist.newUploadText(value);
      // print("Initial text: $value");
    }
  });
}
