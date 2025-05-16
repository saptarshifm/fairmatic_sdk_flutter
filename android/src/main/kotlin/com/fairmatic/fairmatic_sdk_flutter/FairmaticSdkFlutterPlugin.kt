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
          // val iconId = notificationMap["iconId"] as? Int ?: 0 // Default icon ID

          val iconName = "ic_notification"  // This is the PNG file you've added

          // Get the resource ID for the icon
          val iconId = context.resources.getIdentifier(iconName, "drawable", context.packageName)

          // Fallback to system icon if not found
          val finalIconId = if (iconId != 0) iconId else android.R.drawable.ic_dialog_info

          
          val tripNotification = FairmaticTripNotification(
            title,
            content,
            finalIconId,
          )
          
          // Create operation callback
          val operationCallback = object : FairmaticOperationCallback {
            override fun onCompletion(operationResult: FairmaticOperationResult) {
                when (operationResult) {
                    is FairmaticOperationResult.Success -> {
                        // Complete with success
                        result.success(true)  // or any success value you want to return
                    }
                    is FairmaticOperationResult.Failure -> {
                        // Always use error for failures
                        result.error(
                            operationResult.error.name,
                            operationResult.errorMessage,
                            mapOf("errorType" to "OPERATION_FAILURE")
                        )
                    }
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
          
        } catch (e: Exception) {
          result.error(
            "SETUP_ERROR", 
            "Failed to setup Fairmatic SDK: ${e.message}", 
            mapOf("errorType" to "SETUP_EXCEPTION")
        )
        }
      }

      "startDriveWithPeriod1" -> {
    try {
        // Extract the tracking ID parameter
        val trackingId = call.argument<String>("trackingId")

        if (trackingId == null) {
            result.error("INVALID_ARGUMENT", "Tracking ID cannot be null", null)
            return
        }

        Log.d("FairmaticSdkFlutter", "startDriveWithPeriod1 called with trackingId: $trackingId")
        
        // Create operation callback
        val operationCallback = object : FairmaticOperationCallback {
            override fun onCompletion(operationResult: FairmaticOperationResult) {
                when (operationResult) {
                    is FairmaticOperationResult.Success -> {
                        Log.d("FairmaticSdkFlutter", "Drive started successfully with tracking ID: $trackingId")
                        // Complete the Future with success
                        result.success(null)  // or result.success(true) if you want to return a boolean
                    }
                    is FairmaticOperationResult.Failure -> {
                        Log.d("FairmaticSdkFlutter", "Failed to start drive with tracking ID: $trackingId, Error: ${operationResult.errorMessage}")
                        // Complete the Future with an error
                        result.error(
                            "FAIRMATIC_ERROR_${operationResult.error.name}", 
                            operationResult.errorMessage, 
                            mapOf(
                                "errorCode" to operationResult.error.name,
                                "errorType" to "OPERATION_FAILURE"
                            )
                        )
                    }
                }
            }
        }

        // Start the drive with period 1
        Fairmatic.startDriveWithPeriod1(context, trackingId, operationCallback)
        
        // Note: We don't call result.success() here - it will be called in the callback
    } catch (e: Exception) {
        Log.e("FairmaticSdkFlutter", "Exception in startDriveWithPeriod1: ${e.message}")
        result.error("START_DRIVE_ERROR", "Failed to start drive with period 1: ${e.message}", null)
    }
}

      "stopPeriod" -> {
    try {
        Log.d("FairmaticSdkFlutter", "stopPeriod called")
        
        // Create operation callback
        val operationCallback = object : FairmaticOperationCallback {
            override fun onCompletion(operationResult: FairmaticOperationResult) {
                when (operationResult) {
                    is FairmaticOperationResult.Success -> {
                        Log.d("FairmaticSdkFlutter", "Period stopped successfully")
                        // Complete the Future with success
                        result.success(null)  // or result.success(true) if you want to return a boolean
                    }
                    is FairmaticOperationResult.Failure -> {
                        Log.d("FairmaticSdkFlutter", "Failed to stop period: ${operationResult.errorMessage}")
                        // Complete the Future with an error
                        result.error(
                            "FAIRMATIC_ERROR_${operationResult.error.name}", 
                            operationResult.errorMessage, 
                            mapOf(
                                "errorCode" to operationResult.error.name,
                                "errorType" to "OPERATION_FAILURE"
                            )
                        )
                    }
                }
            }
        }

        // Stop the period
        Fairmatic.stopPeriod(context, operationCallback)
        
        // Note: We don't call result.success() here - it will be called in the callback
    } catch (e: Exception) {
        Log.e("FairmaticSdkFlutter", "Exception in stopPeriod: ${e.message}")
        result.error("STOP_PERIOD_ERROR", "Failed to stop period: ${e.message}", null)
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