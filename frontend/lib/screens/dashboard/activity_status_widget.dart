import 'package:flutter/material.dart';

class ActivityStatusWidget extends StatelessWidget {
  final String activity;

  const ActivityStatusWidget({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (activity.toLowerCase()) {
      case 'patrolling':
        iconData = Icons.security;
        iconColor = Colors.blue;
        break;
      case 'mapping':
        iconData = Icons.map;
        iconColor = Colors.purple;
        break;
      case 'rescue mode':
        iconData = Icons.health_and_safety;
        iconColor = Colors.red;
        break;
      case 'idle':
      default:
        iconData = Icons.pause_circle_filled;
        iconColor = Colors.grey;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: iconColor),
        const SizedBox(width: 8),
        Text(
          activity,
          style: TextStyle(color: iconColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
