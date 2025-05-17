import 'package:fairmatic_sdk_flutter/classes/fairmatic_setting_error.dart';
import 'package:fairmatic_sdk_flutter/classes/fairmatic_trip_notification.dart';

import 'classes/fairmatic_configuration.dart';
import 'fairmatic_platform_interface.dart';

class Fairmatic {
  /// Gets the active drive information
  static Future<Map<String, dynamic>?> getActiveDriveInfo() =>
      FairmaticPlatform.instance.getActiveDriveInfo();

  /// Gets the SDK build version
  static Future<String> getBuildVersion() =>
      FairmaticPlatform.instance.getBuildVersion();

  /// Checks if event support is available for the device
  static Future<bool> getEventSupportForDevice() =>
      FairmaticPlatform.instance.getEventSupportForDevice();

  /// Gets Fairmatic settings
  static Future<List<FairmaticSettingError>> getFairmaticSettings() =>
      FairmaticPlatform.instance.getFairmaticSettings();

  /// Checks if accident detection is supported
  static Future<bool> isAccidentDetectionSupported() =>
      FairmaticPlatform.instance.isAccidentDetectionSupported();

  /// Validates if the input parameter is valid
  static Future<bool> isValidInputParameter(String parameter) =>
      FairmaticPlatform.instance.isValidInputParameter(parameter);

  /// Sets the drive detection mode
  static Future<void> setFairmaticDriveDetectionMode(String mode) =>
      FairmaticPlatform.instance.setFairmaticDriveDetectionMode(mode);

  /// Sets up the SDK with the provided configuration
  static Future<void> setup(
    FairmaticConfiguration configuration,
    FairmaticTripNotification tripNotification,
  ) => FairmaticPlatform.instance.setup(configuration, tripNotification);

  /// Starts a drive with the given tracking ID
  static Future<void> startDrive(String? trackingId) =>
      FairmaticPlatform.instance.startDrive(trackingId);

  /// Starts a drive with period 1
  static Future<void> startDriveWithPeriod1(String trackingId) =>
      FairmaticPlatform.instance.startDriveWithPeriod1(trackingId);

  /// Starts a drive with period 2
  static Future<void> startDriveWithPeriod2(String trackingId) =>
      FairmaticPlatform.instance.startDriveWithPeriod2(trackingId);

  /// Starts a drive with period 3
  static Future<void> startDriveWithPeriod3(String trackingId) =>
      FairmaticPlatform.instance.startDriveWithPeriod3(trackingId);

  /// Starts a session with the given session ID
  static Future<void> startSession(String sessionId) =>
      FairmaticPlatform.instance.startSession(sessionId);

  /// Stops a manual drive
  static Future<void> stopManualDrive() =>
      FairmaticPlatform.instance.stopManualDrive();

  /// Stops the current period
  static Future<void> stopPeriod() => FairmaticPlatform.instance.stopPeriod();

  /// Stops the current session
  static Future<void> stopSession() => FairmaticPlatform.instance.stopSession();

  /// Tears down the SDK
  static Future<void> teardown() => FairmaticPlatform.instance.teardown();

  /// Triggers a mock accident for testing
  static Future<void> triggerMockAccident({
    required double confidence,
    DateTime? timestamp,
  }) => FairmaticPlatform.instance.triggerMockAccident(
    confidence: confidence,
    timestamp: timestamp,
  );

  /// Uploads all debug data and logs
  static Future<void> uploadAllDebugDataAndLogs() =>
      FairmaticPlatform.instance.uploadAllDebugDataAndLogs();

  /// Wipes out all data
  static Future<void> wipeOut() => FairmaticPlatform.instance.wipeOut();
}
