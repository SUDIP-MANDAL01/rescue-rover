import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/rover_provider.dart';
import '../../providers/auth_provider.dart';
import 'activity_status_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final roverState = ref.watch(roverProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(roverProvider.notifier).fetchRoverStatus();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hello ${authState.user?.name ?? "User"}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            roverState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Error loading rover data: $err'),
                    ],
                  ),
                ),
              ),
              data: (rover) {
                if (rover == null) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No Rover Connected'),
                    ),
                  );
                }
                
                final isOnline = rover.status.toLowerCase() == 'online';
                final statusColor = isOnline ? Colors.green : Colors.red;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Connected Rover',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 4, backgroundColor: statusColor),
                                  const SizedBox(width: 8),
                                  Text(rover.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Battery Level'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: rover.battery / 100,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey[800],
                                  color: rover.battery > 20 ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text('${rover.battery}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Current Activity'),
                        const SizedBox(height: 8),
                        ActivityStatusWidget(activity: rover.activity),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Last Seen: ${rover.lastSeen != null ? DateTime.parse(rover.lastSeen!).toLocal().toString() : "Unknown"}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
