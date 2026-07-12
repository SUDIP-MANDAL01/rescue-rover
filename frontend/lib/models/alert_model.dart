class Alert {
  final int id;
  final int roverId;
  final String type;
  final String message;
  final String status;
  final String time;
  final String? location;

  Alert({
    required this.id,
    required this.roverId,
    required this.type,
    required this.message,
    required this.status,
    required this.time,
    this.location,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      roverId: json['rover_id'],
      type: json['type'],
      message: json['message'],
      status: json['status'],
      time: json['time'],
      location: json['location'],
    );
  }
}
