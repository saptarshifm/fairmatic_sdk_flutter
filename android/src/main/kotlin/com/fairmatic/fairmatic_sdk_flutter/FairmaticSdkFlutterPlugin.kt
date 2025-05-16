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
import com.fairmatic.sdk.classes.FairmaticTripNotification

// import com.fairmatic.sdk.FairmaticConfiguration
// import com.fairmatic.sdk.FairmaticTripNotification
// import com.fairmatic.sdk.FairmaticOperationCallback
// import com.fairmatic.sdk.FairmaticOperationResult

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
        try {
          // Call the Fairmatic SDK's getBuildVersion method
          val buildVersion = Fairmatic.getBuildVersion()
          result.success(buildVersion)
        } catch (e: Exception) {
          // result.error("ERROR", "Failed to get build version: ${e.message}", null)
        }
      }
      
      "setup" -> {
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
          val driverAttributes = if (attributesMap != null) {
            FairmaticDriverAttributes(
              firstName = attributesMap["firstName"] as? String ?: "",
              lastName = attributesMap["lastName"] as? String ?: "",
              email = attributesMap["email"] as? String,
              phoneNumber = attributesMap["phoneNumber"] as? String
            )
          } else {
            FairmaticDriverAttributes(
              firstName = "",
              lastName = ""
            )
          }
          
          val configuration = FairmaticConfiguration(
            sdkKey = sdkKey,
            driverId = driverId,
            fairmaticDriverAttributes = driverAttributes
            // Add other configuration parameters as needed)
          )
          
          // Create trip notification
          val title = notificationMap["title"] as? String ?: "Trip in Progress"
          val content = notificationMap["content"] as? String ?: "Fairmatic is monitoring your trip"
          val iconId = notificationMap["iconId"] as? Int ?: 0 // Default icon ID
          
          val tripNotification = FairmaticTripNotification(
            title,
            content,
            iconId
          )
          
          // Create operation callback
          // Create operation callback
          val operationCallback = object : FairmaticOperationCallback {
            override fun onCompletion(operationResult: FairmaticOperationResult) {
              // Create a map to pass back to Flutter
              val resultMap = HashMap<String, Any?>()

              when (operationResult) {
                is FairmaticOperationResult.Success -> {
                  resultMap["success"] = true
                }
                is FairmaticOperationResult.Failure -> {
                  resultMap["success"] = false
                  // Send the error code as an integer or string instead of the enum object
                  resultMap["errorCode"] = operationResult.error.name  // Use name() for enum string name
                  // or use ordinal for position in enum
                  // resultMap["errorCode"] = operationResult.error.ordinal
                  resultMap["errorMessage"] = operationResult.errorMessage
                }
              }

              // Invoke the callback in Flutter
              try {
                channel.invokeMethod("onOperationCompleted", resultMap)
              } catch (e: Exception) {
                Log.e("FairmaticSdkFlutter", "Error sending operation result: ${e.message}")
              }
            }
          }
          
          // Setup the Fairmatic SDK
          Fairmatic.setup(
            context,
            configuration,
            tripNotification,
            operationCallback
          )
          
          // Return success immediately, actual result will come through the callback
          result.success(null)
          
        } catch (e: Exception) {
          result.error("SETUP_ERROR", "Failed to setup Fairmatic SDK: ${e.message}", null)
        }
      }
      
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}