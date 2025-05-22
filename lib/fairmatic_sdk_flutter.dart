import 'package:fairmatic_sdk_flutter/classes/fairmatic_setting_error.dart';
import 'package:fairmatic_sdk_flutter/classes/fairmatic_trip_notification.dart';

import 'classes/fairmatic_configuration.dart';
import 'fairmatic_platform_interface.dart';

/// Fairmatic class is the entry point into the Fairmatic SDK Flutter plugin.
/// All methods are threadsafe.
///
/// Applications which want to record Fairmatic insurance trips for a driver may use this API.
/// All drives when a period is in progress will be tagged with the period id. This period id will be made available in the reports and API that Fairmatic provides via the Fairmatic dashboard.
///
/// Only one period may be active at a time. To switch the Fairmatic insurance period, the application can call the relevant startPeriod method directly. Switching periods or calling stop method stops any active drives. A drive with multiple insurance periods will be split into multiple trips for different insurance periods.
class Fairmatic {
  /// Returns an identifier which can be used to identify this SDK build.
  ///
  /// This method returns the version string of the Fairmatic SDK.
  static Future<String> getBuildVersion() =>
      FairmaticPlatform.instance.getBuildVersion();

  /// Checks if event support is available for the device
  ///
  /// Returns `true` if the device supports event detection features,
  /// `false` otherwise.
  static Future<bool> getEventSupportForDevice() =>
      FairmaticPlatform.instance.getEventSupportForDevice();

  /// Get the current state of settings affecting the Fairmatic SDK's normal operation.
  ///
  /// This method returns a list of [FairmaticSettingError] objects that contains
  /// errors and warnings that are affecting Fairmatic's ability to detect trips
  /// and perform other tasks.
  ///
  /// Common issues include:
  /// - Location permission denied
  /// - Activity recognition permission denied
  /// - Battery optimization enabled
  /// - Background restrictions enabled
  /// - Notifications disabled
  ///
  /// Returns an empty list if no issues are found.
  static Future<List<FairmaticSettingError>> getFairmaticSettings() =>
      FairmaticPlatform.instance.getFairmaticSettings();

  /// Checks if accident detection is supported on this device
  ///
  /// Returns `true` if the device supports accident detection features,
  /// `false` otherwise.
  static Future<bool> isAccidentDetectionSupported() =>
      FairmaticPlatform.instance.isAccidentDetectionSupported();

  /// Validates if the input parameter is valid
  ///
  /// [parameter] - The parameter string to validate
  ///
  /// Returns `true` if the parameter is valid, `false` otherwise.
  static Future<bool> isValidInputParameter(String parameter) =>
      FairmaticPlatform.instance.isValidInputParameter(parameter);

  /// Sets the drive detection mode
  ///
  /// [mode] - The drive detection mode to set
  ///
  /// This method configures how the SDK detects and handles drives.
  static Future<void> setFairmaticDriveDetectionMode(String mode) =>
      FairmaticPlatform.instance.setFairmaticDriveDetectionMode(mode);

  /// Setup the Fairmatic SDK with a configuration.
  ///
  /// The application should call this method before anything else in the Fairmatic SDK.
  /// This API should be called early in the application lifecycle.
  /// Calling this method multiple times with the same 'sdkKey' and 'driverId'
  /// in the [FairmaticConfiguration] is a no-op.
  ///
  /// [configuration] - The configuration properties to setup the Fairmatic SDK. Cannot be null.
  /// [tripNotification] - The trip notification object to be used by the Fairmatic SDK. Cannot be null.
  ///
  /// Throws [FairmaticException] if setup fails.
  static Future<void> setup(
    FairmaticConfiguration configuration,
    FairmaticTripNotification tripNotification,
  ) => FairmaticPlatform.instance.setup(configuration, tripNotification);

  /// Starts a drive with the given tracking ID
  ///
  /// [trackingId] - An identifier which allows identifying this drive uniquely.
  /// This identifier must be unique for this user. It may not be null or empty.
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> startDrive(String? trackingId) =>
      FairmaticPlatform.instance.startDrive(trackingId);

