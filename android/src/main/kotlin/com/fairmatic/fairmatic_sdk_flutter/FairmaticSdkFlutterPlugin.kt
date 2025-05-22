package com.fairmatic.fairmatic_sdk_flutter

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.fairmatic.sdk.Fairmatic  // Import the native Fairmatic SDK
import com.fairmatic.sdk.classes.FairmaticConfiguration
import com.fairmatic.sdk.classes.FairmaticDriverAttributes
import com.fairmatic.sdk.classes.FairmaticOperationCallback
import com.fairmatic.sdk.classes.FairmaticOperationResult
import com.fairmatic.sdk.classes.FairmaticSettingError
import com.fairmatic.sdk.classes.FairmaticSettingsCallback
import com.fairmatic.sdk.classes.FairmaticTripNotification

import com.fairmatic.fairmatic_sdk_flutter.FairmaticSdkFlutterUtils.createDriverAttributes
import com.fairmatic.fairmatic_sdk_flutter.FairmaticSdkFlutterUtils.createTripNotification
import com.fairmatic.fairmatic_sdk_flutter.FairmaticSdkFlutterUtils.createOperationCallback


/** FairmaticSdkFlutterPlugin */
class FairmaticSdkFlutterPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will handle the communication between Flutter and native Android
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fairmatic")  // Change to match your Dart channel name
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      
      "getBuildVersion" -> {
        handleGetBuildVersion(result)
      }
      
      "setup" -> {
        handleSetup(call, result)
      }

      "startDriveWithPeriod1" -> {
        handleStartDriveWithPeriod1(call, result)
      }

      "startDriveWithPeriod2" -> {
      handleStartDriveWithPeriod2(call, result)
      }

      "startDriveWithPeriod3" -> {
        handleStartDriveWithPeriod3(call, result)
      }

      "stopPeriod" -> {
        handleStopPeriod(result)
      }

      "getFairmaticSettings" -> {
        handleGetFairmaticSettings(result)
      }

      "teardown" -> {
          handleTeardown(result)
      }

      "wipeOut" -> {
        handleWipeOut(result)
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  private fun handleGetBuildVersion(result: Result) {
    try {
      val buildVersion = Fairmatic.getBuildVersion()
      result.success(buildVersion)
    } catch (e: Exception) {
      Log.e("FairmaticSdkFlutter", "Error getting build version: ${e.message}")
      result.error("BUILD_VERSION_ERROR", "Failed to get build version: ${e.message}", null)
    }
  }

  private fun handleSetup(call: MethodCall, result: Result) {
    try {
      // Extract parameters from the method call
      val configMap = call.argument<Map<String, Any>>("configuration")
      val notificationMap = call.argument<Map<String, Any>>("tripNotification")
      
      Log.d("FairmaticSdkFlutter", "setup called with config: $configMap, notification: $notificationMap")
      
      if (configMap == null) {
        result.error("INVALID_ARGUMENT", "Configuration cannot be null", null)
        return
      }
      
      if (notificationMap == null) {
        result.error("INVALID_ARGUMENT", "Trip notification cannot be null", null)
        return
      }
      
      // Create a Fairmatic configuration
      val sdkKey = configMap["sdkKey"] as? String
      val driverId = configMap["driverId"] as? String
      val attributesMap = configMap["driverAttributes"] as? Map<*, *>

      Log.d("FairmaticSdkFlutter", "SDK Key: $sdkKey, Driver ID: $driverId, Attributes: $attributesMap")
      
      if (sdkKey == null || driverId == null) {
        result.error("INVALID_ARGUMENT", "SDK key and driver ID are required", null)
        return
      }

      // Create FairmaticDriverAttributes from the map
      val driverAttributes = createDriverAttributes(attributesMap)
      
      val configuration = FairmaticConfiguration(
        sdkKey = sdkKey,
        driverId = driverId,
        fairmaticDriverAttributes = driverAttributes
      )
      
      // Create trip notification
      val tripNotification = createTripNotification( notificationMap, context)
      
      // Create operation callback
      val operationCallback = createOperationCallback(result, "setup")
      
      // Setup the Fairmatic SDK
      Fairmatic.setup(
        context,
        configuration,
        tripNotification,
        operationCallback
      )
      
    } catch (e: Exception) {
      Log.e("FairmaticSdkFlutter", "Error in setup: ${e.message}")
      result.error(
        "SETUP_ERROR", 
        "Failed to setup Fairmatic SDK: ${e.message}", 
        mapOf("errorType" to "SETUP_EXCEPTION")
      )
    }
  }

  private fun handleTeardown(result: Result) {
    try {
      Log.d("FairmaticSdkFlutter", "teardown called")

      // Create operation callback
      val operationCallback = createOperationCallback(result, "teardown")

      // Call Fairmatic teardown
      Fairmatic.teardown(context, operationCallback)

      // Note: We don't call result.success() here - it will be called in the callback
    } catch (e: Exception) {
      Log.e("FairmaticSdkFlutter", "Exception in teardown: ${e.message}")
      result.error(
        "TEARDOWN_ERROR",
        "Failed to tear down Fairmatic SDK: ${e.message}",
        null
      )
    }
  }

  private fun handleWipeOut(result: Result) {
    try {
      Log.d("FairmaticSdkFlutter", "Wipeout called")

      // Create operation callback
      val operationCallback = createOperationCallback(result, "wipeout")

      // Call Fairmatic wipeout
      Fairmatic.wipeOut(context, operationCallback)

      // Note: We don't call result.success() here - it will be called in the callback
    } catch (e: Exception) {
      Log.e("FairmaticSdkFlutter", "Exception in wipeout: ${e.message}")
      result.error(
        "WIPEOUT_ERROR",
        "Failed to wipe out Fairmatic SDK: ${e.message}",
        null
      )
    }
  }
  

  private fun handleStartDriveWithPeriod1(call: MethodCall, result: Result) {
    try {
      // Extract the tracking ID parameter
      val trackingId = call.argument<String>("trackingId")
      Log.d("FairmaticSdkFlutter", "startDriveWithPeriod1 called with trackingId: $trackingId")

      if (trackingId == null) {
        result.error("INVALID_ARGUMENT", "Tracking ID cannot be null", null)
        return
      }

      Log.d("FairmaticSdkFlutter", "startDriveWithPeriod1 called with trackingId: $trackingId")
      
      // Create operation callback
      val operationCallback = createOperationCallback(result, "startDriveWithPeriod1")

      // Start the drive with period 1
      Fairmatic.startDriveWithPeriod1(context, trackingId, operationCallback)
      
    } catch (e: Exception) {
      Log.e("FairmaticSdkFlutter", "Exception in startDriveWithPeriod1: ${e.message}")
      result.error("START_DRIVE_ERROR", "Failed to start drive with period 1: ${e.message}", null)
    }
  }

  private fun handleStartDriveWithPeriod2(call: MethodCall, result: Result) {
    try {
      // Extract the tracking ID parameter
      val trackingId = call.argument<String>("trackingId")
  
      if (trackingId == null) {
        result.error("INVALID_ARGUMENT", "Tracking ID cannot be null", "Tracking Id null")
        return
      }

      val operationCallback = createOperationCallback(result, "startDriveWithPeriod2")
  
      // Start the drive with period 2
      Fairmatic.startDriveWithPeriod2(context, trackingId, operationCallback)
      
    } catch (e: Exception) {
      Log.e("FairmaticSdkFlutter", "Exception in startDriveWithPeriod2: ${e.message}")
      result.error("START_DRIVE_ERROR", "Failed to start drive with period 2: ${e.message}", "Object null")
    }
  }

  private fun handleStartDriveWithPeriod3(call: MethodCall, result: Result) {
    try {
      // Extract the tracking ID parameter
      val trackingId = call.argument<String>("trackingId")
  
      if (trackingId == null) {
        result.error("INVALID_ARGUMENT", "Tracking ID cannot be null", null)
        return
      }
  
      Log.d("FairmaticSdkFlutter", "startDriveWithPeriod3 called with trackingId: $trackingId")
      
      // Create operation callback
      val operationCallback = createOperationCallback(result, "startDriveWithPeriod3")
  
      // Start the drive with period 3
      Fairmatic.startDriveWithPeriod3(context, trackingId, operationCallback)
      
    } catch (e: Exception) {
      Log.e("FairmaticSdkFlutter", "Exception in startDriveWithPeriod3: ${e.localizedMessage}")
      result.error("START_DRIVE_ERROR", "Failed to start drive with period 3: ${e.message}", null)
    }
  }

  private fun handleStopPeriod(result: Result) {
    try {
      Log.d("FairmaticSdkFlutter", "stopPeriod called")
      
      // Create operation callback
      val operationCallback = createOperationCallback(result, "stopPeriod")

      // Stop the period
      Fairmatic.stopPeriod(context, operationCallback)
      
    } catch (e: Exception) {
      Log.e("FairmaticSdkFlutter", "Exception in stopPeriod: ${e.message}")
      result.error("STOP_PERIOD_ERROR", "Failed to stop period: ${e.message}", null)
    }
  }

  private fun handleGetFairmaticSettings(result: Result) {
    try {
      Log.d("FairmaticSdkFlutter", "getFairmaticSettings called")

      // Create settings callback that completes the Flutter result
      val settingsCallback = object : FairmaticSettingsCallback {
        override fun onComplete(errors: List<FairmaticSettingError>) {
          // Convert errors to a list of maps
          val errorsList = errors.map { error ->
            mapOf("type" to error.name)
          }

          // Complete the Flutter Future with the errors list directly
          result.success(errorsList)
        }
      }

      // Get Fairmatic settings
      Fairmatic.getFairmaticSettings(context, settingsCallback)

      // Note: We don't call result.success() here - it will be called in the callback
    } catch (e: Exception) {
      Log.e("FairmaticSdkFlutter", "Exception in getFairmaticSettings: ${e.message}")
      result.error(
        "SETTINGS_ERROR",
        "Failed to get Fairmatic settings: ${e.message}",
        null
      )
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

}


/*
private fun handleStartDriveWithPeriod(call: MethodCall, result: Result, periodType: Int) {
    try {
        // Extract the tracking ID parameter
        val trackingId = call.argument<String>("trackingId")

        if (trackingId == null) {
            result.error("INVALID_ARGUMENT", "Tracking ID cannot be null", null)
            return
        }

        Log.d("FairmaticSdkFlutter", "startDriveWithPeriod$periodType called with trackingId: $trackingId")
        
        // Create operation callback
        val operationCallback = createOperationCallback(result, "startDriveWithPeriod$periodType")

        // Call the appropriate Fairmatic SDK method based on period type
        when (periodType) {
            1 -> Fairmatic.startDriveWithPeriod1(context, trackingId, operationCallback)
            2 -> Fairmatic.startDriveWithPeriod2(context, trackingId, operationCallback)
            3 -> Fairmatic.startDriveWithPeriod3(context, trackingId, operationCallback)
            else -> {
                result.error("INVALID_PERIOD", "Invalid period type: $periodType", null)
                return
            }
        }
        
    } catch (e: Exception) {
        Log.e("FairmaticSdkFlutter", "Exception in startDriveWithPeriod$periodType: ${e.message}")
        result.error("START_DRIVE_ERROR", "Failed to start drive with period $periodType: ${e.message}", null)
    }
}
*/