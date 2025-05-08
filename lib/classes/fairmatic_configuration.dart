import 'fairmatic_driver_attributes.dart';

class FairmaticConfiguration {
  String sdkKey;
  String driverId;
  FairmaticDriverAttributes driverAttributes;

  FairmaticConfiguration({
    required this.sdkKey,
    required this.driverId,
    required this.driverAttributes,
  });

  Map<String, dynamic> toMap() {
    return {
      'sdkKey': sdkKey,
      'driverId': driverId,
      'driverAttributes': driverAttributes.toMap(),
    };
  }
}
