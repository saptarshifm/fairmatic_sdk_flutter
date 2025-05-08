import 'fairmatic_operation_result.dart';

abstract class FairmaticOperationCallback {
  void onCompletion(FairmaticOperationResult result);
}
