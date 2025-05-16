import 'dart:async';

import 'package:fairmatic_sdk_flutter/classes/fairmatic_configuration.dart';
import 'package:fairmatic_sdk_flutter/classes/fairmatic_driver_attributes.dart';
import 'package:fairmatic_sdk_flutter/classes/fairmatic_operation_callback.dart';
import 'package:fairmatic_sdk_flutter/classes/fairmatic_operation_result.dart';
import 'package:fairmatic_sdk_flutter/classes/fairmatic_trip_notification.dart';
import 'package:fairmatic_sdk_flutter/fairmatic_sdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String _fairmaticVersion = 'Unknown';
  String _sdkStatus = 'Not initialized';
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fairmatic SDK Example')),
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Fairmatic SDK Version:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _fairmaticVersion,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'SDK Status: $_sdkStatus',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isInitialized ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: getFairmaticVersion,
                        child: const Text('Refresh Version'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            _isInitialized ? null : initializeFairmaticSDK,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isInitialized ? Colors.grey : Colors.blue,
                        ),
                        child: Text(
                          _isInitialized
                              ? 'SDK Initialized'
                              : 'Initialize Fairmatic SDK',
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Future<void> getFairmaticVersion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String version = await Fairmatic.getBuildVersion();
      setState(() {
        _fairmaticVersion = version;
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _fairmaticVersion = 'Error: ${e.message}';
        _isLoading = false;
      });
    }
  }

  Future<void> initializeFairmaticSDK() async {
    setState(() {
      _isLoading = true;
      _sdkStatus = 'Initializing...';
    });

    try {
      final attribute = FairmaticDriverAttributes(
        firstName: "Sachin",
        lastName: "Tendulkar",
      );
      // Create a configuration with required parameters
      // Replace 'YOUR_SDK_KEY' with your actual Fairmatic SDK key
      final configuration = FairmaticConfiguration(
        sdkKey: 'UXBDuLRFg6k2YT3oys2T9njD8BEzAoA1',
        driverId: '35b73e53-898e-4107-aae3-9874743fbf70',
        driverAttributes: attribute,
      );

      // Configure trip notifications
      final tripNotification = FairmaticTripNotification(
        title: 'Trip in Progress',
        content: 'Fairmatic is monitoring your trip',
        iconId: 1,
      );

      // Set up method channel handler to receive callbacks from the native side
      const methodChannel = MethodChannel(
        'fairmatic',
      ); // Make sure this name matches the one in your plugin
      methodChannel.setMethodCallHandler((call) async {
        if (call.method == 'onOperationCompleted') {
          final arguments = call.arguments as Map<dynamic, dynamic>;
          final success = arguments['success'] as bool;

          if (success) {
            setState(() {
              _sdkStatus = 'Initialized successfully';
              _isInitialized = true;
              _isLoading = false;
            });
            _showSnackBar('Fairmatic SDK initialized successfully');
          } else {
            final errorMessage = arguments['errorMessage'] as String;
            setState(() {
              _sdkStatus = 'Initialization error: $errorMessage';
              _isInitialized = false;
              _isLoading = false;
            });
            _showSnackBar('Initialization error: $errorMessage');
          }
        }
        return null;
      });

      // Create operation callbacks
      final operationCallback = SimpleOperationCallback(
        onCompletionHandler: (result) {
          print("Operation result: $result");

          // Check if it's a Success or Failure result
          if (result is Success) {
            setState(() {
              _sdkStatus = 'Initialized successfully';
              _isInitialized = true;
              _isLoading = false;
            });
            _showSnackBar('Fairmatic SDK initialized successfully');
          } else if (result is Failure) {
            setState(() {
              _sdkStatus = 'Initialization error: ${result.errorMessage}';
              _isInitialized = false;
              _isLoading = false;
            });
            _showSnackBar('Initialization error: ${result.errorMessage}');
          }
        },
      );

      print(configuration.toMap());

      // Initialize the SDK
      await Fairmatic.setup(configuration, tripNotification, operationCallback);
    } on PlatformException catch (e) {
      setState(() {
        _sdkStatus = 'Setup failed: ${e.message}';
        _isInitialized = false;
        _isLoading = false;
      });
      _showSnackBar('Error initializing SDK: ${e.message}');
    } catch (e) {
      setState(() {
        _sdkStatus = 'Setup failed: $e';
        _isInitialized = false;
        _isLoading = false;
      });
      _showSnackBar('Error initializing SDK: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getFairmaticVersion();
  }

  void _showSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomePage());
  }

  // @override
  // State<MyApp> createState() => _MyAppState();
}

// Concrete implementation of FairmaticOperationCallback
class SimpleOperationCallback implements FairmaticOperationCallback {
  final Function(FairmaticOperationResult) onCompletionHandler;

  SimpleOperationCallback({required this.onCompletionHandler});

  @override
  void onCompletion(FairmaticOperationResult result) {
    onCompletionHandler(result);
  }
}
