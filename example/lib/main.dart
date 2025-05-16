import 'dart:async';

import 'package:fairmatic_sdk_flutter/classes/fairmatic_configuration.dart';
import 'package:fairmatic_sdk_flutter/classes/fairmatic_driver_attributes.dart';
import 'package:fairmatic_sdk_flutter/classes/fairmatic_error_code.dart';
import 'package:fairmatic_sdk_flutter/classes/fairmatic_trip_notification.dart';
import 'package:fairmatic_sdk_flutter/fairmatic_method_channel.dart';
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
  String _driveStatus = 'No active drive';
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isDriveActive = false;

  final MethodChannel _methodChannel = const MethodChannel('fairmatic');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fairmatic SDK Example')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 10),
                    Text(
                      'Drive Status: $_driveStatus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isDriveActive ? Colors.blue : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: getFairmaticVersion,
                      child: const Text('Refresh Version'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isInitialized ? null : initializeFairmaticSDK,
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
                    const SizedBox(height: 16),
                    Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Drive Operations:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          _isInitialized && !_isDriveActive
                              ? startDriveWithPeriod1
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (!_isInitialized || _isDriveActive)
                                ? Colors.grey
                                : Colors.green,
                      ),
                      child: const Text('Start Drive (Period 1)'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed:
                          _isInitialized && _isDriveActive ? stopPeriod : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (!_isInitialized || !_isDriveActive)
                                ? Colors.grey
                                : Colors.red,
                      ),
                      child: const Text('Stop Period'),
                    ),
                  ],
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

      print(configuration.toMap());

      // Initialize the SDK
      await Fairmatic.setup(configuration, tripNotification);

      // If we get here, the setup was successful
      setState(() {
        _sdkStatus = 'Initialized successfully';
        _isInitialized = true;
        _isLoading = false;
      });
      _showSnackBar('Fairmatic SDK initialized successfully');
    } on FairmaticException catch (e) {
      // Now you have a strongly-typed error with enum code
      setState(() {
        _sdkStatus = 'Initialization error: ${e.message} (code: ${e.code})';
        _isInitialized = false;
        _isLoading = false;
      });
      _showSnackBar('Initialization error: ${e.message}');

      // You can also switch on the error code for specific handling
      switch (e.code) {
        case FairmaticErrorCode.networkNotAvailable:
          // Special handling for network errors
          _showSnackBar('Please check your internet connection');
          break;
        case FairmaticErrorCode.invalidDriverId:
          // Special handling for invalid driver ID
          break;
        // Handle other specific cases
        default:
        // Default error handling
      }
    } catch (e) {
      // Other unexpected errors
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

  Future<void> startDriveWithPeriod1() async {
    setState(() {
      _isLoading = true;
      _driveStatus = 'Starting drive...';
    });

    try {
      // Generate a unique tracking ID
      final trackingId = 'trip_${DateTime.now().millisecondsSinceEpoch}';

      // Start drive with period 1
      await Fairmatic.startDriveWithPeriod1(trackingId);

      // If we get here, the start was successful
      setState(() {
        _driveStatus = 'Drive active (Period 1)';
        _isDriveActive = true;
        _isLoading = false;
      });
      _showSnackBar('Drive started successfully');
    } on PlatformException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      String errorCode = 'UNKNOWN';
      String errorType = 'UNKNOWN';

      if (e.details is Map<dynamic, dynamic>) {
        final details = e.details as Map<dynamic, dynamic>;
        errorCode = details['errorCode'] as String? ?? errorCode;
        errorType = details['errorType'] as String? ?? errorType;
      }

      setState(() {
        _driveStatus = 'Failed to start drive: $errorMessage';
        _isDriveActive = false;
        _isLoading = false;
      });
      _showSnackBar('Error starting drive: $errorMessage');
    } catch (e) {
      setState(() {
        _driveStatus = 'Failed to start drive: $e';
        _isDriveActive = false;
        _isLoading = false;
      });
      _showSnackBar('Error starting drive: $e');
    }
  }

  Future<void> stopPeriod() async {
    setState(() {
      _isLoading = true;
      _driveStatus = 'Stopping period...';
    });

    try {
      // Stop the period
      await Fairmatic.stopPeriod();

      // If we get here, the stop was successful
      setState(() {
        _driveStatus = 'No active drive';
        _isDriveActive = false;
        _isLoading = false;
      });
      _showSnackBar('Period stopped successfully');
    } on PlatformException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      String errorCode = 'UNKNOWN';
      String errorType = 'UNKNOWN';

      if (e.details is Map<dynamic, dynamic>) {
        final details = e.details as Map<dynamic, dynamic>;
        errorCode = details['errorCode'] as String? ?? errorCode;
        errorType = details['errorType'] as String? ?? errorType;
      }

      setState(() {
        _driveStatus = 'Failed to stop period: $errorMessage';
        _isLoading = false;
      });
      _showSnackBar('Error stopping period: $errorMessage');
    } catch (e) {
      setState(() {
        _driveStatus = 'Failed to stop period: $e';
        _isLoading = false;
      });
      _showSnackBar('Error stopping period: $e');
    }
  }

  /*
  void _setupMethodChannelHandler() {
    _methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'onOperationCompleted') {
        final arguments = call.arguments as Map<dynamic, dynamic>;
        final success = arguments['success'] as bool;
        final operation = arguments['operation'] as String?;

        print("Operation completed: $operation, success: $success");

        if (success) {
          switch (operation) {
            case 'setup':
              setState(() {
                _sdkStatus = 'Initialized successfully';
                _isInitialized = true;
                _isLoading = false;
              });
              _showSnackBar('Fairmatic SDK initialized successfully');
              break;

            case 'startDriveWithPeriod1':
              setState(() {
                _driveStatus = 'Drive active (Period 1)';
                _isDriveActive = true;
                _isLoading = false;
              });
              _showSnackBar('Drive started successfully');
              break;

            case 'stopPeriod':
              setState(() {
                _driveStatus = 'No active drive';
                _isDriveActive = false;
                _isLoading = false;
              });
              _showSnackBar('Period stopped successfully');
              break;

            default:
              setState(() {
                _isLoading = false;
              });
              if (operation != null) {
                _showSnackBar('$operation completed successfully');
              }
          }
        } else {
          final errorMessage = arguments['errorMessage'] as String?;

          switch (operation) {
            case 'setup':
              setState(() {
                _sdkStatus = 'Initialization error: $errorMessage';
                _isInitialized = false;
                _isLoading = false;
              });
              _showSnackBar('Initialization error: $errorMessage');
              break;

            case 'startDriveWithPeriod1':
              setState(() {
                _driveStatus = 'Failed to start drive: $errorMessage';
                _isDriveActive = false;
                _isLoading = false;
              });
              _showSnackBar('Failed to start drive: $errorMessage');
              break;

            case 'stopPeriod':
              setState(() {
                _driveStatus = 'Failed to stop period: $errorMessage';
                _isLoading = false;
              });
              _showSnackBar('Failed to stop period: $errorMessage');
              break;

            default:
              setState(() {
                _isLoading = false;
              });
              if (operation != null) {
                _showSnackBar('$operation failed: $errorMessage');
              }
          }
        }
      }
      return null;
    });
  }*/

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

// // Concrete implementation of FairmaticOperationCallback
// class SimpleOperationCallback implements FairmaticOperationCallback {
//   final Function(FairmaticOperationResult) onCompletionHandler;

//   SimpleOperationCallback({required this.onCompletionHandler});

//   @override
//   void onCompletion(FairmaticOperationResult result) {
//     onCompletionHandler(result);
//   }
// }
