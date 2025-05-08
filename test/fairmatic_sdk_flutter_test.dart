import 'package:flutter_test/flutter_test.dart';
import 'package:fairmatic_sdk_flutter/fairmatic_sdk_flutter.dart';
import 'package:fairmatic_sdk_flutter/fairmatic_sdk_flutter_platform_interface.dart';
import 'package:fairmatic_sdk_flutter/fairmatic_sdk_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFairmaticSdkFlutterPlatform
    with MockPlatformInterfaceMixin
    implements FairmaticSdkFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FairmaticSdkFlutterPlatform initialPlatform = FairmaticSdkFlutterPlatform.instance;

  test('$MethodChannelFairmaticSdkFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFairmaticSdkFlutter>());
  });

  test('getPlatformVersion', () async {
    FairmaticSdkFlutter fairmaticSdkFlutterPlugin = FairmaticSdkFlutter();
    MockFairmaticSdkFlutterPlatform fakePlatform = MockFairmaticSdkFlutterPlatform();
    FairmaticSdkFlutterPlatform.instance = fakePlatform;

    expect(await fairmaticSdkFlutterPlugin.getPlatformVersion(), '42');
  });
}
