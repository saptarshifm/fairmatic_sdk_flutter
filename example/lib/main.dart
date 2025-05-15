import 'dart:async';

import 'package:fairmatic_sdk_flutter/fairmatic_sdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _fairmaticVersion = 'Unknown';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Fairmatic SDK Example')),
        body: Center(
          child:
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
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
                      ElevatedButton(
                        onPressed: getFairmaticVersion,
                        child: const Text('Refresh Version'),
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

  @override
  void initState() {
    super.initState();
    getFairmaticVersion();
  }
}
