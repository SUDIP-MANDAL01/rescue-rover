import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alert_provider.dart';
import '../../models/alert_model.dart';

class AlertManagementScreen extends ConsumerStatefulWidget {
  const AlertManagementScreen({super.key});

  @override
  ConsumerState<AlertManagementScreen> createState() => _AlertManagementScreenState();
}

class _AlertManagementScreenState extends ConsumerState<AlertManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertProvider);

    // Watch for new SOS alerts to show popup
    ref.listen<AsyncValue<List<Alert>>>(alertProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        final activeSOS = next.value!.where((a) => a.type == 'SOS' && a.status == 'Active').toList();
        // Just an example trigger, you would want to check if it was already shown
        if (activeSOS.isNotEmpty) {
           // SOSDialog.show(context, activeSOS.first, ref);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Alerts'),
            Tab(text: 'Previous Alerts'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: alertState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (alerts) {
          final activeAlerts = alerts.where((a) => a.status == 'Active').toList();
          final previousAlerts = alerts.where((a) => a.status == 'Acknowledged').toList();
          final historyAlerts = alerts.where((a) => a.status == 'Resolved').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAlertList(activeAlerts),
              _buildAlertList(previousAlerts),
              _buildAlertList(historyAlerts),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertList(List<Alert> alerts) {
    if (alerts.isEmpty) {
      return const Center(child: Text('No alerts found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              alert.type == 'SOS' ? Icons.warning : Icons.info,
              color: alert.type == 'SOS' ? Colors.red : Colors.blue,
            ),
            title: Text(alert.message),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Time: ${DateTime.parse(alert.time).toLocal().toString()}'),
                Text('Location: ${alert.location ?? "Unavailable"}'),
                Text('Status: ${alert.status}', style: TextStyle(color: Colors.grey[400])),
              ],
            ),
            isThreeLine: true,
            trailing: alert.status == 'Active' ? IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () {
                ref.read(alertProvider.notifier).updateAlertStatus(alert.id, 'acknowledge');
              },
            ) : null,
          ),
        );
      },
    );
  }
}
