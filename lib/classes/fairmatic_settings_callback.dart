import 'package:fairmatic_sdk_flutter/classes/fairmatic_setting_error.dart';

abstract class FairmaticSettingsCallback {
  void onComplete(List<FairmaticSettingError>? errors);
}