  /// Call this method once the driver waits for a new ride or delivery request
  ///
  /// A manual trip with the given trackingId will be started immediately.
  /// If this is already in progress with the same trackingId, this call will be a no-op.
  ///
  /// [trackingId] - An identifier which allows identifying this drive uniquely.
  /// This identifier must be unique for this user. It may not be null or empty.
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> startDriveWithPeriod1(String trackingId) =>
      FairmaticPlatform.instance.startDriveWithPeriod1(trackingId);

  /// Call this method once the driver accepts the ride or delivery request
  ///
  /// A manual trip with the given trackingId will be started immediately.
  /// If this is already in progress with the same trackingId, this call will be a no-op.
  ///
  /// [trackingId] - An identifier which allows identifying this drive uniquely.
  /// This identifier must be unique for this user. It may not be null or empty.
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> startDriveWithPeriod2(String trackingId) =>
      FairmaticPlatform.instance.startDriveWithPeriod2(trackingId);

  /// Call this method once the driver starts the ride or delivery
  ///
  /// A manual trip with the given trackingId will be started immediately.
  /// The entire duration in this period will be recorded as a single trip.
  /// If this is already in progress with the same trackingId, this call will be a no-op.
  ///
  /// [trackingId] - An identifier which allows identifying this drive uniquely.
  /// This identifier must be unique for this user. It may not be null or empty.
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> startDriveWithPeriod3(String trackingId) =>
      FairmaticPlatform.instance.startDriveWithPeriod3(trackingId);

  /// Starts a session with the given session ID
  ///
  /// [sessionId] - The unique identifier for the session
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> startSession(String sessionId) =>
      FairmaticPlatform.instance.startSession(sessionId);

  /// Stops a manual drive
  ///
  /// This method stops any currently active manual drive.
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> stopManualDrive() =>
      FairmaticPlatform.instance.stopManualDrive();

  /// Call this method once the driver completes the ride or delivery
  ///
  /// Ongoing trips will be stopped and the current period will end.
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> stopPeriod() => FairmaticPlatform.instance.stopPeriod();

  /// Stops the current session
  ///
  /// This method ends the currently active session.
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> stopSession() => FairmaticPlatform.instance.stopSession();

  /// Shuts down the Fairmatic framework.
  ///
  /// This may be called if the client wishes to turn off the Fairmatic framework
  /// to isolate the operations that the application is doing.
  /// This is a no-op if [setup] has not been called.
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> teardown() => FairmaticPlatform.instance.teardown();

  /// Triggers a mock accident for testing purposes
  ///
  /// [confidence] - The confidence level of the mock accident (0.0 to 1.0)
  /// [timestamp] - Optional timestamp for the accident. If null, current time is used.
  ///
  /// This method is intended for testing and development purposes only.
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> triggerMockAccident({
    required double confidence,
    DateTime? timestamp,
  }) => FairmaticPlatform.instance.triggerMockAccident(
    confidence: confidence,
    timestamp: timestamp,
  );

  /// Uploads all debug data and logs to Fairmatic servers
  ///
  /// This method uploads diagnostic information that can help with troubleshooting
  /// and debugging issues with the SDK.
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> uploadAllDebugDataAndLogs() =>
      FairmaticPlatform.instance.uploadAllDebugDataAndLogs();

  /// Wipe out all the data that Fairmatic keeps locally on the device.
  ///
  /// When Fairmatic SDK is torn down, trip data that is locally persisted continues
  /// to remain persisted. The data will be uploaded when SDK setup is called at a later time.
  /// Wipeout should be used when the application wants to remove all traces of Fairmatic on the device.
  /// Data cannot be recovered after this call.
  ///
  /// **NOTE: This call can be made when the SDK is not running. Call [teardown] to tear down
  /// a live SDK before making this call.**
  ///
  /// Throws [FairmaticException] if the operation fails.
  static Future<void> wipeOut() => FairmaticPlatform.instance.wipeOut();
}
