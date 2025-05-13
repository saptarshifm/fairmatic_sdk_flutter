import 'package:fairmatic_sdk_flutter/classes/fairmatic_trip_notification.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'classes/fairmatic_configuration.dart';
import 'classes/fairmatic_operation_callback.dart'
    show FairmaticOperationCallback;
import 'classes/fairmatic_settings_callback.dart';
import 'fairmatic_method_channel.dart';

abstract class FairmaticPlatform extends PlatformInterface {
  static final Object _token = Object();

  static FairmaticPlatform _instance = FairmaticMethodChannel();

  /// The default instance of [FairmaticPlatform] to use.
  static FairmaticPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FairmaticPlatform] when
  /// they register themselves.
  static set instance(FairmaticPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Constructs a FairmaticPlatform.
  FairmaticPlatform() : super(token: _token);

  /// Gets active drive information
  Future<Map<String, dynamic>?> getActiveDriveInfo() {
    throw UnimplementedError('getActiveDriveInfo() has not been implemented.');
  }

  /// Gets the SDK build version
  Future<String> getBuildVersion() {
    throw UnimplementedError('getBuildVersion() has not been implemented.');
  }

  /// Checks if event support is available for the device
  Future<bool> getEventSupportForDevice() {
    throw UnimplementedError(
      'getEventSupportForDevice() has not been implemented.',
    );
  }

  /// Gets Fairmatic settings
  Future<Map<String, dynamic>?> getFairmaticSettings(
    FairmaticSettingsCallback settingsCallback,
  ) {
    throw UnimplementedError(
      'getFairmaticSettings() has not been implemented.',
    );
  }

  /// Checks if accident detection is supported
  Future<bool> isAccidentDetectionSupported() {
    throw UnimplementedError(
      'isAccidentDetectionSupported() has not been implemented.',
    );
  }

  /// Validates if the input parameter is valid
  Future<bool> isValidInputParameter(String parameter) {
    throw UnimplementedError(
      'isValidInputParameter() has not been implemented.',
    );
  }

  /// Sets the drive detection mode
  Future<void> setFairmaticDriveDetectionMode(String mode) {
    throw UnimplementedError(
      'setFairmaticDriveDetectionMode() has not been implemented.',
    );
  }

  /// Sets up the SDK with the provided configuration
  Future<void> setup(
    FairmaticConfiguration configuration,
    FairmaticTripNotification tripNotification,
    FairmaticOperationCallback operationCallback,
  ) {
    throw UnimplementedError('setup() has not been implemented.');
  }

  /// Starts a drive with the given tracking ID
  Future<void> startDrive(String? trackingId) {
    throw UnimplementedError('startDrive() has not been implemented.');
  }

  /// Starts a drive with period 1
  Future<void> startDriveWithPeriod1() {
    throw UnimplementedError(
      'startDriveWithPeriod1() has not been implemented.',
    );
  }

  /// Starts a drive with period 2
  Future<void> startDriveWithPeriod2(String? trackingId) {
    throw UnimplementedError(
      'startDriveWithPeriod2() has not been implemented.',
    );
  }

  /// Starts a drive with period 3
  Future<void> startDriveWithPeriod3(String? trackingId) {
    throw UnimplementedError(
      'startDriveWithPeriod3() has not been implemented.',
    );
  }

  /// Starts a session with the given session ID
  Future<void> startSession(String sessionId) {
    throw UnimplementedError('startSession() has not been implemented.');
  }

  /// Stops a manual drive
  Future<void> stopManualDrive() {
    throw UnimplementedError('stopManualDrive() has not been implemented.');
  }

  /// Stops the current period
  Future<void> stopPeriod() {
    throw UnimplementedError('stopPeriod() has not been implemented.');
  }

  /// Stops the current session
  Future<void> stopSession() {
    throw UnimplementedError('stopSession() has not been implemented.');
  }

  /// Tears down the SDK
  Future<void> teardown() {
    throw UnimplementedError('teardown() has not been implemented.');
  }

  /// Triggers a mock accident for testing
  Future<void> triggerMockAccident({
    required double confidence,
    DateTime? timestamp,
  }) {
    throw UnimplementedError('triggerMockAccident() has not been implemented.');
  }

  /// Uploads all debug data and logs
  Future<void> uploadAllDebugDataAndLogs() {
    throw UnimplementedError(
      'uploadAllDebugDataAndLogs() has not been implemented.',
    );
  }

  /// Wipes out all data
  Future<void> wipeOut() {
    throw UnimplementedError('wipeOut() has not been implemented.');
  }
}
