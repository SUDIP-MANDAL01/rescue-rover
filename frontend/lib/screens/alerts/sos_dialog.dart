import 'package:flutter/material.dart';
import '../../models/alert_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alert_provider.dart';

class SOSDialog extends StatelessWidget {
  final Alert alert;
  final WidgetRef ref;

  const SOSDialog({super.key, required this.alert, required this.ref});

  static void show(BuildContext context, Alert alert, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SOSDialog(alert: alert, ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
          SizedBox(width: 12),
          Text('SOS ALERT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Message: ${alert.message}'),
          const SizedBox(height: 8),
          Text('Time: ${DateTime.parse(alert.time).toLocal().toString()}'),
          const SizedBox(height: 8),
          Text('Location: ${alert.location ?? "Unavailable"}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(alertProvider.notifier).updateAlertStatus(alert.id, 'mute');
            Navigator.of(context).pop();
          },
          child: const Text('Mute Alarm', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            ref.read(alertProvider.notifier).updateAlertStatus(alert.id, 'acknowledge');
            Navigator.of(context).pop();
          },
          child: const Text('Acknowledge'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            ref.read(alertProvider.notifier).updateAlertStatus(alert.id, 'resolve');
            Navigator.of(context).pop();
          },
          child: const Text('Mark Resolved', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
