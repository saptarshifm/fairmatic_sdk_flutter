import 'package:fairmatic_sdk_flutter/classes/fairmatic_operation_result.dart';

abstract class FairmaticOperationCallback {
  void onCompletion(FairmaticOperationResult result);
}
