package com.fairmatic.fairmatic_sdk_flutter

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.MethodChannel.Result
import com.fairmatic.sdk.classes.FairmaticDriverAttributes
import com.fairmatic.sdk.classes.FairmaticOperationCallback
import com.fairmatic.sdk.classes.FairmaticOperationResult
import com.fairmatic.sdk.classes.FairmaticTripNotification

/**
 * Utility functions for the Fairmatic SDK Flutter plugin
 */
object FairmaticSdkFlutterUtils {
    
    private const val TAG = "FairmaticSdkFlutter"
    private const val DEFAULT_ICON_NAME = "ic_notification"
    
    /**
     * Creates driver attributes from a map
     * 
     * @param attributesMap Map containing driver attribute data, can be null
     * @return FairmaticDriverAttributes object with populated or default values
     */
    fun createDriverAttributes(attributesMap: Map<*, *>?): FairmaticDriverAttributes {
        return if (attributesMap != null) {
            FairmaticDriverAttributes(
                firstName = (attributesMap["firstName"] as? String).orEmpty(),
                lastName = (attributesMap["lastName"] as? String).orEmpty(),
                email = attributesMap["email"] as? String,
                phoneNumber = attributesMap["phoneNumber"] as? String
            )
        } else {
            FairmaticDriverAttributes(
                firstName = "",
                lastName = ""
            )
        }
    }

    /**
     * Creates a trip notification from a map
     * 
     * @param notificationMap Map containing notification configuration
     * @param context Android context for resource resolution
     * @return FairmaticTripNotification object with configured values
     */
    fun createTripNotification(
        notificationMap: Map<String, Any>, 
        context: Context
    ): FairmaticTripNotification {
        val title = notificationMap["title"] as? String 
            ?: "Trip in Progress"
        val content = notificationMap["content"] as? String 
            ?: "Fairmatic is monitoring your trip"

        val iconId = resolveNotificationIcon(context)

        return FairmaticTripNotification(
            title,
            content,
            iconId
        )
    }

    /**
     * Creates an operation callback that completes the Flutter result
     * 
     * @param result Flutter method channel result to complete
     * @param operation Name of the operation for logging purposes
     * @return FairmaticOperationCallback that handles success/failure
     */
    fun createOperationCallback(result: Result, operation: String): FairmaticOperationCallback {
        return object : FairmaticOperationCallback {
            override fun onCompletion(operationResult: FairmaticOperationResult) {
                when (operationResult) {
                    is FairmaticOperationResult.Success -> {
                        Log.d(TAG, "$operation completed successfully")
                        result.success(null)
                    }
                    is FairmaticOperationResult.Failure -> {
                        Log.w(TAG, "$operation failed: ${operationResult.errorMessage}")
                        result.error(
                            operationResult.error.name,
                            operationResult.errorMessage,
                            mapOf(
                                "errorCode" to operationResult.error.name,
                                "errorType" to "OPERATION_FAILURE",
                                "operation" to operation
                            )
                        )
                    }
                }
            }
        }
    }
    
    /**
     * Resolves the notification icon resource ID
     * 
     * @param context Android context for resource resolution
     * @return Resource ID for the notification icon
     */
    private fun resolveNotificationIcon(context: Context): Int {
        val iconId = context.resources.getIdentifier(
            DEFAULT_ICON_NAME, 
            "drawable", 
            context.packageName
        )
        
        return if (iconId != 0) {
            Log.d(TAG, "Using custom notification icon: $DEFAULT_ICON_NAME")
            iconId
        } else {
            Log.d(TAG, "Custom icon not found, using system default")
            android.R.drawable.ic_dialog_info
        }
    }
}