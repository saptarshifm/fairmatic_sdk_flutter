package com.fairmatic.fairmatic_sdk_flutter

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.fairmatic.sdk.Fairmatic
import com.fairmatic.sdk.classes.FairmaticConfiguration
import com.fairmatic.sdk.classes.FairmaticSettingError
import com.fairmatic.sdk.classes.FairmaticSettingsCallback

import com.fairmatic.fairmatic_sdk_flutter.FairmaticSdkFlutterUtils.createDriverAttributes
import com.fairmatic.fairmatic_sdk_flutter.FairmaticSdkFlutterUtils.createTripNotification
import com.fairmatic.fairmatic_sdk_flutter.FairmaticSdkFlutterUtils.createOperationCallback

/**
 * FairmaticSdkFlutterPlugin - Main plugin class for Fairmatic SDK Flutter integration
 */
class FairmaticSdkFlutterPlugin : FlutterPlugin, MethodCallHandler {
    
    companion object {
        private const val TAG = "FairmaticSdkFlutter"
        private const val CHANNEL_NAME = "fairmatic"
        
        // Error codes
        private const val INVALID_ARGUMENT = "INVALID_ARGUMENT"
        private const val BUILD_VERSION_ERROR = "BUILD_VERSION_ERROR"
        private const val SETUP_ERROR = "SETUP_ERROR"
        private const val TEARDOWN_ERROR = "TEARDOWN_ERROR"
        private const val WIPEOUT_ERROR = "WIPEOUT_ERROR"
        private const val START_DRIVE_ERROR = "START_DRIVE_ERROR"
        private const val STOP_PERIOD_ERROR = "STOP_PERIOD_ERROR"
        private const val SETTINGS_ERROR = "SETTINGS_ERROR"
    }

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        Log.d(TAG, "Plugin attached to engine")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "Method call received: ${call.method}")
        
        try {
            when (call.method) {
                "getPlatformVersion" -> handleGetPlatformVersion(result)
                "getBuildVersion" -> handleGetBuildVersion(result)
                "setup" -> handleSetup(call, result)
                "startDriveWithPeriod1" -> handleStartDriveWithPeriod1(call, result)
                "startDriveWithPeriod2" -> handleStartDriveWithPeriod2(call, result)
                "startDriveWithPeriod3" -> handleStartDriveWithPeriod3(call, result)
                "stopPeriod" -> handleStopPeriod(result)
                "getFairmaticSettings" -> handleGetFairmaticSettings(result)
                "teardown" -> handleTeardown(result)
                "wipeOut" -> handleWipeOut(result)
                else -> {
                    Log.w(TAG, "Unhandled method: ${call.method}")
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error in method ${call.method}: ${e.message}", e)
            result.error(
                "UNEXPECTED_ERROR",
                "An unexpected error occurred: ${e.message}",
                null
            )
        }
    }

    /**
     * Handles getPlatformVersion method call
     */
    private fun handleGetPlatformVersion(result: Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    /**
     * Handles getBuildVersion method call
     */
    private fun handleGetBuildVersion(result: Result) {
        try {
            val buildVersion = Fairmatic.getBuildVersion()
            Log.d(TAG, "Build version retrieved: $buildVersion")
            result.success(buildVersion)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting build version", e)
            result.error(
                BUILD_VERSION_ERROR,
                "Failed to get build version: ${e.message}",
                null
            )
        }
    }

    /**
     * Handles setup method call
     */
    private fun handleSetup(call: MethodCall, result: Result) {
        try {
            val configMap = call.argument<Map<String, Any>>("configuration")
            val notificationMap = call.argument<Map<String, Any>>("tripNotification")

            if (configMap == null) {
                result.error(INVALID_ARGUMENT, "Configuration cannot be null", null)
                return
            }

            if (notificationMap == null) {
                result.error(INVALID_ARGUMENT, "Trip notification cannot be null", null)
                return
            }

            val sdkKey = configMap["sdkKey"] as? String
            val driverId = configMap["driverId"] as? String

            if (sdkKey.isNullOrBlank() || driverId.isNullOrBlank()) {
                result.error(INVALID_ARGUMENT, "SDK key and driver ID are required", null)
                return
            }

            val attributesMap = configMap["driverAttributes"] as? Map<*, *>
            val driverAttributes = createDriverAttributes(attributesMap)

            val configuration = FairmaticConfiguration(
                sdkKey = sdkKey,
                driverId = driverId,
                fairmaticDriverAttributes = driverAttributes
            )

            val tripNotification = createTripNotification(notificationMap, context)
            val operationCallback = createOperationCallback(result, "setup")

            Log.d(TAG, "Setting up Fairmatic SDK for driver: $driverId")
            Fairmatic.setup(context, configuration, tripNotification, operationCallback)

        } catch (e: Exception) {
            Log.e(TAG, "Error in setup", e)
            result.error(
                SETUP_ERROR,
                "Failed to setup Fairmatic SDK: ${e.message}",
                null
            )
        }
    }

    /**
     * Handles startDriveWithPeriod1 method call
     */
    private fun handleStartDriveWithPeriod1(call: MethodCall, result: Result) {
        try {
            val trackingId = call.argument<String>("trackingId")

            if (trackingId.isNullOrBlank()) {
                result.error(INVALID_ARGUMENT, "Tracking ID cannot be null or empty", null)
                return
            }

            Log.d(TAG, "Starting drive with period 1, trackingId: $trackingId")

            val operationCallback = createOperationCallback(result, "startDriveWithPeriod1")
            Fairmatic.startDriveWithPeriod1(context, trackingId, operationCallback)

        } catch (e: Exception) {
            Log.e(TAG, "Error starting drive with period 1", e)
            result.error(
                START_DRIVE_ERROR,
                "Failed to start drive with period 1: ${e.message}",
                null
            )
        }
    }

    /**
     * Handles startDriveWithPeriod2 method call
     */
    private fun handleStartDriveWithPeriod2(call: MethodCall, result: Result) {
        try {
            val trackingId = call.argument<String>("trackingId")

            if (trackingId.isNullOrBlank()) {
                result.error(INVALID_ARGUMENT, "Tracking ID cannot be null or empty", null)
                return
            }

            Log.d(TAG, "Starting drive with period 2, trackingId: $trackingId")

            val operationCallback = createOperationCallback(result, "startDriveWithPeriod2")
            Fairmatic.startDriveWithPeriod2(context, trackingId, operationCallback)

        } catch (e: Exception) {
            Log.e(TAG, "Error starting drive with period 2", e)
            result.error(
                START_DRIVE_ERROR,
                "Failed to start drive with period 2: ${e.message}",
                null
            )
        }
    }

    /**
     * Handles startDriveWithPeriod3 method call
     */
    private fun handleStartDriveWithPeriod3(call: MethodCall, result: Result) {
        try {
            val trackingId = call.argument<String>("trackingId")

            if (trackingId.isNullOrBlank()) {
                result.error(INVALID_ARGUMENT, "Tracking ID cannot be null or empty", null)
                return
            }

            Log.d(TAG, "Starting drive with period 3, trackingId: $trackingId")

            val operationCallback = createOperationCallback(result, "startDriveWithPeriod3")
            Fairmatic.startDriveWithPeriod3(context, trackingId, operationCallback)

        } catch (e: Exception) {
            Log.e(TAG, "Error starting drive with period 3", e)
            result.error(
                START_DRIVE_ERROR,
                "Failed to start drive with period 3: ${e.message}",
                null
            )
        }
    }

    /**
     * Handles stopPeriod method call
     */
    private fun handleStopPeriod(result: Result) {
        try {
            Log.d(TAG, "Stopping period")
            val operationCallback = createOperationCallback(result, "stopPeriod")
            Fairmatic.stopPeriod(context, operationCallback)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping period", e)
            result.error(
                STOP_PERIOD_ERROR,
                "Failed to stop period: ${e.message}",
                null
            )
        }
    }

    /**
     * Handles getFairmaticSettings method call
     */
    private fun handleGetFairmaticSettings(result: Result) {
        try {
            Log.d(TAG, "Getting Fairmatic settings")

            val settingsCallback = object : FairmaticSettingsCallback {
                override fun onComplete(errors: List<FairmaticSettingError>) {
                    val errorsList = errors.map { error ->
                        mapOf("type" to error.name)
                    }
                    Log.d(TAG, "Settings retrieved with ${errors.size} issues")
                    result.success(errorsList)
                }
            }

            Fairmatic.getFairmaticSettings(context, settingsCallback)

        } catch (e: Exception) {
            Log.e(TAG, "Error getting Fairmatic settings", e)
            result.error(
                SETTINGS_ERROR,
                "Failed to get Fairmatic settings: ${e.message}",
                null
            )
        }
    }

    /**
     * Handles teardown method call
     */
    private fun handleTeardown(result: Result) {
        try {
            Log.d(TAG, "Tearing down Fairmatic SDK")
            val operationCallback = createOperationCallback(result, "teardown")
            Fairmatic.teardown(context, operationCallback)
        } catch (e: Exception) {
            Log.e(TAG, "Error in teardown", e)
            result.error(
                TEARDOWN_ERROR,
                "Failed to tear down Fairmatic SDK: ${e.message}",
                null
            )
        }
    }

    /**
     * Handles wipeOut method call
     */
    private fun handleWipeOut(result: Result) {
        try {
            Log.d(TAG, "Wiping out Fairmatic data")
            val operationCallback = createOperationCallback(result, "wipeOut")
            Fairmatic.wipeOut(context, operationCallback)
        } catch (e: Exception) {
            Log.e(TAG, "Error in wipeOut", e)
            result.error(
                WIPEOUT_ERROR,
                "Failed to wipe out Fairmatic SDK: ${e.message}",
                null
            )
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "Plugin detached from engine")
        channel.setMethodCallHandler(null)
    }
}