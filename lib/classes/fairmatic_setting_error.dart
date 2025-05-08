class FairmaticSettingError {
  final FairmaticSettingErrorType type;

  FairmaticSettingError({required this.type});

  factory FairmaticSettingError.fromMap(Map<dynamic, dynamic> map) {
    return FairmaticSettingError(
      type: FairmaticSettingErrorTypeExtension.fromNativeValue(
        map['type'] as String,
      ),
    );
  }
}

/// List of errors that must be resolved for trip detection to work correctly.
enum FairmaticSettingErrorType {
  locationPermissionDenied,

  activityRecognitionPermissionDenied,

  preciseLocationDenied,

  locationModeHighAccuracyDenied,

  backgroundRestrictionEnabled,

  batteryOptimizationEnabled,

  notificationsDisabled,

  googlePlayServicesVersionError,

  internalError,
}

extension FairmaticSettingErrorTypeExtension on FairmaticSettingErrorType {
  static FairmaticSettingErrorType fromNativeValue(String value) {
    switch (value) {
      case 'LOCATION_PERMISSION_DENIED':
        return FairmaticSettingErrorType.locationPermissionDenied;
      case 'ACTIVITY_RECOGNITION_PERMISSION_DENIED':
        return FairmaticSettingErrorType.activityRecognitionPermissionDenied;
      case 'PRECISE_LOCATION_DENIED':
        return FairmaticSettingErrorType.preciseLocationDenied;
      case 'LOCATION_MODE_HIGH_ACCURACY_DENIED':
        return FairmaticSettingErrorType.locationModeHighAccuracyDenied;
      case 'BACKGROUND_RESTRICTION_ENABLED':
        return FairmaticSettingErrorType.backgroundRestrictionEnabled;
      case 'BATTERY_OPTIMIZATION_ENABLED':
        return FairmaticSettingErrorType.batteryOptimizationEnabled;
      case 'NOTIFICATIONS_DISABLED':
        return FairmaticSettingErrorType.notificationsDisabled;
      case 'GOOGLE_PLAY_SERVICES_VERSION_ERROR':
        return FairmaticSettingErrorType.googlePlayServicesVersionError;
      case 'INTERNAL_ERROR':
      default:
        return FairmaticSettingErrorType.internalError;
    }
  }
}
