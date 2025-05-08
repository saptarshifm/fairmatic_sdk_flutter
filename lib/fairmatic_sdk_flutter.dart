
import 'fairmatic_sdk_flutter_platform_interface.dart';

class FairmaticSdkFlutter {
  Future<String?> getPlatformVersion() {
    return FairmaticSdkFlutterPlatform.instance.getPlatformVersion();
  }
}
