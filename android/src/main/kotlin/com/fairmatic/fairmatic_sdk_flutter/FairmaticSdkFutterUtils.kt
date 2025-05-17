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

    /**
     * Creates driver attributes from a map
     */
    fun createDriverAttributes(attributesMap: Map<*, *>?): FairmaticDriverAttributes {
        return if (attributesMap != null) {
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
    }

    /**
     * Creates a trip notification from a map
     */
    fun createTripNotification(notificationMap: Map<String, Any>, context: Context): FairmaticTripNotification {
        val title = notificationMap["title"] as? String ?: "Trip in Progress"
        val content = notificationMap["content"] as? String ?: "Fairmatic is monitoring your trip"

        val iconName = "ic_notification"
        val iconId = context.resources.getIdentifier(iconName, "drawable", context.packageName)
        val finalIconId = if (iconId != 0) iconId else android.R.drawable.ic_dialog_info

        return FairmaticTripNotification(
            title,
            content,
            finalIconId
        )
    }

    /**
     * Creates an operation callback that completes the Flutter result
     */
    fun createOperationCallback(result: Result, operation: String): FairmaticOperationCallback {
        return object : FairmaticOperationCallback {
            override fun onCompletion(operationResult: FairmaticOperationResult) {
                when (operationResult) {
                    is FairmaticOperationResult.Success -> {
                        Log.d("FairmaticSdkFlutter", "$operation completed successfully")
                        result.success(null)
                    }
                    is FairmaticOperationResult.Failure -> {
                        Log.d("FairmaticSdkFlutter", "$operation failed: ${operationResult.errorMessage}")
                        result.error(
                            operationResult.error.name,
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
    }
}