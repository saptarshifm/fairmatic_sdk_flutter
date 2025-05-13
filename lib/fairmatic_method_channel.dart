// lib/src/fairmatic_method_channel.dart
import 'package:fairmatic_sdk_flutter/classes/fairmatic_setting_error.dart';
import 'package:fairmatic_sdk_flutter/classes/fairmatic_trip_notification.dart';
import 'package:flutter/services.dart';

import 'classes/fairmatic_configuration.dart';
import 'classes/fairmatic_operation_callback.dart';
import 'classes/fairmatic_operation_result.dart';
import 'classes/fairmatic_settings_callback.dart';
import 'fairmatic_platform_interface.dart';

class FairmaticMethodChannel extends FairmaticPlatform {
  /// The method channel used to interact with the native platform.
  static const MethodChannel _channel = MethodChannel('fairmatic');

  /// Callback for operations
  FairmaticOperationCallback? _operationCallback;

  /// Callback for settings
  FairmaticSettingsCallback? _settingsCallback;

  /// Constructor
  FairmaticMethodChannel() {
    _setMethodCallHandler();
  }

  @override
  Future<Map<String, dynamic>?> getActiveDriveInfo() async {
    final Map<dynamic, dynamic>? activeDriveInfo = await _channel.invokeMethod(
      'getActiveDriveInfo',
    );
    return activeDriveInfo?.cast<String, dynamic>();
  }

  @override
  Future<String> getBuildVersion() async {
    final String buildVersion = await _channel.invokeMethod('getBuildVersion');
    return buildVersion;
  }

  @override
  Future<bool> getEventSupportForDevice() async {
    final bool isSupported = await _channel.invokeMethod(
      'getEventSupportForDevice',
    );
    return isSupported;
  }

  @override
  Future<Map<String, dynamic>?> getFairmaticSettings(
    FairmaticSettingsCallback settingsCallback,
  ) async {
    _settingsCallback = settingsCallback;

    final Map<dynamic, dynamic>? settings = await _channel.invokeMethod(
      'getFairmaticSettings',
    );
    return settings?.cast<String, dynamic>();
  }

  @override
  Future<bool> isAccidentDetectionSupported() async {
    final bool isSupported = await _channel.invokeMethod(
      'isAccidentDetectionSupported',
    );
    return isSupported;
  }

  @override
  Future<bool> isValidInputParameter(String parameter) async {
    final bool isValid = await _channel.invokeMethod(
      'isValidInputParameter',
      parameter,
    );
    return isValid;
  }

  @override
  Future<void> setFairmaticDriveDetectionMode(String mode) async {
    await _channel.invokeMethod('setFairmaticDriveDetectionMode', {
      'mode': mode,
    });
  }

  @override
  Future<void> setup(
    FairmaticConfiguration configuration,
    FairmaticTripNotification tripNotification,
    FairmaticOperationCallback operationCallback,
  ) async {
    _operationCallback = operationCallback;

    await _channel.invokeMethod('setup', {
      'fairmaticConfiguration': configuration.toMap(),
      'fairmaticTripNotification': tripNotification.toMap(),
    });
  }

  @override
  Future<void> startDrive(String? trackingId) async {
    await _channel.invokeMethod('startDrive', {'trackingId': trackingId});
  }

  @override
  Future<void> startDriveWithPeriod1() async {
    await _channel.invokeMethod('startDriveWithPeriod1');
  }

  @override
  Future<void> startDriveWithPeriod2(String? trackingId) async {
    await _channel.invokeMethod('startDriveWithPeriod2', trackingId);
  }

  @override
  Future<void> startDriveWithPeriod3(String? trackingId) async {
    await _channel.invokeMethod('startDriveWithPeriod3', trackingId);
  }

  @override
  Future<void> startSession(String sessionId) async {
    await _channel.invokeMethod('startSession', {'sessionId': sessionId});
  }

  @override
  Future<void> stopManualDrive() async {
    await _channel.invokeMethod('stopManualDrive');
  }

  @override
  Future<void> stopPeriod() async {
    await _channel.invokeMethod('stopPeriod');
  }

  @override
  Future<void> stopSession() async {
    await _channel.invokeMethod('stopSession');
  }

  @override
  Future<void> teardown() async {
    await _channel.invokeMethod('teardown');
  }

  @override
  Future<void> triggerMockAccident({
    required double confidence,
    DateTime? timestamp,
  }) async {
    await _channel.invokeMethod('triggerMockAccident', {
      'confidence': confidence,
      'timestamp':
          timestamp?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> uploadAllDebugDataAndLogs() async {
    await _channel.invokeMethod('uploadAllDebugDataAndLogs');
  }

  @override
  Future<void> wipeOut() async {
    await _channel.invokeMethod('wipeOut');
  }

  /// Sets up the method call handler
  void _setMethodCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onOperationCallback':
          if (_operationCallback != null) {
            final Map<dynamic, dynamic> args = call.arguments;
            final operationResult = FairmaticOperationResult.fromMap(
              args.cast<String, dynamic>(),
            );
            _operationCallback!.onCompletion(operationResult);
          }
          break;
        case 'onSettingsCallback':
          if (_settingsCallback != null) {
            final Map<dynamic, dynamic> args = call.arguments;

            // Convert the arguments to a FairmaticSettingError object
            // If there's a list of errors, we need to handle that
            if (args.containsKey('errors') && args['errors'] is List) {
              List<dynamic> errorsList = args['errors'];
              List<FairmaticSettingError> errors =
                  errorsList
                      .map(
                        (e) => FairmaticSettingError.fromMap(
                          e.cast<String, dynamic>(),
                        ),
                      )
                      .toList();
              _settingsCallback!.onComplete(errors.isEmpty ? null : errors);
            } else {
              _settingsCallback!.onComplete(null);
            }
          }
          break;
        default:
          print('Method not implemented: ${call.method}');
      }
    });
  }
}
