import 'package:flutter/services.dart';

class VeriphOneChannel {
  static const platform = MethodChannel('one.veriph.sdk/verification');

  static Future<String?> subscribeToVerificationEvent(String apiKey, String sessionUuid) async {
    try {
      return await platform
          .invokeMethod<String?>('startVerification', <String, String>{
        'apiKey': apiKey,
        'sessionUuid': sessionUuid,
      });
    } on PlatformException {
      return null;
    }
  }
}
