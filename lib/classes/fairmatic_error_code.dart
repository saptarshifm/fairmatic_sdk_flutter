enum FairmaticErrorCode {
  // Make sure these match the ORDINAL positions in the Kotlin enum
  invalidDriverId, // INVALID_DRIVER_ID (position 0)
  sdkNotSetup, // SDK_NOT_SETUP (position 1)
  invalidTrackingId, // INVALID_TRACKING_ID (position 2)
  networkNotAvailable, // NETWORK_NOT_AVAILABLE (position 3)
  fairmaticSdkError, // FAIRMATIC_SDK_ERROR (position 4)
  fairmaticSdkNotTornDown, // FAIRMATIC_SDK_NOT_TORN_DOWN (position 5)
  invalidDriverName, // INVALID_DRIVER_NAME (position 6)
  sdkKeyNotFound, // SDK_KEY_NOT_FOUND (position 7)
  fleetSizeLimitExceeded, // FLEET_SIZE_LIMIT_EXCEEDED (position 8)
  driverDeleted, // DRIVER_DELETED (position 9)
  accountNotProvisioned, // ACCOUNT_NOT_PROVISIONED (position 10)
  unknown, // For any other errors
}
