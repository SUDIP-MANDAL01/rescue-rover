import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alert_provider.dart';
import '../../models/alert_model.dart';
import '../../core/theme.dart';

class AlertManagementScreen extends ConsumerStatefulWidget {
  const AlertManagementScreen({super.key});

  @override
  ConsumerState<AlertManagementScreen> createState() =>
      _AlertManagementScreenState();
}

class _AlertManagementScreenState extends ConsumerState<AlertManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(alertProvider.notifier).fetchAlerts());
  }

  @override
  Widget build(BuildContext context) {
    final alertAsync = ref.watch(alertProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), AppTheme.primaryDark],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alerts',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'SOS & Notification History',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: const Icon(Icons.notifications_active,
                        color: AppTheme.accentOrange, size: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Alert List — handle AsyncValue
            Expanded(
              child: alertAsync.when(
                loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.accentBlue),
                ),
                error: (e, _) => Center(
                  child: Text('Error loading alerts',
                      style: TextStyle(color: AppTheme.accentRed)),
                ),
                data: (alerts) {
                  if (alerts.isEmpty) return _EmptyState();
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.read(alertProvider.notifier).fetchAlerts(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return _AlertCard(
                          alert: alert,
                          onAcknowledge: () => ref
                              .read(alertProvider.notifier)
                              .updateAlertStatus(alert.id, 'acknowledge'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                color: AppTheme.accentGreen, size: 56),
          ),
          const SizedBox(height: 20),
          const Text(
            'All Clear!',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'No alerts at the moment',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onAcknowledge;

  const _AlertCard({required this.alert, required this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    final isSOS = alert.type == 'SOS';
    final isNew = alert.status == 'New';
    final color = isSOS ? AppTheme.accentRed : AppTheme.accentOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew ? color.withValues(alpha: 0.5) : AppTheme.dividerColor,
          width: isNew ? 1.5 : 1,
        ),
        boxShadow: isNew
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                    isSOS ? Icons.sos : Icons.warning_amber,
                    color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.type,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: color)),
                    const SizedBox(height: 2),
                    Text(alert.message,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(alert.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  alert.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(alert.status),
                  ),
                ),
              ),
            ],
          ),
          if (isNew) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton.icon(
                onPressed: onAcknowledge,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Acknowledge',
                    style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentGreen,
                  side: const BorderSide(color: AppTheme.accentGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'New':
        return AppTheme.accentRed;
      case 'Acknowledged':
        return AppTheme.accentOrange;
      case 'Resolved':
        return AppTheme.accentGreen;
      default:
        return AppTheme.textSecondary;
    }
  }
}
