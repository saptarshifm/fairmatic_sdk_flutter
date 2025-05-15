package com.fairmatic.fairmatic_sdk_flutter

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.fairmatic.sdk.Fairmatic  // Import the native Fairmatic SDK

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
          result.error("ERROR", "Failed to get build version: ${e.message}", null)
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