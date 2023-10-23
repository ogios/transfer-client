import 'package:flutter/material.dart';
import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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
    // print("Shared: " + (value.map((f) => f.type).join(",") ?? ""));
    print("Shared: ${value}");
  }, onError: (err) {
    print("getIntentDataStream error: $err");
  });

  // For sharing images coming from outside the app while the app is closed
  ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
    // print("Shared:" + (value.map((f) => f.path).join(",") ?? ""));
    print("Shared: $value");
  });

  // For sharing or opening urls/text coming from outside the app while the app is in the memory
  _intentDataStreamSubscription =
      ReceiveSharingIntent.getTextStream().listen((String value) {
    print("Share text: $value");
  }, onError: (err) {
    print("getLinkStream error: $err");
  });

  // For sharing or opening urls/text coming from outside the app while the app is closed
  ReceiveSharingIntent.getInitialText().then((String? value) {
    if (value != null) {
      print("Initial text: $value");
    }
  });
}
