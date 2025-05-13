/// Flutter representation of the native FairmaticTripNotification class
class FairmaticTripNotification {
  final String title;
  final String content;
  final int iconId;

  // Optional properties that have default values in the native code
  String channelId;
  String channelName;
  String channelDescription;
  int notificationId;

  // Content intent can't be directly passed from Flutter to native,
  // so we'll typically set this on the native side

  /// Creates a new FairmaticTripNotification object
  FairmaticTripNotification({
    required this.title,
    required this.content,
    required this.iconId,
    this.channelId = "fairmatic_sdk_notification_channel",
    this.channelName = "Fairmatic SDK Notifications",
    this.channelDescription = "Fairmatic SDK notifications Channel",
    this.notificationId = 75100,
  });

  /// Creates a FairmaticTripNotification from a map
  /// Useful when receiving data from the native side
  factory FairmaticTripNotification.fromMap(Map<String, dynamic> map) {
    return FairmaticTripNotification(
      title: map['title'] as String,
      content: map['content'] as String,
      iconId: map['iconId'] as int,
      channelId:
          map['channelId'] as String? ?? "fairmatic_sdk_notification_channel",
      channelName:
          map['channelName'] as String? ?? "Fairmatic SDK Notifications",
      channelDescription:
          map['channelDescription'] as String? ??
          "Fairmatic SDK notifications Channel",
      notificationId: map['notificationId'] as int? ?? 75100,
    );
  }

  /// Converts this object to a map for serialization across the platform channel
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'iconId': iconId,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'notificationId': notificationId,
    };
  }
}
