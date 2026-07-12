class Rover {
  final int id;
  final String roverKey;
  final String status;
  final int battery;
  final String activity;
  final String? lastSeen;

  Rover({
    required this.id,
    required this.roverKey,
    required this.status,
    required this.battery,
    required this.activity,
    this.lastSeen,
  });

  factory Rover.fromJson(Map<String, dynamic> json) {
    return Rover(
      id: json['id'],
      roverKey: json['rover_key'],
      status: json['status'],
      battery: json['battery'],
      activity: json['activity'],
      lastSeen: json['last_seen'],
    );
  }
}
