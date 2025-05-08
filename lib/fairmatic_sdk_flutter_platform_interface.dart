import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fairmatic_sdk_flutter_method_channel.dart';

abstract class FairmaticSdkFlutterPlatform extends PlatformInterface {
  /// Constructs a FairmaticSdkFlutterPlatform.
  FairmaticSdkFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FairmaticSdkFlutterPlatform _instance = MethodChannelFairmaticSdkFlutter();

  /// The default instance of [FairmaticSdkFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFairmaticSdkFlutter].
  static FairmaticSdkFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FairmaticSdkFlutterPlatform] when
  /// they register themselves.
  static set instance(FairmaticSdkFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
