import 'package:fairmatic_sdk_flutter/classes/fairmatic_error_code.dart';

class Failure extends FairmaticOperationResult {
  final FairmaticErrorCode error;
  final String errorMessage;

  Failure(this.error, this.errorMessage);
}

abstract class FairmaticOperationResult {
  static FairmaticOperationResult fromMap(Map<String, dynamic> arguments) {
    if (arguments['error'] == null) {
      return Success();
    } else {
      return Failure(
        FairmaticErrorCode.values[arguments['error']],
        arguments['errorMessage'],
      );
    }
  }
}

class Success extends FairmaticOperationResult {}
