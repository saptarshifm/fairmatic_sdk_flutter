import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fairmatic_sdk_flutter_platform_interface.dart';

/// An implementation of [FairmaticSdkFlutterPlatform] that uses method channels.
class MethodChannelFairmaticSdkFlutter extends FairmaticSdkFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fairmatic_sdk_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
